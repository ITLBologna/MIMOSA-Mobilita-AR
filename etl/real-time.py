 #
 # Copyright 2022-2023 bitApp S.r.l.
 #
 # This program is free software: you can redistribute it and/or modify
 # it under the terms of the GNU General Public License as published by
 # the Free Software Foundation, either version 3 of the License, or
 # (at your option) any later version.
 #
 # This program is distributed in the hope that it will be useful,
 # but WITHOUT ANY WARRANTY; without even the implied warranty of
 # MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 # GNU General Public License for more details.
 #
 # You should have received a copy of the GNU General Public License
 # along with this program.  If not, see <http://www.gnu.org/licenses/>.
 #
 # Mimosa ETL
 #
 #
 # Contact: info@bitapp.it
 #

from protobuf_to_dict import protobuf_to_dict
from protobuf_to_dict import dict_to_protobuf
from dotenv.main import load_dotenv
import pandas as pd
import requests
import os
from google.transit import gtfs_realtime_pb2
import time
from datetime import (datetime, timedelta)
import threading
import signal

### paths
load_dotenv()
outputPath = os.environ['LOCAL_PATH_OUTPUT_DATASET']
gtfsrtOutputPath = os.environ['GTFSRT_OUTPUT_PATH']

files = {
    'AGENCY_ID': {
        'tripUpdates': 'tripUpdates_URL',
        'vehiclePositions': 'vehiclePositions_URL',
        'delay': 30,
    },
}

class Vehicles (threading.Thread):
    mustStop = False
    agencyId = None

    def __init__(self, agencyId):
        threading.Thread.__init__(self)
        self.agencyId = agencyId

    def stop (self):
        self.mustStop = True

    def run (self):
        agencyCalendarDates = pd.read_csv(outputPath + '/' + self.agencyId + '/calendar_dates.txt')
        agencyTrips = pd.read_csv(outputPath + '/' + self.agencyId + '/trips.txt')
        agencyStopTimes = pd.read_csv(outputPath + '/' + self.agencyId + '/stop_times.txt', low_memory=False)
        agencyStopTimes = agencyStopTimes[agencyStopTimes.stop_sequence == 1]

        # Vehicles
        feed = gtfs_realtime_pb2.FeedMessage()

        lastFeedTime = 0

        cachedTrips = {}
        cacheCounter = 0

        while True:
            retrySameFeed = 1

            if cacheCounter > 2880:
                cachedTrips = {}
                cacheCounter = 0
            else:
                cacheCounter = cacheCounter + 1

            while True:
                if self.mustStop:
                    print(self.agencyId, 'vehicles', 'Terminating')
                    exit()

                start = time.time()

                try:
                    f = requests.get(files[self.agencyId]['vehiclePositions'])
                    feed.ParseFromString(f.content)

                    feedData = protobuf_to_dict(feed)

                    if (lastFeedTime == feedData['header']['timestamp']):
                        print(self.agencyId, 'vehicles', 'Same feed, retry in', retrySameFeed)
                        time.sleep(retrySameFeed)
                        if retrySameFeed < files[self.agencyId]['delay']:
                            retrySameFeed = retrySameFeed + 1
                    else:
                        break
                except:
                    print(self.agencyId, 'vehicles', 'Exception reading feed, retry in', retrySameFeed)
                    time.sleep(retrySameFeed)
                    if retrySameFeed < files[self.agencyId]['delay']:
                        retrySameFeed = retrySameFeed + 1
            
            lastFeedTime = feedData['header']['timestamp']

            feedTime = datetime.fromtimestamp(feedData['header']['timestamp'])
            print(self.agencyId, 'vehicles', 'Feed', feedTime)

            if "entity" not in feedData:
                print(self.agencyId, 'vehicles', 'no entity found')
            else:
                for entity in feedData['entity']:
                    if 'route_id' in entity['vehicle']['trip']:
                        entity['vehicle']['trip']['route_id'] = self.agencyId + '_' + entity['vehicle']['trip']['route_id']
                    elif 'trip_id' in entity['vehicle']['trip']:
                        entity['vehicle']['trip']['trip_id'] = self.agencyId + '_' + entity['vehicle']['trip']['trip_id']
                        filteredRouteTrips = agencyTrips[agencyTrips.trip_id == entity['vehicle']['trip']['trip_id']]
                        if filteredRouteTrips.empty:
                            print(self.agencyId, 'vehicles', 'given trip not found')
                            print(entity['vehicle']['trip'])
                            continue
                        entity['vehicle']['trip']['route_id'] = filteredRouteTrips.iloc[0]['route_id']
                        continue
                    else:
                        print(self.agencyId, 'vehicles', 'no route_id or trip_id found')
                        print(entity['vehicle']['trip'])
                        continue


                    if 'stop_id' in entity['vehicle']:
                        entity['vehicle']['stop_id'] = self.agencyId + '_' + entity['vehicle']['stop_id']

                    if 'trip_id' not in entity['vehicle']['trip']:
                        if entity['vehicle']['trip']['route_id'] + '_' + entity['vehicle']['trip']['start_date'] + entity['vehicle']['trip']['start_time'] + '_' + str(entity['vehicle']['trip']['direction_id']) in cachedTrips:
                            entity['vehicle']['trip']['trip_id'] = cachedTrips[entity['vehicle']['trip']['route_id'] + '_' + entity['vehicle']['trip']['start_date'] + entity['vehicle']['trip']['start_time'] + '_' + str(entity['vehicle']['trip']['direction_id'])]
                            continue

                        filteredCalendarDates = agencyCalendarDates[agencyCalendarDates.date == int(entity['vehicle']['trip']['start_date'])]

                        if filteredCalendarDates.empty:
                            print(self.agencyId, 'vehicles', 'no calendar dates found')
                            print(entity['vehicle']['trip'])
                            continue

                        jCalendarDatesTrips = filteredCalendarDates.join(agencyTrips.set_index('service_id'), on='service_id', how='left')

                        filteredTrips = jCalendarDatesTrips[
                            (jCalendarDatesTrips.route_id == (entity['vehicle']['trip']['route_id'])) & 
                            (jCalendarDatesTrips.direction_id == int(entity['vehicle']['trip']['direction_id']))
                        ]

                        if filteredTrips.empty:
                            print(self.agencyId, 'vehicles', 'no trips found')
                            print(entity['vehicle']['trip'])
                            continue

                        jTripsStopTimes = filteredTrips.join(agencyStopTimes.set_index('trip_id'), on='trip_id', how='left')

                        gtfsTime = entity['vehicle']['trip']['start_time']

                        if (datetime.now() - timedelta(hours= 12)).strftime('%Y%m%d') == entity['vehicle']['trip']['start_date']:
                            gtfsSplitTime = entity['vehicle']['trip']['start_time'].split(':')

                            if int(gtfsSplitTime[0]) < 12:
                                gtfsTime = str(int(gtfsSplitTime[0]) + 24) + ':' + gtfsSplitTime[1] + ':' + gtfsSplitTime[2]

                        filteredStopTimes = jTripsStopTimes[jTripsStopTimes.departure_time == gtfsTime]

                        if filteredStopTimes.empty:
                            print(self.agencyId, 'vehicles', 'no first stops found')
                            continue

                        entity['vehicle']['trip']['trip_id'] = filteredStopTimes.iloc[0]['trip_id']

                        cachedTrips[entity['vehicle']['trip']['route_id'] + '_' + entity['vehicle']['trip']['start_date'] + entity['vehicle']['trip']['start_time'] + '_' + str(entity['vehicle']['trip']['direction_id'])] = filteredStopTimes.iloc[0]['trip_id']
                    else:
                        entity['vehicle']['trip']['trip_id'] = self.agencyId + '_' + entity['vehicle']['trip']['trip_id']

            newFeed = dict_to_protobuf(gtfs_realtime_pb2.FeedMessage, feedData)

            if not os.path.exists(gtfsrtOutputPath + '/' + self.agencyId):
                os.makedirs(gtfsrtOutputPath + '/' + self.agencyId)

            with open(gtfsrtOutputPath + '/' + self.agencyId + '/vehicle_positions.pb', 'wb') as f:
                f.write(newFeed.SerializeToString())
            
            end = time.time()
            print(self.agencyId, 'vehicles', 'Done in', end - start)

            now = datetime.now()
            delay = abs((now - feedTime).seconds)
            sleepTime = files[self.agencyId]['delay'] - delay

            if sleepTime < 0:
                sleepTime = 0

            print(self.agencyId, 'vehicles', 'Delay', delay)
            print(self.agencyId, 'vehicles', 'Sleeping', sleepTime)
            time.sleep(sleepTime)

class Trips (threading.Thread):
    mustStop = False
    agencyId = None

    def __init__(self, agencyId):
        threading.Thread.__init__(self)
        self.agencyId = agencyId

    def stop (self):
        self.mustStop = True

    def run (self):
        agencyCalendarDates = pd.read_csv(outputPath + '/' + self.agencyId + '/calendar_dates.txt')
        agencyTrips = pd.read_csv(outputPath + '/' + self.agencyId + '/trips.txt')
        agencyStopTimes = pd.read_csv(outputPath + '/' + self.agencyId + '/stop_times.txt', low_memory=False)
        agencyFirstStopTimes = agencyStopTimes[agencyStopTimes.stop_sequence == 1]

        # Trips
        feed = gtfs_realtime_pb2.FeedMessage()

        lastFeedTime = 0

        cachedTrips = {}
        cacheCounter = 0

        while True:
            retrySameFeed = 1

            if cacheCounter > 2880:
                cachedTrips = {}
                cacheCounter = 0
            else:
                cacheCounter = cacheCounter + 1

            while True:
                if self.mustStop:
                    print(self.agencyId, 'trips', 'Terminating')
                    exit()

                start = time.time()

                try:
                    f = requests.get(files[self.agencyId]['tripUpdates'])
                    feed.ParseFromString(f.content)

                    feedData = protobuf_to_dict(feed)

                    if (lastFeedTime == feedData['header']['timestamp']):
                        print(self.agencyId, 'trips', 'Same feed, retry in', retrySameFeed)
                        time.sleep(retrySameFeed)
                        if retrySameFeed < files[self.agencyId]['delay']:
                            retrySameFeed = retrySameFeed + 1
                    else:
                        break
                except:
                    print(self.agencyId, 'trips', 'Exception reading feed, retry in', retrySameFeed)
                    time.sleep(retrySameFeed)
                    if retrySameFeed < files[self.agencyId]['delay']:
                        retrySameFeed = retrySameFeed + 1
            
            lastFeedTime = feedData['header']['timestamp']

            feedTime = datetime.fromtimestamp(feedData['header']['timestamp'])
            print(self.agencyId, 'trips', 'Feed', feedTime)

            if "entity" not in feedData:
                print(self.agencyId, 'trips', 'no entity found')
            else:
                for entity in feedData['entity']:
                    entity['trip_update']['trip']['route_id'] = self.agencyId + '_' + entity['trip_update']['trip']['route_id']

                    findStopIds = False
                    convertToTimestamp = False
                            
                    for stopTimeUpdate in entity['trip_update']['stop_time_update']:
                        if 'stop_id' in stopTimeUpdate:
                            stopTimeUpdate['stop_id'] = self.agencyId + '_' + stopTimeUpdate['stop_id']
                        else:
                            findStopIds = True

                        if ('arrival' in stopTimeUpdate and 'time' not in stopTimeUpdate['arrival']) and ('departure' in stopTimeUpdate and 'time' not in stopTimeUpdate['departure']):
                            convertToTimestamp = True

                    if 'trip_id' in entity['trip_update']['trip']:
                        entity['trip_update']['trip']['trip_id'] = self.agencyId + '_' + entity['trip_update']['trip']['trip_id']

                    if 'trip_id' not in entity['trip_update']['trip']:
                        if 'stop_id' in entity['trip_update']['stop_time_update'][len(entity['trip_update']['stop_time_update']) - 1]:
                            lastStopSequence = None
                            lastStopId = entity['trip_update']['stop_time_update'][len(entity['trip_update']['stop_time_update']) - 1]['stop_id']
                        if 'stop_sequence' in entity['trip_update']['stop_time_update'][len(entity['trip_update']['stop_time_update']) - 1]:
                            lastStopId = None
                            lastStopSequence = entity['trip_update']['stop_time_update'][len(entity['trip_update']['stop_time_update']) - 1]['stop_sequence']

                        if entity['trip_update']['trip']['route_id'] + '_' + entity['trip_update']['trip']['start_date'] + entity['trip_update']['trip']['start_time'] + '_' + str(entity['trip_update']['trip']['direction_id']) + '_' + str(lastStopId or lastStopSequence) in cachedTrips:
                            entity['trip_update']['trip']['trip_id'] = cachedTrips[entity['trip_update']['trip']['route_id'] + '_' + entity['trip_update']['trip']['start_date'] + entity['trip_update']['trip']['start_time'] + '_' + str(entity['trip_update']['trip']['direction_id']) + '_' + str(lastStopId or lastStopSequence)]

                    if 'trip_id' not in entity['trip_update']['trip']:
                        filteredCalendarDates = agencyCalendarDates[agencyCalendarDates.date == int(entity['trip_update']['trip']['start_date'])]

                        if filteredCalendarDates.empty:
                            print(self.agencyId, 'trips', 'no calendar dates found')
                            print(entity['trip_update']['trip'])
                            continue

                        jCalendarDatesTrips = filteredCalendarDates.join(agencyTrips.set_index('service_id'), on='service_id', how='left')

                        filteredTrips = jCalendarDatesTrips[
                            (jCalendarDatesTrips.route_id == (entity['trip_update']['trip']['route_id'])) & 
                            (jCalendarDatesTrips.direction_id == int(entity['trip_update']['trip']['direction_id']))
                        ]

                        if filteredTrips.empty:
                            print(self.agencyId, 'trips', 'no trips found')
                            print(entity['trip_update']['trip'])
                            continue

                        jTripsStopTimes = filteredTrips.join(agencyFirstStopTimes.set_index('trip_id'), on='trip_id', how='left')

                        gtfsTime = entity['trip_update']['trip']['start_time']

                        if (datetime.now() - timedelta(hours= 12)).strftime('%Y%m%d') == entity['trip_update']['trip']['start_date']:
                            gtfsSplitTime = entity['trip_update']['trip']['start_time'].split(':')

                            if int(gtfsSplitTime[0]) < 12:
                                gtfsTime = str(int(gtfsSplitTime[0]) + 24) + ':' + gtfsSplitTime[1] + ':' + gtfsSplitTime[2]

                        filteredStopTimes = jTripsStopTimes[jTripsStopTimes.departure_time == gtfsTime]

                        if filteredStopTimes.empty:
                            print(self.agencyId, 'trips', 'no first stops found')
                            print(entity['trip_update']['trip'])
                            continue

                        tripId = filteredStopTimes.iloc[0]['trip_id']

                        if len(filteredStopTimes) > 1:
                            print(self.agencyId, 'trips', 'found multiple trips, filtering')
                            print(entity['trip_update']['trip'])
                            for filteredStopTime in filteredStopTimes.iloc:
                                sortedTripStops = agencyStopTimes[agencyStopTimes.trip_id == filteredStopTime['trip_id']].sort_values(by='stop_sequence', ascending=False)
                                tripLastStopId = sortedTripStops['stop_id'].values[0]
                                tripLastStopSequence = sortedTripStops['stop_sequence'].values[0]

                                if lastStopId != None and tripLastStopId == lastStopId:
                                    tripId = filteredStopTime['trip_id']
                                    print(self.agencyId, 'trips', 'selected filtered trip by last stop id', tripId)
                                    break
                                elif lastStopSequence != None and str(tripLastStopSequence) == str(lastStopSequence):
                                    tripId = filteredStopTime['trip_id']
                                    print(self.agencyId, 'trips', 'selected filtered trip by last stop sequence', tripId)
                                    break

                        entity['trip_update']['trip']['trip_id'] = tripId

                        cachedTrips[entity['trip_update']['trip']['route_id'] + '_' + entity['trip_update']['trip']['start_date'] + entity['trip_update']['trip']['start_time'] + '_' + str(entity['trip_update']['trip']['direction_id']) + '_' + str(lastStopId or lastStopSequence)] = tripId

                    if findStopIds or convertToTimestamp:
                        filteredTripStops = agencyStopTimes[agencyStopTimes.trip_id == entity['trip_update']['trip']['trip_id']]

                        for stopTimeUpdate in entity['trip_update']['stop_time_update']:
                            if 'stop_id' not in stopTimeUpdate:
                                staticStopTime = filteredTripStops[filteredTripStops.stop_sequence == stopTimeUpdate['stop_sequence']]

                                if staticStopTime.empty:
                                    print(self.agencyId, 'trips', 'no static stop time found')
                                    print(entity['trip_update']['trip'])
                                    continue

                                stopTimeUpdate['stop_id'] = staticStopTime.iloc[0]['stop_id']
                            else:
                                staticStopTime = filteredTripStops[filteredTripStops.stop_id == stopTimeUpdate['stop_id']]
                                
                                if staticStopTime.empty:
                                    print(self.agencyId, 'trips', 'no static stop time found')
                                    print(entity['trip_update']['trip'])
                                    continue
                            
                            if 'arrival' in stopTimeUpdate and 'time' not in stopTimeUpdate['arrival'] and 'delay' in stopTimeUpdate['arrival']:
                                startDate = datetime.strptime(entity['trip_update']['trip']['start_date'], '%Y%m%d')
                                splittedTime = staticStopTime.iloc[0]['arrival_time'].split(':')
                                timeDuration = timedelta(hours=int(splittedTime[0]), minutes=int(splittedTime[1]), seconds=int(splittedTime[2]))

                                dateTime = startDate + timeDuration + timedelta(seconds=stopTimeUpdate['arrival']['delay'])

                                stopTimeUpdate['arrival']['time'] = int(dateTime.timestamp())

                            if 'departure' in stopTimeUpdate and 'time' not in stopTimeUpdate['departure'] and 'delay' in stopTimeUpdate['departure']:
                                startDate = datetime.strptime(entity['trip_update']['trip']['start_date'], '%Y%m%d')
                                splittedTime = staticStopTime.iloc[0]['departure_time'].split(':')
                                timeDuration = timedelta(hours=int(splittedTime[0]), minutes=int(splittedTime[1]), seconds=int(splittedTime[2]))

                                dateTime = startDate + timeDuration + timedelta(seconds=stopTimeUpdate['departure']['delay'])

                                stopTimeUpdate['departure']['time'] = int(dateTime.timestamp())

            newFeed = dict_to_protobuf(gtfs_realtime_pb2.FeedMessage, feedData)

            if not os.path.exists(gtfsrtOutputPath + '/' + self.agencyId):
                os.makedirs(gtfsrtOutputPath + '/' + self.agencyId)

            with open(gtfsrtOutputPath + '/' + self.agencyId + '/trip_updates.pb', 'wb') as f:
                f.write(newFeed.SerializeToString())
            
            end = time.time()
            print(self.agencyId, 'trips', 'Done in', end - start)

            now = datetime.now()
            delay = abs((now - feedTime).seconds)
            sleepTime = files[self.agencyId]['delay'] - delay

            if sleepTime < 0:
                sleepTime = 0

            print(self.agencyId, 'trips', 'Delay', delay)
            print(self.agencyId, 'trips', 'Sleeping', sleepTime)
            time.sleep(sleepTime)

threads = {}

for agencyId in files:
    if 'vehiclePositions' in files[agencyId] and files[agencyId]['vehiclePositions'] != '':
        threads[agencyId + '_vehicles'] = Vehicles(agencyId)
        threads[agencyId + '_vehicles'].start()
    if 'tripUpdates' in files[agencyId] and files[agencyId]['tripUpdates'] != '':
        threads[agencyId + '_trips'] = Trips(agencyId)
        threads[agencyId + '_trips'].start()

run = True

def handler_stop_signals(signum, frame):
    global run
    run = False

signal.signal(signal.SIGINT, handler_stop_signals)
signal.signal(signal.SIGTERM, handler_stop_signals)

try:
    while run:
        time.sleep(2)
    
    for threadKey in threads:
        threads[threadKey].stop()
    
    for threadKey in threads:
        threads[threadKey].join()
except KeyboardInterrupt:
    for threadKey in threads:
        threads[threadKey].stop()
    
    for threadKey in threads:
        threads[threadKey].join()
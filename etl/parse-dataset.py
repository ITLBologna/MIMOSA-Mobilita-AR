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

import pandas as pd
import csv
from dotenv.main import load_dotenv
import os
from zipfile import ZipFile

## Path to save results
load_dotenv()
local_path_dataset = os.environ['LOCAL_PATH_DATASET']
local_path_output_dataset = os.environ['LOCAL_PATH_OUTPUT_DATASET']

agencies = {
    'AGENCY_ID': {
        'name': 'AGENCY NAME',
        'url': 'AGENCY URL',
        'phone': 'AGENCY PHONE',
        'fare_url': 'AGENCY FARE URL',
        'email': 'AGENCY EMAIL',
        'latitude': '0',
        'longitude': '0',
    },
}

## Prepare empty dataframe for all files with column names
agency_result = pd.DataFrame(columns=['agency_id', 'agency_name', 'agency_url', 'agency_timezone', 'agency_lang', 'agency_phone', 'agency_fare_url', 'agency_email', 'agency_lat', 'agency_lon'])
stops_result = pd.DataFrame(columns=['stop_id', 'stop_code', 'stop_name', 'stop_desc', 'stop_lat', 'stop_lon', 'zone_id', 'stop_url', 'location_type', 'parent_station', 'stop_timezone', 'wheelchair_boarding', 'level_id', 'platform_code'])
routes_result = pd.DataFrame(columns=['route_id', 'agency_id', 'route_short_name', 'route_long_name', 'route_desc', 'route_type', 'route_url','route_color', 'route_text_color', 'route_sort_order', 'continuous_pickup', 'continuous_drop_off', 'eligibility_restricted'])
trips_result = pd.DataFrame(columns=['route_id', 'service_id', 'trip_id', 'trip_headsign', 'trip_short_name', 'direction_id', 'block_id', 'shape_id', 'wheelchair_accessible', 'bikes_allowed', 'drt_advance_book_min', 'peak_offpeak'])
calendar_dates_result = pd.DataFrame(columns=['service_id', 'date', 'exception_type'])
stop_times_result = pd.DataFrame(columns=['trip_id', 'arrival_time', 'departure_time', 'stop_id', 'stop_sequence', 'stop_headsign', 'pickup_type', 'drop_off_type', 'continuous_pickup', 'continuous_drop_off', 'shape_dist_traveled', 'timepoint'])
shapes_result = pd.DataFrame(columns=['shape_id', 'shape_pt_lat', 'shape_pt_lon', 'shape_pt_sequence', 'shape_dist_traveled'])

count = 0

agencyIndex = 0

for agency_id in agencies:
    print(agency_id)

    agency_tmp = pd.DataFrame(columns=['agency_id', 'agency_name', 'agency_url', 'agency_timezone', 'agency_lang', 'agency_phone', 'agency_fare_url', 'agency_email'])
    stops_tmp = pd.DataFrame(columns=['stop_id', 'stop_code', 'stop_name', 'stop_desc', 'stop_lat', 'stop_lon', 'zone_id', 'stop_url', 'location_type', 'parent_station', 'stop_timezone', 'wheelchair_boarding', 'level_id', 'platform_code'])
    routes_tmp = pd.DataFrame(columns=['route_id', 'agency_id', 'route_short_name', 'route_long_name', 'route_desc', 'route_type', 'route_url','route_color', 'route_text_color', 'route_sort_order', 'continuous_pickup', 'continuous_drop_off', 'eligibility_restricted'])
    trips_tmp = pd.DataFrame(columns=['route_id', 'service_id', 'trip_id', 'trip_headsign', 'trip_short_name', 'direction_id', 'block_id', 'shape_id', 'wheelchair_accessible', 'bikes_allowed', 'drt_advance_book_min', 'peak_offpeak'])
    calendar_dates_tmp = pd.DataFrame(columns=['service_id', 'date', 'exception_type'])
    stop_times_tmp = pd.DataFrame(columns=['trip_id', 'arrival_time', 'departure_time', 'stop_id', 'stop_sequence', 'stop_headsign', 'pickup_type', 'drop_off_type', 'continuous_pickup', 'continuous_drop_off', 'shape_dist_traveled', 'timepoint'])
    shapes_tmp = pd.DataFrame(columns=['shape_id', 'shape_pt_lat', 'shape_pt_lon', 'shape_pt_sequence', 'shape_dist_traveled'])
    feed_info_tmp = pd.DataFrame(columns=['feed_id', 'feed_publisher_name', 'feed_publisher_url', 'feed_lang'], data={
        'feed_id': [agency_id],
        'feed_publisher_name': ['Mimosa ITL'],
        'feed_publisher_url': ['https://www.fondazioneitl.org'],
        'feed_lang': ['it'],
    })

    agency_data = pd.read_csv(local_path_dataset + '/' + agency_id + "/agency.txt")
    agency_data['agency_id'] = agency_id
    agency_data['agency_name'] = agencies[agency_id]['name']
    agency_data['agency_url'] = agencies[agency_id]['url']
    agency_data['agency_phone'] = agencies[agency_id]['phone']
    agency_data['agency_fare_url'] = agencies[agency_id]['fare_url']
    agency_data['agency_email'] = agencies[agency_id]['email']
    agency_tmp = pd.concat([agency_tmp, agency_data])
    agency_data['agency_lat'] = agencies[agency_id]['latitude']
    agency_data['agency_lon'] = agencies[agency_id]['longitude']
    agency_result = pd.concat([agency_result, agency_data])

    stops_data = pd.read_csv(local_path_dataset + '/' + agency_id + "/stops.txt")
    stops_data['stop_code'] = stops_data['stop_id']
    stops_data['stop_id'] = agency_id + '_' + stops_data['stop_id'].astype(str)
    stops_tmp = pd.concat([stops_tmp, stops_data])
    stops_result = pd.concat([stops_result, stops_data])

    routes_data = pd.read_csv(local_path_dataset + '/' + agency_id + "/routes.txt", dtype=str)
    routes_data['agency_id'] = agency_id
    routes_data['route_id'] = agency_id + '_' + routes_data['route_id'].astype(str)
    routes_tmp = pd.concat([routes_tmp, routes_data])
    routes_result = pd.concat([routes_result, routes_data])

    trips_data = pd.read_csv(local_path_dataset + '/' + agency_id + "/trips.txt", dtype=str)
    trips_data['route_id'] = agency_id + '_' + trips_data['route_id'].astype(str)
    trips_data['service_id'] = agency_id + '_' + trips_data['service_id'].astype(str)
    trips_data['trip_id'] = agency_id + '_' + trips_data['trip_id'].astype(str)
    if 'shape_id' in trips_data: trips_data['shape_id'] = agency_id + '_' + trips_data['shape_id'].astype(str)
    trips_tmp = pd.concat([trips_tmp, trips_data])
    trips_result = pd.concat([trips_result, trips_data])

    calendar_dates_data = pd.read_csv(local_path_dataset + '/' + agency_id + "/calendar_dates.txt")
    calendar_dates_data['service_id'] = agency_id + '_' + calendar_dates_data['service_id'].astype(str)
    calendar_dates_tmp = pd.concat([calendar_dates_tmp, calendar_dates_data])
    calendar_dates_result = pd.concat([calendar_dates_result, calendar_dates_data])

    stop_times_data = pd.read_csv(local_path_dataset + '/' + agency_id + "/stop_times.txt", low_memory=False)
    stop_times_data['trip_id'] = agency_id + '_' + stop_times_data['trip_id'].astype(str)
    stop_times_data['stop_id'] = agency_id + '_' + stop_times_data['stop_id'].astype(str)
    if agency_id == 'SETA':
        stop_times_data['stop_headsign'] = ''
    stop_times_tmp = pd.concat([stop_times_tmp, stop_times_data])
    stop_times_result = pd.concat([stop_times_result, stop_times_data])

    if agency_id not in ['RFI', 'FER']:
        shapes_data = pd.read_csv(local_path_dataset + '/' + agency_id + "/shapes.txt", low_memory=False)
        shapes_data['shape_id'] = agency_id + '_' + shapes_data['shape_id'].astype(str)
        shapes_tmp = pd.concat([shapes_tmp, shapes_data])
        shapes_result = pd.concat([shapes_result, shapes_data])

    if not os.path.exists(local_path_output_dataset + '/' + agency_id):
        os.makedirs(local_path_output_dataset + '/' + agency_id)

    agency_tmp.to_csv(local_path_output_dataset + '/' + agency_id + '/agency.txt', index=None, quoting=csv.QUOTE_ALL)
    stops_tmp.to_csv(local_path_output_dataset + '/' + agency_id + '/stops.txt', index=None, quoting=csv.QUOTE_ALL)
    routes_tmp.to_csv(local_path_output_dataset + '/' + agency_id + '/routes.txt', index=None, quoting=csv.QUOTE_ALL)
    trips_tmp.to_csv(local_path_output_dataset + '/' + agency_id + '/trips.txt', index=None, quoting=csv.QUOTE_ALL)
    calendar_dates_tmp.to_csv(local_path_output_dataset + '/' + agency_id + '/calendar_dates.txt', index=None, quoting=csv.QUOTE_ALL)
    stop_times_tmp.to_csv(local_path_output_dataset + '/' + agency_id + '/stop_times.txt', index=None, quoting=csv.QUOTE_ALL)
    shapes_tmp.to_csv(local_path_output_dataset + '/' + agency_id + '/shapes.txt', index=None, quoting=csv.QUOTE_ALL)
    feed_info_tmp.to_csv(local_path_output_dataset + '/' + agency_id + '/feed_info.txt', index=None, quoting=csv.QUOTE_ALL)

    with ZipFile(local_path_output_dataset + '/' + str(agencyIndex) + '_' + agency_id + '_GTFS.zip', 'w') as zip_object:
        # Adding files that need to be zipped
        zip_object.write(local_path_output_dataset + '/' + agency_id + '/agency.txt', 'agency.txt')
        zip_object.write(local_path_output_dataset + '/' + agency_id + '/stops.txt', 'stops.txt')
        zip_object.write(local_path_output_dataset + '/' + agency_id + '/routes.txt', 'routes.txt')
        zip_object.write(local_path_output_dataset + '/' + agency_id + '/trips.txt', 'trips.txt')
        zip_object.write(local_path_output_dataset + '/' + agency_id + '/calendar_dates.txt', 'calendar_dates.txt')
        zip_object.write(local_path_output_dataset + '/' + agency_id + '/stop_times.txt', 'stop_times.txt')
        zip_object.write(local_path_output_dataset + '/' + agency_id + '/shapes.txt', 'shapes.txt')
        zip_object.write(local_path_output_dataset + '/' + agency_id + '/feed_info.txt', 'feed_info.txt')

    agencyIndex += 1

if not os.path.exists(local_path_output_dataset + '/combined'):
    os.makedirs(local_path_output_dataset + '/combined')

## save in local path
agency_result.to_csv(local_path_output_dataset + '/combined/agency.txt', index=None, quoting=csv.QUOTE_ALL)
stops_result.to_csv(local_path_output_dataset + '/combined/stops.txt', index=None, quoting=csv.QUOTE_ALL)
routes_result.to_csv(local_path_output_dataset + '/combined/routes.txt', index=None, quoting=csv.QUOTE_ALL)
trips_result.to_csv(local_path_output_dataset + '/combined/trips.txt', index=None, quoting=csv.QUOTE_ALL)
calendar_dates_result.to_csv(local_path_output_dataset + '/combined/calendar_dates.txt', index=None, quoting=csv.QUOTE_ALL)
stop_times_result.to_csv(local_path_output_dataset + '/combined/stop_times.txt', index=None, quoting=csv.QUOTE_ALL)
shapes_result.to_csv(local_path_output_dataset + '/combined/shapes.txt', index=None, quoting=csv.QUOTE_ALL)


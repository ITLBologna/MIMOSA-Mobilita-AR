/*
 * Copyright 2022-2023 bitApp S.r.l.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Mimosa Transit API
 *
 *
 * Contact: info@bitapp.it
 */

package controllers

import (
	"encoding/csv"
	"encoding/gob"
	"errors"
	"fmt"
	"log"
	"net/http"
	"os"
	"sort"
	"strconv"
	"strings"
	"time"

	"github.com/bitapp-srl/mimosa-itl-api-go/api/models"
	"github.com/bitapp-srl/mimosa-itl-api-go/rt"
	"github.com/bitapp-srl/mimosa-itl-api-go/util"
	"github.com/gin-gonic/gin"
	_ "github.com/joho/godotenv/autoload"
	"github.com/twpayne/go-polyline"
	"google.golang.org/protobuf/proto"
)

const graphVersion string = "0001"

type DataStorage struct {
	Version           string
	GtfsDataStorage   *GtfsDataStorage
	ParsedDataStorage *ParsedDataStorage
}

type GtfsDataStorage struct {
	Agencies      map[string]models.GtfsAgency              //agency_id
	Stops         map[string]models.Stop                    //stop_id
	Routes        map[string]models.GtfsRoute               //route_id
	Trips         map[string]models.GtfsTrip                //trip_id
	CalendarDates map[string][]models.GtfsCalendarDates     //date
	Shapes        map[string][]models.GtfsShape             //shape_id
	StopTimes     map[string]map[string]models.GtfsStopTime //trip_id,stop_id
	Vehicles      map[string]models.VehiclesStore           //agency_id
	Updates       map[string]models.UpdatesStore            //agency_id
}

type ParsedDataStorage struct {
	MapShapes         map[string]string                    //shape_id
	MapStopsByTripId  map[string][]models.TripResponseStop // trip_id
	MapStopTimesByDay map[string]map[string][]string       // calendar_date,stop_id
}

var dataStorage = initDataStorage()

func initDataStorage() *DataStorage {
	graphEnabled := os.Getenv("ENABLE_GRAPH")
	graphPath := os.Getenv("GRAPH_PATH")

	if graphEnabled == "true" {
		decodeFile, decodeErr := os.Open(graphPath)
		if decodeErr == nil {
			defer decodeFile.Close()

			decoder := gob.NewDecoder(decodeFile)
			decodedStorage := new(DataStorage)
			decoder.Decode(decodedStorage)

			if decodedStorage.Version != graphVersion {
				panic("Graph version mismatch")
			}

			return decodedStorage
		}

		log.Println(decodeErr)
	}

	storage := new(DataStorage)

	storage.Version = graphVersion
	storage.GtfsDataStorage = initGtfsDataStorage()
	storage.ParsedDataStorage = initParsedDataStorage(storage.GtfsDataStorage)

	if graphEnabled == "true" {
		encodeFile, encodeErr := os.Create(graphPath)
		if encodeErr != nil {
			panic(encodeErr)
		}

		encoder := gob.NewEncoder(encodeFile)

		if err := encoder.Encode(storage); err != nil {
			panic(err)
		}
		encodeFile.Close()
	}

	return storage
}

func initGtfsDataStorage() *GtfsDataStorage {
	gtfsPath := os.Getenv("GTFS_PATH")

	storage := new(GtfsDataStorage)
	storage.Agencies = loadAgencies(gtfsPath + "/agency.txt")
	storage.Routes = loadRoutes(gtfsPath + "/routes.txt")
	storage.Stops = loadStops(gtfsPath + "/stops.txt")
	storage.Trips = loadTrips(gtfsPath + "/trips.txt")
	storage.CalendarDates = loadCalendarDates(gtfsPath + "/calendar_dates.txt")
	storage.Shapes = loadShapes(gtfsPath + "/shapes.txt")
	storage.StopTimes = loadStopTimes(gtfsPath + "/stop_times.txt")

	return storage
}

func initParsedDataStorage(gtfsStorage *GtfsDataStorage) *ParsedDataStorage {
	storage := new(ParsedDataStorage)
	storage.MapShapes = buildMapShapes(gtfsStorage)
	storage.MapStopsByTripId = buildMapStopsByTripId(gtfsStorage)
	storage.MapStopTimesByDay = buildMapStopTimesByDay(gtfsStorage)

	return storage
}

func buildMapShapes(storage *GtfsDataStorage) map[string]string {
	log.Println("building map shapes...")
	mapShapes := make(map[string]string)

	if os.Getenv("LOAD_SHAPES") == "false" {
		return mapShapes
	}

	log.Printf("Building mapShapes")
	for shapeId, shapes := range storage.Shapes {
		mapShapes[shapeId] = encodeShapepolyline(shapes)
	}

	return mapShapes
}

func buildMapStopsByTripId(storage *GtfsDataStorage) map[string][]models.TripResponseStop {
	log.Println("building map stops by trip_id...")
	stops := make(map[string][]models.TripResponseStop)
	for trip_id := range storage.Trips {
		stops[trip_id] = stopsByTripId(storage, trip_id)
	}
	return stops
}

func buildMapCalendarDatesByServiceId(storage *GtfsDataStorage) map[string][]*models.GtfsCalendarDates {
	log.Println("building map calendar dates by service_id...")
	cds := make(map[string][]*models.GtfsCalendarDates)
	for _, calendarDates := range storage.CalendarDates {
		for _, calendarDate := range calendarDates {
			cds[calendarDate.ServiceId] = append(cds[calendarDate.ServiceId], &calendarDate)
		}
	}
	return cds
}

func buildMapStopTimesByDay(storage *GtfsDataStorage) map[string]map[string][]string {
	log.Println("building map stop times by day...")
	sts := make(map[string]map[string][]string)

	if os.Getenv("LOAD_STOP_TIMES") == "false" {
		return sts
	}

	cTrips := len(storage.Trips)
	iTrips := 0

	mapCalendarDatesByServiceId := buildMapCalendarDatesByServiceId(storage)

	for tripId, stopTimes := range storage.StopTimes {
		iTrips++
		if iTrips%1000 == 0 {
			log.Printf("StopTimes Trip %d/%d", iTrips, cTrips)
		}

		trip := storage.Trips[tripId]

		for _, calendarDate := range mapCalendarDatesByServiceId[trip.ServiceId] {
			if sts[calendarDate.Date] == nil {
				sts[calendarDate.Date] = make(map[string][]string)
			}

			for stopId, stopTime := range stopTimes {
				sts[calendarDate.Date][stopId] = append(sts[calendarDate.Date][stopId], stopTime.TripId)
			}
		}
	}

	if os.Getenv("ORDER_STOP_TIMES") == "false" {
		return sts
	}

	log.Println("ordering stop times...")

	for date, stops := range sts {
		for stopId, times := range stops {
			sort.Slice(times, func(i, j int) bool {
				return storage.StopTimes[times[i]][stopId].ArrivalTime < storage.StopTimes[times[j]][stopId].ArrivalTime
			})

			sts[date][stopId] = times
		}
	}

	return sts
}

/**
 * 0. "shape_id"
 * 1. "shape_pt_lat"
 * 2. "shape_pt_lon"
 * 3. "shape_pt_sequence"
 * 4. "shape_dist_traveled"
 */
func loadShapes(filename string) map[string][]models.GtfsShape {
	f, err := os.Open(filename)
	log.Printf("Opening %s", filename)
	if err != nil {
		log.Fatal(err)
	}
	csvReader := csv.NewReader(f)
	data, err := csvReader.ReadAll()
	if err != nil {
		log.Fatal(err)
	}
	var shape *models.GtfsShape
	var shapes = make(map[string][]models.GtfsShape)
	for i, row := range data {
		if i > 0 {
			shape = new(models.GtfsShape)
			shape.ShapeId = row[0]
			shape.ShapePtLat, _ = strconv.ParseFloat(row[1], 64)
			shape.ShapePtLon, _ = strconv.ParseFloat(row[2], 64)
			shape.ShapePtSequence, _ = strconv.Atoi(row[3])
			shape.ShapeDistTraveled, _ = strconv.ParseFloat(row[4], 64)
			shapes[row[0]] = append(shapes[row[0]], *shape)
		}
	}
	return shapes
}

/**
 * 0. "agency_id"
 * 1. "agency_name"
 * 2. "agency_url"
 * 3. "agency_timezone"
 * 4. "agency_lang"
 * 5. "agency_phone"
 * 6. "agency_fare_url"
 * 7. "agency_email"
 * 8. "agency_lat"
 * 9. "agency_lon"
 */
func loadAgencies(filename string) map[string]models.GtfsAgency {
	f, err := os.Open(filename)
	log.Printf("Opening %s", filename)
	if err != nil {
		log.Fatal(err)
	}
	csvReader := csv.NewReader(f)
	data, err := csvReader.ReadAll()
	if err != nil {
		log.Fatal(err)
	}
	var agency *models.GtfsAgency
	var agencies = make(map[string]models.GtfsAgency)

	for i, row := range data {
		if i > 0 {
			lat, _ := strconv.ParseFloat(row[8], 64)
			lon, _ := strconv.ParseFloat(row[9], 64)

			agency = new(models.GtfsAgency)
			agency.AgencyId = row[0]
			agency.AgencyName = row[1]
			agency.AgencyUrl = row[2]
			agency.AgencyTimezone = row[3]
			agency.AgencyLang = row[4]
			agency.AgencyPhone = row[5]
			agency.AgencyFareUrl = row[6]
			agency.AgencyEmail = row[7]
			agency.AgencyLat = lat
			agency.AgencyLon = lon
			agencies[row[0]] = *agency
		}
	}
	return agencies
}

/**
 * 0. "service_id"
 * 1. "date"
 * 2. "exception_type"
 */
func loadCalendarDates(filename string) map[string][]models.GtfsCalendarDates {
	f, err := os.Open(filename)
	log.Printf("Opening %s", filename)
	if err != nil {
		log.Fatal(err)
	}
	csvReader := csv.NewReader(f)
	data, err := csvReader.ReadAll()
	if err != nil {
		log.Fatal(err)
	}
	var service *models.GtfsCalendarDates
	var services = make(map[string][]models.GtfsCalendarDates)
	for i, row := range data {
		if i > 0 {
			service = new(models.GtfsCalendarDates)
			service.ServiceId = row[0]
			service.Date = row[1]
			service.ExceptionType = row[2]
			services[row[1]] = append(services[row[1]], *service)
		}
	}
	return services
}

/**
 * 0. "stop_id"
 * 1. "stop_code"
 * 2. "stop_name"
 * 3. "stop_desc"
 * 4. "stop_lat"
 * 5. "stop_lon"
 * 6. "zone_id"
 * 7. "stop_url"
 * 8. "location_type"
 * 9. "parent_station"
 * 10. "stop_timezone"
 * 11. "wheelchair_boarding"
 * 12. "level_id"
 * 13. "platform_code"
 */
func loadStops(filename string) map[string]models.Stop {
	f, err := os.Open(filename)
	log.Printf("Opening %s", filename)
	if err != nil {
		log.Fatal(err)
	}
	csvReader := csv.NewReader(f)
	data, err := csvReader.ReadAll()
	if err != nil {
		log.Fatal(err)
	}
	var stops = make(map[string]models.Stop)
	for i, row := range data {
		if i > 0 {
			lat, _ := strconv.ParseFloat(row[4], 64)
			lon, _ := strconv.ParseFloat(row[5], 64)
			locationType, _ := strconv.ParseUint(row[8], 10, 64)
			wheelchairBoarding, _ := strconv.ParseUint(row[11], 10, 64)
			stop := models.Stop{
				StopId:             row[0],
				StopCode:           row[1],
				StopName:           row[2],
				StopDesc:           row[3],
				StopLat:            lat,
				StopLon:            lon,
				ZoneId:             row[6],
				StopUrl:            row[7],
				LocationType:       locationType,
				ParentStation:      row[9],
				StopTimezone:       row[10],
				WheelchairBoarding: wheelchairBoarding,
				LevelId:            row[12],
				PlatformCode:       row[13],
			}
			stops[row[0]] = stop
		}
	}

	return stops
}

/**
 * 0. "route_id"
 * 1. "agency_id"
 * 2. "route_short_name"
 * 3. "route_long_name"
 * 4. "route_desc"
 * 5. "route_type"
 * 6. "route_url"
 * 7. "route_color"
 * 8. "route_text_color"
 * 9. "route_sort_order"
 * 10. "continuous_pickup"
 * 11. "continuous_drop_off"
 * 12. "eligibility_restricted"
 */
func loadRoutes(filename string) map[string]models.GtfsRoute {
	f, err := os.Open(filename)
	log.Printf("Opening %s", filename)
	if err != nil {
		log.Fatal(err)
	}
	csvReader := csv.NewReader(f)
	data, err := csvReader.ReadAll()
	if err != nil {
		log.Fatal(err)
	}
	var route *models.GtfsRoute
	var routes = make(map[string]models.GtfsRoute)

	for i, row := range data {
		if i > 0 {
			route = new(models.GtfsRoute)
			route.RouteId = row[0]
			route.AgencyId = row[1]
			route.RouteShortName = row[2]
			route.RouteLongName = row[3]
			route.RouteDesc = row[4]
			route.RouteType = row[5]
			route.RouteUrl = row[6]
			route.RouteColor = row[7]
			route.RouteTextColor = row[8]
			route.RouteSortOrder, _ = strconv.ParseUint(row[9], 10, 64)
			route.ContinuousPickup, _ = strconv.ParseUint(row[10], 10, 64)
			route.ContinuousDropOff, _ = strconv.ParseUint(row[11], 10, 64)
			// route.EligibilityRestricted = row[12]
			routes[row[0]] = *route
		}
	}
	return routes
}

/**
 * 0. "trip_id"
 * 1. "arrival_time"
 * 2. "departure_time"
 * 3. "stop_id"
 * 4. "stop_sequence"
 * 5. "stop_headsign"
 * 6. "pickup_type"
 * 7. "drop_off_type"
 * 8. "continuous_pickup"
 * 9. "continuous_drop_off"
 * 10. "shape_dist_traveled"
 * 11. "timepoint"
 */
func loadStopTimes(filename string) map[string]map[string]models.GtfsStopTime {
	f, err := os.Open(filename)
	log.Printf("Opening %s", filename)
	if err != nil {
		log.Fatal(err)
	}
	csvReader := csv.NewReader(f)
	data, err := csvReader.ReadAll()
	if err != nil {
		log.Fatal(err)
	}
	var st *models.GtfsStopTime
	var sts = make(map[string]map[string]models.GtfsStopTime)
	for i, row := range data {
		if i > 0 {
			st = new(models.GtfsStopTime)
			st.TripId = row[0]
			st.ArrivalTime = row[1]
			st.DepartureTime = row[2]
			st.StopId = row[3]
			st.StopSequence, _ = strconv.ParseUint(row[4], 10, 64)
			st.StopHeadsign = row[5]
			st.PickupType, _ = strconv.ParseUint(row[6], 10, 64)
			st.DropOffType, _ = strconv.ParseUint(row[7], 10, 64)
			st.ContinuousPickup, _ = strconv.ParseUint(row[8], 10, 64)
			st.ContinuousDropOff, _ = strconv.ParseUint(row[9], 10, 64)
			st.ShapeDistTraveled, _ = strconv.ParseFloat(row[10], 64)
			st.Timepoint, _ = strconv.ParseUint(row[11], 10, 64)
			if _, ok := sts[row[0]]; !ok {
				sts[row[0]] = make(map[string]models.GtfsStopTime)
			}

			sts[row[0]][row[3]] = *st
		}
	}
	return sts
}

/**
 * 0. "route_id"
 * 1. "service_id"
 * 2. "trip_id"
 * 3. "trip_headsign"
 * 4. "trip_short_name"
 * 5. "direction_id"
 * 6. "block_id"
 * 7. "shape_id"
 * 8. "wheelchair_accessible"
 * 9. "bikes_allowed"
 * 10. "drt_advance_book_min"
 * 11. "peak_offpeak"
 */
func loadTrips(filename string) map[string]models.GtfsTrip {
	f, err := os.Open(filename)
	log.Printf("Opening %s", filename)
	if err != nil {
		log.Fatal(err)
	}
	csvReader := csv.NewReader(f)
	data, err := csvReader.ReadAll()
	if err != nil {
		log.Fatal(err)
	}
	var trip *models.GtfsTrip
	var trips = make(map[string]models.GtfsTrip)
	for i, row := range data {
		if i > 0 {
			trip = new(models.GtfsTrip)
			trip.RouteId = row[0]
			trip.ServiceId = row[1]
			trip.TripId = row[2]
			trip.TripHeadsign = row[3]
			trip.TripShortName = row[4]
			trip.DirectionId, _ = strconv.Atoi(row[5])
			trip.BlockId = row[6]
			trip.ShapeId = row[7]
			trip.WheelchairAccessible = row[8]
			trip.BikesAllowed = row[9]
			// trip.DrtAdvanceBookMin = row[10]
			// trip.PeakOffpeak = row[11]
			trips[row[2]] = *trip
		}
	}
	return trips
}

func GetVehiclePositions(c *gin.Context) {
	gtfsrtPath := os.Getenv("GTFSRT_PATH")
	agencyId := c.Params.ByName("agencyId")

	filename := gtfsrtPath + "/" + agencyId + "/vehicle_positions.pb"
	dat, err := os.ReadFile(filename)
	if err != nil {
		log.Print(err)
		c.JSON(http.StatusInternalServerError, nil)
		return
	}

	feed := rt.FeedMessage{}
	err = proto.Unmarshal(dat, &feed)
	if err != nil {
		log.Print(err)
		c.JSON(http.StatusInternalServerError, nil)
		return
	}

	c.JSON(http.StatusOK, feed.Entity)
}

func GetTripUpdates(c *gin.Context) {
	gtfsrtPath := os.Getenv("GTFSRT_PATH")

	agencyId := c.Params.ByName("agencyId")

	filename := gtfsrtPath + "/" + agencyId + "/trip_updates.pb"
	dat, err := os.ReadFile(filename)
	if err != nil {
		log.Print(err)
		c.JSON(http.StatusInternalServerError, nil)
		return
	}

	feed := rt.FeedMessage{}
	err = proto.Unmarshal(dat, &feed)
	if err != nil {
		log.Print(err)
		c.JSON(http.StatusInternalServerError, nil)
		return
	}

	c.JSON(http.StatusOK, feed.Entity)
}

func GetRouteVehicles(c *gin.Context) {
	routeId := c.Params.ByName("routeId")
	direction := c.Query("direction")
	tripId := c.Query("trip")

	route := dataStorage.GtfsDataStorage.Routes[routeId]

	agencyId := route.AgencyId

	if agencyId == "" {
		agencyId = strings.Split(routeId, "_")[0]
	}

	store, _ := getAgencyVehicles(agencyId)

	vehicles := make([]models.VehiclePosition, 0)

	if tripId != "" {
		trip := dataStorage.GtfsDataStorage.Trips[tripId]

		direction = fmt.Sprint(trip.DirectionId)
	}

	if direction == "" {
		vehicles = store.Vehicles[routeId]
	} else {
		directionInt, _ := strconv.ParseInt(direction, 10, 0)

		for _, vp := range store.Vehicles[routeId] {
			if vp.Trip.DirectionId == int(directionInt) {
				vehicles = append(vehicles, vp)
			}
		}
	}

	expirestAt := time.Now().Local().Add(time.Second * time.Duration(5))

	if store.ExpiresAt.After(time.Now().Local()) {
		expirestAt = store.ExpiresAt
	}

	response := models.VehiclesPositionsResponse{
		ExpiresAt: expirestAt.UTC().Format(time.RFC3339),
		Data:      vehicles,
	}
	c.JSON(http.StatusOK, response)
}

func getAgencyVehicles(agencyId string) (store models.VehiclesStore, ok bool) {
	if dataStorage.GtfsDataStorage.Vehicles == nil {
		dataStorage.GtfsDataStorage.Vehicles = make(map[string]models.VehiclesStore)
	}

	store, exists := dataStorage.GtfsDataStorage.Vehicles[agencyId]

	if exists && store.ExpiresAt.After(time.Now()) {
		return store, true
	}

	gtfsrtPath := os.Getenv("GTFSRT_PATH")

	filename := gtfsrtPath + "/" + agencyId + "/vehicle_positions.pb"
	dat, err := os.ReadFile(filename)

	if err != nil {
		log.Print(err)
		return models.VehiclesStore{}, false
	}

	feed := rt.FeedMessage{}
	err = proto.Unmarshal(dat, &feed)
	if err != nil {
		log.Print(err)
		return models.VehiclesStore{}, false
	}

	vehicles := make(map[string][]models.VehiclePosition)

	for _, vehiclePosition := range feed.Entity {
		if vehiclePosition.Vehicle.Trip.RouteId == nil {
			continue
		}

		if vehiclePosition.Vehicle.Position.Latitude == nil {
			continue
		}

		if vehiclePosition.Vehicle.Position.Longitude == nil {
			continue
		}

		if vehiclePosition.Vehicle.Timestamp == nil {
			continue
		}

		route := dataStorage.GtfsDataStorage.Routes[*vehiclePosition.Vehicle.Trip.RouteId]

		var trip models.GtfsTrip

		if vehiclePosition.Vehicle.Trip.TripId != nil {
			trip = dataStorage.GtfsDataStorage.Trips[*vehiclePosition.Vehicle.Trip.TripId]

			if trip.TripId == "" {
				log.Println("Trip not found", *vehiclePosition.Vehicle.Trip.TripId)
			}

			if trip.TripShortName == "" {
				trip.TripShortName = route.RouteShortName
			}

			if trip.TripHeadsign == "" {
				trip.TripHeadsign = tripHeadsignById(trip.TripId)
			}
		}

		var directionId int

		if vehiclePosition.Vehicle.Trip.DirectionId != nil {
			directionId = int(*vehiclePosition.Vehicle.Trip.DirectionId)
		}

		var bearing float64

		if vehiclePosition.Vehicle.Position.Bearing != nil {
			bearing = float64(*vehiclePosition.Vehicle.Position.Bearing)
		}

		var speed float64

		if vehiclePosition.Vehicle.Position.Speed != nil {
			speed = float64(*vehiclePosition.Vehicle.Position.Speed)
		}

		var odometer float64

		if vehiclePosition.Vehicle.Position.Odometer != nil {
			odometer = float64(*vehiclePosition.Vehicle.Position.Odometer)
		}

		var occupancyStatus int

		if vehiclePosition.Vehicle.OccupancyStatus != nil {
			occupancyStatus = int(*vehiclePosition.Vehicle.OccupancyStatus)
		}

		var stopId string

		if vehiclePosition.Vehicle.StopId != nil {
			stopId = *vehiclePosition.Vehicle.StopId
		}

		var currentStatus int

		if vehiclePosition.Vehicle.CurrentStatus != nil {
			currentStatus = int(*vehiclePosition.Vehicle.CurrentStatus)
		}

		var congestionLevel int

		if vehiclePosition.Vehicle.CongestionLevel != nil {
			congestionLevel = int(*vehiclePosition.Vehicle.CongestionLevel)
		}

		var label string

		if vehiclePosition.Vehicle.Vehicle.Label != nil {
			label = *vehiclePosition.Vehicle.Vehicle.Label
		}

		var licensePlate string

		if vehiclePosition.Vehicle.Vehicle.LicensePlate != nil {
			licensePlate = *vehiclePosition.Vehicle.Vehicle.LicensePlate
		}

		vehicles[*vehiclePosition.Vehicle.Trip.RouteId] = append(vehicles[*vehiclePosition.Vehicle.Trip.RouteId], models.VehiclePosition{
			Trip: models.TripResponse{
				RouteId:       *vehiclePosition.Vehicle.Trip.RouteId,
				TripId:        trip.TripId,
				TripHeadsign:  trip.TripHeadsign,
				TripShortName: trip.TripShortName,
				DirectionId:   directionId,
				ShapeId:       trip.ShapeId,
				ShapePolyline: dataStorage.ParsedDataStorage.MapShapes[trip.ShapeId],
				// Stops:         dataStorage.ParsedDataStorage.MapStopsByTripId[trip.TripId],
			},
			Label:           label,
			LicensePlate:    licensePlate,
			Latitude:        float64(*vehiclePosition.Vehicle.Position.Latitude),
			Longitude:       float64(*vehiclePosition.Vehicle.Position.Longitude),
			Bearing:         bearing,
			Speed:           speed,
			Odometer:        odometer,
			OccupancyStatus: occupancyStatus,
			StopId:          stopId,
			CurrentStatus:   currentStatus,
			CongestionLevel: congestionLevel,
			UpdatedAt:       time.Unix(int64(*vehiclePosition.Vehicle.Timestamp), 0).Format(time.RFC3339),
		})
	}

	dataStorage.GtfsDataStorage.Vehicles[agencyId] = models.VehiclesStore{
		ExpiresAt: time.Unix(int64(*feed.Header.Timestamp)+65, 0),
		Vehicles:  vehicles,
	}

	return dataStorage.GtfsDataStorage.Vehicles[agencyId], true
}

func GetStopUpdates(c *gin.Context) {
	stopId := c.Params.ByName("stopId")
	routeId := c.Query("route")

	agencyId := strings.Split(stopId, "_")[0]

	store, _ := getAgencyUpdates(agencyId)

	updates := make([]models.StopTimeUpdate, 0)

	if routeId == "" {
		updates = store.Updates[stopId]
	} else {
		for _, stu := range store.Updates[stopId] {
			if stu.RouteId == routeId {
				updates = append(updates, stu)
			}
		}
	}

	response := models.StopTimeUpdatesResponse{
		ExpiresAt: store.ExpiresAt.UTC().Format(time.RFC3339),
		Data:      updates,
	}
	c.JSON(http.StatusOK, response)
}

func getAgencyUpdates(agencyId string) (store models.UpdatesStore, ok bool) {
	if dataStorage.GtfsDataStorage.Updates == nil {
		dataStorage.GtfsDataStorage.Updates = make(map[string]models.UpdatesStore)
	}

	store, exists := dataStorage.GtfsDataStorage.Updates[agencyId]

	if exists && store.ExpiresAt.After(time.Now()) {
		return store, true
	}

	gtfsrtPath := os.Getenv("GTFSRT_PATH")

	filename := gtfsrtPath + "/" + agencyId + "/trip_updates.pb"
	dat, err := os.ReadFile(filename)

	if err != nil {
		log.Print(err)
		return models.UpdatesStore{}, false
	}

	feed := rt.FeedMessage{}
	err = proto.Unmarshal(dat, &feed)
	if err != nil {
		log.Print(err)
		return models.UpdatesStore{}, false
	}

	updates := make(map[string][]models.StopTimeUpdate)
	liveTrips := make(map[string]bool)

	for _, tripUpdate := range feed.Entity {
		if tripUpdate.TripUpdate.Trip.RouteId == nil {
			continue
		}

		if tripUpdate.TripUpdate.StopTimeUpdate == nil {
			continue
		}

		var trip models.GtfsTrip

		if tripUpdate.TripUpdate.Trip.TripId != nil {
			trip = dataStorage.GtfsDataStorage.Trips[*tripUpdate.TripUpdate.Trip.TripId]
			liveTrips[*tripUpdate.TripUpdate.Trip.TripId] = true

			if trip.TripId == "" {
				log.Println("Trip not found", *tripUpdate.TripUpdate.Trip.TripId)
			}
		}

		var directionId int

		if tripUpdate.TripUpdate.Trip.DirectionId != nil {
			directionId = int(*tripUpdate.TripUpdate.Trip.DirectionId)
		}

		var vehicleLabel string

		if tripUpdate.TripUpdate.Vehicle.Label != nil {
			vehicleLabel = *tripUpdate.TripUpdate.Vehicle.Label
		}

		var vehicleLicensePlate string

		if tripUpdate.TripUpdate.Vehicle.LicensePlate != nil {
			vehicleLicensePlate = *tripUpdate.TripUpdate.Vehicle.LicensePlate
		}

		var startDate string

		if tripUpdate.TripUpdate.Trip.StartDate != nil {
			startDate = *tripUpdate.TripUpdate.Trip.StartDate
		} else {
			startDate = time.Now().Format("20060102")
		}

		var timestamp uint64

		if tripUpdate.TripUpdate.Timestamp != nil {
			timestamp = uint64(*tripUpdate.TripUpdate.Timestamp)
		}

		if len(tripUpdate.TripUpdate.StopTimeUpdate) == 0 {
			continue
		}

		if tripUpdate.TripUpdate.StopTimeUpdate[len(tripUpdate.TripUpdate.StopTimeUpdate)-1].StopId == nil {
			continue
		}

		lastStopId := *tripUpdate.TripUpdate.StopTimeUpdate[len(tripUpdate.TripUpdate.StopTimeUpdate)-1].StopId

		for _, stopTimeUpdate := range tripUpdate.TripUpdate.StopTimeUpdate {
			if stopTimeUpdate.StopId == nil {
				continue
			}

			var stopSequence uint64

			if stopTimeUpdate.StopSequence != nil {
				stopSequence = uint64(*stopTimeUpdate.StopSequence)
			}

			var arrivalTime *time.Time

			if stopTimeUpdate.Arrival != nil && stopTimeUpdate.Arrival.Time != nil {
				tmpArrivalTime := time.Unix(int64(*stopTimeUpdate.Arrival.Time), 0)
				arrivalTime = &tmpArrivalTime
			}

			var departureTime *time.Time

			if stopTimeUpdate.Departure != nil && stopTimeUpdate.Departure.Time != nil {
				tmpDepartureTime := time.Unix(int64(*stopTimeUpdate.Departure.Time), 0)
				departureTime = &tmpDepartureTime
			}

			if departureTime == nil {
				departureTime = arrivalTime
			}

			if arrivalTime == nil {
				arrivalTime = departureTime
			}

			updates[*stopTimeUpdate.StopId] = append(updates[*stopTimeUpdate.StopId], models.StopTimeUpdate{
				RouteId:             *tripUpdate.TripUpdate.Trip.RouteId,
				DirectionId:         directionId,
				TripId:              trip.TripId,
				StartDate:           startDate,
				ArrivalTime:         arrivalTime,
				DepartureTime:       departureTime,
				StopId:              *stopTimeUpdate.StopId,
				StopSequence:        stopSequence,
				VehicleLabel:        vehicleLabel,
				VehicleLicensePlate: vehicleLicensePlate,
				Timestamp:           timestamp,
				LastStopId:          lastStopId,
			})
		}
	}

	for _, stopTimeUpdates := range updates {
		sort.Slice(stopTimeUpdates, func(i, j int) bool {
			var iTime time.Time
			var jTime time.Time

			if stopTimeUpdates[i].ArrivalTime != nil {
				iTime = *stopTimeUpdates[i].ArrivalTime
			} else {
				iTime = *stopTimeUpdates[i].DepartureTime
			}

			if stopTimeUpdates[j].ArrivalTime != nil {
				jTime = *stopTimeUpdates[j].ArrivalTime
			} else {
				jTime = *stopTimeUpdates[j].DepartureTime
			}

			return iTime.Before(jTime)
		})
	}

	dataStorage.GtfsDataStorage.Updates[agencyId] = models.UpdatesStore{
		ExpiresAt: time.Unix(int64(*feed.Header.Timestamp)+65, 0),
		Updates:   updates,
		LiveTrips: liveTrips,
	}

	return dataStorage.GtfsDataStorage.Updates[agencyId], true
}

func GetStopArrivals(c *gin.Context) {
	log.Printf("Serving GetStopArrivals")

	stopId := c.Params.ByName("stopId")
	routeId := c.Query("route")
	next, _ := strconv.ParseUint(c.Query("next"), 10, 64)

	if dataStorage.ParsedDataStorage.MapStopTimesByDay == nil {
		c.JSON(http.StatusOK, gin.H{"msg": "Can't load data"})
	}

	loc, _ := time.LoadLocation("Europe/Rome")
	currentTime := time.Now().In(loc)

	days := make([]string, 0)

	if next != 0 {
		if currentTime.Hour() < 2 {
			days = append(days, currentTime.Add(time.Duration(-24)*time.Hour).Format("20060102"))
			days = append(days, currentTime.Format("20060102"))
		} else {
			days = append(days, currentTime.Format("20060102"))
			days = append(days, currentTime.Add(time.Duration(24)*time.Hour).Format("20060102"))
		}
	} else {
		days = append(days, currentTime.Format("20060102"))
	}

	sts := make([]models.StopTimeResponse, 0)

	agencyId := strings.Split(stopId, "_")[0]

	store, storeStatus := getAgencyUpdates(agencyId)

	var added uint64 = 0

	for _, searchDay := range days {
		for _, tripId := range dataStorage.ParsedDataStorage.MapStopTimesByDay[searchDay][stopId] {
			if next != 0 && added >= next {
				break
			}

			if store.LiveTrips[tripId] {
				continue
			}

			stopTime := dataStorage.GtfsDataStorage.StopTimes[tripId][stopId]

			trip := dataStorage.GtfsDataStorage.Trips[stopTime.TripId]

			route := dataStorage.GtfsDataStorage.Routes[dataStorage.GtfsDataStorage.Trips[stopTime.TripId].RouteId]

			if trip.TripHeadsign == "" {
				trip.TripHeadsign = tripHeadsignById(trip.TripId)
			}

			if trip.TripShortName == "" {
				trip.TripShortName = route.RouteShortName
			}

			if routeId == "" || routeId == route.RouteId {
				parsedArrivalTime, _ := parseGtfsTime(searchDay, stopTime.ArrivalTime)
				parsedDepartureTime, _ := parseGtfsTime(searchDay, stopTime.DepartureTime)

				if next == 0 || parsedArrivalTime.After(currentTime) {
					stopTimeResponse := models.StopTimeResponse{
						StopId:                 stopTime.StopId,
						ScheduledArrivalTime:   parsedArrivalTime.UTC().Format(time.RFC3339),
						ScheduledDepartureTime: parsedDepartureTime.UTC().Format(time.RFC3339),
						ArrivalTime:            stopTime.ArrivalTime,   // legacy
						DepartureTime:          stopTime.DepartureTime, // legacy
						StopSequence:           stopTime.StopSequence,
						Trip:                   trip,
						Route:                  route,
					}

					sts = append(sts, stopTimeResponse)
					added++
				}
			}
		}
	}

	expirestAt := time.Now().Local().Add(time.Second * time.Duration(30))

	var liveAdded uint64 = 0

	if storeStatus {
		if store.ExpiresAt.After(time.Now().Local()) {
			expirestAt = store.ExpiresAt
		} else {
			expirestAt = time.Now().Local().Add(time.Second * time.Duration(5))
		}

		for _, stopTimeUpdate := range store.Updates[stopId] {
			if next != 0 && liveAdded >= next {
				break
			}

			if routeId == "" || routeId == stopTimeUpdate.RouteId {
				trip := dataStorage.GtfsDataStorage.Trips[stopTimeUpdate.TripId]
				route := dataStorage.GtfsDataStorage.Routes[stopTimeUpdate.RouteId]

				if stopTimeUpdate.TripId == "" || trip.TripId == "" || route.RouteId == "" {
					tripHeadsign := "ND"

					lastStop := dataStorage.GtfsDataStorage.Stops[stopTimeUpdate.LastStopId]

					if lastStop.StopName != "" {
						tripHeadsign = lastStop.StopName
					}

					stopTimeResponse := models.StopTimeResponse{
						StopId:       stopTimeUpdate.StopId,
						StopSequence: stopTimeUpdate.StopSequence,
						Trip: models.GtfsTrip{
							RouteId:       stopTimeUpdate.RouteId,
							DirectionId:   stopTimeUpdate.DirectionId,
							TripHeadsign:  tripHeadsign,
							TripShortName: strings.Split(stopTimeUpdate.RouteId, "_")[1],
						},
						Route: dataStorage.GtfsDataStorage.Routes[stopTimeUpdate.RouteId],
					}

					var parsedTime time.Time

					if stopTimeUpdate.DepartureTime != nil {
						stopTimeResponse.LiveDepartureTime = stopTimeUpdate.DepartureTime.UTC().Format(time.RFC3339)
						stopTimeResponse.DepartureTime = stopTimeUpdate.DepartureTime.Local().Format("15:04:05") // legacy
						parsedTime = *stopTimeUpdate.DepartureTime
					}

					if stopTimeUpdate.ArrivalTime != nil {
						stopTimeResponse.LiveArrivalTime = stopTimeUpdate.ArrivalTime.UTC().Format(time.RFC3339)
						stopTimeResponse.ArrivalTime = stopTimeUpdate.ArrivalTime.Local().Format("15:04:05") // legacy
						parsedTime = *stopTimeUpdate.ArrivalTime
					}

					if stopTimeResponse.Route.RouteId == "" {
						stopTimeResponse.Route.RouteId = stopTimeUpdate.RouteId
						stopTimeResponse.Route.AgencyId = agencyId
						stopTimeResponse.Route.RouteShortName = strings.Split(stopTimeUpdate.RouteId, "_")[1]
					}

					if next == 0 || parsedTime.After(currentTime) {
						sts = append(sts, stopTimeResponse)
						liveAdded++
					}
				} else {
					stopTime := dataStorage.GtfsDataStorage.StopTimes[trip.TripId][stopId]

					parsedArrivalTime, _ := parseGtfsTime(stopTimeUpdate.StartDate, stopTime.ArrivalTime)
					parsedDepartureTime, _ := parseGtfsTime(stopTimeUpdate.StartDate, stopTime.DepartureTime)

					if trip.TripHeadsign == "" {
						trip.TripHeadsign = tripHeadsignById(trip.TripId)
					}

					if trip.TripShortName == "" {
						trip.TripShortName = route.RouteShortName
					}

					stopTimeResponse := models.StopTimeResponse{
						StopId:                 stopTime.StopId,
						ScheduledArrivalTime:   parsedArrivalTime.UTC().Format(time.RFC3339),
						ScheduledDepartureTime: parsedDepartureTime.UTC().Format(time.RFC3339),
						StopSequence:           stopTime.StopSequence,
						Trip:                   trip,
						Route:                  route,
					}

					var parsedTime time.Time

					if stopTimeUpdate.DepartureTime != nil {
						stopTimeResponse.LiveDepartureTime = stopTimeUpdate.DepartureTime.UTC().Format(time.RFC3339)
						stopTimeResponse.DepartureTime = stopTimeUpdate.DepartureTime.Local().Format("15:04:05") // legacy
						parsedTime = *stopTimeUpdate.DepartureTime
					}

					if stopTimeUpdate.ArrivalTime != nil {
						stopTimeResponse.LiveArrivalTime = stopTimeUpdate.ArrivalTime.UTC().Format(time.RFC3339)
						stopTimeResponse.ArrivalTime = stopTimeUpdate.ArrivalTime.Local().Format("15:04:05") // legacy
						parsedTime = *stopTimeUpdate.ArrivalTime
					}

					if stopTimeResponse.Route.RouteId == "" {
						stopTimeResponse.Route.RouteId = stopTimeUpdate.RouteId
						stopTimeResponse.Route.AgencyId = agencyId
						stopTimeResponse.Route.RouteShortName = strings.Split(stopTimeUpdate.RouteId, "_")[1]
					}

					if next == 0 || parsedTime.After(currentTime) {
						sts = append(sts, stopTimeResponse)
						liveAdded++
					}
				}
			}
		}
	}

	sort.Slice(sts, func(i, j int) bool {
		var iTime time.Time
		var jTime time.Time

		if sts[i].LiveArrivalTime != "" {
			iTime, _ = time.Parse(time.RFC3339, sts[i].LiveArrivalTime)
		} else {
			iTime, _ = time.Parse(time.RFC3339, sts[i].ScheduledArrivalTime)
		}

		if sts[j].LiveArrivalTime != "" {
			jTime, _ = time.Parse(time.RFC3339, sts[j].LiveArrivalTime)
		} else {
			jTime, _ = time.Parse(time.RFC3339, sts[j].ScheduledArrivalTime)
		}

		return iTime.Before(jTime)
	})

	if next != 0 {
		sts = sts[:next]
	}

	response := models.StopTimesResponse{
		ExpiresAt: expirestAt.UTC().Format(time.RFC3339),
		Data:      sts,
	}
	c.JSON(http.StatusOK, response)
}

func GetRouteTrips(c *gin.Context) {

	routeId := c.Params.ByName("routeId")

	shapes := make([]string, 0)
	trips := make([]models.TripResponse, 0)
	services := make(map[string]bool)

	currentTime := time.Now()

	today := currentTime.Format("20060102")

	for _, calendarDate := range dataStorage.GtfsDataStorage.CalendarDates[today] {
		services[calendarDate.ServiceId] = true
	}
	log.Printf("num services: %d", len(services))

	for _, trip := range dataStorage.GtfsDataStorage.Trips {
		if trip.RouteId == routeId && services[trip.ServiceId] {
			// search for shape in shapes
			var found = 0
			for _, v := range shapes {
				if v == trip.ShapeId {
					found++
				}
			}
			if found == 0 {
				shapes = append(shapes, trip.ShapeId)
				var tripResponse models.TripResponse
				if trip.TripHeadsign == "" {
					trip.TripHeadsign = tripHeadsignById(trip.TripId)
				}
				tripResponse.RouteId = trip.RouteId
				tripResponse.TripId = trip.TripId
				tripResponse.TripHeadsign = trip.TripHeadsign
				tripResponse.TripShortName = trip.TripShortName
				tripResponse.DirectionId = trip.DirectionId
				tripResponse.ShapeId = trip.ShapeId
				tripResponse.ShapePolyline = dataStorage.ParsedDataStorage.MapShapes[trip.ShapeId]
				tripResponse.Stops = dataStorage.ParsedDataStorage.MapStopsByTripId[trip.TripId]
				trips = append(trips, tripResponse)
			}

		}
	}
	response := models.TripsResponse{
		Data: trips,
	}
	c.JSON(http.StatusOK, response)
}

func GetAllAgencies(c *gin.Context) {
	if dataStorage.GtfsDataStorage.Agencies == nil {

		c.JSON(http.StatusOK, gin.H{"msg": "Can't load data"})

	} else {
		var response = new(models.AgenciesResponse)

		for _, value := range dataStorage.GtfsDataStorage.Agencies {
			response.Data = append(response.Data, value)
		}
		c.JSON(http.StatusOK, response)
	}
}

func GetAllRoutes(c *gin.Context) {
	strLat := c.Query("lat")
	strLon := c.Query("lon")
	lat, _ := strconv.ParseFloat(strLat, 64)
	lon, _ := strconv.ParseFloat(strLon, 64)
	log.Printf("lat %f, lon %f", lat, lon)

	if dataStorage.GtfsDataStorage.Routes == nil {

		c.JSON(http.StatusOK, gin.H{"msg": "Can't load data"})

	} else {
		var response = new(models.RoutesResponse)

		for _, value := range dataStorage.GtfsDataStorage.Routes {
			response.Data = append(response.Data, value)
		}
		c.JSON(http.StatusOK, response)
	}
}

// GetAllStops - Get all stops
func GetAllStops(c *gin.Context) {

	type StopDistance struct {
		models.Stop
		DistanceFromPoint float64 `json:"distance_from_position"`
	}
	type StopsDistance struct {
		Data []StopDistance `json:"data"`
	}

	log.Printf("Serving GetAllStops")
	strLat := c.Query("lat")
	strLon := c.Query("lon")
	if dataStorage.GtfsDataStorage.Stops == nil {

		c.JSON(http.StatusOK, gin.H{"msg": "Can't load data"})

	} else {
		if strLat != "" && strLon != "" {
			var r float64
			var limit int
			lat, _ := strconv.ParseFloat(strLat, 64)
			lon, _ := strconv.ParseFloat(strLon, 64)
			if c.Query("maxDistanceInKm") != "" {
				r, _ = strconv.ParseFloat(c.Query("maxDistanceInKm"), 64)
			} else {
				r = 0.3
			}
			if c.Query("limit") != "" {
				limit, _ = strconv.Atoi(c.Query("limit"))
			} else {
				limit = 10
			}

			var distances []StopDistance

			distances = make([]StopDistance, 0)
			for _, stop := range dataStorage.GtfsDataStorage.Stops {

				distance := util.Distance(lat, lon, stop.StopLat, stop.StopLon, "K")
				if distance < r {
					sd := StopDistance{
						Stop:              stop,
						DistanceFromPoint: distance,
					}
					distances = append(distances, sd)
				}

			}
			sort.Slice(distances, func(i, j int) bool {
				return distances[i].DistanceFromPoint < distances[j].DistanceFromPoint
			})

			if limit > len(distances) {
				limit = len(distances)
			}
			log.Println("len ", len(distances), "cap ", cap(distances))

			stopsDistance := StopsDistance{
				Data: distances[0:limit],
			}
			c.JSON(http.StatusOK, stopsDistance)
		} else {
			var response = new(models.StopsResponse)
			stops := make([]models.Stop, 0)
			for _, value := range dataStorage.GtfsDataStorage.Stops {
				stops = append(stops, value)
			}
			response.Data = stops
			c.JSON(http.StatusOK, response)
		}
	}
}

// func tripShortName(routeShortName string, tripHeadsign string) (tripShortName string) {
// 	tripShortName = routeShortName
// 	if tripHeadsign != "" {
// 		tripShortName = tripShortName + tripHeadsign
// 	}
// 	return tripShortName
// }

func tripHeadsignById(tripId string) string {
	stopId := ""
	var stopSequence uint64 = 0

	for _, stopTime := range dataStorage.GtfsDataStorage.StopTimes[tripId] {
		if stopTime.StopSequence > stopSequence {
			stopId = stopTime.StopId
			stopSequence = stopTime.StopSequence
		}
	}

	if stopId == "" {
		return ""
	}

	return dataStorage.GtfsDataStorage.Stops[stopId].StopName
}

func encodeShapepolyline(shapes []models.GtfsShape) string {
	coords := [][]float64{}

	for _, record := range shapes {
		coord := []float64{record.ShapePtLat, record.ShapePtLon}
		coords = append(coords, coord)
	}

	return string(polyline.EncodeCoords(coords))
}

func stopsByTripId(storage *GtfsDataStorage, tripId string) []models.TripResponseStop {

	var tripResponseStop = make([]models.TripResponseStop, 0)
	for _, stop := range storage.StopTimes[tripId] {
		resp := models.TripResponseStop{
			StopId:        stop.StopId,
			StopCode:      storage.Stops[stop.StopId].StopCode,
			StopName:      storage.Stops[stop.StopId].StopName,
			StopDesc:      storage.Stops[stop.StopId].StopDesc,
			StopLat:       storage.Stops[stop.StopId].StopLat,
			StopLon:       storage.Stops[stop.StopId].StopLon,
			ZoneId:        storage.Stops[stop.StopId].ZoneId,
			ArrivalTime:   stop.ArrivalTime,
			DepartureTime: stop.DepartureTime,
			StopSequence:  stop.StopSequence,
		}
		tripResponseStop = append(tripResponseStop, resp)
	}

	sort.Slice(tripResponseStop, func(i, j int) bool {
		return tripResponseStop[i].StopSequence < tripResponseStop[j].StopSequence
	})

	return tripResponseStop
}

func GetStopDistance(c *gin.Context) {
	startStopId := c.Query("start_stop_id")
	endStopId := c.Query("end_stop_id")
	routeId := c.Query("route_id")

	startStop := dataStorage.GtfsDataStorage.Stops[startStopId]
	endStop := dataStorage.GtfsDataStorage.Stops[endStopId]

	if startStop.StopId == "" || endStop.StopId == "" {
		c.JSON(http.StatusNotFound, nil)
		return
	}

	route := dataStorage.GtfsDataStorage.Routes[routeId]

	if routeId != "" && route.RouteId == "" {
		c.JSON(http.StatusNotFound, nil)
		return
	}

	currentTime := time.Now()
	today := currentTime.Format("20060102")

	distance := 0

	for _, tripId := range dataStorage.ParsedDataStorage.MapStopTimesByDay[today][startStopId] {
		if routeId != "" && dataStorage.GtfsDataStorage.Trips[tripId].RouteId != route.RouteId {
			continue
		}

		startSequence := 0
		endSequence := 0

		for _, stopTime := range dataStorage.GtfsDataStorage.StopTimes[tripId] {
			if stopTime.StopId == startStopId {
				startSequence = int(stopTime.StopSequence)
			}

			if stopTime.StopId == endStopId {
				endSequence = int(stopTime.StopSequence)
			}

			if startSequence > 0 && endSequence > 0 {
				if (endSequence - startSequence) > distance {
					distance = endSequence - startSequence
				}
				break
			}
		}
	}

	response := models.StopDistanceResponse{
		StopDistance: distance,
	}

	c.JSON(http.StatusOK, response)
}

func parseGtfsTime(gtfsDay string, gtfsTime string) (time.Time, error) {
	loc, _ := time.LoadLocation("Europe/Rome")

	parsedDay, _ := time.ParseInLocation("20060102", gtfsDay, loc)
	splittedTime := strings.Split(gtfsTime, ":")

	if len(splittedTime) != 3 {
		return time.Now(), errors.New("malformed time")
	}

	duration, _ := time.ParseDuration(splittedTime[0] + "h" + splittedTime[1] + "m" + splittedTime[2] + "s")

	return parsedDay.Add(duration), nil
}

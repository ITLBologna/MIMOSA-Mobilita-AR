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

package models

type TripsResponse struct {
	Data []TripResponse `json:"data"`
}

type TripResponse struct {
	RouteId       string             `json:"route_id"`
	TripId        string             `json:"trip_id,omitempty"`
	TripHeadsign  string             `json:"trip_headsign,omitempty"`
	TripShortName string             `json:"trip_short_name,omitempty"`
	DirectionId   int                `json:"direction_id"`
	ShapeId       string             `json:"shape_id,omitempty"`
	ShapePolyline string             `json:"shape_polyline,omitempty"`
	Stops         []TripResponseStop `json:"stops"`
}

type TripResponseStop struct {
	StopId        string  `json:"stop_id"`
	StopCode      string  `json:"stop_code,omitempty"`
	StopName      string  `json:"stop_name"`
	StopDesc      string  `json:"stop_desc,omitempty"`
	StopLat       float64 `json:"stop_lat,omitempty"`
	StopLon       float64 `json:"stop_lon,omitempty"`
	ZoneId        string  `json:"zone_id,omitempty"`
	ArrivalTime   string  `json:"arrival_time"`
	DepartureTime string  `json:"departure_time"`
	StopSequence  uint64  `json:"stop_sequence"`
}

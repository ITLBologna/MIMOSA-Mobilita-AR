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

type GtfsTrip struct {
	RouteId              string `json:"route_id"`
	ServiceId            string `json:"service_id,omitempty"`
	TripId               string `json:"trip_id,omitempty"`
	TripHeadsign         string `json:"trip_headsign,omitempty"`
	TripShortName        string `json:"trip_short_name,omitempty"`
	DirectionId          int    `json:"direction_id"`
	BlockId              string `json:"block_id,omitempty"`
	ShapeId              string `json:"shape_id,omitempty"`
	Polyline             string `json:"polyline,omitempty"`
	WheelchairAccessible string `json:"wheelchair_accessible,omitempty"`
	BikesAllowed         string `json:"bikes_allowed,omitempty"`
}

type GtfsStopTime struct {
	TripId            string  `json:"trip_id"`
	ArrivalTime       string  `json:"arrival_time"`
	DepartureTime     string  `json:"departure_time"`
	StopId            string  `json:"stop_id"`
	StopSequence      uint64  `json:"stop_sequence"`
	StopHeadsign      string  `json:"stop_headsign"`
	PickupType        uint64  `json:"pickup_type,omitempty"`
	DropOffType       uint64  `json:"drop_off_type,omitempty"`
	ContinuousPickup  uint64  `json:"continuous_pickup,omitempty"`
	ContinuousDropOff uint64  `json:"continuous_drop_off,omitempty"`
	ShapeDistTraveled float64 `json:"shape_dist_traveled,omitempty"`
	Timepoint         uint64  `json:"timepoint,omitempty"`
}

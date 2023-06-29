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

import "time"

type StopTimeUpdate struct {
	RouteId             string     `json:"route_id"`
	DirectionId         int        `json:"direction_id"`
	TripId              string     `json:"trip_id,omitempty"`
	StartDate           string     `json:"start_date,omitempty"`
	ArrivalTime         *time.Time `json:"arrival_time,omitempty"`
	DepartureTime       *time.Time `json:"departure_time,omitempty"`
	StopId              string     `json:"stop_id"`
	StopSequence        uint64     `json:"stop_sequence,omitempty"`
	VehicleLabel        string     `json:"vehicle_label,omitempty"`
	VehicleLicensePlate string     `json:"vehicle_license_plate,omitempty"`
	Timestamp           uint64     `json:"timestamp,omitempty"`
	LastStopId          string     `json:"last_stop_id,omitempty"`
}

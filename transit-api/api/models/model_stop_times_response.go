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

type StopTimesResponse struct {
	ExpiresAt string             `json:"expires_at"`
	Data      []StopTimeResponse `json:"data"`
}

type StopTimeResponse struct {
	StopId                 string    `json:"stop_id"`
	ScheduledArrivalTime   string    `json:"scheduled_arrival_time,omitempty"`
	LiveArrivalTime        string    `json:"live_arrival_time,omitempty"`
	ScheduledDepartureTime string    `json:"scheduled_departure_time,omitempty"`
	LiveDepartureTime      string    `json:"live_departure_time,omitempty"`
	ArrivalTime            string    `json:"arrival_time,omitempty"`
	DepartureTime          string    `json:"departure_time,omitempty"`
	StopSequence           uint64    `json:"stop_sequence,omitempty"`
	Route                  GtfsRoute `json:"route"`
	Trip                   GtfsTrip  `json:"trip"`
}

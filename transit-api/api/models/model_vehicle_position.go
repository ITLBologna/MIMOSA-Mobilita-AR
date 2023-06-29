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

type VehiclePosition struct {
	Trip            TripResponse `json:"trip"`
	Label           string       `json:"label,omitempty"`
	LicensePlate    string       `json:"license_plate,omitempty"`
	Latitude        float64      `json:"latitude"`
	Longitude       float64      `json:"longitude"`
	Bearing         float64      `json:"bearing,omitempty"`
	Odometer        float64      `json:"odometer,omitempty"`
	Speed           float64      `json:"speed,omitempty"`
	StopId          string       `json:"stop_id,omitempty"`
	CurrentStatus   int          `json:"current_status,omitempty"`
	OccupancyStatus int          `json:"occupancy_status,omitempty"`
	CongestionLevel int          `json:"congestion_level,omitempty"`
	UpdatedAt       string       `json:"updated_at"`
}

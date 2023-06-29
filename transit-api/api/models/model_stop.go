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

type Stop struct {
	StopId string `json:"stop_id"`

	StopCode string `json:"stop_code,omitempty"`

	StopName string `json:"stop_name"`

	StopDesc string `json:"stop_desc,omitempty"`

	StopLat float64 `json:"stop_lat,omitempty"`

	StopLon float64 `json:"stop_lon,omitempty"`

	ZoneId string `json:"zone_id,omitempty"`

	StopUrl string `json:"stop_url,omitempty"`

	LocationType uint64 `json:"location_type,omitempty"`

	ParentStation string `json:"parent_station,omitempty"`

	StopTimezone string `json:"stop_timezone,omitempty"`

	WheelchairBoarding uint64 `json:"wheelchair_boarding,omitempty"`

	LevelId string `json:"level_id,omitempty"`

	PlatformCode string `json:"platform_code,omitempty"`
}

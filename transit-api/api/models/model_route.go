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

type GtfsRoute struct {
	RouteId string `json:"route_id"`

	AgencyId string `json:"agency_id"`

	RouteShortName string `json:"route_short_name"`

	RouteLongName string `json:"route_long_name,omitempty"`

	RouteDesc string `json:"route_desc,omitempty"`

	RouteType string `json:"route_type,omitempty"`

	RouteUrl string `json:"route_url,omitempty"`

	RouteColor string `json:"route_color,omitempty"`

	RouteTextColor string `json:"route_text_color,omitempty"`

	RouteSortOrder uint64 `json:"route_sort_order,omitempty"`

	ContinuousPickup uint64 `json:"continuous_pickup,omitempty"`

	ContinuousDropOff uint64 `json:"continuous_drop_off,omitempty"`
}

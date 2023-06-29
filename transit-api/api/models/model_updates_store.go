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

import (
	"time"
)

type UpdatesStore struct {
	ExpiresAt time.Time `json:"expires_at"`

	Updates   map[string][]StopTimeUpdate `json:"updates"`    // stop_id
	LiveTrips map[string]bool             `json:"live_trips"` // trip_id
}

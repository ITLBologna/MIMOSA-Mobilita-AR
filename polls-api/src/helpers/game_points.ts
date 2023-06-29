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
 * Mimosa API
 *
 *
 * Contact: info@bitapp.it
 */

import axios from 'axios';

export async function  get_points (start_stop_id: string, end_stop_id: string, route_id: string) {
    let stops = 0;
    await axios.get(`${process.env.POINTS_URL}/utils/stops/distance?start_stop_id=${start_stop_id}&end_stop_id=${end_stop_id}&route_id=${route_id}`)
    .then(resp => {
        stops = resp.data.stop_distance;
    });
    if(stops <= 10){
        return stops;
    } else if(stops > 10 && stops <= 20){
        return 10 + ((stops - 10)*0.5);
    } else if(stops > 20){
        return 15 + ((stops - 20)*0.2);
    }
}
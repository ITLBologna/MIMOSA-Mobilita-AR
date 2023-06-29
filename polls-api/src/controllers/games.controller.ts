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

import { Request, Response } from "express";
import { get_points } from "../helpers/game_points.js";
import { get_leaderboard, post_trip } from "../services/games.service.js";
import { get_user, update_user_points } from "../services/users.service.js";

export async function play(req: Request, res: Response) {
    const { user_id, in_stop_id, out_stop_id, otp_first_stop_id, otp_last_stop_id} = req.body;
    let user_item = await get_user(user_id);
    let points;

    if(in_stop_id === otp_first_stop_id && out_stop_id === otp_last_stop_id){
        points = 25;
    } else {
        points = await get_points(in_stop_id, out_stop_id, "") || 0;
    }
    
    if(user_item.Item != undefined){
        let run = await post_trip(user_id, in_stop_id, out_stop_id, points);
        let update = await update_user_points(user_id, points );

        if(run && update){
            res.send( {data: run} );
        } else {
            res.status(400);
        }
    } else {
        res.status(404).send({
            error: 'User not found'
        });
    }
}

export async function leaderboard(req: Request, res: Response) {
    const user_id = req.params.user_id;

    let users = await get_leaderboard(user_id);
    let user_item = await get_user(user_id);

    if(users){
        if(user_item.Item?.gamification_consent){
            res.send({
                data: {
                    "leaderboard": users.leaderboard,
                    "user": {
                        "points": user_item.Item?.points,
                        "rank": users.user_index+1
                    }
                },
            });
        } else {
            res.send({
                data: {
                    "leaderboard": users.leaderboard,
                },
            });
        }
        
    } else {
        res.status(400);
    }
}

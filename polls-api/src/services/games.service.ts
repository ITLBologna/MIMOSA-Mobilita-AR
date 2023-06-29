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

import { GetCommand, PutCommand, ScanCommand, UpdateCommand } from '@aws-sdk/lib-dynamodb';
import { client } from '../helpers/database.js'
import { games, users } from '../index.js';

export async function post_trip(user_id: string, in_stop_id: string, out_stop_id: string, points: number) {

    const runs_params = {
        TableName: games,
        Item: {
            user_id: user_id,
            posix_time: Date.now(),
            in_stop_id: in_stop_id,
            out_stop_id: out_stop_id,
            points: points,
        },
        ReturnValues: 'ALL_OLD'
    }

    try {
        const runs_data = await client.send(new PutCommand(runs_params));
        return runs_params.Item;
    } catch (err) {
        console.log("Error", err);
        return null;
    }
}

export async function get_leaderboard(user_id: string) {
    let i = undefined;

    let params = {
        TableName: users,
        FilterExpression: 'points >= :points ',
        ExpressionAttributeValues: {
            ':points': 0
        }
    }

    try {
        const data = await client.send(new ScanCommand(params));
        let users = data.Items;
        let user_index: any;
        let rank: number = 0;
        users?.sort(function (a, b) {
            if (b.points === a.points) {
                return a.updated_at - b.updated_at;
            }
            return b.points - a.points;
        });
        user_index = users?.findIndex(function (item, i) {
            return item.user_id === user_id
        });
        users = users?.slice(0, 10).map(u => ({ points: u.points, rank: rank += 1 }))


        return {
            "leaderboard": users,
            "user_index": user_index
        };
    } catch (err) {
        console.log("Error", err);
        return null;
    }
}
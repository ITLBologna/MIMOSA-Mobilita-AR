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
import { users_backend } from '../index.js';
import bcrypt from 'bcrypt'
export async function get_user_backend (username: string) {
    let params = {
        TableName: users_backend,
        Key: {
            'username': username,
        },
    }

    try {
        const data = await client.send(new GetCommand(params));
        return data;
    } catch (err) {
        console.log("Error", err);
        throw new Error(err as any);
    }
}

export async function create_user_backend (username: string, password: string) {
    const params = {
        TableName: users_backend,
        Item: {
            username: username.toString(),
            password: (await bcrypt.hash(password, 10)).toString(),
            info : {
                created_at: Date.now(),
                deleted_at: null
            }
        }
    }
    try {
        const data = await client.send(new PutCommand(params));
        return params.Item;
    } catch (err) {
        console.log("Error", err);
    }
}

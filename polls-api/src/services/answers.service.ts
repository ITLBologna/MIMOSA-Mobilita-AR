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
import { pollsAnswers } from '../index.js';

export async function get_answers_by_user_id (user_id: string) {
    let params = {
        TableName: pollsAnswers,
        FilterExpression: 'info.deleted_at = :deleted_at and user_id = :user_id',
        ExpressionAttributeValues: {
            ':deleted_at': null,
            ':user_id': user_id
        }
    }

    try {
        const data = await client.send(new ScanCommand(params));
        return data.Items;
    } catch (err) {
        console.log("Error", err);
    }

}

export async function get_answers_by_poll_id (poll_id: string) {
    let params = {
        TableName: pollsAnswers,
        FilterExpression: 'info.deleted_at = :deleted_at and poll_id = :poll_id',
        ExpressionAttributeValues: {
            ':deleted_at': null,
            ':poll_id': poll_id
        }
    }

    try {
        const data = await client.send(new ScanCommand(params));
        return data.Items;
    } catch (err) {
        console.log("Error", err);
    }

}

export async function get_answers_by_user_id_poll_id (user_id: string, poll_id: string) {
    let params = {
        TableName: pollsAnswers,
        Key: {
            'poll_id': poll_id,
            'user_id': user_id
        }
    }
    try {
        const data = await client.send(new GetCommand(params));
        if (data.Item != undefined && data.Item?.info.deleted_at == null) {
            return data;
        } else {
            return null;
        }
    } catch (err) {
        console.log("Error", err);
    }

}

export async function put_answers (answers : any, poll_id: string, user_id : string) {
        let params = {
            TableName: pollsAnswers,
            Item: {
                poll_id: poll_id,
                user_id: user_id,
                user_answers: answers,
                info: {
                    created_at: Date.now(),
                    update_at: Date.now(),
                    deleted_at: null,
                }
            },
            ReturnValues: 'ALL_OLD'
        }

        try {

            const data = await client.send(new PutCommand(params));
            return data.Attributes;

        } catch (err) {
            console.log("Error", err);
            return null;
        }
}

export async function soft_delete_answers (poll_id: string, user_id : string) {

    let params = {
        TableName: pollsAnswers,
        Key: {
            'poll_id': poll_id,
            'user_id': user_id
        },
        UpdateExpression: 'set info.deleted_at = :r',
        ExpressionAttributeValues: {
            ':r': Date.now()
        },
        ReturnValues: 'ALL_NEW'

    }

    try {
        const data = await client.send(new UpdateCommand(params));
        return data;
    } catch (err) {
        console.log("Error", err);
        return null;
    }
}
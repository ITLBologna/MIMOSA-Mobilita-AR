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
import { show_published_polls } from './polls.service.js';
import { get_answers_by_user_id } from './answers.service.js';
import { users } from '../index.js';


export async function get_user(user_id: string) {
    let params = {
        TableName: users,
        Key: {
            'user_id': user_id,
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

export async function post_user(user_id: string, suggestions_consent: boolean, gamification_consent: boolean, survey_consent: boolean) {
    const params = {
        TableName: users,
        Item: {
            user_id: user_id,
            points: 0,
            created_at: Date.now(),
            updated_at: Date.now(),
            suggestions_consent: suggestions_consent,
            gamification_consent: gamification_consent,
            survey_consent: survey_consent,
        },
        ReturnValues: 'ALL_OLD'
    }
    try {
        const data = await client.send(new PutCommand(params));
        return data.Attributes;
    } catch (err) {
        console.log("Error", err);
    }
}

export async function show_poll(register_date: number, user_id: string) {
    try {
        let published_polls: any = await show_published_polls();
        let answers_by_user_id: any = await get_answers_by_user_id(user_id);


        let find = false;
        for (let i = 0; i < published_polls.length; i++) {
            let published_poll = published_polls[i];

            let showable = register_date + (3600000 * published_poll.time_to_show);
            
            if (showable < Date.now()) {
                find = true;
                if (answers_by_user_id.length > 0) {
                    for (let i = 0; i < answers_by_user_id.length; i++) {
                        let answers = answers_by_user_id[i]
                        if (published_poll.poll_id == answers.poll_id) {
                            find = false;
                            break;
                        }
                    };
                } else {
                    find = true;
                }

            }
            if (find) {
                return published_poll.poll_id;
            }
        }
        if (!find) {
            return null;
        }


    } catch (error) {
        console.log(error);
    }
}

export async function update_user_points(user_id: string, points: number) {
    let user_points = await (await get_user(user_id)).Item?.points;

    let update_points_params = {
        TableName: users,
        Key: {
            'user_id': user_id,
        },
        UpdateExpression: 'set points = :p, updated_at = :r',
        ExpressionAttributeValues: {
            ':p': user_points + points,
            ':r': Date.now()
        },
        ReturnValues: 'ALL_NEW'

    }

    try {

        const update_points_data = await client.send(new UpdateCommand(update_points_params));
        return (update_points_data.Attributes);
    } catch (err) {
        console.log("Error", err);
        return null;
    }
}

export async function update_user_consents(user_id: string, gamification_consent: boolean, suggestions_consent: boolean, survey_consent: boolean) {
    let update_points_params = {
        TableName: users,
        Key: {
            'user_id': user_id,
        },
        UpdateExpression: 'set gamification_consent = :g, suggestions_consent = :s, survey_consent = :sc, updated_at = :r',
        ExpressionAttributeValues: {
            ':g': gamification_consent,
            ':s': suggestions_consent,
            ':sc': survey_consent,
            ':r': Date.now()
        },
        ReturnValues: 'ALL_NEW'

    }

    try {

        const update_points_data = await client.send(new UpdateCommand(update_points_params));
        return (update_points_data.Attributes);
    } catch (err) {
        console.log("Error", err);
        return null;
    }
}
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
import { polls } from '../index.js';

export async function show_published_polls() {
    let params = {
        TableName: polls,
        FilterExpression: 'info.deleted_at = :deleted_at and poll_status = :poll_status',
        ExpressionAttributeValues: {
            ':deleted_at': null,
            ':poll_status': 'published'
        }
    }

    try {
        const data = await client.send(new ScanCommand(params));
        let polls = data.Items;
        polls?.sort( function(a,b){
            return a.time_to_show - b.time_to_show;
        })
        return polls;
    } catch (err) {
        console.log("Error", err);
    }
}

export async function update_is_already_answered(poll_id: string) {

        let params = {
            TableName: polls,
            Key: {
                'poll_id': poll_id,
            },
            UpdateExpression: 'set is_already_answered = :r',
            ExpressionAttributeValues: {
                ':r': true
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

export async function create_poll(poll: any, poll_id: string, created_at: number) {
    let countQuestions = 1;

    poll.questions.forEach((question: any) => {

        question['question_id'] = countQuestions;
        countQuestions++;

        let answers = question.answer_options;
        if (answers != undefined) {
            let countAnswers = 1;

            answers.forEach((answer: any) => {
                answer['answer_option_id'] = countAnswers;
                countAnswers++;
            });
        }
    });

    const params = {
        TableName: polls,
        Item: {
            info: {
                created_at: created_at,
                updated_at: Date.now(),
                deleted_at: null,
            },
            poll_id: poll_id,
            title: poll.title,
            description: poll.description,
            time_to_show: poll.time_to_show,
            questions: poll.questions,
            poll_status: 'draft',
            is_already_answered: false,
        },
        ReturnValues: 'ALL_OLD'
    }

    try {
        const data = await client.send(new PutCommand(params));
        return params.Item;
        //res.send({ data: params.Item });

    } catch (err) {
        console.log("Error", err);
        return null;
    }
}

export async function show_polls () {
    let params = {
        TableName: polls,
        FilterExpression: 'info.deleted_at = :deleted_at',
        ExpressionAttributeValues: {
            ':deleted_at': null,
        }
    }

    try {
        const data = await client.send(new ScanCommand(params));
        return data.Items;
    } catch (err) {
        console.log("Error", err);
    }
}

export async function show_polls_by_status (status: string) {
    let params = {
        TableName: polls,
        FilterExpression: 'info.deleted_at = :deleted_at and poll_status = :poll_status',
        ExpressionAttributeValues: {
            ':deleted_at': null,
            ':poll_status': status
        }
    }

    try {
        const data = await client.send(new ScanCommand(params));
        return data.Items;
    } catch (err) {
        console.log("Error", err);
    }
}

export async function show_poll(poll_id: string) {
    let params = {
        TableName: polls,
        Key: {
            'poll_id': poll_id,
        },
    }

    try {
        const data = await client.send(new GetCommand(params));
        if(data.Item?.info.deleted_at == null){
            return data.Item;
        } else {
            return null;
        }
        
    } catch (err) {
        console.log("Error", err);
        return null;
    }
}

export async function soft_delete_poll (poll_id: string) {

    let params = {
        TableName: polls,
        Key: {
            'poll_id': poll_id,
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

export async function patch_user_status (poll_id: string, poll_status: string) {
        let params = {
            TableName: polls,
            Key: {
                'poll_id': poll_id,
            },
            UpdateExpression: 'set poll_status = :s, info.updated_at = :r',
            ExpressionAttributeValues: {
                ':s': poll_status,
                ':r': Date.now()
            },
            ReturnValues: 'ALL_NEW'

        }

        try {
            const data = await client.send(new UpdateCommand(params));
            return data.Attributes;
        } catch (err) {
            console.log("Error", err);
        }
}
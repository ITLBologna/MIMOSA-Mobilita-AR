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

import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import dotenv from 'dotenv'
import { DynamoDBDocument } from '@aws-sdk/lib-dynamodb';
dotenv.config();

const access_key: any = process.env.ACCESS_KEY_ID
const secret_key: any = process.env.SECRET_ACCESS_KEY
const region: any = process.env.REGION
const dynamo_db_endpoint: string | undefined = process.env.DYNAMO_DB_ENDPOINT
const dynamo_db_port: string | undefined = process.env.DYNAMO_DB_PORT

const getDynamoDbEndpoint = (): string | undefined => {
    if (dynamo_db_endpoint === '' || dynamo_db_endpoint === null || dynamo_db_endpoint === undefined) {
        return;
    }

    return `${dynamo_db_endpoint}${dynamo_db_port !== '' ? `:${dynamo_db_port}` : ''}`;
}

export const client = new DynamoDBClient({
    region: region,
    credentials: {
        accessKeyId: access_key,
        secretAccessKey: secret_key
    },
    //endpoint: getDynamoDbEndpoint()

});

const marshallOptions = {
    removeUndefinedValues: true
}

const ddbDocClient = DynamoDBDocument.from(client, { marshallOptions })
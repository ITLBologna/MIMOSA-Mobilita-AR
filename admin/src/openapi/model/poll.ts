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

/**
 * MIMOSA - API
 * No description provided (generated by Openapi Generator https://github.com/openapitools/openapi-generator)
 *
 * The version of the OpenAPI document: 1.3.0
 * Contact: support@bitapp.it
 *
 * NOTE: This class is auto generated by OpenAPI Generator (https://openapi-generator.tech).
 * https://openapi-generator.tech
 * Do not edit the class manually.
 */
import { Question } from './question';
import { Info } from './info';
import { PollStatusEnum } from './pollStatusEnum';


export interface Poll { 
    readonly poll_id: string;
    title: string;
    description?: string;
    time_to_show: number;
    poll_status?: PollStatusEnum;
    info: Info;
    questions: Array<Question>;
    is_already_answered?: boolean;
}


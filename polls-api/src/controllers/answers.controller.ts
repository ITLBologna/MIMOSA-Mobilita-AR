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
import { validate_token } from "../helpers/validate.js";
import { get_answers_by_user_id_poll_id, put_answers, soft_delete_answers } from "../services/answers.service.js";
import { update_is_already_answered } from "../services/polls.service.js";

export async function get_answers(req: Request, res: Response) {
    const { poll_id, user_id } = req.params;
    const bearer: any = req.headers.bearer;
    let answers = await get_answers_by_user_id_poll_id(user_id, poll_id);

    if (answers) {
        res.send({ data: answers.Item });
    } else {
        res.status(404).send({});
    }


}

export async function post_answers(req: Request, res: Response) {
    const { poll_id, user_id } = req.params;
    const answers = req.body.user_answers;
    const bearer: any = req.headers.bearer;

    if (await get_answers_by_user_id_poll_id(user_id, poll_id) == null) {
        let poll_answers = await put_answers(answers, poll_id, user_id);
        await update_is_already_answered(poll_id);

        res.send({ data: poll_answers });
    } else {
        res.status(400).send({ error: "poll already answered" });
    }



}

export async function delete_answers(req: Request, res: Response) {
    const { poll_id, user_id } = req.params;
    const answers = req.body.answers;
    const bearer: any = req.headers.bearer;

    let data = await soft_delete_answers(poll_id, user_id);

    if (!validate_token(bearer)) {
        res.sendStatus(401);
    } else if (!data) {
        res.sendStatus(404);
    } else {
        res.sendStatus(200);
    }
}
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
import { create_poll, patch_user_status, show_poll, show_polls, show_polls_by_status, soft_delete_poll } from "../services/polls.service.js";
import { is_empty, is_not_empty } from "../helpers/empty_functions.js";
import { get_answers_by_poll_id, get_answers_by_user_id, get_answers_by_user_id_poll_id } from "../services/answers.service.js";
import { convertArrayToCSV } from "convert-array-to-csv";
import crypto from "crypto";
import { get_user } from "../services/users.service.js";

export async function post_poll(req: Request, res: Response) {
    const poll = req.body;
    const bearer: any = req.headers.bearer;
    if (!validate_token(bearer)) {
        res.sendStatus(401);
    } else {
        const poll_id = crypto.randomUUID();
        const created_at = Date.now();
        let data = await create_poll(poll, poll_id, created_at);

        if (data != null) {
            res.status(200).send({ data: data })
        } else {
            res.status(400);
        }
    }
}

export async function get_polls(req: Request, res: Response) {
    const { poll_status }: any = req.query;
    const bearer: any = req.headers.bearer;
    let polls: any;

    if (!validate_token(bearer)) {
        res.sendStatus(401);
    } else {
        if (is_not_empty(poll_status)) {
            polls = await show_polls_by_status(poll_status);
        } else {
            polls = await show_polls();
        }

        res.send({ data: polls });
    }


}

export async function get_poll_by_id(req: Request, res: Response) {
    const poll_id = req.params.poll_id;
    // const bearer: any = req.headers.bearer;

    // if (!validate_token(bearer)) {
    //     res.sendStatus(401);
    // } else {
    let poll = await show_poll(poll_id);

    if (is_not_empty(poll)) {
        res.send({ data: poll })
    } else {
        res.sendStatus(404);
    }
    // }


}

export async function get_unanswered_poll(req: Request, res: Response) {
    const { poll_id, user_id } = req.params;
    let poll = await show_poll(poll_id);
    let user = await get_user(user_id);

    if (is_not_empty(poll) && is_not_empty(user.Item)) {
        let answers = await get_answers_by_user_id_poll_id(user_id, poll_id);
        if (answers == null) {
            res.send({ data: poll })
        } else {
            res.sendStatus(409);
        }
    } else {
        res.sendStatus(404);
    }

}

export async function delete_poll(req: Request, res: Response) {
    const { poll_id } = req.params;
    const bearer: any = req.headers.bearer;

    let data = await soft_delete_poll(poll_id);

    if (!validate_token(bearer)) {
        res.sendStatus(401);
    } else if (is_not_empty(data)) {
        res.sendStatus(200);
    } else {
        res.sendStatus(404);
    }
}

export async function put_poll(req: Request, res: Response) {
    const poll_id = req.params.poll_id;
    const poll = await show_poll(poll_id);
    const new_poll = req.body;
    const bearer: any = req.headers.bearer;

    if (!validate_token(bearer)) {
        res.sendStatus(401);
    } else {
        let data = await create_poll(new_poll, poll_id, poll?.info.created_at);

        if (data != null) {
            res.status(200).send({ data: data })
        } else {
            res.status(400);
        }
    }
}

export async function update_status(req: Request, res: Response) {
    const bearer: any = req.headers.bearer;
    const new_status = req.body.poll_status;
    const poll_id = req.params.poll_id;
    const poll_item = await show_poll(poll_id);

    if (!validate_token(bearer)) {
        res.sendStatus(401);
    } else if (is_not_empty(poll_item)) {
        let old_status = poll_item?.poll_status;
        if (old_status == 'draft' && new_status == 'published') {
            patch_user_status(poll_id, new_status);
            res.status(200).send({ data: { new_status } });
        }
        else if (old_status == 'published' && (new_status == 'closed')) {
            patch_user_status(poll_id, new_status);
            res.status(200).send({ data: { new_status } });
        }
        else if (old_status == 'closed' && new_status == 'published') {
            patch_user_status(poll_id, new_status);
            res.status(200).send({ data: { new_status } });
        }
        else if (old_status == 'published' && new_status == 'draft') {
            if (poll_item?.is_already_answered == false) {
                patch_user_status(poll_id, new_status);
                res.status(200).send({ data: { new_status } });
            } else {
                res.sendStatus(400);
            }
        } else {
            res.sendStatus(400);
        }
    } else {
        res.sendStatus(404);
    }
}

export async function export_poll(req: Request, res: Response) {
    const bearer: any = req.headers.bearer;

    if (!validate_token(bearer)) {
        res.sendStatus(401);
    } else {
        const poll_id = req.params.poll_id;
        const items = (await get_answers_by_poll_id(poll_id));
        console.log(items);
        const poll = (await show_poll(poll_id));
        let headers: string[] = ['User_ID'];
        let rows: string[][] = [];

        poll?.questions.forEach(function (item: any) {
            headers.push(item.text);
        });

        items?.forEach(function (item: any) {
            let answers: string[] = [];
            answers.push(item.user_id)

            item.user_answers.forEach(function (item: any) {
                if (item.answer_option_id != undefined) {
                    answers.push(String(item.answer_option_id));
                } else if (item.answer_option_ids != undefined) {
                    answers.push(String(item.answer_option_ids))
                } else {
                    answers.push(item.answer_text)
                }
            })
            rows.push(answers);
        })

        const csvFromArrayOfArrays = convertArrayToCSV(rows, {
            header: headers,
            separator: ','
        });

        res.setHeader("Content-Type", "text/csv");
        res.setHeader("Content-Disposition", "attachment; filename=users_answers.csv");
        res.setHeader("Access-Control-Expose-Headers", "Content-Disposition");
        res.status(200).end(csvFromArrayOfArrays);
    }
}

export async function report_poll(req: Request, res: Response) {
    const bearer: any = req.headers.bearer;

    if (!validate_token(bearer)) {
        res.sendStatus(401);
    } else {
        const poll_id = req.params.poll_id;
        const poll_item = await show_poll(poll_id);

        if (Object.keys(poll_item ?? {}).length == 0) {
            res.sendStatus(404);
            return;
        }

        const user_answers = await get_answers_by_poll_id(poll_id);

        if (Object.keys(user_answers ?? {}).length == 0) {
            res.sendStatus(404);
            return;
        }

        type CloseAnswer = {
            answer_option_id: number,
            answer_option_text: string,
            number_of_answers: number
        }

        type FreeTextAnswer = {
            answer_text: string
        }

        type MultipleAnswer = {
            answer_option_id: number,
            answer_option_text: string,
            number_of_answers: number
        }

        type Question = {
            question_id: number,
            question_text: string,
            question_type: string,
            closed_answers: CloseAnswer[],
            free_answers: FreeTextAnswer[],
            multiple_answers: MultipleAnswer[]
        }

        let reports: Question[] = [];

        //made response
        poll_item?.questions.forEach(function (question: any) {
            let closed_answers: CloseAnswer[] = [];
            let free_answers: FreeTextAnswer[] = [];
            let multiple_answers: MultipleAnswer[] = [];

            let question_item = {

                question_id: question.question_id,
                question_text: question.text,
                question_type: question.question_type,
                closed_answers: closed_answers,
                free_answers: free_answers,
                multiple_answers: multiple_answers
            }

            if (question.question_type != 'free_answer') {

                question.answer_options.forEach(function (item: any) {

                    let answer = {
                        answer_option_id: item.answer_id,
                        answer_option_text: item.text,
                        number_of_answers: 0
                    }
                    if (question.question_type == 'closed_answer')
                        closed_answers.push(answer);
                    if (question.question_type == 'multiple_answer')
                        multiple_answers.push(answer);
                })
            }

            reports.push(question_item);
        })


        //add statistics to response
        let poll_completed = 0;
        user_answers?.forEach(function (item: any) {

            poll_completed++;

            item.user_answers.forEach(function (item: any) {
                if (item.answer_option_id != undefined) {
                    reports[item.question_id - 1].closed_answers[item.answer_option_id - 1].number_of_answers += 1;
                } else if (item.answer_text != undefined) {
                    let answer = {
                        answer_text: String(item.answer_text)
                    }
                    reports[item.question_id - 1].free_answers.push(answer);
                } else if (item.answer_option_ids != undefined) {
                    item.answer_option_ids.forEach(function (value: any) {
                        reports[item.question_id - 1].multiple_answers[value - 1].number_of_answers += 1;
                    })
                }
            })
        })
        const response = {
            data: {
                title: poll_item?.title,
                description: poll_item?.description,
                poll_completed: poll_completed,
                poll_status: poll_item?.poll_status,
                reports: reports
            }
        }
        res.send(response);
    }
}
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

import express from 'express'
import { delete_answers, get_answers, post_answers } from './controllers/answers.controller.js';
import { leaderboard, play } from './controllers/games.controller.js';
import { delete_poll, export_poll, get_polls, get_poll_by_id, post_poll, put_poll, report_poll, update_status, get_unanswered_poll } from './controllers/polls.controller.js';
import { access_user, suggestions } from "./controllers/users.controller.js";
import { auth, register_user } from "./controllers/backend-users.controller.js";

const router = express.Router();

//users
router.post("/user/access", access_user);
router.get("/users/:user_id/suggestions", suggestions);

//answers
router.get('/users/:user_id/polls/:poll_id', get_answers);
router.post('/users/:user_id/polls/:poll_id', post_answers);
router.delete('/users/:user_id/polls/:poll_id', delete_answers);

//games
router.post('/play', play);
router.get('/leaderboard/:user_id', leaderboard);

//polls
router.post('/polls', post_poll);
router.get('/polls', get_polls);
router.get('/polls/:poll_id', get_poll_by_id);
router.delete('/polls/:poll_id', delete_poll);
router.put('/polls/:poll_id', put_poll);
router.patch('/polls/:poll_id/status', update_status);
router.get('/polls/:poll_id/users/:user_id', get_unanswered_poll);

//export
router.get('/polls/:poll_id/answers/export', export_poll);

//report
router.get('/polls/:poll_id/report', report_poll);

//auth
router.post('/login', auth);
router.post('/register', register_user);


export default router;

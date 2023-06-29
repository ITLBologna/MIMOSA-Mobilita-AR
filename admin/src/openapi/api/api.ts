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

export * from './auth.service';
import { AuthService } from './auth.service';
export * from './game.service';
import { GameService } from './game.service';
export * from './pollReplies.service';
import { PollRepliesService } from './pollReplies.service';
export * from './polls.service';
import { PollsService } from './polls.service';
export * from './report.service';
import { ReportService } from './report.service';
export const APIS = [AuthService, GameService, PollRepliesService, PollsService, ReportService];

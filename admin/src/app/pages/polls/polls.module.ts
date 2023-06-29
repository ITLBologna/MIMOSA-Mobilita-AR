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

import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { PollsRoutingModule } from './polls-routing.module';
import { PollsComponent } from './components/polls/polls.component';
import { SharedModule } from 'src/app/shared/shared.module';
import { PollFormComponent } from './components/poll-form/poll-form.component';
import { PollDetailComponent } from './components/poll-detail/poll-detail.component';
import { PollStatisticsComponent } from './components/poll-statistics/poll-statistics.component';


@NgModule({
  declarations: [
    PollsComponent,
    PollFormComponent,
    PollDetailComponent,
    PollStatisticsComponent
  ],
  imports: [
    CommonModule,
    PollsRoutingModule,
    SharedModule
  ]
})
export class PollsModule { }

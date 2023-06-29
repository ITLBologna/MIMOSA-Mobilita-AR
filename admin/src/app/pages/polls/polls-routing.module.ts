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

import { PollStatisticsComponent } from './components/poll-statistics/poll-statistics.component';
import { PollDetailComponent } from './components/poll-detail/poll-detail.component';
import { PollsComponent } from './components/polls/polls.component';
import { PollFormComponent } from './components/poll-form/poll-form.component';
import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';

const routes: Routes = [
  {
    path: '',
    component: PollsComponent,  
  },
  {
    path: 'new',
    component: PollFormComponent,
  },
  {
    path: ':pollId',
    component: PollDetailComponent,
  },
  {
    path: ':pollId/edit',
    component: PollFormComponent,
  },
  {
    path: ':pollId/statistics',
    component: PollStatisticsComponent,
  }
];

@NgModule({
  imports: [RouterModule.forChild(routes)],
  exports: [RouterModule]
})
export class PollsRoutingModule { }

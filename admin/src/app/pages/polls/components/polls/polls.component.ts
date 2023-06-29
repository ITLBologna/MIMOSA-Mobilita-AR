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

import { Column } from 'src/app/shared/interfaces/column';
import { Component, OnInit, TemplateRef, ViewChild } from '@angular/core';
import { Poll, PollsService, PollStatusEnum } from 'src/openapi';
import { PollStatusPipe } from 'src/app/pipes/poll-status.pipe';

@Component({
  selector: 'app-polls',
  templateUrl: './polls.component.html',
  styleUrls: ['./polls.component.scss'],
})
export class PollsComponent implements OnInit {
  pollsData: Poll[] = [];
  filterStatus: PollStatusEnum|undefined = undefined;

  @ViewChild('svgEdit', { static: true }) svgEdit: TemplateRef<any> | undefined
  @ViewChild('svgStatistics', { static: true }) svgStatistics: TemplateRef<any> | undefined
  @ViewChild('svgViewDetail', { static: true }) svgViewDetail: TemplateRef<any> | undefined

  constructor(
    private pollsService: PollsService,
    private pollStatusPipe: PollStatusPipe 
    ) {}

  ngOnInit() {
    this.getData();
  }

  getData() {
    this.pollsService.pollsGet(this.filterStatus).subscribe({
      next: (response) => {
        this.pollsData = response.data
      },
      error: (error) => {
        console.log('error', error);
      }
    });
  }

  cleanFilter() {
    this.filterStatus = undefined;
    this.getData();
  }

  tableColumns: Array<Column> = [
    {
      columnDef: 'title',
      header: 'Titolo',
      cell: (poll: Record<string, any>) => `${poll['title']}`,
      isLink: true,
      url: (poll: Record<string, any>) => `${poll['poll_id']}`,
    },
    {
      columnDef: 'descritpion',
      header: 'Descrizione',
      cell: (poll: Record<string, any>) => `${poll['description']}`,
    },
    {
      columnDef: 'time_to_show',
      header: 'Tempo',
      cell: (poll: Record<string, any>) => `${poll['time_to_show']}`,
    },
    {
      columnDef: 'status',
      header: 'Stato',
      cell: (poll: Record<string, any>) => this.pollStatusPipe.transform(poll['poll_status']),
    },
    {
      columnDef: 'action',
      header: 'Azioni',
      cell: (poll: Record<string, any>) => poll['poll_status'] === 'draft' ? this.svgEdit : this.svgStatistics,
      isTemplate: (poll: Record<string, any>) => true,
      isLink: true,
      url: (poll: Record<string, any>) => poll['poll_status'] === 'draft' ? `${poll['poll_id']}/edit` : `${poll['poll_id']}/statistics`
     },
     {
      columnDef: 'detail',
      header: 'Dettaglio',
      cell: (poll: Record<string, any>) => this.svgViewDetail,
      isTemplate: (poll: Record<string, any>) => true,
      isLink: true,
      url: (poll: Record<string, any>) => `${poll['poll_id']}`
     }
  ];
}

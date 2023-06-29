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

import { HttpClient, HttpHeaders } from '@angular/common/http';
import { Component, OnInit } from '@angular/core';
import { EnvService } from 'src/app/env.service';
import { Column } from 'src/app/shared/interfaces/column';

@Component({
  selector: 'app-users',
  templateUrl: './users.component.html',
  styleUrls: ['./users.component.scss']
})
export class UsersComponent implements OnInit {
  usersData: any[] = [];

  constructor(
    private http: HttpClient,
    private env: EnvService
  ) {}

  ngOnInit(): void {
    this.getData();
  }

  getData() {
    const basePath = this.env.API_BASE_PATH_TRACKINGDATA;
    const token = localStorage.getItem('currentToken');

    // API Call
    let headers: HttpHeaders = new HttpHeaders();
    headers = headers.set( 'Bearer',`${token}`);

    this.http
    .get<any>(`${basePath}/users`, {
      headers: headers
    })
    .subscribe(users => {
      this.usersData = users.data;
    });
  }

  columns: Array<Column> = [
    {
      columnDef: 'user',
      header: 'Utente',
      cell: (user: Record<string, any>) => user['user_id'],
      isLink: true,
      url: (poll: Record<string, any>) => `${poll['user_id']}`,
    },
    {
      columnDef: 'date',
      header: 'Data ultima registrazione',
      cell: (user: Record<string, any>) => (new Date(user['last_posixtime'])).toLocaleDateString('it-IT', { timeZone: 'Europe/Rome', year: 'numeric', month: '2-digit', day: '2-digit' }) ,
    }
  ];
}

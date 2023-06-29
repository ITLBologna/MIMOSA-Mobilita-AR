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

import { Injectable } from '@angular/core';
import {
  HttpRequest,
  HttpHandler,
  HttpEvent,
  HttpInterceptor
} from '@angular/common/http';
import { Observable, throwError } from 'rxjs';
import { catchError } from 'rxjs/operators';


@Injectable()
export class ErrorInterceptor implements HttpInterceptor {

  constructor() {}

  intercept(request: HttpRequest<any>, next: HttpHandler): Observable<HttpEvent<any>> {
    // Global.isInMaintenanceMode = false;
    return next.handle(request).pipe(
      catchError((err) => {

        if (err.status === 503) {
          console.log('error 503');
        } else if (err.status === 401) {

          // auto logout if 401 response returned from api
          localStorage.removeItem('currentToken');
          // sessionStorage.removeItem('currentToken');

          localStorage.setItem('sessionExpired', 'true');
          // tslint:disable-next-line: deprecation
          setTimeout(function(){
            location.reload();
         }, 3000);
          // location.reload();
        }
        return throwError(err);
      })
    );
  }
}

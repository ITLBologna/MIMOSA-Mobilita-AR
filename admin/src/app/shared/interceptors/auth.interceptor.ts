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
import { Observable } from 'rxjs';

@Injectable()
export class AuthInterceptor implements HttpInterceptor {

  constructor() {}

  intercept(request: HttpRequest<unknown>, next: HttpHandler): Observable<HttpEvent<unknown>> {
    const basePath: string = (window as any).__env.API_BASE_PATH;
    if (request.url.toLowerCase().includes(basePath.toLowerCase())) {
      const token = this.currentToken();

      if (token) {
        return next.handle(
          request.clone({
            setHeaders: { bearer: token },
          })
        );
      }
    }
    return next.handle(request);
  }

  currentToken(): string | null {
    const token = localStorage.getItem('currentToken');

    if (token && token.length > 0) {
      return token;
    } else {
      localStorage.removeItem('currentToken');
      // sessionStorage.removeItem('currentToken');
      // tslint:disable-next-line: deprecation
      // location.reload(true);
      return null;
    }
  }
}

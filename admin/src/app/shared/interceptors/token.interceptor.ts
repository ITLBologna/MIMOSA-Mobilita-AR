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
import { HttpRequest, HttpHandler, HttpEvent, HttpInterceptor } from '@angular/common/http';
import { Observable } from 'rxjs';
import { EnvService } from 'src/app/env.service';

@Injectable({
    providedIn: 'root',
  })
export class TokenInterceptor implements HttpInterceptor {

    constructor(
        private env: EnvService,
    ) {}

    intercept(request: HttpRequest<unknown>, next: HttpHandler): Observable<HttpEvent<unknown>> {

        const basePath = this.env.API_BASE_PATH;
        
        if (request.url.toLowerCase().includes(basePath.toLowerCase())) {
            const token = '8dba8bccd84b69165aea3480745a23e0e0f9ced4e04efed52c857fad6c62173292ec742fff13593e7b5999dc2177032f4ce3759658645037367db7ba52f0cb69';
            return next.handle(
                request.clone({
                setHeaders: { bearer: token },
                })
            ); 
        }
        return next.handle(request);
    }
}
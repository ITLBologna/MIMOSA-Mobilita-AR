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
import { BehaviorSubject, map, Observable } from 'rxjs';
import { AuthService, LoginRequest } from 'src/openapi';

@Injectable({
  providedIn: 'root'
})
export class AuthenticationService {

  private currentTokenSubject!: BehaviorSubject<string | null>;

  public get currentToken(): string | null {
    return this.currentTokenSubject.value;
  }

  constructor(
    private authService: AuthService
  ) {
    try {
      const currentToken: string | null = localStorage.getItem('currentToken');
      this.currentTokenSubject = new BehaviorSubject<string | null>(currentToken);
    } catch (error) {
      localStorage.setItem('sessionExpired', 'true');
      localStorage.removeItem('currentToken');
      location.reload();
    }
  }

  login(username: string, password: string, remember: boolean): Observable<string> {

    const request: LoginRequest = {
      username,
      password
    };

    return this.authService.loginPost(request).pipe(
      map(
        (response) => {
          const token = response.token;
          if (token) {
            // store user details and jwt token in local storage to keep user logged in between page refreshes
            localStorage.setItem('currentToken', token);

            this.currentTokenSubject.next(token);

          }

          return token;
        },
        (error: any) => {
          console.error('authentication service',error);

          return error;
        }
      )
    );
  }

  logout(): void {
    //console.log('Logging out...');
    // remove user from local storage to log user out
    localStorage.removeItem('currentToken');
    // sessionStorage.removeItem('currentToken');
    // this.currentTokenSubject.next(null);
  }
}

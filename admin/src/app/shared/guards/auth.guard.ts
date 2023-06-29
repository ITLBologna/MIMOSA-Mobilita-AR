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
import { ActivatedRouteSnapshot, CanActivate, Router, RouterStateSnapshot, UrlTree } from '@angular/router';
import { Observable } from 'rxjs';
import { AuthenticationService } from '../services/authentication.service';

@Injectable({
  providedIn: 'root'
})
export class AuthGuard implements CanActivate {

  constructor(
    private router: Router,
    private authenticationService: AuthenticationService
  ) {}

  canActivate(
    route: ActivatedRouteSnapshot, state: RouterStateSnapshot): Observable<boolean | UrlTree> | Promise<boolean | UrlTree> | boolean | UrlTree {

      const currentToken = this.authenticationService.currentToken;
      if (currentToken) {
        try {
          const tokenData = JSON.parse(atob(currentToken.split('.')[1]));
          if (tokenData.exp * 1000 < Date.now()) {
            this.authenticationService.logout();
            localStorage.setItem('sessionExpired', 'true');
            location.reload();
            return false;
          }
        } catch (error) {
          console.log(error);
          this.authenticationService.logout();
          localStorage.setItem('sessionExpired', 'true');
          location.reload();
          return false;
        }



        return true;
      }


      this.router.navigate(['/login']);
      return false;
  }

}

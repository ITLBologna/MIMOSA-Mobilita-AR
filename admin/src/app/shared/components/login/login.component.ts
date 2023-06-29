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

import { Component, OnInit } from '@angular/core';
import { FormGroup, FormBuilder, Validators, AbstractControl } from '@angular/forms';
import { ActivatedRoute, Router } from '@angular/router';
import { Message, MessagesService } from '../../messages/messages.service';
import { AuthenticationService } from '../../services/authentication.service';

@Component({
  selector: 'app-login',
  templateUrl: './login.component.html',
  styleUrls: ['./login.component.scss']
})
export class LoginComponent implements OnInit {
  loginForm!: FormGroup;
  loading = false;
  submitted = false;
  errors: any = {};
  returnUrl: string = '';

  // convenience getter for easy access to form fields
  get f(): { [key: string]: AbstractControl } {
    return this.loginForm.controls;
  }

  constructor(
    private formBuilder: FormBuilder,
    private messagesService: MessagesService,
    private authenticationService: AuthenticationService,
    private router: Router,
    private route: ActivatedRoute
  ) {}

  ngOnInit() {
    this.loginForm = this.formBuilder.group({
      username: ['', [Validators.required]],
      password: ['', Validators.required],
      // remember: [true],
    });

    // eslint-disable-next-line eqeqeq
    if (localStorage.getItem('sessionExpired') == 'true') {
      localStorage.removeItem('sessionExpired');
    }
  }

  login(): void {
    this.submitted = true;

    // stop here if form is invalid
    if (this.loginForm.invalid) {
      return;
    }

    this.loading = true;

    this.authenticationService
      .login(
        this.f['username'].value,
        this.f['password'].value,
        true // this.f.remember.value
      )
      .subscribe(
        (response) => {
          this.router.navigate(['polls']);
          this.messagesService.addMessage(new Message('Login effetuato correttamente.', 5000, 'default'));
          this.loading = false;
        },
        (error) => {
          this.loading = false;
          let errorMsg = 'Si è verificato un errore';

          if (error && error.error && error.error.data.error) {
            switch (error.error.data.error) {
              case 'Invalid credentials':

                errorMsg = 'Credenziali non valide.';
                break;

              default:
                break;
            }
          }

          if (error && error.error && error.error.errors) {
            this.errors = error.error.errors;
          }

          this.messagesService.addMessage(new Message(errorMsg, 5000, 'error'));
        }
      );
  }

}

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

import { MessagesModule } from './messages/messages.module';
import { FormsModule, ReactiveFormsModule } from '@angular/forms';
import { RouterModule } from '@angular/router';
import { MatTableModule } from '@angular/material/table';
import { MatButtonModule } from '@angular/material/button';
import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { TableComponent } from './components/table/table.component';
import { MatFormFieldModule } from '@angular/material/form-field';
import { PipesModule } from '../pipes/pipes.module';
import { LoginComponent } from './components/login/login.component';
import { MenuComponent } from './components/menu/menu.component';
import {MatTabsModule} from '@angular/material/tabs';

@NgModule({
  declarations: [
    TableComponent,
    LoginComponent,
    MenuComponent,
  ],
  imports: [
    CommonModule,
    MatTableModule,
    RouterModule,
    MatButtonModule,
    FormsModule,
    MatFormFieldModule,
    ReactiveFormsModule,
    PipesModule,
    MessagesModule,
    MatTabsModule
  ],
  exports: [
    RouterModule,
    TableComponent,
    MatTableModule,
    FormsModule,
    MatFormFieldModule,
    MatButtonModule,
    ReactiveFormsModule,
    PipesModule,
    MessagesModule,
    LoginComponent,
    MenuComponent,
    MatTabsModule
  ]
})
export class SharedModule { }

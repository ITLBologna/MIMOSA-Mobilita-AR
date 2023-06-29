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

import { EnvServiceProvider } from './env.service.provider';
import { ApiModule } from './../openapi/api.module';
import { NgModule } from '@angular/core';
import { BrowserModule } from '@angular/platform-browser';
import { AppRoutingModule } from './app-routing.module';
import { AppComponent } from './app.component';
import { BrowserAnimationsModule } from '@angular/platform-browser/animations';
import { SharedModule } from './shared/shared.module';
import { HttpClientModule } from '@angular/common/http'
import { FormsModule } from '@angular/forms';
import { interceptorProviders } from './shared/interceptors/interceptors';
import { Configuration, ConfigurationParameters } from 'src/openapi';
import { PipesModule } from './pipes/pipes.module';


export function apiConfiguration(): Configuration {
  const params: ConfigurationParameters = {
    basePath: (window as {[key: string]: any })['__env'].API_BASE_PATH,
  };
  return new Configuration(params);
}

@NgModule({
  declarations: [
    AppComponent,
  ],
  imports: [
    BrowserModule,
    AppRoutingModule,
    BrowserAnimationsModule,
    SharedModule,
    HttpClientModule,
    FormsModule,
    ApiModule.forRoot(apiConfiguration),
    PipesModule,
   
  ],
  providers: [
    interceptorProviders,
    EnvServiceProvider,
  ],
  bootstrap: [AppComponent]
})
export class AppModule { }

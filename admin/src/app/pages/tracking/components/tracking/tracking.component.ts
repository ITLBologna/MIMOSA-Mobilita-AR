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
import { ActivatedRoute } from '@angular/router';
import mapboxgl, { GeoJSONSource } from 'mapbox-gl';
import { EnvService } from 'src/app/env.service';
import { MapboxService } from 'src/app/shared/services/mapbox.service';
import { environment } from 'src/environment/environment';

@Component({
  selector: 'app-tracking',
  templateUrl: './tracking.component.html',
  styleUrls: ['./tracking.component.scss']
})
export class TrackingComponent implements OnInit {

  map!: mapboxgl.Map;
  style = 'mapbox://styles/mapbox/streets-v11';
  lat = 44.4949;
  lng =  11.3426;

  userGeoJsonData: any;
  userId: number | undefined;

  constructor(
    private mapboxService: MapboxService,
    private http: HttpClient,
    private env: EnvService,
    private activatedRoute: ActivatedRoute
  ) {
    this.activatedRoute.params.subscribe((params) => {
      this.userId = params['userId'];
    });
  }

  ngOnInit() {
    this.getTrackingData();
  }

  getTrackingData() {
    const basePath = this.env.API_BASE_PATH_TRACKINGDATA;
    const token = localStorage.getItem('currentToken');

    // API Call
    let headers: HttpHeaders = new HttpHeaders();
    headers = headers.set( 'Bearer',`${token}`);

    // chiamata per avere le coordinate di uno user
    this.http
      .get<any>(`${basePath}/data/${this.userId}`, {
        headers: headers
      })
      .subscribe(data => {
        this.userGeoJsonData = data.data;
      });

  // mappa si apre a Bologna
    mapboxgl.accessToken = environment.mapbox.accessToken;
      this.map = new mapboxgl.Map({
        container: 'map',
        style: this.style,
        zoom: 13,
        center: [this.lng, this.lat]
    });
  // Add map controls
    this.map.addControl(new mapboxgl.NavigationControl());

  // load layer with geoJson data inline
    this.map.on('load', () => {
      this.map.addSource('tracking-data', {
        type: 'geojson',
        data: this.userGeoJsonData,
      });

        this.map.addLayer({
          'id': 'tracking-layer',
          'type': 'circle',
          'source': 'tracking-data',
          'paint': {
          'circle-radius': 4,
          'circle-stroke-width': 2,
          'circle-color': 'red',
          'circle-stroke-color': 'white'
          }
        });
    });
  }
}

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
 * Mimosa APP
 *
 *
 * Contact: info@bitapp.it
 *
 */

import 'dart:convert';

class RequestParameters {
	String? mode;
	String? arriveBy;
	String? minTransferTime;
	String? showIntermediateStops;
	String? fromPlace;
	String? toPlace;
	String? weelchair;
	String? locale;

	RequestParameters({
		this.mode, 
		this.arriveBy, 
		this.minTransferTime, 
		this.showIntermediateStops, 
		this.fromPlace, 
		this.toPlace, 
		this.weelchair, 
		this.locale, 
	});

	static RequestParameters fromMap(Map<String, dynamic> map) {
		return RequestParameters(
			mode: map['mode'],
			arriveBy: map['arriveBy'],
			minTransferTime: map['minTransferTime'],
			showIntermediateStops: map['showIntermediateStops'],
			fromPlace: map['fromPlace'],
			toPlace: map['toPlace'],
			weelchair: map['weelchair'],
			locale: map['locale'],
		);
	}

	static RequestParameters fromJson(String data) {
		return RequestParameters.fromMap(json.decode(data) as Map<String, dynamic>);
	}
}

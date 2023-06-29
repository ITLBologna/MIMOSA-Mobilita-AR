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

import { Component, Input, OnInit } from '@angular/core';
import { Message } from '../messages.service';

@Component({
  selector: 'app-message',
  templateUrl: './message.component.html',
  styleUrls: ['./message.component.scss']
})
export class MessageComponent implements OnInit {
  @Input() message: Message | undefined;
  displayMessage = true;

  constructor() { }

  ngOnInit() {
    console.log(this.message?.type);
    if (this.message?.timeout != null) {
      setTimeout(() => {
        this.displayMessage = false;
      }, this.message.timeout);
    }
  }

  close(event: MouseEvent) {
    this.displayMessage = false;
  }
}

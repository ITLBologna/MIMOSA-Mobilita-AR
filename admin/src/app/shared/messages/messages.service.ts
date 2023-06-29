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

import { EventEmitter, Injectable } from '@angular/core';

export class Message {
  text: string;
  timeout: number;
  type?: string;

  constructor (text: string, timeout: number, type: string) {
    this.text = text;
    this.timeout = timeout;
    this.type = type;
  }
}

@Injectable({
  providedIn: 'root'
})

export class MessagesService {
  private messages: Message[] = [];
  updatedMessages = new EventEmitter<void>();
  cleanedMessages = new EventEmitter<void>();

  constructor() { }

  addMessage(message: Message, propagate: boolean = true) {
    this.messages.push(message);
    if (propagate) {
      this.updatedMessages.emit();
    }
  }

  getMessages(): Message[] {
    const messages = this.messages;
    this.messages = [];

    return messages;
  }

  refresh() {
    this.updatedMessages.emit();
    this.cleanedMessages.emit();
  }

}

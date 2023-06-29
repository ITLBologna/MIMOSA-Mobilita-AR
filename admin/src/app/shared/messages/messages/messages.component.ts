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

import { Message, MessagesService } from '../messages.service';
import { Component, OnDestroy, OnInit } from '@angular/core';

@Component({
  selector: 'app-messages',
  templateUrl: './messages.component.html',
  styleUrls: ['./messages.component.scss']
})
export class MessagesComponent implements OnInit, OnDestroy {
  messages: Message[] = [];
    private subscription: any;
    private subscriptionClean: any;

    constructor(private messagesService: MessagesService) { }

    ngOnInit() {
      this.messages = this.messagesService.getMessages();

      this.subscription = this.messagesService.updatedMessages.subscribe(event => {
          this.messages.push(...this.messagesService.getMessages());
      });

      this.subscriptionClean = this.messagesService.cleanedMessages.subscribe(event => {
          this.messages = [];
      });
  }

  ngOnDestroy() {
    if (this.subscription) {
        this.subscription.unsubscribe();
    }

    if (this.subscriptionClean) {
        this.subscriptionClean.unsubscribe();
    }
}
}

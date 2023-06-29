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
import { ActivatedRoute, Router } from '@angular/router';
import { Message, MessagesService } from 'src/app/shared/messages/messages.service';
import { Poll, PollsService, PollStatusEnum, PollStatusRequest } from 'src/openapi';


@Component({
  selector: 'app-poll-detail',
  templateUrl: './poll-detail.component.html',
  styleUrls: ['./poll-detail.component.scss']
})
export class PollDetailComponent implements OnInit {

  pollId: string = '';
  poll: Poll | undefined;
  statusRequest: PollStatusRequest = { poll_status: PollStatusEnum.Draft};
  visibleIndex = -1;
  visibleArray: number[] = [];

  constructor(
    private pollsService: PollsService,
    private activatedRoute: ActivatedRoute,
    private router: Router,
    private messagesService: MessagesService,
  ) {
    this.activatedRoute.params.subscribe((params) => {
      this.pollId = params['pollId'];
      this.getData(this.pollId);
    });
  }

  ngOnInit(): void {}

  getData(id: string) {
    this.pollsService.pollsPollIdGet(id).subscribe({
      next: (response) => (this.poll = response.data),
      error: (error) => console.log('error', error),
    })
  }

  deletePoll(id: string) {
    this.pollsService.pollsPollIdDelete(id).subscribe({
      next: (response) => (
        this.messagesService.addMessage(new Message('Sondaggio eliminato con successo.', 5000, 'default'),),
        this.navigateBack()),
      error: (error) => console.log(error)
    });
  }

  changePollStatus(draft?: boolean) {
    if (this.poll?.poll_status == 'draft') {
      this.statusRequest = {poll_status: PollStatusEnum.Published};
    } else if (this.poll?.poll_status == 'closed') {
      this.statusRequest = {poll_status: PollStatusEnum.Published};
    } else if (this.poll?.poll_status == 'published' && this.poll.is_already_answered == false ) {
      if (draft == true) {
        this.statusRequest = {poll_status: PollStatusEnum.Draft};
      } else if (draft == undefined) {
        this.statusRequest = {poll_status: PollStatusEnum.Closed};
      }
    } else if (this.poll?.poll_status == 'published' && this.poll.is_already_answered == true) {
      this.statusRequest = {poll_status: PollStatusEnum.Closed};
    }

    this.pollsService.pollsPollIdStatusPatch(this.pollId, this.statusRequest).subscribe({
      next: () => {
        this.messagesService.addMessage(new Message('Stato del sondaggio modificato con successo.', 5000, 'default'),),
        this.getData(this.pollId)
      },
      error: () => console.log('errore'),
    });
  }

  showOptions(questionIndex: number) {
    if (this.visibleArray.includes(questionIndex)) {
      const index = this.visibleArray.indexOf(questionIndex);
      this.visibleArray.splice(index,1);
    } else {
      this.visibleArray.push(questionIndex);
    }
  }

  navigateBack() {
    this.router.navigate(['/polls']);
  }
}

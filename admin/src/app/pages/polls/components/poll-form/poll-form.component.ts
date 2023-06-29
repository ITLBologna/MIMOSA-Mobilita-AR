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

import { Component, OnInit } from '@angular/core';;
import { Poll, PollRequest, PollsService, QuestionTypeEnum} from 'src/openapi';
import { Router, ActivatedRoute } from '@angular/router';
import { Message, MessagesService } from 'src/app/shared/messages/messages.service';

@Component({
  selector: 'app-poll-form',
  templateUrl: './poll-form.component.html',
  styleUrls: ['./poll-form.component.scss'],
})

export class PollFormComponent implements OnInit {

  pollRequest: PollRequest = {
    title: '',
    description: '',
    time_to_show: 0,
    questions: [{
      text: '',
      question_type: QuestionTypeEnum.FreeAnswer,
      answer_options: [],
    },],
  };

  pollId: string | undefined;

  poll: Poll | undefined;

  constructor(
    private pollsService: PollsService,
    private router: Router,
    private activatedRoute: ActivatedRoute,
    private messagesService: MessagesService,
  ) {
    this.activatedRoute.params.subscribe((params) => {
      this.pollId = params['pollId'];
      if (this.pollId) {
        this.getData(this.pollId);
      }
    });
  }

  ngOnInit() {}

  getData(pollId: string) {
    this.pollsService.pollsPollIdGet(pollId).subscribe({
      next: (response) => {
        this.poll = response.data
        this.pollRequest = this.transformDataToRequest(response.data)
      },
      error: (error) => console.log('error:', error),
    });
  }

  transformDataToRequest(poll: Poll): PollRequest {
    return {
      title: poll.title,
      time_to_show: poll.time_to_show,
      description: poll.description ?? '',
      questions: poll.questions,
    }
  }

  handleSubmit() {
    if (this.pollId) {
      this.update(this.pollId);
    } else {
      this.create();
    }
  }

  create() {
    this.pollsService.pollsPost(this.pollRequest).subscribe({
      next: (response) => (
        this.messagesService.addMessage(new Message('Sondaggio creato con successo.', 5000, 'default'),),
        this.navigateBack()),
      error: (error) => console.log(error),
    });
  }

  update(pollId: string) {
    this.pollsService.pollsPollIdPut(pollId, this.pollRequest).subscribe({
      next: (response) => (
        this.messagesService.addMessage(new Message('Sondaggio modificato con successo.', 5000, 'default'),),
        this.navigateBack()),
      error: (error) => console.log(error),
    });
  }

  addQuestion() {
    this.pollRequest.questions.push({
      text: '',
      question_type: QuestionTypeEnum.FreeAnswer,
      answer_options: [],
    });
  }

  removeQuestion(questionIndex: number) {
    this.pollRequest.questions.splice(questionIndex,1);
  }

  addAnswer(questionIndex: number) {
    this.pollRequest.questions[questionIndex].answer_options?.push({
      text: '',
    });
  }

  removeAnswer(questionIndex: number, answerIndex: number) {
    this.pollRequest.questions[questionIndex].answer_options?.splice(answerIndex,1);
  }

  navigateBack() {
    this.router.navigate(['/polls']);
  }

}

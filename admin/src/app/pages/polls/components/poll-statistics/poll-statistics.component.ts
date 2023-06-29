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

import { HttpEventType } from '@angular/common/http';
import { Component } from '@angular/core';
import { ActivatedRoute, Router } from '@angular/router';
import { PollReportResponseData, PollsService, ReportService } from 'src/openapi';

@Component({
  selector: 'app-poll-statistics',
  templateUrl: './poll-statistics.component.html',
  styleUrls: ['./poll-statistics.component.scss'],
})
export class PollStatisticsComponent {
  pollId: string = '';
  pollReport: PollReportResponseData | undefined;
  visibleArray: number[] = [];

  constructor(
    private router: Router,
    private activatedRoute: ActivatedRoute,
    private reportService: ReportService,
    private pollsService: PollsService,

  ) {
    this.activatedRoute.params.subscribe((params) => {
      this.pollId = params['pollId'];
      if (this.pollId) {
        this.getData(this.pollId);
      }
    });
  }

  getData(pollId: string) {
    this.reportService.pollsPollIdReportGet(pollId).subscribe({
      next: (response) => this.pollReport = response.data,
      error: (error) => console.log('error:', error),
    })
  }

  showStatistics(questionIndex: number) {
    if (this.visibleArray.includes(questionIndex)) {
      const index = this.visibleArray.indexOf(questionIndex);
      this.visibleArray.splice(index,1);
    } else {
      this.visibleArray.push(questionIndex);
    }
  }

  downloadExcel() {
    this.pollsService.pollsPollIdAnswersExportGet(this.pollId, "response").subscribe({
      next: (data) => {
        if (data.type === HttpEventType.Response) {


          if (data.ok) {
            let textFile = null;
            if (textFile !== null) {
              window.URL.revokeObjectURL(textFile);
            }
            if (data.body !== null) {

              textFile = window.URL.createObjectURL(data.body);

              let a = document.createElement('a'); //make a link in document
              let linkText = document.createTextNode('fileLink');
              a.appendChild(linkText);

              a.href = textFile;

              a.id = 'fileLink';

              const contentDispositionHeader = data.headers.get('Content-Disposition');
              const fileName = contentDispositionHeader?.match(/filename="?(.+)"?/);
              a.download = decodeURI(fileName?.[1]?.replace('%2F', '/') || 'statistics.csv')
              a.style.visibility = 'hidden';

              document.body.appendChild(a);

              const element = document.getElementById('fileLink');
              element?.click();
              element?.remove();
            }
          } else {

          }
        }
      },
      error: (error) => {

      },
    })
  }

  navigateBack() {
    this.router.navigate(['/polls']);
  }
}

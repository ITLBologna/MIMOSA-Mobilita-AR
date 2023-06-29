![banner](resources/banner.png)

## MIMOSA Mobilità AR

This repository contains the open source code developed by [Fondazione ITL](https://www.fondazioneitl.org/) for the MIMOSA augmented-reality InfoMobility application related to the project ["Maritime and MultimOdal Sustainable pAssenger transport solutions and services"](https://www.fondazioneitl.org/en/project/mimosa-maritime-and-multimodal-sustainable-passenger-transport-solutions-and-services/) (MIMOSA).

This Mimosa Mobilità AR action is related to the development of both cloud/server infrastructure and mobile application front-end for the augmented reality infomobility application.

### Cloud Environment (low load, pilot project)

Here is the technical description of the virtual machine cloud instances deployed for the core MIMOSA services, dimensioned for the Pilot Project which should handle from 100 to 1000 active users

**Amazon AWS Instances**
- 5 VM EC2, tu O.S. Ubuntu 22.04 LTS
  -	Mimosa Production (r6g.medium, EBS 16Gb)
  - Mimosa Development (r6g.medium, EBS 16Gb)
  - Mimosa OTP (OpenTripPlanner, r6g.medium, EBS 16Gb)
  - Mimosa Analytics (Matomo, t4g.small, EBS 50Gb)
  - Mimosa Pelias (Pelias, c6i.large, EBS 24Gb)


### Installation (Windows 10)
- 

### Usage

To use the Mimosa Fluxus-AI application, you first need to properly prepare the videos to be processed. A recording session may consist of several video files, which must be grouped together and placed in an appropriate directory. Consider the example here, in which we have two video files representing 2 consecutive recording sessions of the same area, namely video_01.MP4 and video_02.MP4, both inside a directory named fluxus_ai_demo. To ensure the system operates correctly, it is recommended that each video be given a descriptive name using a common prefix ("video" in our example) followed by a numerical suffix to indicate the time ordering ("_01" and "_02" in or example)". This will help to clearly identify and organize the videos within the system.

![alt text](resources/usage1.jpg)

Once you have populated the directory with the videos you want to analyze, you can open the Mimosa application and select this directory for processing by pressing the "select" button. At this point, the calibration procedure will start. Specifically, the system will present the user with a frame of the area to be analyzed and request to select the flow line (green), which is the imaginary line on the road that will be used to extract statistics. The statistics will always refer to the time when a vehicle crosses the flow line. Then, the user must delimit the analysis area to a specific portion of the image by selecting an appropriate polygon containing the flow line (red). By excluding areas that are irrelevant to the analysis, you can speed up video processing and make it more efficient. To draw the line an polygon, follow the instructions on-screen:

![alt text](resources/usage2.jpg)

The system will now begin processing the videos. The results of this processing will be saved in the previously designated directory and will consist of three files: full_video.trk, full_video.dat, and data.csv. The first two files are binary files used exclusively by the Fluxus-AI application and contain the detections and labels extracted with YOLOx and the tracks obtained through the short-term tracking module. The third file, data.csv, is a standard CSV file that can be opened and analyzed with any application that supports this format, such as Microsoft Excel.

Note that, if you select a directory that already contains the data.csv file, you do not need to repeat either the streamline selection step or the video processing step. The Fluxus-AI application is able to display the aggregate statistics based on the queries specified by the user, who can filter the data using numerous parameters including vehicle classes and time intervals. Here, an example of a query is shown, in which the requests to view the vehicular flow in the first 15 minutes of a video, considering only vehicles belonging to the class "car" and the class "motorcycle":

![alt text](resources/usage3.jpg)

### Acknowledgment

Fluxus AI has been part of the [MIMOSA](https://www.fondazioneitl.org/en/project/mimosa-maritime-and-multimodal-sustainable-passenger-transport-solutions-and-services/)

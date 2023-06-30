![banner](resources/banner.png)

# MIMOSA Mobilità AR

This repository contains the open source code developed by [Fondazione ITL](https://www.fondazioneitl.org/) for the MIMOSA augmented-reality InfoMobility application related to the project ["Maritime and MultimOdal Sustainable pAssenger transport solutions and services"](https://www.fondazioneitl.org/en/project/mimosa-maritime-and-multimodal-sustainable-passenger-transport-solutions-and-services/) (MIMOSA).

This Mimosa Mobilità AR action is related to the development of both cloud/server infrastructure and mobile application front-end for the augmented reality infomobility application.

## Cloud Environment (low load, pilot project)

The cloud infrastructure consists of four servers:
- Mimosa Backend
- Mimosa OTP
- Mimosa Pelias
- Mimosa Matomo

### Mimosa Backend

This server hosts the 6 modules described below, handling data acquisition and transformation, and serves data to the mobile app and to the administrator dashboard.

Here is the technical description of the virtual machine cloud instances deployed for the core MIMOSA services, dimensioned for the Pilot Project which should handle from 100 to 1000 active users

**Amazon AWS Instances**
- 5 VM EC2, tu O.S. Ubuntu 22.04 LTS
  -	Mimosa Production (r6g.medium, EBS 16Gb)
  - Mimosa Development (r6g.medium, EBS 16Gb)
  - Mimosa OTP (OpenTripPlanner, r6g.medium, EBS 16Gb)
  - Mimosa Analytics (Matomo, t4g.small, EBS 50Gb)
  - Mimosa Pelias (Pelias, c6i.large, EBS 24Gb)

#### Modules description:

**polls-api (Express.js):**

- This Express.js project acts as an API server for managing surveys and gamification features.
- It handles data submitted by the mobile app for gamification purposes.
- It provides endpoints to retrieve game scores and generate leaderboards for the users who participated.

Follow the [README](polls-api/README.md) for the installation.

**tracking-api (Express.js):**

- The tracking-api is an Express.js project that receives and stores location data sent by the Flutter mobile app.
- It saves the data to a DynamoDB database for later use by other components, such as the admin frontend.

Follow the [README](tracking-api/README.md) for the installation.

**admin (Angular):**

- This project serves as an Angular frontend that connects to the polls-api and tracking-api.
- It provides an interface for managing surveys, including creation, configuration, and deletion.
- It also utilizes the tracking-api (Express.js) to display location data collected from the mobile app on a map.

Follow the [README](admin/README.md) for the installation.

**webcontent (Angular):**

- This Angular frontend project hosts web pages that are displayed within a webview in the mobile app.
- It includes pages such as the privacy policy, the app guide, and other informational content for the app.

Follow the [README](webcontent/README.md) for the installation.

**etl (Python):**

The etl project consists of Python scripts that handle the ETL (Extract, Transform, Load) process for gathering data from various transportation agencies and generating a graph for use with Open Trip Planner in the Mimosa application.

Follow the [README](etl/README.md) for installation and usage.

**transit-api (Golang):**

The transit-api project is a Golang project that serves as a utility API for providing transit-related information to the Mimosa application. It offers various functionalities such as retrieving a list of transportation agencies, bus stops, transit schedules, and real-time information from GTFS (General Transit Feed Specification) and GTFS Real-Time data.

Follow the [README](transit-api/README.md) for installation and usage.

### OTP

For OTP installation please follow the [official documentation](https://docs.opentripplanner.org/en/v2.2.0/).

### Pelias

For Pelias installation please follow the [official documentation](https://github.com/pelias/documentation/blob/master/getting_started_install.md).

### Matomo

For Matomo installation please follow the [official documentation](https://matomo.org/faq/on-premise/installing-matomo/).

### Acknowledgment

MIMOSA Mobilità AR has been part of the [MIMOSA](https://www.fondazioneitl.org/en/project/mimosa-maritime-and-multimodal-sustainable-passenger-transport-solutions-and-services/) project funded by the European Union’s Italy-Croatia CBC Programme strategic call. MIMOSA aims at improving the offer of multimodal sustainable passengers’ transport solutions and services by promoting a new cross-border approach for passenger mobility in the Italy-Croatia Programme area. This will be achieved through a range of multimodal solutions, innovative smart tools and technologies.

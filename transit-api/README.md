# transit-api

The transit-api project is a Golang project that serves as a utility API for providing transit-related information to the Mimosa application. It offers various functionalities such as retrieving a list of transportation agencies, bus stops, transit schedules, and real-time information from GTFS (General Transit Feed Specification) and GTFS Real-Time data.

## Prerequisites:

Ensure that Golang is installed on your machine along with the necessary dependencies.

## 1. Installation

1. Clone the Git repository of the transit-api project or copy the project files onto your local machine.
2. Open a terminal or command prompt and navigate to the project directory.

## 2. Configuration

The transit-api project requires configuration settings to connect to the relevant data sources and define any necessary parameters. 

Copy the file `.env.example`

```bash
cp .env.example .env
```

Fill the `.env` with the necessary information:

**GTFS_PATH**: is the path where the combined GTFS will be moved
**GTFSRT_PATH**: is the path to the folder containing the real time GTFS
**LOAD_SHAPES**: choose if trip shapes will be loaded (values: `true` or `false`)
**LOAD_STOP_TIMES**: choose if stop times will be loaded (values: `true` or `false`)
**ORDER_STOP_TIMES**: choose if stops will be sorted by arrival (values: `true` or `false`)
**ENABLE_GRAPH**: choose if graph will be enabled (values: `true` or `false`)
**GRAPH_PATH**: is the path to the graph

## 3. Build

Run the following command to build the project:

```bash
go build
```

## 4. Run

Run the following command to run the project:

```bash
./trasit-api
```

Although it works, it is recommended to use a supervisor that can restart the process if it stops, or even launch it at startup.

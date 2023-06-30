# tracking-api

The tracking-api is an API server that handles the functionality of tracking and storing user location data for the Mimosa mobile application. It allows the Flutter app to send the user's location at regular intervals and stores the data in a DynamoDB database.

## Installation and Dependencies:

This instructions refers to the Mimosa Production (or Development) AWS instance (see the main [README](../README.md))

### 1. Install Node.js and npm (Node Package Manager) on the server

First check if Node.js already installed on the system with the following command:

```bash
node -v
```

If Node.js is not installed, run the following commands:

```bash
sudo apt update
sudo apt update
```

The command `node-v` should now output the installed version of node.

Now, you can install the Node Package Manager (NPM):

```bash
sudo apt install npm
```

### 2. Clone the Repository:

Clone the Git repository of the tracking-api project (or copy the tracking-api folder) onto the server, in a folder of your choice (typically `/var/www`).

Navigate to the project directory and install the required dependencies using these commands (assuming you put the tracking-api folder in `/var/www`):

```bash
cd /var/www/tracking-api
npm install
```

### 3. Configuration:

Copy the `.env.example` file and rename it to `.env`. You can do it with this command:

```bash
cp .env.example .env
```

Now edit the file, and put the necessary configurations.:

*PORT*: is the name of the port used by the API to listen to incoming connections (ie. 3001)

*ACCESS_KEY_ID*: the AWS DynamoDB access key id
*SECRET_ACCESS_KEY*: the AWS DynamoDB access key secret
*REGION*: the AWS DynamoDB instance

*TABLE_NAME_TRACKING_DATA*: is the name of the table that holds the collected positions
*TABLE_NAME_USERS*:  is the name of the table with the users of the app

*JWT_KEY_SECRET*: is the key used to encrypt the JWT token

### 4. Build

Build the project with this command:

```bash
npm run build
```

### 5. Run

You can use this command to run the project:

```bash
/usr/bin/node /var/www/polls-api/dist/index.js
```

Although it works, it is recommended to use a supervisor that can restart the process if it stops, or even launch it at startup.

### 6. Serve

In order to serve the API, a web server is recommended. For instance, nginx can act as a reverse proxy and forward requests to the specified port.

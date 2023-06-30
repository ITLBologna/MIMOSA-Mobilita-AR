# polls-api

The polls-api serves as an API server that handles various functionalities related to managing surveys and gamification features in Mimosa.

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

### 2. Clone the repository

Clone the Git repository of the polls-api project (or copy the polls-api folder) onto the server, in a folder of your choice (typically `/var/www`).

Navigate to the project directory and install the required dependencies using these commands (assuming you put the polls-api folder in `/var/www`):

```bash
cd /var/www/polls-api
npm install
```

### 3. Configuration:

Copy the `.env.example` file and rename it to `.env`. You can do it with this command:

```bash
cp .env.example .env
```

Now edit the file, and put the necessary configurations.:

*PORT*: is the name of the port used by the API to listen to incoming connections (ie. 3000)

*ACCESS_KEY_ID*: the AWS DynamoDB access key id
*SECRET_ACCESS_KEY*: the AWS DynamoDB access key secret
*REGION*: the AWS DynamoDB instance

*TABLE_NAME_POLLS*: is the name of the surveys table 
*TABLE_NAME_POLLS_ANSWERS*: is the name of the tbale with the answers of the surveys
*TABLE_NAME_USERS*:  is the name of the table with the users of the app
*TABLE_NAME_GAMES*: is the name of the table with all games played
*TABLE_NAME_USERS_BACKEND*: is the name with the table of the users of the admin dashboard
*SECRET_JWT_KEY*: is the key used to encrypt the JWT token
*POINTS_URL*: endpoint of the API that return the points earned from one stop to another
*GAMIFICATION_ENABLED*: is a configuration which enables, or disable, the gamification feature (values: `true` or `false`)
*LEADERBOARD_ENABLED*: is a configuration which enables, or disable, the the leaderboard in the app (values: `true` or `false`)

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

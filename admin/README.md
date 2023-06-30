# admin

The admin project is an Angular frontend application that serves as the administrative interface for managing surveys within the Mimosa application. It provides a user-friendly interface to create, configure, and delete surveys, as well as visualizing user location data on a map.

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

Clone the Git repository of the admin project (or copy the admin folder) onto the server, in a folder of your choice (typically `/var/www`).

Navigate to the project directory and install the required dependencies using these commands (assuming you put the admin folder in `/var/www`):

```bash
cd /var/www/admin
npm install
```

### 3. Build

Run the following command to build the project:

```bash
npm run build -- --configuration=production
```

### 4. Configuration

Navigate to the dist folder:

```bash
cd dist
```

Create a new `env.js` and copy the following code:

```js
(function (window) {
  window.__env = window.__env || {};

  window.__env.production = true;
  window.__env.API_BASE_PATH = ;
  window.__env.API_BASE_PATH_TRACKINGDATA = ;
  window.__env.stage = 'production';
}(this));
```

Configure the API endpoints according to your web servers setup.

### 5. Serve

As a static website, the content of the dist folder can be served with any web server.

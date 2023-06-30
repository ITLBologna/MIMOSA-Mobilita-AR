# webcontent

The webcontent project is an Angular frontend application that serves as a container for web pages to be displayed within a webview component in the Mimosa mobile application. It hosts various pages that provide informational content to the app users, such as the privacy policy, data usage guide, or any other relevant web content.

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

Clone the Git repository of the webcontent project (or copy the webcontent folder) onto the server, in a folder of your choice (typically `/var/www`).

Navigate to the project directory and install the required dependencies using these commands (assuming you put the webcontent folder in `/var/www`):

```bash
cd /var/www/webcontent
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
  window.__env.stage = 'production';
}(this));
```

Configure the API endpoints according to your web servers setup.

### 5. Serve

As a static website, the content of the dist folder can be served with any web server.

'use strict';

// Require index.html so it gets copied to dist
require('./index.html');

var app = require('./Main.elm').Elm.Main;
app.init({ node: document.querySelector('main') });

// Create your WebSocket.
var socket = new WebSocket('wss://echo.websocket.org');

// When a command goes to the `sendMessage` port, we pass the message
// along to the WebSocket.
app.ports.sendMessage.subscribe(function(message) {
    socket.send(message);
});

// When a message comes into our WebSocket, we pass the message along
// to the `messageReceiver` port.
socket.addEventListener("message", function(event) {
    app.ports.messageReceiver.send(event.data);
});
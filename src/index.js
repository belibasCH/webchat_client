'use strict';

// Require index.html so it gets copied to dist
require('./index.html');

var app = require('./Main.elm').Elm.Main.init({ node: document.querySelector('main') });

// Create your WebSocket.
var socket = new WebSocket('ws://localhost:8080');
console.log("Socket created", socket);

// When a command goes to the `sendMessage` port, we pass the message
// along to the WebSocket.
app.ports.sendMessage.subscribe(function(message) {
    console.log("Sending message", message);
    socket.send(JSON.stringify(message));
});

// When a message comes into our WebSocket, we pass the message along
// to the `messageReceiver` port.
socket.addEventListener("message", function(event) {
    console.log("Received message", event.data);
    app.ports.messageReceiver.send(event.data);
});
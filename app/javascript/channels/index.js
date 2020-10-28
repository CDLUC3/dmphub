// Load all the channels within this directory and all subdirectories.
// Channel files must be named *_channel.js.

const channels = require.context('.', true, /Channel\.js$/)
channels.keys().forEach(channels)

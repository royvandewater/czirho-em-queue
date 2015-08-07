debug = require('debug')('czirho:bus')
_ = require 'lodash'
zmq = require 'zmq'

class Bus
  constructor: (options={}) ->
    {@insertPort, @subscribePort} = options
    @inbox = zmq.socket 'pull'
    @inbox.on 'message', @onMessage
    @outbox = zmq.socket 'pub'

  run: =>
    @inbox.bindSync "tcp://127.0.0.1:#{@insertPort}"
    @outbox.bindSync "tcp://127.0.0.1:#{@subscribePort}"
    debug "Started bus listening for messages on: #{@insertPort}, emitting on #{@subscribePort}"

  onMessage: (id, messageStr) =>
    debug 'onMessage', id.toString(), messageStr.toString()
    @outbox.send [id.toString(), messageStr.toString()]

module.exports = Bus

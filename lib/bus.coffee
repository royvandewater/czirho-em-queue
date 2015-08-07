debug = require('debug')('czirho:bus')
_ = require 'lodash'
zmq = require 'zmq'

class Bus
  constructor: (options={}) ->
    {@insertPort, @subscribePort} = options
    @inbox = zmq.socket 'pull'
    @inbox.on 'message', @onMessage

  run: =>
    @inbox.bindSync "tcp://127.0.0.1:#{@insertPort}"
    debug "Started bus listening for messages on: #{@insertPort}, emitting on #{@subscribePort}"

  onMessage: (messageStr) =>
    debug 'onMessage', messageStr.toString()

module.exports = Bus

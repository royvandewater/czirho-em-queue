debug = require('debug')('czirho:core')
zmq = require 'zmq'

class Core
  constructor: (options={}) ->
    {@insertPort, @subscribePort} = options
    @jobQueue = zmq.socket 'pull'
    @jobQueue.on 'message', @onMessage

  run: =>
    @jobQueue.bindSync "tcp://127.0.0.1:#{@insertPort}"
    debug "Started core listening on: #{@insertPort}, emitting on #{@subscribePort}"

  onMessage: (message) =>
    debug 'message received', message.toString()

module.exports = Core

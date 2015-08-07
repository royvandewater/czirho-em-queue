debug = require('debug')('czirho:adapter')
_ = require 'lodash'
uuid = require 'uuid'
zmq = require 'zmq'

class Adapter
  constructor: (options={}) ->
    {@busPorts, @queuePorts} = options

  run: =>
    debug "Started adapter. Putting jobs in #{@queuePorts}, getting messages from #{@busPorts}"

    @buses = _.map @busPorts, @_createConnectedBus
    _.each @buses, (bus) => bus.socket.on 'message', @onMessage

    @queues = _.map @queuePorts, @_createConnectedQueue

    @interval = setInterval @sendJob, 1000

  onMessage: (idBuffer, messageStrBuffer) =>
    id = idBuffer.toString()
    messageStr = messageStrBuffer.toString()

    debug 'onMessage', id, messageStr
    _.each @buses, (bus) => bus.socket.unsubscribe id

  sendJob: =>
    queue = _.sample @queues
    id    = uuid.v1()
    debug "sendJob", "sending to: #{queue.port} with id: #{id}"
    queue.socket.send JSON.stringify ['sum', [1, 1], id]

    debug "subscribing to #{id}"
    _.each @buses, (bus) => bus.socket.subscribe id

  _createConnectedBus: (port) =>
    socket = zmq.socket 'sub'
    socket.connect "tcp://127.0.0.1:#{port}"

    return { port: port, socket: socket }

  _createConnectedQueue: (port) =>
    socket = zmq.socket 'push'
    socket.connect "tcp://127.0.0.1:#{port}"

    return { port: port, socket: socket }

module.exports = Adapter

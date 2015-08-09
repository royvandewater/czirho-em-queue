debug = require('debug')('czirho:adapter')
_ = require 'lodash'
uuid = require 'uuid'
zmq = require 'zmq'

class Adapter
  constructor: (options={}) ->
    {@busPorts, @queuePorts} = options
    @pendingMessages = {}

  run: =>
    debug "Started adapter. Putting jobs in #{@queuePorts}, getting messages from #{@busPorts}"

    @buses = _.map @busPorts, @_createConnectedBus
    _.each @buses, (bus) => bus.socket.on 'message', @onMessage
    console.warn "No buses passed in to adapter, responses will not be received" if _.isEmpty @buses

    @queues = _.map @queuePorts, @_createConnectedQueue
    if _.isEmpty @queues
      console.error "Adapter has no queues, cannot send jobs" 
      process.exit 1

    @interval = setInterval @sendJob, 1000

  onMessage: (idBuffer, messageStrBuffer) =>
    id = idBuffer.toString()
    messageStr = messageStrBuffer.toString()

    debug 'onMessage', id, messageStr
    _.each @buses, (bus) => bus.socket.unsubscribe id
    @printMessage id, messageStr
    
  printMessage: (id, message) =>
    values = @pendingMessages[id].values
    valuesStr = values.join ' + '
    console.log "#{valuesStr} = #{message}"
    delete @pendingMessages[id]

  sendJob: =>
    queue = _.sample @queues

    id    = uuid.v1()
    values = _.times _.random(1,10), => _.random(1,10)
    
    @pendingMessages[id] = {operation: 'sum', values: values}

    debug "subscribing to #{id}"
    _.each @buses, (bus) => bus.socket.subscribe id
    
    debug "sendJob", "sending to: #{queue.port} with id: #{id}"
    queue.socket.send JSON.stringify ['sum', values, id]

  _createConnectedBus: (port) =>
    socket = zmq.socket 'sub'
    socket.connect "tcp://127.0.0.1:#{port}"

    return { port: port, socket: socket }

  _createConnectedQueue: (port) =>
    socket = zmq.socket 'push'
    socket.connect "tcp://127.0.0.1:#{port}"

    return { port: port, socket: socket }

module.exports = Adapter

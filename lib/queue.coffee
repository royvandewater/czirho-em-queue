debug = require('debug')('czirho:queue')
_ = require 'lodash'
zmq = require 'zmq'

class Queue
  constructor: (options={}) ->
    {@insertPort, @corePorts} = options
    @jobQueue = zmq.socket 'rep'
    @jobQueue.on 'message', @onMessage

  run: =>
    @jobQueue.bindSync "tcp://127.0.0.1:#{@insertPort}"
    @cores = _.map @corePorts, @_createConnectedCore
    debug "Started queue listening for jobs on: #{@insertPort}, putting jobs in #{@corePorts}"

  onMessage: (message) =>
    messageStr = message.toString()
    debug 'message received', messageStr, @insertPort

    try
      [operation, args, id] = @_parseMessage messageStr
    catch error
      return debug error.message

    @sendJob message

    @jobQueue.send id

  sendJob: (message) =>
    core = _.sample @cores
    debug "sendJob", "sending to: #{core.port}"
    core.socket.send message

  _createConnectedCore: (port) =>
    socket = zmq.socket 'push'
    socket.connect "tcp://127.0.0.1:#{port}"

    return { port: port, socket: socket }

  _parseMessage: (messageStr) =>
    try
      message = JSON.parse messageStr
    catch
      throw new Error 'bad JSON, ignoring'

    return message

module.exports = Queue

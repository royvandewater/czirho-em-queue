debug = require('debug')('czirho:core')
_ = require 'lodash'
zmq = require 'zmq'

VALID_OPERATIONS = ['sum']

class Core
  constructor: (options={}) ->
    {@insertPort, @busPorts} = options
    @inbox = zmq.socket 'pull'
    @inbox.on 'message', @onMessage

  run: =>
    if _.isEmpty @busPorts
      console.error 'Core has no buses, cannot send repsonses'
      process.exit 1

    @buses = _.map @busPorts, @_createConnectedBus
    @inbox.bindSync "tcp://127.0.0.1:#{@insertPort}"

    debug "Started core listening on: #{@insertPort}, emitting on #{@subscribePort}"

  onMessage: (messageStr) =>
    debug 'onMessage', messageStr.toString(), @insertPort

    try
      [operation, args, id] = @_parseMessage messageStr
    catch error
      return debug error.message

    returnValue = @[operation](args)
    @sendResponse id, returnValue

  sendResponse: (id, value) =>
    bus = _.sample @buses

    debug "sending #{bus.port} this response: #{value} with id: #{id}"
    bus.socket.send [id, JSON.stringify value]

  sum: (addents) =>
    debug 'sum', addents
    _.reduce addents, (total, n) => total + n

  _createConnectedBus: (port) =>
    socket = zmq.socket 'push'
    socket.connect "tcp://127.0.0.1:#{port}"

    return { port: port, socket: socket }

  _parseMessage: (messageStr) =>
    try
      message = JSON.parse messageStr
    catch
      throw new Error 'bad JSON, ignoring'

    unless _.contains VALID_OPERATIONS, _.first(message)
      throw new Error 'bad operation, ignoring'

    return message

module.exports = Core

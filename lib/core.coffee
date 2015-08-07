debug = require('debug')('czirho:core')
_ = require 'lodash'
zmq = require 'zmq'

VALID_OPERATIONS = ['sum']

class Core
  constructor: (options={}) ->
    {@insertPort, @subscribePort} = options
    @outbox = zmq.socket 'push'
    @inbox = zmq.socket 'pull'
    @inbox.on 'message', @onMessage

  run: =>
    @outbox.bindSync "tcp://127.0.0.1:#{@subscribePort}"
    @inbox.bindSync "tcp://127.0.0.1:#{@insertPort}"

    debug "Started core listening on: #{@insertPort}, emitting on #{@subscribePort}"

  onMessage: (messageStr) =>
    debug 'message received', messageStr.toString()

    try
      [operation, args, id] = @_parseMessage messageStr
    catch error
      return debug error.message

    returnValue = @[operation](args)
    response = [id, returnValue]
    debug "sending #{response}"
    @outbox.send JSON.stringify response

  sum: (addents) =>
    debug 'sum', addents
    _.reduce addents, (total, n) => total + n

  _parseMessage: (messageStr) =>
    try
      message = JSON.parse messageStr
    catch
      throw new Error 'bad JSON, ignoring'

    unless _.contains VALID_OPERATIONS, _.first(message)
      throw new Error 'bad operation, ignoring'

    return message

module.exports = Core

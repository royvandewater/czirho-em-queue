commander = require 'commander'
_ = require 'lodash'
packageJSON = require './package.json'
Adapter = require './lib/adapter'
Bus = require './lib/bus'
Core = require './lib/core'
Queue = require './lib/queue'

class Command
  constructor: ->
    @adapters = []
    @buses = []
    @cores = []
    @queues = []

  parseInt: (arg) => parseInt arg

  parseOptions: =>
    @options = commander
      .version packageJSON.version
      .option '-c, --cores <n>',    'number of cores nodes (default: 1)', @parseInt, 1
      .option '-b, --buses <n>',    'number of bus nodes (default: 1)', @parseInt, 1
      .option '-a, --adapters <n>', 'Number of adapter nodes (default: 1)', @parseInt, 1
      .option '-q, --queues <n>',   'Number of queue nodes (default: 1)', @parseInt, 1
      .parse process.argv

  run: =>
    @parseOptions()
    @startCores()
    @startQueues()
    @startBuses()
    @startAdapters()

  startAdapters: =>
    _.times @options.adapters, =>
      adapter = new Adapter queuePorts: @_queueInsertPorts(), busPorts: @_busSubscribePorts()
      adapter.run()
      @adapters.push adapter

  startBuses: =>
    _.times @options.buses, =>
      bus = new Bus corePorts: @_coreSubscribePorts(), subscribePort: @_randomPort()
      bus.run()
      @buses.push bus

  startCores: =>
    _.times @options.cores, =>
      core = new Core insertPort: @_randomPort(), subscribePort: @_randomPort()
      core.run()
      @cores.push core

  startQueues: =>
    _.times @options.queues, =>
      queue = new Queue insertPort: @_randomPort(), corePorts: @_coreInsertPorts()
      queue.run()
      @queues.push queue

  _busSubscribePorts: =>
    _.pluck @buses, 'subscribePort'

  _coreInsertPorts: =>
    _.pluck @cores, 'insertPort'

  _coreSubscribePorts: =>
    _.pluck @cores, 'subscribePort'

  _queueInsertPorts: =>
    _.pluck @queues, 'insertPort'

  _randomPort: =>
    _.random 49152, 65535

command = new Command()
command.run()

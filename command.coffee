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
    @buses    = []
    @cores    = []
    @queues   = []

  parseInt: (arg) => parseInt arg

  parseOptions: =>
    @options = commander
      .version packageJSON.version
      .option '-c, --cores <n>',    'number of cores nodes (default: 1)', @parseInt, 1
      .option '-b, --buses <n>',    'number of bus nodes (default: 1)', @parseInt, 1
      .option '-a, --adapters <n>', 'Number of adapter nodes (default: 1)', @parseInt, 1
      .option '-q, --queues <n>',   'Number of queue nodes (default: 1)', @parseInt, 1
      .option '-d, --direct',       'Adapter bypasses the Queue. Allows the system to work with "--queues 0"'
      .parse process.argv

  run: =>
    @parseOptions()
    @startBuses()
    @startCores()
    @startQueues()
    @startAdapters()

  startAdapters: =>
    busPorts = @_busSubscribePorts()
    
    queuePorts = @_queueInsertPorts()
    queuePorts = @_coreInsertPorts() if @options.direct
    
    _.times @options.adapters, =>
      adapter = new Adapter busPorts: busPorts, queuePorts: queuePorts
      adapter.run()
      @adapters.push adapter

  startBuses: =>
    _.times @options.buses, =>
      bus = new Bus insertPort: @_randomPort(), subscribePort: @_randomPort()
      bus.run()
      @buses.push bus

  startCores: =>
    busPorts = @_busInsertPorts()
    
    _.times @options.cores, =>
      core = new Core insertPort: @_randomPort(), busPorts: busPorts
      core.run()
      @cores.push core

  startQueues: =>
    corePorts = @_coreInsertPorts()
    
    _.times @options.queues, =>
      queue = new Queue insertPort: @_randomPort(), corePorts: corePorts
      queue.run()
      @queues.push queue

  _busInsertPorts: =>
    _.pluck @buses, 'insertPort'

  _busSubscribePorts: =>
    _.pluck @buses, 'subscribePort'

  _coreInsertPorts: =>
    _.pluck @cores, 'insertPort'

  _queueInsertPorts: =>
    _.pluck @queues, 'insertPort'

  _randomPort: =>
    _.random 49152, 65535

command = new Command()
command.run()

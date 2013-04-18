root = this

###########################################

Promise = require 'promise'

class Supervisor
  constructor: (methods) ->
    this[name] = body for own name, body of methods
    @of or= (value) -> value
    @map or= (fn) -> fn
    @chain or= (mValue, fn) -> @map(fn)(mValue)
    this[name] = body.bind(this) for own name, body of this

Supervisor.Identity = new Supervisor()

Supervisor.Maybe = new Supervisor
  map: (fn) ->
    (mValue) ->
      if (mValue is null or mValue is undefined)
        mValue
      else
        fn(mValue)
        
Supervisor.Writer = new Supervisor
  of: (value) -> [value, '']
  map: (fn) ->
    ([value, writtenSoFar]) ->
      [result, newlyWritten] = fn(value)
      [result, writtenSoFar + newlyWritten]
      
Supervisor.List = new Supervisor
  of: (value) -> [value]
  join: (mValue) ->
    mValue.reduce @concat, @zero()
  map: (fn) ->
    (mValue) -> mValue.map(fn)
  zero: -> []
  concat: (ma, mb) -> ma.concat(mb)
  chain: (mValue, fn) -> @join(@map(fn)(mValue))

Supervisor.Promise = new Supervisor
  of: (value) -> new Promise( (resolve, reject) -> resolve(value) )
  map: (fnReturningAPromise) ->
    (promiseIn) ->
      new Promise (resolvePromiseOut, rejectPromiseOut) ->
        promiseIn.then(
          ((value) ->
            fnReturningAPromise(value).then(resolvePromiseOut, rejectPromiseOut)),
          rejectPromiseOut)
          
Supervisor.Callback = new Supervisor
  of: (value) ->
    (callback) ->
      callback(value)
  map: (fn) ->
    (value) ->
      (callback) ->
        fn(value, callback)
  chain: (mValue, fn) ->
    (callback) =>
      mValue(
        (value) => @map(fn)(value)(callback)
      )
    
Supervisor.sequence = (args...) ->
  if args[0] instanceof Supervisor
    [supervisor, fns...] = args
  else
    supervisor = Supervisor.Identity
    fns = args
  ->
    fns.reduce supervisor.chain, supervisor.of.apply(supervisor, arguments)
    
###########################################

root.Supervisor = Supervisor
    
if typeof exports isnt 'undefined'
  if typeof module isnt 'undefined' and module.exports?
    exports = module.exports = root
  exports.supervis =
    es: root
else
  root.supervis =
    es: root
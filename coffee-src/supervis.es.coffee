root = this

###########################################

Promise = require 'promise'

fluent = (method) ->
  ->
    method.apply(this, arguments)
    this
    
tap = (value, fn) ->
  fn(value)
  value

class Monad
  constructor: (methods) ->
    this[name] = body for own name, body of methods
    @of or= (value) -> value
    @map or= (fn) -> fn
    @chain or= (mValue, fn) -> @map(fn)(mValue)
    this[name] = body.bind(this) for own name, body of this

Monad.Identity = new Monad()

Monad.Maybe = new Monad
  map: (fn) ->
    (mValue) ->
      if (mValue is null or mValue is undefined)
        mValue
      else
        fn(mValue)
        
Monad.Writer = new Monad
  of: (value) -> [value, '']
  map: (fn) ->
    ([value, writtenSoFar]) ->
      [result, newlyWritten] = fn(value)
      [result, writtenSoFar + newlyWritten]
      
Monad.List = new Monad
  of: (value) -> [value]
  join: (mValue) ->
    mValue.reduce @concat, @zero()
  map: (fn) ->
    (mValue) -> mValue.map(fn)
  zero: -> []
  concat: (ma, mb) -> ma.concat(mb)
  chain: (mValue, fn) -> @join(@map(fn)(mValue))

Monad.Promise = new Monad
  of: (value) -> new Promise( (resolve, reject) -> resolve(value) )
  map: (fnReturningAPromise) ->
    (promiseIn) ->
      new Promise (resolvePromiseOut, rejectPromiseOut) ->
        promiseIn.then(
          ((value) ->
            fnReturningAPromise(value).then(resolvePromiseOut, rejectPromiseOut)),
          rejectPromiseOut)
          
Monad.Continuation = new Monad
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
    
  
sequence = (args...) ->
  if args[0] instanceof Monad
    [monad, fns...] = args
  else
    monad = Monad.Identity
    fns = args
  ->
    fns.reduce monad.chain, monad.of.apply(monad, arguments)

root.sequence = sequence
root.Monad = Monad
root.Promise = Promise
root.Identity = (n) -> n
    
###########################################
    
if typeof exports isnt 'undefined'
  if typeof module isnt 'undefined' and module.exports?
    exports = module.exports = root
  exports.supervis =
    es: root
else
  root.supervis =
    es: root
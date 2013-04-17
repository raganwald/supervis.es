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
    @join or= (mValue) -> mValue
    @chain or= (mValue, fn) -> @join(@map(fn)(mValue))
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
    
Monad.Promise = new Monad
  of: (value) -> new Promise( (resolve, reject) -> resolve(value) )
  map: (fnReturningAPromise) ->
    (promiseIn) ->
      new Promise (resolvePromiseOut, rejectPromiseOut) ->
        promiseIn.then(
          ((value) ->
            fnReturningAPromise(value).then(resolvePromiseOut, rejectPromiseOut)),
          rejectPromiseOut)

sequence = (args...) ->
  if args[0] instanceof Monad
    [monad, fns...] = args
  else
    monad = Monad.Identity
    fns = args
  (value) ->
    fns.reduce monad.chain, monad.of(value)

root.sequence = sequence
root.Monad = Monad
root.Promise = Promise
    
###########################################
    
if typeof exports isnt 'undefined'
  if typeof module isnt 'undefined' and module.exports?
    exports = module.exports = root
  exports.supervis =
    es: root
else
  root.supervis =
    es: root
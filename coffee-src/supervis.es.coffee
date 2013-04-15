root = this

###########################################

fluent = (method) ->
  ->
    method.apply(this, arguments)
    this

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
  

class Promise
  
  @schedule: (thunk) ->
    if process?.nextTick?
      process.nextTick thunk
    else if window?.setTimeout?
      window.setTimeout thunk, 0
    else if setTimeout?
      setTimout thunk, 0
      
  @immediate = (value) ->
    new Promise().resolve(value)
    
  STATE =
    unfulfilled:
      then: (promise, onResolved, onRejected) ->
      resolve: (promise, value) ->
        promise.state = STATE.resolved
        promise.value = value
        Promise.schedule(-> handler(promise.value)) for handler in promise.onResolveds
      reject: (promise, error) ->
        promise.state = STATE.rejected
        promise.error = error
        Promise.schedule(-> handler(promise.error)) for handler in promise.onRejecteds
    resolved:
      then: (promise, onResolved, onRejected) ->
        Promise.schedule -> onResolved(promise.value) if onResolved?
      resolve: (promise, value) ->
        # ignore
      reject: (promise, error) ->
        throw "already resolved, cannot reject"
    rejected:
      then: (promise, onResolved, onRejected) ->
        Promise.schedule -> onRejected(promise.error) if onRejected?
      resolve: (promise, value) ->
        throw "already rejected, cannot resolved"
      reject: (promise, error) ->
        # ignore
        
  constructor: ->
    @state = STATE.unfulfilled
    @onResolveds = []
    @onRejecteds = []
    @resolver = @resolve.bind(this)
    @rejecter = @reject.bind(this)
    
  then: fluent (onResolved, onRejected) ->
    @onResolveds.push(onResolved) if onResolved?
    @onRejecteds.push(onRejected) if onRejected?
    @state.then(this, onResolved, onRejected)
    
  resolve: fluent (value) ->
    @state.resolve(this, value)
    
  reject: fluent (error) ->
    @state.reject(this, error)
    
Monad.Promise = new Monad
  of: (value) -> Promise.immediate(value)
  map: (fnReturningAPromise) ->
    (promiseIn) ->
      p = new Promise()
      promiseIn
        .then(
          ((value) ->
            fnReturningAPromise(value).then(p.resolver, p.rejecter))
        , p.rejecter)
      p

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
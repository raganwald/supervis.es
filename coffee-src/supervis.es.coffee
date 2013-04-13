root = this

###########################################

class Monad
  constructor: (methods) ->
    this[name] = body for own name, body of methods
    @mReturn or= (value) -> value
    @fmap or= (fn) -> fn
    @join or= (mValue) -> mValue
    @mBind or= (mValue, fn) -> @join(@fmap(fn)(mValue))
    this[name] = body.bind(this) for own name, body of this

Monad.Identity = new Monad()

Monad.Maybe = new Monad
  fmap: (fn) ->
    (mValue) ->
      if (mValue is null or mValue is undefined)
        mValue
      else
        fn(mValue)
        
Monad.Writer = new Monad
  mReturn: (value) -> [value, '']
  fmap: (fn) ->
    ([value, writtenSoFar]) ->
      [result, newlyWritten] = fn(value)
      [result, writtenSoFar + newlyWritten]
      
Monad.List = new Monad
  mReturn: (value) -> [value]
  join: (mValue) ->
    mValue.reduce @plus, @zero()
  fmap: (fn) ->
    (mValue) -> mValue.map(fn)
  zero: -> []
  plus: (ma, mb) -> ma.concat(mb)

sequence = (args...) ->
  if args[0] instanceof Monad
    [monad, fns...] = args
  else
    monad = Monad.Identity
    fns = args
  (value) ->
    fns.reduce monad.mBind, monad.mReturn(value)

root.sequence = sequence
root.Monad = Monad
    
###########################################
    
if typeof exports isnt 'undefined'
  if typeof module isnt 'undefined' and module.exports?
    exports = module.exports = root
  exports.supervis =
    es: root
else
  root.supervis =
    es: root
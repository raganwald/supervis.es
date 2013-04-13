root = this

###########################################

class Monad
  constructor: ({@unit, @bind}) ->
  lift: (fn) ->
    (value) -> @bind(fn)(@unit(value))

Monad.Identity = new Monad
  unit: (value) -> value
  bind: (fn) -> fn

Monad.Maybe = new Monad
  unit: (value) -> value
  bind: (fn) ->
    (boundValue) ->
      if (boundValue is null or boundValue is undefined)
        boundValue
      else
        fn(boundValue)
        
Monad.Writer = new Monad
  unit: (value) -> [value, '']
  bind: (fn) ->
    ([value, writtenSoFar]) ->
      [result, newlyWritten] = fn(value)
      [result, writtenSoFar + newlyWritten]
      
Monad.List = new Monad
  unit: (value) -> [value]
  bind: (fn) ->
    (values) ->
      values.reduce ((acc, value) -> acc.concat(fn(value))), []

sequence = (args...) ->
  if args[0] instanceof Monad
    [monad, fns...] = args
  else
    monad = Monad.Identity
    fns = args
  boundFns = fns.map(monad.bind)
  (value) ->
    boundFns.reduce ((acc, boundFn) -> boundFn(acc)), monad.unit(value)

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
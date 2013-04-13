root = this

###########################################

class Monad
  constructor: ({@unit, @bind}) ->
  lift: (fn) ->
    (value) -> @bind(fn)(@unit(value))

Identity = new Monad
  unit: (value) -> value
  bind: (fn) -> fn

sequence = (args...) ->
  if args[0] instanceof Monad
    [monad, fns...] = args
  else
    monad = Identity
    fns = args
  boundFns = fns.map(monad.bind)
  (value) ->
    boundFns.reduce ((acc, boundFn) -> boundFn(acc)), monad.unit(value)

root.supervis =
  es:
    sequence: sequence
    
###########################################
    
if typeof exports isnt 'undefined'
  if typeof module isnt 'undefined' and module.exports?
    exports = module.exports = root
  exports.supervis =
    es: root
else
  root.supervis =
    es: root
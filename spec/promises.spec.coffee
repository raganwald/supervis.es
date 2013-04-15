{Promise, sequence, Monad} = require('../lib/supervis.es')

# patch 'schedule'

Promise.schedule = (thunk) -> thunk()

describe "Promises", ->
  
  it "should be a thing", ->
    expect( Promise ).not.toBeUndefined()
    
  it "should be fluent", ->
    p = new Promise()
    expect( p instanceof Promise ).toBeTruthy()
    expect( p.then() ).toEqual p
    expect( p.resolve('foo') ).toEqual p
    
    p2 = new Promise()
      .then(((v) -> x = v), (-> x = 'fail'))
      .resolve('succeed')
      
    expect( p2 instanceof Promise ).toBeTruthy()
    
  it "should do something reasonable with success", ->
    x = undefined
    p = new Promise()
      .then(((v) -> x = v), (-> x = 'fail'))
      .resolve('succeed')
    expect( x ).toEqual('succeed')
    
  it "should do something reasonable with failure", ->
    x = undefined
    p = new Promise()
      .then((-> x = 'succeed'), ((e) -> x = e))
      .reject('fail')
    expect( x ).toEqual('fail')
    
  it "should retain its value after being resolved", ->
    
    x = undefined
    p = new Promise()
      .resolve('delayed')
      .then (v) -> x = v
    expect( x ).toEqual('delayed')
    
  describe "sequence", ->
    
    it "should work for a doubling promise", ->
      
      double = (value) ->
        Promise.immediate(value * 2)
        
      x = undefined
      
      sequencedPromise = sequence(Monad.Promise, double)(3)
        .then((value) -> x = value)
      
      expect( x ).toEqual 6
      
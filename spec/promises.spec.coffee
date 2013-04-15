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
      .then(((v) -> success = v), (-> success = 'fail'))
      .resolve('succeed')
      
    expect( p2 instanceof Promise ).toBeTruthy()
    
  it "should do something reasonable with success", ->
    success = undefined
    p = new Promise()
      .then(((v) -> success = v), (-> success = 'fail'))
      .resolve('succeed')
    expect( success ).toEqual('succeed')
    
  it "should do something reasonable with failure", ->
    success = undefined
    p = new Promise()
      .then((-> success = 'succeed'), ((e) -> success = e))
      .reject('fail')
    expect( success ).toEqual('fail')
    
  it "should retain its value after being resolved", ->
    
    success = undefined
    p = new Promise()
      .resolve('delayed')
      .then (v) -> success = v
    expect( success ).toEqual('delayed')
    
  describe "sequence", ->
    
    it "should work for a doubling promise", ->
      
      double = (value) ->
        Promise.immediate(value * 2)
        
      success = undefined
      failure = undefined
      
      sequencedPromise = sequence(Monad.Promise, double)(3)
        .then(((value) -> success = value), ((error) -> failure = error))
      
      expect( success ).toEqual 6
      expect( failure ).toBeUndefined()
    
    it "should make mine a double double", ->
      
      double = (value) ->
        Promise.immediate(value * 2)
        
      success = undefined
      failure = undefined
      
      sequencedPromise = sequence(Monad.Promise, double, double)(1)
        .then(((value) -> success = value), ((error) -> failure = error))
      
      expect( success ).toEqual 4
      expect( failure ).toBeUndefined()
    
    it "should fail forward", ->
      
      double = (value) ->
        Promise.immediate(value * 2)
        
      fail = (value) ->
        new Promise().reject('sorry, old chap!')
        
      success = undefined
      failure = undefined
      
      sequencedPromise = sequence(Monad.Promise, double, fail, double)(1)
        .then(((value) -> success = value), ((error) -> failure = error))
      
      expect( success ).toBeUndefined()
      expect( failure ).toEqual 'sorry, old chap!'
      
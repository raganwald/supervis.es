{sequence, Monad, Identity} = require('../lib/supervis.es')

double = (v, c) -> c(v * 2)
plus1 = (v, c) -> c(v + 1)

describe "continuation", ->
  
  it "should work for the null sequence", ->
    
    expect( sequence(Monad.Continuation)(42)(Identity) ).toBe 42
  
  it "should work for a double", ->
    
    expect( sequence(Monad.Continuation, double)(42)(Identity) ).toBe 84
  
  it "should work for a double double", ->
    
    expect( sequence(Monad.Continuation, double, double)(2)(Identity) ).toBe 8
  
  it "should work for a double plus1 double", ->
    
    expect( sequence(Monad.Continuation, double, plus1, double)(2)(Identity) ).toBe 10
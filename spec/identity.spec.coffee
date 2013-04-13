{sequence} = require('../lib/supervis.es')

double = (n) -> n + n
    
describe "monads", ->
  
  describe "sequence", ->
  
    it "should be a thing", ->
      expect( sequence ).not.toBeNull()
      
    it "should return a function when given a function", ->
      expect( sequence(double) ).not.toBeNull()
    
  it "should sequence a single function", ->
    expect( sequence(double)(3) ).toEqual 6
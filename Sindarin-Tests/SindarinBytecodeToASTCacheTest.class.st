Class {
	#name : #SindarinBytecodeToASTCacheTest,
	#superclass : #TestCase,
	#instVars : [
		'cache',
		'compiledMethod'
	],
	#category : #'Sindarin-Tests'
}

{ #category : #running }
SindarinBytecodeToASTCacheTest >> setUp [
	"Hooks that subclasses may override to define the fixture of test."
	super setUp.	
	compiledMethod := ScriptableDebuggerTests >> #helperMethod23.
	cache := SindarinBytecodeToASTCache generateForCompiledMethod: compiledMethod
]

{ #category : #helpers }
SindarinBytecodeToASTCacheTest >> testCacheInInterval: interval equalsNode: aNode [
	interval do: [ :i | 
		self assert: (cache nodeForPC: i) identicalTo: aNode ]
]

{ #category : #tests }
SindarinBytecodeToASTCacheTest >> testCachedMethodNode [
	self assert: cache methodNode identicalTo: compiledMethod ast
]

{ #category : #tests }
SindarinBytecodeToASTCacheTest >> testFirstBCOffsetTest [
	self assert: cache firstBcOffset equals: compiledMethod initialPC
]

{ #category : #tests }
SindarinBytecodeToASTCacheTest >> testHigherThanLastBCOffsetAccessTest [
	| pc |
	pc := cache lastBcOffset + 5.
	self
		assert: (cache nodeForPC: pc)
		identicalTo: (compiledMethod sourceNodeForPC: pc)
]

{ #category : #tests }
SindarinBytecodeToASTCacheTest >> testLastBCOffsetTest [
	self
		assert: cache lastBcOffset
		equals:
			compiledMethod ast ir startSequence withAllSuccessors last last
				bytecodeOffset
]

{ #category : #tests }
SindarinBytecodeToASTCacheTest >> testLowerThanFirstBCOffsetAccessTest [
	self
		testCacheInInterval: (0 to: cache firstBcOffset - 1)
		equalsNode: compiledMethod ast
]

{ #category : #tests }
SindarinBytecodeToASTCacheTest >> testNodeForBCOffsetRangeTest [
	| pcRange |
	pcRange := 47 to: 48.
	pcRange do: [ :pc | 
		self
			testCacheInInterval: pcRange
			equalsNode: (compiledMethod sourceNodeForPC: pc) ]
]

{ #category : #tests }
SindarinBytecodeToASTCacheTest >> testNodeForBCOffsetTest [
	| pc |
	pc := 51.
	self
		assert: (cache nodeForPC: pc)
		identicalTo: (compiledMethod sourceNodeForPC: pc)
]
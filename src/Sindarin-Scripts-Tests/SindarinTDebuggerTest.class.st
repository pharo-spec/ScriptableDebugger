Class {
	#name : 'SindarinTDebuggerTest',
	#superclass : 'TestCase',
	#instVars : [
		'script'
	],
	#category : 'Sindarin-Scripts-Tests-tests',
	#package : 'Sindarin-Scripts-Tests',
	#tag : 'tests'
}

{ #category : 'running' }
SindarinTDebuggerTest >> setUp [
	super setUp.
	
	script := SindarinTestDebuggerScript new
]

{ #category : 'tests' }
SindarinTDebuggerTest >> testDefaultArguments [
	self assertEmpty: script class defaultArguments.
	self assertEmpty: script arguments
]

{ #category : 'tests' }
SindarinTDebuggerTest >> testDefaultHooks [
	self assertEmpty: script class defaultHooks.
	self assertEmpty: script hooks
]

{ #category : 'tests' }
SindarinTDebuggerTest >> testDefaultPredicates [
	self assertEmpty: script class defaultPredicates.
	self assertEmpty: script predicates
]

{ #category : 'tests' }
SindarinTDebuggerTest >> testDefaultShouldExecute [
	self assert: script shouldExecute
]

{ #category : 'tests' }
SindarinTDebuggerTest >> testEmptyScriptExecution [

	self assert: (script executeWith: SindarinTestDebugger new) identicalTo: script
]

{ #category : 'tests' }
SindarinTDebuggerTest >> testExecuteRaiseScriptingException [

	self should: [ script execute ] raise: SindarinPointcutException.
	[ script execute ]
		on: SindarinPointcutException
		do: [ :e | self assert: e script identicalTo: script ]
]

{ #category : 'tests' }
SindarinTDebuggerTest >> testMultipleScriptExecution [

	| example |
	example := SindarinScriptPointcutsExamples new.
	example script: script.
	example exampleSquared.
	example exampleSquared.
	self assert: script counter equals: 2.
	self assert: example result equals: 16
]

{ #category : 'tests' }
SindarinTDebuggerTest >> testScriptExecution [

	| example |
	example := SindarinScriptPointcutsExamples new.
	example script: script.
	example exampleSquared.
	self
		assert: script node
		identicalTo:
		(example class >> #exampleSquared) ast statements third value
			receiver.
	self assert: example result equals: 16
]

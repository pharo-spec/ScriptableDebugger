Class {
	#name : #TDebuggerScriptTest,
	#superclass : #TestCase,
	#instVars : [
		'script'
	],
	#category : #'Sindarin-Scripts-Tests-tests'
}

{ #category : #running }
TDebuggerScriptTest >> setUp [
	super setUp.
	
	script := SinDummyDebuggerScript new
]

{ #category : #tests }
TDebuggerScriptTest >> testDefaultArguments [
	self assertEmpty: script class defaultArguments.
	self assertEmpty: script arguments
]

{ #category : #tests }
TDebuggerScriptTest >> testDefaultHooks [
	self assertEmpty: script class defaultHooks.
	self assertEmpty: script hooks
]

{ #category : #tests }
TDebuggerScriptTest >> testDefaultPredicates [
	self assertEmpty: script class defaultPredicates.
	self assertEmpty: script predicates
]

{ #category : #tests }
TDebuggerScriptTest >> testDefaultShouldExecute [
	self assert: script shouldExecute
]

{ #category : #tests }
TDebuggerScriptTest >> testEmptyScriptExecution [

	self assert: (script executeWith: Object new) identicalTo: script
]

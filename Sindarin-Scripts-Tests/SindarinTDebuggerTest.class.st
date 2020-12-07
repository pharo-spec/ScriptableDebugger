Class {
	#name : #SindarinTDebuggerTest,
	#superclass : #TestCase,
	#instVars : [
		'script'
	],
	#category : #'Sindarin-Scripts-Tests-tests'
}

{ #category : #running }
SindarinTDebuggerTest >> setUp [
	super setUp.
	
	script := SindarinTestDebuggerScript new
]

{ #category : #tests }
SindarinTDebuggerTest >> testDefaultArguments [
	self assertEmpty: script class defaultArguments.
	self assertEmpty: script arguments
]

{ #category : #tests }
SindarinTDebuggerTest >> testDefaultHooks [
	self assertEmpty: script class defaultHooks.
	self assertEmpty: script hooks
]

{ #category : #tests }
SindarinTDebuggerTest >> testDefaultPredicates [
	self assertEmpty: script class defaultPredicates.
	self assertEmpty: script predicates
]

{ #category : #tests }
SindarinTDebuggerTest >> testDefaultShouldExecute [
	self assert: script shouldExecute
]

{ #category : #tests }
SindarinTDebuggerTest >> testEmptyScriptExecution [

	self assert: (script executeWith: Object new) identicalTo: script
]

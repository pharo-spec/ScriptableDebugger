"
An abstract class representing a script for the ScriptableDebugger.
Has an automatic mechanism to register its script on the ScriptableDebugger class.

## Instance variables
- `dbg`: the SindarinDebugger instance that will control the interrupted execution
"
Class {
	#name : 'SindarinScript',
	#superclass : 'Object',
	#instVars : [
		'dbg',
		'args'
	],
	#category : 'Sindarin-Scripts-core',
	#package : 'Sindarin-Scripts',
	#tag : 'core'
}

{ #category : 'accessing' }
SindarinScript >> arguments: anArray [
	args := anArray
]

{ #category : 'accessing' }
SindarinScript >> debugger [
	^dbg
]

{ #category : 'accessing' }
SindarinScript >> debugger: aSindarinDebugger [
	dbg := aSindarinDebugger 
]

{ #category : 'running' }
SindarinScript >> execute [
	"By default: does nothing"
]

{ #category : 'deprecated' }
SindarinScript >> execute: aScriptableDebugger [
	self subclassResponsibility
]

{ #category : 'deprecated' }
SindarinScript >> execute: aScriptableDebugger withArgs: anOrderedCollection [
	self subclassResponsibility.
]

{ #category : 'running' }
SindarinScript >> executeWith: aSindarinDebugger [
	dbg := aSindarinDebugger.
	self execute
]

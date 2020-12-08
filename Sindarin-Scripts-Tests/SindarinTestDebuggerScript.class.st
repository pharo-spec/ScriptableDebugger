"
I am a dummy sindaring debugging script for test purposes
"
Class {
	#name : #SindarinTestDebuggerScript,
	#superclass : #Object,
	#traits : 'TDebuggerScript',
	#classTraits : 'TDebuggerScript classTrait',
	#instVars : [
		'node'
	],
	#category : #'Sindarin-Scripts-Tests-utils'
}

{ #category : #executing }
SindarinTestDebuggerScript >> executeWith: aDebugger [

	node inspect.
	node := aDebugger node.
	aDebugger resume
]

{ #category : #accessing }
SindarinTestDebuggerScript >> node [

	^ node
]

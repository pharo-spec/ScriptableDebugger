"
I am a dummy sindaring debugging script for test purposes
"
Class {
	#name : 'SindarinTestDebuggerScript',
	#superclass : 'Object',
	#traits : 'TDebuggerScript',
	#classTraits : 'TDebuggerScript classTrait',
	#instVars : [
		'node',
		'counter'
	],
	#category : 'Sindarin-Scripts-Tests-utils',
	#package : 'Sindarin-Scripts-Tests',
	#tag : 'utils'
}

{ #category : 'accessing' }
SindarinTestDebuggerScript >> counter [

	^ counter
]

{ #category : 'executing' }
SindarinTestDebuggerScript >> executeWith: aDebugger [

	node := aDebugger node.
	counter := counter + 1
]

{ #category : 'executing' }
SindarinTestDebuggerScript >> initialize [ 
	counter := 0
]

{ #category : 'accessing' }
SindarinTestDebuggerScript >> node [

	^ node
]

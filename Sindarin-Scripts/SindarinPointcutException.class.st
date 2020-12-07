"
I am an exception raised when the execution reaches a given point in the code (an ast).
When that happens, I require the system to debug me.
Only Sindarin can debug me.
When Sindarin debugs me, it executes the debugging script that I reference.

"
Class {
	#name : #SindarinPointcutException,
	#superclass : #Exception,
	#instVars : [
		'script'
	],
	#category : #'Sindarin-Scripts'
}

{ #category : #debugging }
SindarinPointcutException class >> debug [
	^self new debug
]

{ #category : #handling }
SindarinPointcutException >> debug [
	signalContext := thisContext contextTag.
	signaler ifNil: [ signaler := self receiver ].
	super debug
]

{ #category : #testing }
SindarinPointcutException >> isHandleableBy: aDebugger [
	^aDebugger == SindarinDebugger 
]

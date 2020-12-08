"
I provide examples of code to instrument for testing Sindarin scripts pointcuts
"
Class {
	#name : #SindarinScriptPointcutsExamples,
	#superclass : #Object,
	#instVars : [
		'script'
	],
	#category : #'Sindarin-Scripts-examples'
}

{ #category : #examples }
SindarinScriptPointcutsExamples >> exampleSquared [
	|init square|
	init := 2.
	script execute.
	square := init squared.
	^square squared
	
	
]

{ #category : #accessing }
SindarinScriptPointcutsExamples >> script [

	^ script
]

{ #category : #accessing }
SindarinScriptPointcutsExamples >> script: anObject [

	script := anObject
]

"
I provide examples of code to instrument for testing Sindarin scripts pointcuts
"
Class {
	#name : #SindarinScriptPointcutsExamples,
	#superclass : #Object,
	#category : #'Sindarin-Scripts-examples'
}

{ #category : #'as yet unclassified' }
SindarinScriptPointcutsExamples >> exampleSquared [
	|init square|
	init := 2.
	square := init squared.
	^square squared
	
	
]

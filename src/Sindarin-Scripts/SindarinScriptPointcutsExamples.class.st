"
I provide examples of code to instrument for testing Sindarin scripts pointcuts
"
Class {
	#name : 'SindarinScriptPointcutsExamples',
	#superclass : 'Object',
	#instVars : [
		'script',
		'result'
	],
	#category : 'Sindarin-Scripts-examples',
	#package : 'Sindarin-Scripts',
	#tag : 'examples'
}

{ #category : 'examples' }
SindarinScriptPointcutsExamples >> exampleSquared [
	|init square|
	init := 2.
	script execute.
	square := init squared.
	result := square squared
	
	
]

{ #category : 'accessing' }
SindarinScriptPointcutsExamples >> result [

	^ result
]

{ #category : 'accessing' }
SindarinScriptPointcutsExamples >> script [

	^ script
]

{ #category : 'accessing' }
SindarinScriptPointcutsExamples >> script: anObject [

	script := anObject
]

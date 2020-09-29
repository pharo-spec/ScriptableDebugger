Class {
	#name : #SindarinPointcutExample,
	#superclass : #Object,
	#category : #'Sindarin-Pointcuts'
}

{ #category : #'as yet unclassified' }
SindarinPointcutExample >> exampleSquared [
	|init square|
	init := 2.
	square := init squared.
	'Resumed.' crTrace.
	^square squared
	
	
]

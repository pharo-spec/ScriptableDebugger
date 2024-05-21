"
Start demo:
dbg := SindarinDebugger debug: [ SindarinDemo_GoldDigger new start ]

Demo script:
dbg step: 3; stepOver: 2; step: 3.

"
Class {
	#name : 'SindarinDemo_GoldDigger',
	#superclass : 'Object',
	#category : 'Sindarin-Demo',
	#package : 'Sindarin-Demo'
}

{ #category : 'as yet unclassified' }
SindarinDemo_GoldDigger >> gold [
	^ 42
]

{ #category : 'as yet unclassified' }
SindarinDemo_GoldDigger >> moreRock [
	^self
]

{ #category : 'as yet unclassified' }
SindarinDemo_GoldDigger >> rock [
	self halt.
	self rock1
]

{ #category : 'as yet unclassified' }
SindarinDemo_GoldDigger >> rock1 [
	self rock2
]

{ #category : 'as yet unclassified' }
SindarinDemo_GoldDigger >> rock2 [
	self rock3
]

{ #category : 'as yet unclassified' }
SindarinDemo_GoldDigger >> rock3 [
	self moreRock.
	self moreRock.
	self rock4.
]

{ #category : 'as yet unclassified' }
SindarinDemo_GoldDigger >> rock4 [
	self rock5.
]

{ #category : 'as yet unclassified' }
SindarinDemo_GoldDigger >> rock5 [
	self rock6.
]

{ #category : 'as yet unclassified' }
SindarinDemo_GoldDigger >> rock6 [
	"Relevant point for the bug you are tracking"
	self gold.
]

{ #category : 'as yet unclassified' }
SindarinDemo_GoldDigger >> start [
	self rock
]

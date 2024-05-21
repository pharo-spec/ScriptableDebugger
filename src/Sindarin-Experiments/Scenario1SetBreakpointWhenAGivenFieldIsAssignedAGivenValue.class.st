Class {
	#name : 'Scenario1SetBreakpointWhenAGivenFieldIsAssignedAGivenValue',
	#superclass : 'Object',
	#instVars : [
		'var'
	],
	#category : 'Sindarin-Experiments',
	#package : 'Sindarin-Experiments'
}

{ #category : 'as yet unclassified' }
Scenario1SetBreakpointWhenAGivenFieldIsAssignedAGivenValue >> doNothing [
	^ 1
	
]

{ #category : 'as yet unclassified' }
Scenario1SetBreakpointWhenAGivenFieldIsAssignedAGivenValue >> helper1 [
	self doNothing.
	self helper2.
	var := nil.
	self doNothing.
]

{ #category : 'as yet unclassified' }
Scenario1SetBreakpointWhenAGivenFieldIsAssignedAGivenValue >> helper2 [
	var := 2.
	self doNothing.
	self helper3.
	
]

{ #category : 'as yet unclassified' }
Scenario1SetBreakpointWhenAGivenFieldIsAssignedAGivenValue >> helper3 [
	var := nil.
	
]

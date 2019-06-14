Class {
	#name : #Scenario1SetBreakpointWhenAGivenFieldIsAssignedAGivenValue,
	#superclass : #Object,
	#instVars : [
		'var'
	],
	#category : #'ScriptableDebugger-Tests'
}

{ #category : #run }
Scenario1SetBreakpointWhenAGivenFieldIsAssignedAGivenValue class >> runScenario [
	"When ran, this code sets breakpoints on the two 'var := nil' statements in Clazz's methods, but not on 'var := 1'. Do not forget to remove the breakpoints manually after running this method."
	<script>
	| scdbg |
	scdbg := ScriptableDebuggerOld debug: [ self class new helper1 ].
	[scdbg isExecutionFinished] whileFalse: [ |node| node := scdbg currentNode. ((node isAssignment) and: [ (node variable name = #var) and: [(scdbg class: (scdbg currentReceiver class) isEqualOrSubclassOf: self class ) and: [scdbg topValueOfCurrentContextValueStack == nil]]]) ifTrue: [ scdbg setVBreakpoint ]. scdbg step. ].
	scdbg commitVBreakpoints.
]

{ #category : #'as yet unclassified' }
Scenario1SetBreakpointWhenAGivenFieldIsAssignedAGivenValue >> doNothing [
	^ 1
	
]

{ #category : #'as yet unclassified' }
Scenario1SetBreakpointWhenAGivenFieldIsAssignedAGivenValue >> helper1 [
	self doNothing.
	self helper2.
	var := nil.
	self doNothing.
]

{ #category : #'as yet unclassified' }
Scenario1SetBreakpointWhenAGivenFieldIsAssignedAGivenValue >> helper2 [
	var := 2.
	self doNothing.
	self helper3.
	
]

{ #category : #'as yet unclassified' }
Scenario1SetBreakpointWhenAGivenFieldIsAssignedAGivenValue >> helper3 [
	var := nil.
	
]

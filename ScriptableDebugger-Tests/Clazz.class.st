Class {
	#name : #Clazz,
	#superclass : #Scenario1SetBreakpointWhenAGivenFieldIsAssignedAGivenValue,
	#instVars : [
		'var'
	],
	#category : #'ScriptableDebugger-Tests'
}

{ #category : #run }
Clazz class >> runScenario [
	"When ran, this code sets breakpoints on the two 'var := nil' statements in Clazz's methods, but not on 'var := 1'. Do not forget to remove the breakpoints manually after running this method."
	<script>
	| scdbg |
	scdbg := ScriptableDebuggerOld debug: [ Clazz new helper1 ].
	[scdbg isExecutionFinished] whileFalse: [ |node| node := scdbg currentNode. ((node isAssignment) and: [ (node variable name = #var) and: [(scdbg class: (scdbg currentReceiver class) isEqualOrSubclassOf: Clazz ) and: [scdbg topValueOfCurrentContextValueStack == nil]]]) ifTrue: [ scdbg setVBreakpoint ]. scdbg step. ].
	scdbg commitVBreakpoints.
]

{ #category : #'as yet unclassified' }
Clazz >> doNothing [
	^ 1
	
]

{ #category : #'as yet unclassified' }
Clazz >> helper1 [
	self doNothing.
	self helper2.
	var := nil.
	self doNothing.
]

{ #category : #'as yet unclassified' }
Clazz >> helper2 [
	var := 2.
	self doNothing.
	self helper3.
	
]

{ #category : #'as yet unclassified' }
Clazz >> helper3 [
	var := nil.
	
]

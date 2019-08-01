"
Represent the fact that the debugged execution stopped because it was about to signal a Halt exception (typically when reaching a `self halt`)
"
Class {
	#name : #'ExecutionStop_Halt',
	#superclass : #ExecutionStop,
	#category : #Sindarin
}

{ #category : #testing }
ExecutionStop_Halt >> isHalt [
	^ true
]

"
Represent the fact that the debugged execution stopped because it was about to signal the Break exception (typically when reaching a metalink breakpoint)
"
Class {
	#name : #'ExecutionStop_Break',
	#superclass : #ExecutionStop,
	#category : #Sindarin
}

{ #category : #testing }
ExecutionStop_Break >> isBreak [
	^ true
]

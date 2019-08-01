"
Represent the fact that the debugged execution stopped because it finished (the execution is complete)
"
Class {
	#name : #'ExecutionStop_ExecutionFinished',
	#superclass : #ExecutionStop,
	#category : #Sindarin
}

{ #category : #testing }
ExecutionStop_ExecutionFinished >> isExecutionFinished [
	^ true
]

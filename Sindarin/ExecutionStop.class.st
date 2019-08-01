"
Represents the reason why a debugged execution stopped (typically after it was told to #continue)
"
Class {
	#name : #ExecutionStop,
	#superclass : #Object,
	#category : #Sindarin
}

{ #category : #testing }
ExecutionStop >> isBreak [
	^ false
]

{ #category : #testing }
ExecutionStop >> isExecutionFinished [
	^ false
]

{ #category : #testing }
ExecutionStop >> isHalt [
	^ false
]

{ #category : #testing }
ExecutionStop >> isVirtualBreakpoint [
	^ false
]

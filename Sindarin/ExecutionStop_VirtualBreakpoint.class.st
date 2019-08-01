"
Represent the fact that the debugged execution stopped because it reached a virtual breakpoint (class VirtualBreakpoint)
"
Class {
	#name : #'ExecutionStop_VirtualBreakpoint',
	#superclass : #ExecutionStop,
	#instVars : [
		'virtualBreakpoint'
	],
	#category : #Sindarin
}

{ #category : #testing }
ExecutionStop_VirtualBreakpoint >> isVirtualBreakpoint [
	^ true
]

{ #category : #accessing }
ExecutionStop_VirtualBreakpoint >> virtualBreakpoint [
	^ virtualBreakpoint
]

{ #category : #accessing }
ExecutionStop_VirtualBreakpoint >> virtualBreakpoint: anObject [
	virtualBreakpoint := anObject
]

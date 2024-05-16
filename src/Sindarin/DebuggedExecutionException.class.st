Class {
	#name : 'DebuggedExecutionException',
	#superclass : 'Error',
	#category : 'Sindarin-Exceptions',
	#package : 'Sindarin',
	#tag : 'Exceptions'
}

{ #category : 'testing' }
DebuggedExecutionException >> isExceptionSignalledForDebuggedExecution [
	^ true
]

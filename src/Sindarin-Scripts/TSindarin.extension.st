Extension { #name : 'TSindarin' }

{ #category : '*Sindarin-Scripts' }
TSindarin classSide >> debugSessionWithScript: aDebugSession [

	| debugger exception sindarinPointCutExceptionClass |
	debugger := self debugSession: aDebugSession.
	
	exception := aDebugSession exception.
	sindarinPointCutExceptionClass := Smalltalk at: #SindarinPointcutException ifAbsent:[nil].
	exception class == sindarinPointCutExceptionClass ifFalse: [ 
		aDebugSession resume; clear.
		^ self ].
	
	"Stepping to return to the context requesting the execution of a Sindarin script"
	debugger step.
	debugger step.
	exception script executeWith: debugger.
	aDebugSession resume; clear; terminate
	
]

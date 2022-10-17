Extension { #name : #DebugSession }

{ #category : #'*Sindarin' }
DebugSession >> asSindarinDebugSession [
	^ SindarinDebugSession new debugSession: self
]

{ #category : #'*Sindarin' }
DebugSession >> suspendedContext: aContext [ 
	
	interruptedContext := aContext
]

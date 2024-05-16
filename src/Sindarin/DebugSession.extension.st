Extension { #name : 'DebugSession' }

{ #category : '*Sindarin' }
DebugSession >> asSindarinDebugSession [
	^ SindarinDebugSession new debugSession: self
]

{ #category : '*Sindarin' }
DebugSession >> stepToFirstInterestingBytecodeWithJumpIn: aProcess [
	"After a restart of a method activation step to the first 
	bytecode instruction that is of interest for the debugger.
	
	In this case step until a bytecode that causes a context switch,
	as otherwise one will have to press may time step into without 
	seeing any visible results."
	
	"If we are are stepping into a quick method,
	make sure that we step correctly over the first primitive bytecode"
	| suspendedContext |
	suspendedContext := aProcess suspendedContext.
	(suspendedContext method isQuick and: [ suspendedContext pc == suspendedContext method initialPC ])
		ifTrue: [ ^ suspendedContext updatePCForQuickPrimitiveRestart ].
	
	^ aProcess stepToSendOrReturnOrJump
]

{ #category : '*Sindarin' }
DebugSession >> suspendedContext: aContext [ 
	
	interruptedContext := aContext
]

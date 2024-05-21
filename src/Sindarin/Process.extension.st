Extension { #name : 'Process' }

{ #category : '*Sindarin' }
Process >> stepToSendOrReturnOrJump [

	^Processor activeProcess
		evaluate: [suspendedContext := suspendedContext stepToSendOrReturnOrJump]
		onBehalfOf: self
]

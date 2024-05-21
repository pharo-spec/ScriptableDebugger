Extension { #name : 'Context' }

{ #category : '*Sindarin' }
Context >> stepToSendOrReturnOrJump [

	"Simulate the execution of bytecodes until either sending a message or 
	returning a value to the receiver (that is, until switching contexts)."

	| stream context |
	stream := InstructionStream on: method pc: pc.
	[ 
	self isDead or: [ 
		stream willSendOrReturnOrStoreOrCreateBlock or: [ stream willJump ] ] ] 
		whileFalse: [ 
			context := stream interpretNextInstructionFor: self.
			context == self ifFalse: [ "Caused by mustBeBoolean handling" 
				^ context ] ]
]

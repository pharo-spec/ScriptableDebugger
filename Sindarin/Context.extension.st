Extension { #name : #Context }

{ #category : #'*Sindarin' }
Context >> stepToSendOrReturnOrJump [
	"Simulate the execution of bytecodes until either sending a message or 
	returning a value to the receiver (that is, until switching contexts)."

	| stream context |
	stream := InstructionStream on: method pc: pc.	
	[ self isDead or: [ stream willSend or: [ stream willReturn or: [ stream willStore or: [ stream willCreateBlock or: [ stream willJumpIfFalse or:[ stream willJumpIfTrue or: [ stream willJumpTo ] ] ] ] ] ] ] ]
		whileFalse: [
			context := stream interpretNextInstructionFor: self.
			context == self ifFalse: [
				"Caused by mustBeBoolean handling"
				^context ]]
]

Extension { #name : #InstructionStream }

{ #category : #'*Sindarin' }
InstructionStream >> willJump [
	"Answer whether the next bytecode will jump."

	^ self willJumpIfFalse or:[ self willJumpIfTrue or: [ self willJumpTo ] ]
]

{ #category : #'*Sindarin' }
InstructionStream >> willJumpIfTrue [
	"Answer whether the next bytecode is a jump-if-false."

	^ self method encoderClass isBranchIfTrueAt: pc in: self method
]

{ #category : #'*Sindarin' }
InstructionStream >> willJumpTo [
	"Answer whether the next bytecode is a jump-if-false."

	^ self method encoderClass isJumpAt: pc in: self method
]

{ #category : #'*Sindarin' }
InstructionStream >> willSendOrReturnOrStoreOrCreateBlock [

	"Answer whether the next bytecode will be interesting for the debugger to stop."

	^ self willSend or: [ 
		  self willReturn or: [ self willStore or: [ self willCreateBlock ] ] ]
]

Extension { #name : #InstructionStream }

{ #category : #'*Sindarin' }
InstructionStream >> willJumpIfFalse [
	"Answer whether the next bytecode is a jump-if-false."

	^ self method encoderClass isBranchIfFalseAt: pc in: self method
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

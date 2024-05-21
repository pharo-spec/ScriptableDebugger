"
# Start
Get a ScriptableDebugger instance by doing: `ScriptableDebugger debug: [ <your execution> ]`.
Alternatively, you can get a ScriptableDebugger instance attached on an already existing DebugSession by doing: `ScriptableDebugger attach: aDebugSession` 

# Breakpoints
ScriptableDebugger uses the VirtualBreakpoints class for its breakpoints. 
The breakpoints set by ScriptableDebugger are ""virtual"", in the sense that they do not modify any bytecode (as common breakpoints do) and do not show up in the rest of the IDE. They are simply markers indicating that the scritpable debugger should stop the debugged execution if it reaches an ast node or method on which a virtual breakpoint has been set. A virtual breakpoint set by a scriptable debugger instance is ""visible"" by all other scriptable debugger instances.

Virtual breakpoints were introduced because due to technical limitations, normal breakpoints cannot be set in methods that are already in the stack of the debugged execution.

# Instance Variables:
- process: the (suspended) Process in which the debugged execution takes place
- debugSession: the DebugSession monitoring the debugged execution.
- stepHooks: OrderedCollection<Block>. A list of blocks to be evaluated after each step of the debugged execution
"
Class {
	#name : 'SindarinDebugger',
	#superclass : 'Object',
	#traits : 'TDebugger + TSindarin',
	#classTraits : 'TDebugger classTrait + TSindarin classTrait',
	#category : 'Sindarin-Base',
	#package : 'Sindarin',
	#tag : 'Base'
}

{ #category : 'stackAccessHelpers' }
SindarinDebugger >> assignmentValue [
	"Returns the value about to be assigned, if the current node is an assignment node. Otherwise, returns nil"
	self flag: 'Why there is no error raised here, while for the case of message sends there is an error?'.
	self isAssignment ifFalse: [
		^ nil "Error signal: 'Not about to perform a assignment'" ].
	^ self context at: self currentContextStackSize
]

{ #category : 'stackAccessHelpers' }
SindarinDebugger >> assignmentVariableName [
	"Returns the variable name about to be assigned to, if the current node is an assignment node. Otherwise, returns nil"
	self flag: 'Why there is no error raised in the case of assignemnts, while there is one for message sends?'.
	self isAssignment ifFalse: [
		^ nil "Error signal: 'Not about to perform a assignment'" ].
	^ self node variable name
]

{ #category : 'astAndAstMapping' }
SindarinDebugger >> bestNodeFor: anInterval [

	^ self node methodNode bestNodeFor: anInterval
]

{ #category : 'ast manipulation' }
SindarinDebugger >> canStillExecute: aProgramNode [
	"returns true if the last pc mapped to aProgramNode is greater than `self pc` in the right context "

	| lastPcForNode rightContext |
	rightContext := self context.

	[
	rightContext == rightContext outerMostContext or: [
		rightContext method ast allChildren identityIncludes: aProgramNode ] ]
		whileFalse: [ rightContext := rightContext sender ].

	lastPcForNode := (rightContext method ast lastPcForNode: aProgramNode)
		                 ifNil: [ 0 ].

	^ rightContext pc < lastPcForNode
]

{ #category : 'execution predicates' }
SindarinDebugger >> contextIsAboutToSignalException: aContext [
	"Returns whether aContext is about to execute a message-send of selector #signal to an instance of the Exception class (or one of its subclasses)"

	| node |
	node := self node.
	self isMessageSend ifFalse: [ ^ false ].
	(#( #signal #signalIn: ) includes: node selector) ifFalse: [ ^ false ].
	aContext basicSize >= 1 ifFalse: [ ^ false ].
	(Exception allSubclasses includes: (aContext at: aContext basicSize))
		ifTrue: [ ^ true ]. "#signal sent to a subclass of Exception"
	^(Exception allSubclasses includes: (aContext at: aContext basicSize) class) "#signal sent to an instance of a subclass of Exception"

]

{ #category : 'stepping - auto' }
SindarinDebugger >> continue [
	"Steps the execution until it:
	- is about to signal an exception.
	- has finished"
	self flag: 'What''s the difference between this and #resume?'.
	[ self isExecutionFinished or: [ self isAboutToSignalException ] ]
		whileFalse: [ self step ]
]

{ #category : 'accessing' }
SindarinDebugger >> firstPCOfStatement: aStatementNode [

	^ self methodNode firstPCOfStatement: aStatementNode
]

{ #category : 'execution predicates' }
SindarinDebugger >> hasSignalledUnhandledException [
	"Returns true if the debugged execution has signalled an exception that has not been handled by any on:do: (i.e. the #defaultAction of the exception is about to be executed. This default action typically leads to opening a debugger on the process that signalled the exception)"

	^ (#( #defaultAction #signal #signalIn: ) includes: self selector) and: [
		  self receiver isKindOf: Exception ]
]

{ #category : 'execution predicates' }
SindarinDebugger >> isAboutToInstantiateClass [

	| methodAboutToExecute |
	self isMessageSend ifFalse: [ ^ false ].
	methodAboutToExecute := self receiver class lookupSelector:
		                        self node selector.
	^ methodAboutToExecute notNil and: [ 
		  self instanceCreationPrimitives includes:
			  methodAboutToExecute primitive ]
]

{ #category : 'execution predicates' }
SindarinDebugger >> isAboutToSignalException [

	^ self contextIsAboutToSignalException: self context
]

{ #category : 'API - changes' }
SindarinDebugger >> jumpIntoBlock: aBlockNode toNode: targetNode [
	"Moves to targetNode that must be in aBlockNode, which should be a recursive child"

	| blockClosure newContext firstPCForNode |
	"To jump into a block, we change pc to the block creation pc and we step it to get the block closure and create a new context for it. Then, we call moveToNode: recursively to go to the correct pc in the new context (or to create even more contexts if we want to enter embedded blocks)"
	firstPCForNode := self methodNode firstPcForNode: aBlockNode.
	self pc: firstPCForNode.
	self stepBytecode.
	blockClosure := self topStack.
	newContext := blockClosure asContextWithSender: self context.

	"we need to change the suspended context and do the same in its debug session to see what we do in the debugger"
	self currentProcess suspendedContext: newContext.
	self debugSession suspendedContext: newContext.
	^ self moveToNode: targetNode
]

{ #category : 'stackAccessHelpers' }
SindarinDebugger >> message: aSelector [
	"Returns whether the execution is about to send a message of selector @aSelector to any object"

	^ self isMessageSend and: [ self messageSelector = aSelector ]
]

{ #category : 'stackAccessHelpers' }
SindarinDebugger >> message: aSelector to: anObject [
	"Returns whether the execution is about to send a message of selector @aSelector to @anObject"

	^ (self message: aSelector) and: [ self messageReceiver == anObject ]
]

{ #category : 'stackAccessHelpers' }
SindarinDebugger >> message: aSelector toInstanceOf: aClass [
	"Returns whether the execution is about to send a message of selector @aSelector to an instance of class @aClass"

	| node |
	node := self node.
	self isMessageSend ifFalse: [ ^ false ].
	node selector = aSelector ifFalse: [ ^ false ].
	^ self messageReceiver isKindOf: aClass
]

{ #category : 'stackAccessHelpers' }
SindarinDebugger >> messageArguments [
	"Returns the arguments of the message about to be sent, if the current node is a message node."

	| argumentNumber arguments i |
	self isMessageSend ifFalse: [
		Error signal: 'Not about to send a message' ].
	argumentNumber := self node arguments size.
	arguments := OrderedCollection new.
	i := 0.
	[ i = argumentNumber ] whileFalse: [
		arguments add: (self context at:
				 self currentContextStackSize - argumentNumber + i + 1).
		i := i + 1 ].
	^ arguments
]

{ #category : 'stackAccessHelpers' }
SindarinDebugger >> messageReceiver [
	"Returns the receiver of the message about to be sent, if the current node is a message node."

	self isMessageSend
		ifFalse: [ Error signal: 'Not about to send a message' ].
	^ self context
		at: self currentContextStackSize - self node arguments size
]

{ #category : 'stackAccessHelpers' }
SindarinDebugger >> messageSelector [
	"Returns the selector of the message about to be sent, if the current node is a message node."

	self isMessageSend
		ifFalse: [ Error signal: 'Not about to send a message' ].
	^ self node selector
]

{ #category : 'API - changes' }
SindarinDebugger >> moveToNode: aNode [

	"Allows to jump to the first bytecode offset associated to aNode, as long as aNode is in the same lexical context as the suspended context"

	| firstPCForNode |
	firstPCForNode := self methodNode firstPcForNode: aNode.

	firstPCForNode ifNil: [ "If a node does not have any associated pc and if it is not a child in the method node then, aNode may be identical to the method node or its body, in which case, we move to the endPC. Otherwise, we check if it is a child in the home context's method node. If this is the case, this means we want to exit a block context. Otherwise, aNode is not a child in the home context's method node"
		(self methodNode parentOfIdenticalSubtree: aNode)
			ifNil: [ 
				(aNode == self methodNode or: [ aNode == self methodNode body ])
					ifTrue: [ firstPCForNode := self method endPC ]
					ifFalse: [ 
						^ self context ~~ self context home
							ifTrue: [ self tryMoveToNodeInHomeContext: aNode ]
							ifFalse: [ NodeNotInASTError signal ] ] ]
			ifNotNil: [ :parent | 
				| nextNode |
				"If a node does not have any associated pc but this node is a child in the method node then, we go to the next node that will be executed (so in pre-order) and that has an associated pc in this context."
				nextNode := self nextExecutedNodeAfter: aNode.
				firstPCForNode := self methodNode firstPcForNode: nextNode.
				nextNode isBlock ifTrue: [ "If the node after aNode is a block node, then this means we want to enter a block." 
					^ self jumpIntoBlock: nextNode toNode: aNode ] ] ].

	self pc: firstPCForNode
]

{ #category : 'accessing - bytes' }
SindarinDebugger >> nextBytecode [

	^ self symbolicBytecodesForCurrent detect: [ :each | 
		  each offset = self pc ]
]

{ #category : 'API - changes' }
SindarinDebugger >> nextExecutedNodeAfter: aNode [

	^ self methodNode nextExecutedNodeAfter: aNode
]

{ #category : 'API - changes' }
SindarinDebugger >> pc: anInteger [
	"Allows to move to the first PC associated to the node to which anInteger is associated. anInteger must be a valid pc in the suspended context"

	| nextNode methodNode firstPCOfStatementNode |
	"If aimedPC is outside the context PCs range, then an error is signaled"
	(anInteger < self method initialPC or: [
		 anInteger > self method endPC ]) ifTrue: [
		^ NotValidPcError signal ].
	methodNode := self methodNode.
	nextNode := methodNode sourceNodeForPC: anInteger.
	"If the aimed node is associated to the method node or its body, then we suppose that it is wanted and we'll get there directly"
	(nextNode == methodNode or: [ nextNode == methodNode body ])
		ifTrue: [ firstPCOfStatementNode := anInteger ]
		ifFalse: [ "If not, we skip to the wanted node, from the first (recursive) pc of the first statement node. We don't skip from the method node initial pc, otherwise we would create again the temp variables and lose their values."
			firstPCOfStatementNode := self firstPCOfStatement:
				                          methodNode statements first.
			self cleanStack ].
	self context pc: firstPCOfStatementNode.

	"If the first pc of the first statement is mapped to a block creation. That means that it needs the associated temp vector on top of the stack. The bytecode that pushes this vector on the stack precedes the block creation. So, here, this bytecode is mapped to the method node and has been skipped. Thus, we go back to the previous bytecode to execute it."
	self instructionStream willCreateBlock ifTrue: [
		self context pc: self instructionStream previousPc.
		self stepBytecode ].

	self debugSession stepToFirstInterestingBytecodeIn:
		self debugSession interruptedProcess.
	self skipUpToNode: nextNode
]

{ #category : 'stepping - auto' }
SindarinDebugger >> proceed [
	"alias of #continue"

	^ self continue
]

{ #category : 'asserting' }
SindarinDebugger >> shouldStepIntoInMethod: aRBMethodNode [
	"used by #stpeToReturn to know if it should stepInto or stepOver. It should stepInto to get to non-local returns"

	| messageNode childrenOfMessageNode |
	messageNode := self node.
	self isMessageSend ifFalse: [ ^ false ].
	childrenOfMessageNode := messageNode children.
	childrenOfMessageNode := childrenOfMessageNode
		                         select: [ :child |
			                         child isBlock or: [
				                         child isVariable and: [
					                         (child variableValueInContext:
						                          self context) isBlock ] ] ]
		                         thenCollect: [ :child |
			                         child isVariable ifTrue: [
				                         (child variableValueInContext:
					                          self context) startpcOrOuterCode ast ] ].
	^ childrenOfMessageNode anySatisfy: [ :child |
		  (RBBlockDefinitionSearchingVisitor newToSearch: child) visitNode:
			  aRBMethodNode ]
]

{ #category : 'private' }
SindarinDebugger >> signalExceptionIfDebuggedExecutionHasSignalledUnhandledException [

	| unhandledException |
	self hasSignalledUnhandledException ifFalse: [ ^ self ].

	"The debugged execution signalled an exception, this exception was not handled and is about to cause a debugger to open. Signalling an exception **in the scriptable debugger's process** to inform the user of this"
	unhandledException := self receiver.
	UnhandledExceptionSignalledByADebuggedExecution signalWithException:
		unhandledException


	"ifTrue:
			[" "The debugged execution signalled an exception, this exception was not handled and is about to cause a debugger to open."
	"Signalling an exception **in the scriptable debugger's process** to inform the user of this"
	"unhandledException := self messageArguments at: 1.
			UnhandledExceptionSignalledByADebuggedExecution
				signalWithException: unhandledException ]"
]

{ #category : 'private' }
SindarinDebugger >> signalExceptionIfDebuggedExecutionIsFinished [
	"Signals an DebuggedExecutionIsFinished exception if the debugged execution is finished"

	self isExecutionFinished ifTrue: [
		DebuggedExecutionIsFinished signal ]
]

{ #category : 'stepping -  skip' }
SindarinDebugger >> skip [

	| instructionStream |
	instructionStream := self instructionStream.

	"We need to treat jumps before messages because if it is associated to a message node, it would pop the arguments of the message, that aren't on the stack if they are jumps"
	instructionStream willJump ifTrue: [ ^ self skipJump ].
	"A return bytecode can be on any node so have to treat it here systematically"
	instructionStream willReturn ifTrue: [ ^ self skipReturnNode ].

	self node skipWithDebugger: self
]

{ #category : 'stepping -  skip' }
SindarinDebugger >> skipAssignmentNodeCompletely [
	
	"Pop the value that will be assigned"
	self context pop.

	"If the assignment is a store bytecode and not a pop bytecode, we push the current value of the variable that was going to be assigned."
	self willStoreButNotPop ifTrue: [
		self context push:
			(self node variable variableValueInContext: self context) ].

	"Increase the pc to go over the assignment"
	self skipPcToNextBytecode.
	"Execute bytecodes the debugger usually executes without stopping the execution (for example popping the return value of the just executed message send if it is not used afterwards)"
	self debugSession stepToFirstInterestingBytecodeWithJumpIn:
		self debugSession interruptedProcess
]

{ #category : 'stepping -  skip' }
SindarinDebugger >> skipAssignmentNodeWith: replacementValue [

	"Pop the value to be assigned"
	self context pop.
	
	"Push the replacement value on the context's value stack, to simulate that the assignment happened and had value nil"
	self context push: replacementValue.
	self step.
	"Execute bytecodes the debugger usually executes without stopping the execution (for example popping the return value of the just executed message send if it is not used afterwards)"
	self debugSession stepToFirstInterestingBytecodeWithJumpIn:
		self debugSession interruptedProcess
]

{ #category : 'stepping -  skip' }
SindarinDebugger >> skipBlockNode [

	self skipPcToNextBytecode.

	self context push: nil.

	self debugSession stepToFirstInterestingBytecodeWithJumpIn:
		self debugSession interruptedProcess
]

{ #category : 'stepping -  skip' }
SindarinDebugger >> skipJump [

	| instructionStream |
	instructionStream := self instructionStream.
	"If the next bytecode is a jumpTrue: or a jumpFalse: bytecode, then it expects one argument on the stack. As we skip the jump bytecode, we pop it."
	(instructionStream willJumpIfFalse or: [
		 instructionStream willJumpIfTrue ]) ifTrue: [ self context pop ].
	self skipPcToNextBytecode.
	self debugSession stepToFirstInterestingBytecodeWithJumpIn:
		self debugSession interruptedProcess
]

{ #category : 'stepping -  skip' }
SindarinDebugger >> skipMessageNode [

	self node arguments do: [ :arg | self context pop ]. "Pop the arguments of the message send from the context's value stack"

	"Increase the pc to go over the message send"
	self skipPcToNextBytecode.
	"Execute bytecodes the debugger usually executes without stopping the execution (for example popping the return value of the just executed message send if it is not used afterwards)"
	self debugSession stepToFirstInterestingBytecodeWithJumpIn:
		self debugSession interruptedProcess
]

{ #category : 'stepping -  skip' }
SindarinDebugger >> skipMessageNodeWith: replacementValue [

	self node arguments do: [ :arg | self context pop ]. "Pop the arguments of the message send from the context's value stack"
	"Pop the receiver from the context's value stack"
	self context pop.
	"Push the replacement value on the context's value stack, to simulate that the message send happened and returned nil"
	self context push: replacementValue.
	"Increase the pc to go over the message send"
	self skipPcToNextBytecode.
	"Execute bytecodes the debugger usually executes without stopping the execution (for example popping the return value of the just executed message send if it is not used afterwards)"
	self debugSession stepToFirstInterestingBytecodeWithJumpIn:
		self debugSession interruptedProcess
]

{ #category : 'stepping -  skip' }
SindarinDebugger >> skipReturnNode [

	| node allReturnNodes |
	node := self node.

	"We collect the list of nodes associated to a return bytecode, via the IR"
	allReturnNodes := self method ir children flatCollect: [ :irSequence |
		                  irSequence sequence
			                  select: [ :irInstruction |
			                  irInstruction isReturn ]
			                  thenCollect: [ :irInstruction |
			                  irInstruction sourceNode ] ].
	"If this is the last node of the method that is mapped to a return bytecode, we can't skip it and we stop there."
	node == allReturnNodes last ifTrue: [
		^ SindarinSkippingReturnWarning signal:
			  'Cannot skip the last return in the method' ].

	self skipPcToNextBytecode.
	self debugSession stepToFirstInterestingBytecodeWithJumpIn:
		self debugSession interruptedProcess
]

{ #category : 'stepping -  skip' }
SindarinDebugger >> skipThroughNode: aProgramNode [
	"Skips execution until program counter reaches aProgramNode.
	Also skip the target node."

	self skipUpToNode: aProgramNode skipTargetNode: true
]

{ #category : 'stepping -  skip' }
SindarinDebugger >> skipToPC: aPC [

	"Skips execution until program counter reaches aPC."

	[ [ self pc >= aPC ] whileFalse: [ self skip ] ]
		on: SindarinSkippingReturnWarning
		do: [ ^ self ]
]

{ #category : 'stepping -  skip' }
SindarinDebugger >> skipUpToNode: aProgramNode [
	"Skips execution until program counter reaches aProgramNode.
	Does not skip the target node."

	self skipUpToNode: aProgramNode skipTargetNode: false
]

{ #category : 'stepping -  skip' }
SindarinDebugger >> skipUpToNode: aProgramNode skipTargetNode: skipTargetNode [

	"Skips execution until program counter reaches aProgramNode."
	[ 
	[ 
	self node ~~ aProgramNode and: [ 
		self canStillExecute: aProgramNode  ] ] whileTrue: [ 
		self skip ] ]
		on: SindarinSkippingReturnWarning
		do: [ ^ self ].
	aProgramNode isReturn ifTrue: [ ^ self ].
	skipTargetNode ifTrue: [ self skip ]
]

{ #category : 'stepping -  skip' }
SindarinDebugger >> skipWith: replacementValue [
	"If it is a message-send or assignment, skips the execution of the current instruction, and puts the replacementValue on the execution stack."

	"If the current node is a message send or assignment"

	(self isMessageSend not and: [ self isAssignment not ]) ifTrue: [
		^ self ].
	self node isMessage ifTrue: [
		^ self skipMessageNodeWith: replacementValue ].
	self node isAssignment ifTrue: [
		^ self skipAssignmentNodeWith: replacementValue ]
]

{ #category : 'ast manipulation' }
SindarinDebugger >> statementNodeContaining: aNode [

	| method statementNode parentOfStatementNode |
	method := self methodNode.
	statementNode := aNode.
	parentOfStatementNode := method parentOfIdenticalSubtree:
		                         statementNode.
	parentOfStatementNode
		ifNil: [ ^ NodeNotInASTError signal ]
		ifNotNil: [ 
			[ parentOfStatementNode isSequence ] whileFalse: [ 
				statementNode := parentOfStatementNode.
				parentOfStatementNode := parentOfStatementNode parent ] ].
	^ statementNode
]

{ #category : 'stepping - steps' }
SindarinDebugger >> step [
	"Executes the next instruction. If the instruction is a message-send, step inside it."

	self signalExceptionIfDebuggedExecutionHasSignalledUnhandledException.
	self signalExceptionIfDebuggedExecutionIsFinished.
	self basicStep
]

{ #category : 'stepping - steps' }
SindarinDebugger >> step: anInt [
	"Call the #step method @anInt times"

	anInt timesRepeat: [ self step ]
]

{ #category : 'stepping - steps' }
SindarinDebugger >> stepBytecode [
	"Executes the next bytecode"

	self flag: 'Needs to be tested'.
	self signalExceptionIfDebuggedExecutionHasSignalledUnhandledException.
	process completeStep: self debugSession context.
	self debugSession updateContextTo: process suspendedContext
]

{ #category : 'stepping - steps' }
SindarinDebugger >> stepOver [
	| startContext |
	self flag: 'Why don''t we use the stepOver from the debug session? Do we really need to use the #step that performs exception check and termination check every time?'.
	startContext := self context.
	self step.
	[ self context == startContext
		or: [ (startContext isDead or: [ self context isDead ])
				or: [ startContext hasSender: self context ]]]
		whileFalse: [ self step ]
]

{ #category : 'stepping - steps' }
SindarinDebugger >> stepOver: anInt [
	"Call the #stepOver method @anInt times"

	anInt timesRepeat: [ self stepOver ]
]

{ #category : 'stepping - steps' }
SindarinDebugger >> stepThrough [
	"Hacked for demonstration purposes to have a stepThrough"

	self signalExceptionIfDebuggedExecutionHasSignalledUnhandledException.
	self basicStepThrough
]

{ #category : 'stepping - steps' }
SindarinDebugger >> stepToMethodEntry [

	self flag:
		'Maybe all the instructionStream API should be in Sindarin, as helpers'.
	self stepUntil: [ self instructionStream willSend ].
	process step: self context.
	self debugSession updateContextTo: process suspendedContext
]

{ #category : 'stepping - steps' }
SindarinDebugger >> stepToReturn [

	| oldContext methodAST |
	oldContext := self outerMostContextOf: self context.
	methodAST := self context method ast.

	[
	((self outerMostContextOf: self context) = oldContext and: [
		 self instructionStream willReturn ]) or: [
		self hasSignalledUnhandledException ] ] whileFalse: [
		(self shouldStepIntoInMethod: methodAST)
			ifTrue: [ self basicStep ]
			ifFalse: [ self basicStepOver ] ]
]

{ #category : 'stepping - steps' }
SindarinDebugger >> stepUntil: aBlock [
	"Steps the execution until aBlock evaluates to true"

	aBlock whileFalse: [ self step ]
]

{ #category : 'API - changes' }
SindarinDebugger >> tryMoveToNodeInHomeContext: aNode [
	"Moves to node aNode if aNode is in the lexical context. Otherwise, the program state goes back to how it was before trying and signals an error as the node is not in AST"

	| oldContext |
	oldContext := self context.
	self currentProcess suspendedContext: oldContext home.
	self debugSession suspendedContext: oldContext home.
	[ self moveToNode: aNode ]
		on: NodeNotInASTError
		do: [
			self currentProcess suspendedContext: oldContext.
			self debugSession suspendedContext: oldContext.
			^ NodeNotInASTError signal ]
]

{ #category : 'execution predicates' }
SindarinDebugger >> willStoreButNotPop [

	^ self instructionStream willStoreButNotPop
]

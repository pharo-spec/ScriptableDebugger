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
	#name : #SindarinDebugger,
	#superclass : #Object,
	#traits : 'TDebugger',
	#classTraits : 'TDebugger classTrait',
	#instVars : [
		'process',
		'stepHooks',
		'sindarinSession',
		'blockToDebug'
	],
	#category : #'Sindarin-Base'
}

{ #category : #start }
SindarinDebugger class >> attachTo: aDebugSession [
	"Returns a new instance of ScriptableDebugger attached to aDebugSession"

	^ self new attachTo: aDebugSession
]

{ #category : #actions }
SindarinDebugger class >> closeAllDebuggers [
	<script>
	
	self allInstances do: [ :dbg | dbg terminate ]
]

{ #category : #start }
SindarinDebugger class >> debug: aBlock [
	"Creates an execution of aBlock and returns an instance of ScriptableDebugger attached to this execution"

	^ self new debug: aBlock
]

{ #category : #'instance creation' }
SindarinDebugger class >> debugSession: aDebugSession [

	| debugger exception sindarinPointCutExceptionClass |
	debugger := self attachTo: aDebugSession.
	
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

{ #category : #'graphical debugger' }
SindarinDebugger >> activateAutoRefreshOfAttachedGraphicalDebugger [
	sindarinSession activateEventTriggering.
	self refreshAttachedGraphicalDebugger
]

{ #category : #'step hook' }
SindarinDebugger >> addStepHook: aBlock [
	"Adds aBlock to the list of step hooks. Step hooks are executed after each step of the execution"

	stepHooks add: aBlock
]

{ #category : #stackAccessHelpers }
SindarinDebugger >> arguments [
	"Returns the arguments of the current stack-frame."

	^ self context arguments
]

{ #category : #stackAccessHelpers }
SindarinDebugger >> assignmentValue [
	"Returns the value about to be assigned, if the current node is an assignment node. Otherwise, returns nil"

	self node isAssignment
		ifFalse: [ ^ nil	"Error signal: 'Not about to perform a assignment'" ].
	^ self context at: self currentContextStackSize
]

{ #category : #stackAccessHelpers }
SindarinDebugger >> assignmentVariableName [
	"Returns the variable name about to be assigned to, if the current node is an assignment node. Otherwise, returns nil"

	self node isAssignment
		ifFalse: [ ^ nil	"Error signal: 'Not about to perform a assignment'" ].
	^ self node variable name
]

{ #category : #start }
SindarinDebugger >> attachTo: aDebugSession [
	"Attaches this scriptable debugger to an already existing instance of DebugSession or SindarinDebugSession"

	sindarinSession := aDebugSession asSindarinDebugSession.
	process := aDebugSession interruptedProcess.
	sindarinSession deactivateEventTriggering
]

{ #category : #astAndAstMapping }
SindarinDebugger >> bestNodeFor: anInterval [
	^self node methodNode bestNodeFor: anInterval
]

{ #category : #'ast manipulation' }
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

{ #category : #stackAccess }
SindarinDebugger >> context [
	"Returns a reification of the current stack-frame."

	^ self debugSession interruptedContext
]

{ #category : #private }
SindarinDebugger >> contextIsAboutToSignalException: aContext [
	"Returns whether aContext is about to execute a message-send of selector #signal to an instance of the Exception class (or one of its subclasses)"

	| node |
	node := aContext method methodNode bcToASTCache nodeForPC: aContext pc.
	node isMessage
		ifFalse: [ ^ false ].
	node selector = #signal
		ifFalse: [ ^ false ].
	aContext basicSize >= 1
		ifFalse: [ ^ false ].
	(Exception allSubclasses includes: (aContext at: aContext basicSize))
		ifTrue: [ ^ true ].	"#signal sent to a subclass of Exception"
	(Exception allSubclasses
		includes: (aContext at: aContext basicSize) class)
		ifTrue: [ ^ true ].	"#signal sent to an instance of a subclass of Exception"
	^ false
]

{ #category : #'stepping -  auto' }
SindarinDebugger >> continue [
	"Steps the execution until it:
	- is about to signal a Halt exception. In this case return #halt.
	- is about to signal a Break exception. In this case return #breakpoint.
	- has reached a virtual breakpoint. In this case return the virtual breakpoint.
	- has finished. In this case return nil."

	| signalMessageNode exceptionClassBeingSignalled stepHook |
	self flag: 'Sorry, this is shit :)'.
	stepHook := [ VirtualBreakpoint all
		detect: [ :vbrkpt | vbrkpt hitTest: self node ]
		ifFound: [ :vbrkpt | 
			self removeStepHook: stepHook.
			^ vbrkpt ] ].
	self addStepHook: stepHook.
	[ self isExecutionFinished
		or: [ self contextIsAboutToSignalException: self context ] ]
		whileFalse: [ self step ].
	self isExecutionFinished
		ifTrue: [ ^ nil ].
	signalMessageNode := self node.
	exceptionClassBeingSignalled := self context
		at: self context size - signalMessageNode arguments size.
	exceptionClassBeingSignalled == Halt
		ifTrue: [ "Encountered a Halt (typically signalled by a 'self halt')"
			self skip.
			self removeStepHook: stepHook.
			^ #halt ].
	exceptionClassBeingSignalled == Break
		ifTrue: [ "Encountered a Break (i.e. a breakpoint)"
			self skip.
			self removeStepHook: stepHook.
			^ #breakpoint ]
]

{ #category : #accessing }
SindarinDebugger >> currentBytecode [
	^ self context method symbolicBytecodes
]

{ #category : #private }
SindarinDebugger >> currentContextStackSize [
	^ self context basicSize
]

{ #category : #process }
SindarinDebugger >> currentProcess [
	^process
]

{ #category : #'graphical debugger' }
SindarinDebugger >> deactivateAutoRefreshOfAttachedGraphicalDebugger [
	sindarinSession deactivateEventTriggering
]

{ #category : #start }
SindarinDebugger >> debug: aBlock [
	blockToDebug := aBlock.
	process := aBlock newProcess name: 'ExecutionDebuggedByScriptableDebugger'.
	sindarinSession := SindarinDebugSession
		newWithName: 'ScriptableDebuggerDebugSession'
		forProcess: process.
	sindarinSession deactivateEventTriggering.
	"Step the process until it enters the block for which a process was created"
	[ self context closure == blockToDebug ] whileFalse: [ self step ]
]

{ #category : #accessing }
SindarinDebugger >> debugSession [
	"Returns the DebugSession representing the execution this ScriptableDebugger is debugging"

	^ sindarinSession debugSession
]

{ #category : #private }
SindarinDebugger >> hasSignalledUnhandledException [
	"Returns true if the debugged execution has signalled an exception that has not been handled by any on:do: (i.e. the #defaultAction of the exception is about to be executed. This default action typically leads to opening a debugger on the process that signalled the exception)"
	^ (#(#defaultAction #signal) includes: self selector ) and: [ self receiver isKindOf: Exception ]
]

{ #category : #initialization }
SindarinDebugger >> initialize [
	stepHooks := OrderedCollection new
]

{ #category : #private }
SindarinDebugger >> instanceCreationPrimitives [
	"* 70 */ primitiveNew,
	/* 71 */ primitiveNewWithArg,
	/* 79 */ primitiveNewMethod,
	/* 148 */ primitiveClone,
	/* 160 */ primitiveAdoptInstance"
	^#(70 71 79 148 160)
]

{ #category : #'execution predicates' }
SindarinDebugger >> isAboutToInstantiateClass [

	| methodAboutToExecute |
	self node isMessage ifFalse: [ ^ false ].
	methodAboutToExecute := self receiver class lookupSelector:
		                        self node selector.
	^ methodAboutToExecute notNil and: [ 
		  self instanceCreationPrimitives includes:
			  methodAboutToExecute primitive ]
]

{ #category : #private }
SindarinDebugger >> isAboutToSignalException [
	"OLD METHOD. SEE #hasSignalledUnhandledException"
	"Returns whether the debugged execution is about to signal an exception"
	^ (self node isMessage
		and: [ self messageSelector = #unhandledErrorDefaultAction:
				and: [ self messageReceiver isKindOf: UIManager ] ])
]

{ #category : #stackAccess }
SindarinDebugger >> isExecutionFinished [
	"Returns whether the debugged execution is finished"

	^ process isTerminated
]

{ #category : #stackAccessHelpers }
SindarinDebugger >> message: aSelector [
	"Returns whether the execution is about to send a message of selector @aSelector to any object"

	| node |
	node := self node.
	node isMessage
		ifFalse: [ ^ false ].
	node selector = aSelector
		ifFalse: [ ^ false ].
	^ true
]

{ #category : #stackAccessHelpers }
SindarinDebugger >> message: aSelector to: anObject [
	"Returns whether the execution is about to send a message of selector @aSelector to @anObject"

	| node |
	node := self node.
	node isMessage
		ifFalse: [ ^ false ].
	node selector = aSelector
		ifFalse: [ ^ false ].
	self messageReceiver == anObject
		ifFalse: [ ^ false ].
	^ true
]

{ #category : #stackAccessHelpers }
SindarinDebugger >> message: aSelector toInstanceOf: aClass [
	"Returns whether the execution is about to send a message of selector @aSelector to an instance of class @aClass"

	| node |
	node := self node.
	node isMessage
		ifFalse: [ ^ false ].
	node selector = aSelector
		ifFalse: [ ^ false ].
	(self messageReceiver isKindOf: aClass)
		ifFalse: [ ^ false ].
	^ true
]

{ #category : #stackAccessHelpers }
SindarinDebugger >> messageArguments [
	"Returns the arguments of the message about to be sent, if the current node is a message node."

	| argumentNumber arguments i |
	self node isMessage
		ifFalse: [ Error signal: 'Not about to send a message' ].
	argumentNumber := self node arguments size.
	arguments := OrderedCollection new.
	i := 0.
	[ i = argumentNumber ]
		whileFalse: [ arguments
				add:
					(self context
						at: self currentContextStackSize - argumentNumber + i + 1).
			i := i + 1 ].
	^ arguments
]

{ #category : #stackAccessHelpers }
SindarinDebugger >> messageReceiver [
	"Returns the receiver of the message about to be sent, if the current node is a message node."

	self node isMessage
		ifFalse: [ Error signal: 'Not about to send a message' ].
	^ self context
		at: self currentContextStackSize - self node arguments size
]

{ #category : #stackAccessHelpers }
SindarinDebugger >> messageSelector [
	"Returns the selector of the message about to be sent, if the current node is a message node."

	self node isMessage
		ifFalse: [ Error signal: 'Not about to send a message' ].
	^ self node selector
]

{ #category : #stackAccessHelpers }
SindarinDebugger >> method [
	"Returns the method of the current stack-frame."

	^ self context method
]

{ #category : #accessing }
SindarinDebugger >> methodNode [ 

	^ self method ast
]

{ #category : #'accessing - bytes' }
SindarinDebugger >> nextBytecode [

	^ self currentBytecode detect: [ :each | 
		  each offset = self context pc ]
]

{ #category : #astAndAstMapping }
SindarinDebugger >> node [
	"Returns the AST node about to be executed by the top context of the execution"

	^ self context method sourceNodeForPC: self context pc
]

{ #category : #astAndAstMapping }
SindarinDebugger >> nodeForContext: aContext [
	"Returns the AST node about to be executed by the top context of the execution"

	^ aContext method sourceNodeForPC: aContext pc
]

{ #category : #'graphical debugger' }
SindarinDebugger >> openInGraphicalDebugger [
	sindarinSession canBeTerminated: false.	"Prevents the graphical debugger from terminating the debug session when it's closed."
	self
		flag:
			'Should be an extension of DebuggerSelector and handled by its sole instance'
]

{ #category : #'accessing - context' }
SindarinDebugger >> outerMostContextOf: aContext [

	| currentContext oldContext |
	currentContext := aContext.
	oldContext := nil.
	[currentContext ~= oldContext] whileTrue: [ 
		oldContext := currentContext.
		currentContext := currentContext outerMostContext ].
	^ currentContext
]

{ #category : #accessing }
SindarinDebugger >> pc [
	^ self context pc
]

{ #category : #accessing }
SindarinDebugger >> pc: anInteger [

	self context pc: anInteger.
	[ self context stackPtr > self context numTemps ] whileTrue: [ 
		self context pop ].

	self debugSession stepToFirstInterestingBytecodeIn:
		self debugSession interruptedProcess
]

{ #category : #'stepping -  auto' }
SindarinDebugger >> proceed [
	"alias of #continue"

	^ self continue
]

{ #category : #stackAccessHelpers }
SindarinDebugger >> receiver [
	"Returns the receiver of the current stack-frame."

	^ self context receiver
]

{ #category : #'graphical debugger' }
SindarinDebugger >> refreshAttachedGraphicalDebugger [
	sindarinSession refreshAttachedDebugger
]

{ #category : #'step hook' }
SindarinDebugger >> removeStepHook: aBlock [
	"Remove aBlock from the list of step hooks"

	stepHooks remove: aBlock
]

{ #category : #stackAccess }
SindarinDebugger >> restart [
	"Resets this debugger on a new execution of the block passed as argument to the initial call to #debug:"
	self initialize.
	self debug: blockToDebug.
]

{ #category : #'stepping -  auto' }
SindarinDebugger >> resume [

	sindarinSession resumeAndClear
]

{ #category : #scripts }
SindarinDebugger >> run: aSindarinScript [
	aSindarinScript executeWith: self
]

{ #category : #stackAccessHelpers }
SindarinDebugger >> selector [
	"Returns the selector of the current stack-frame."

	^ self context selector
]

{ #category : #breakpoints }
SindarinDebugger >> setBreakpoint [
	"Sets a breakpoint on the current node, returns an object reifying the breakpoint."

	^ self setBreakpointOn: self node
]

{ #category : #breakpoints }
SindarinDebugger >> setBreakpointOn: target [
	"Sets a breakpoint on target (a node or a compiled method), returns an object reifying the breakpoint."

	| astTarget |
	astTarget := target.
	(target isKindOf: CompiledMethod)
		ifTrue: [ astTarget := target ast ].
	^ VirtualBreakpoint newOnNode: astTarget setBy: self
]

{ #category : #asserting }
SindarinDebugger >> shouldStepIntoInMethod: aRBMethodNode [

	| messageNode childrenOfMessageNode |
	messageNode := self node.
	messageNode isMessage ifFalse: [ ^ false ].
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

{ #category : #private }
SindarinDebugger >> signalExceptionIfDebuggedExecutionHasSignalledUnhandledException [
	| unhandledException |
	(self hasSignalledUnhandledException)
		ifTrue: [ 
			unhandledException := self receiver.
			UnhandledExceptionSignalledByADebuggedExecution
				signalWithException: unhandledException.
		]
	
		"ifTrue:
			[" "The debugged execution signalled an exception, this exception was not handled and is about to cause a debugger to open."
			"Signalling an exception **in the scriptable debugger's process** to inform the user of this"
			"unhandledException := self messageArguments at: 1.
			UnhandledExceptionSignalledByADebuggedExecution
				signalWithException: unhandledException ]"
]

{ #category : #private }
SindarinDebugger >> signalExceptionIfDebuggedExecutionIsFinished [
	"Signals an DebuggedExecutionIsFinished exception if the debugged execution is finished"
	(self isExecutionFinished) ifTrue: [ 
		DebuggedExecutionIsFinished signal.
	].
]

{ #category : #accessing }
SindarinDebugger >> sindarinSession: aSindarinDebugSession [

	sindarinSession := aSindarinDebugSession
]

{ #category : #'stepping -  skip' }
SindarinDebugger >> skip [
	
	| nextBytecode |
	"If it is a message send or assignment, skips the execution of the current instruction, and puts nil on the execution stack."
	self node isAssignment ifTrue: [ ^ self skipAssignmentNodeCompletely ].
  self node isMessage ifTrue: [ ^ self skipMessageNode ].
  self node isMethod ifTrue: [ ^ self step ].
  self node isBlock ifTrue: [ self skipBlockNode ].
	nextBytecode := self currentBytecode detect: [ :each | 
		                each offset = self pc ].
	(self node isReturn or: [ 
		 nextBytecode bytes first between: 88 and: 94 ]) ifTrue: [ 
		^ self skipReturnNode ].
	self node isSequence ifTrue: [ ^ self step ].

	self skipWith: nil
]

{ #category : #'stepping -  skip' }
SindarinDebugger >> skipAssignmentNodeCompletely [

	| currentBytecode |
	currentBytecode := self currentBytecode detect: [ :each | 
		                   each offset = self context pc ].

	"Pop the value that will be assigned"
	self context pop.

	"If the assignment is a store bytecode and not a pop bytecode, we push the current value of the variable that was going to be assigned."
	(#( 243 244 245 252 ) includes: currentBytecode bytes first) ifTrue: [ 
		self context push:
			(self node variable variableValueInContext: self context) ].

	"Increase the pc to go over the assignment"
	self context pc: self context pc + currentBytecode bytes size.
	"Execute bytecodes the debugger usually executes without stopping the execution (for example popping the return value of the just executed message send if it is not used afterwards)"
	self debugSession stepToFirstInterestingBytecodeIn:
		self debugSession interruptedProcess
]

{ #category : #'stepping -  skip' }
SindarinDebugger >> skipAssignmentNodeWith: replacementValue [
	self context pop.
	"Pop the value to be assigned"
	"Push the replacement value on the context's value stack, to simulate that the assignment happened and had value nil"
	self context push: replacementValue.
	self step.
	"Execute bytecodes the debugger usually executes without stopping the execution (for example popping the return value of the just executed message send if it is not used afterwards)"
	self debugSession
		stepToFirstInterestingBytecodeIn: self debugSession interruptedProcess
]

{ #category : #'stepping -  skip' }
SindarinDebugger >> skipBlockNode [

	| nextBytecode |
	nextBytecode := self currentBytecode detect: [ :bytecode | bytecode offset = self pc ].
	
	self context pc: self pc + nextBytecode bytes size.
	
	self context push: nil
]

{ #category : #'stepping - skip' }
SindarinDebugger >> skipMessageNode [

	self node arguments do: [ :arg | self context pop ]. "Pop the arguments of the message send from the context's value stack"

	"Increase the pc to go over the message send"
	self context pc: self context pc + self nextBytecode bytes size.
	"Execute bytecodes the debugger usually executes without stopping the execution (for example popping the return value of the just executed message send if it is not used afterwards)"
	self debugSession stepToFirstInterestingBytecodeIn:
		self debugSession interruptedProcess
]

{ #category : #'stepping -  skip' }
SindarinDebugger >> skipMessageNodeWith: replacementValue [

	self node arguments do: [ :arg | self context pop ]. "Pop the arguments of the message send from the context's value stack"
	"Pop the receiver from the context's value stack"
	self context pop.
	"Push the replacement value on the context's value stack, to simulate that the message send happened and returned nil"
	self context push: replacementValue.
	"Increase the pc to go over the message send"
	self context pc: self context pc + self nextBytecode bytes size.
	"Execute bytecodes the debugger usually executes without stopping the execution (for example popping the return value of the just executed message send if it is not used afterwards)"
	self debugSession stepToFirstInterestingBytecodeIn:
		self debugSession interruptedProcess
]

{ #category : #'stepping - skip' }
SindarinDebugger >> skipReturnNode [

	^ SindarinSkippingReturnWarning signal: 'Cannot skip a return node'
]

{ #category : #'stepping -  skip' }
SindarinDebugger >> skipThroughNode: aProgramNode [
	"Skips execution until program counter reaches aProgramNode.
	Also skip the target node."

	self skipUpToNode: aProgramNode skipTargetNode: true
]

{ #category : #'stepping -  skip' }
SindarinDebugger >> skipToPC: aPC [

	"Skips execution until program counter reaches aPC."

	[ [ self pc >= aPC ] whileFalse: [ self skip ] ]
		on: SindarinSkippingReturnWarning
		do: [ ^ self ]
]

{ #category : #'stepping -  skip' }
SindarinDebugger >> skipUpToNode: aProgramNode [
	"Skips execution until program counter reaches aProgramNode.
	Does not skip the target node."

	self skipUpToNode: aProgramNode skipTargetNode: false
]

{ #category : #'stepping -  skip' }
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

{ #category : #'stepping -  skip' }
SindarinDebugger >> skipWith: replacementValue [
	"If it is a message-send or assignment, skips the execution of the current instruction, and puts the replacementValue on the execution stack."

	"If the current node is a message send or assignment"

	(self node isMessage not
		and: [ self node isAssignment not ])
		ifTrue: [ ^ self ].
	self node isMessage
		ifTrue: [ ^ self skipMessageNodeWith: replacementValue ].
	self node isAssignment
		ifTrue: [ ^	self skipAssignmentNodeWith: replacementValue ]
]

{ #category : #stackAccess }
SindarinDebugger >> stack [
	"Returns a list of context objects representing the current call stack."

	^ self debugSession stack
]

{ #category : #API }
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

{ #category : #'stepping - steps' }
SindarinDebugger >> step [
	"Executes the next instruction. If the instruction is a message-send, step inside it."

	self signalExceptionIfDebuggedExecutionHasSignalledUnhandledException.
	self signalExceptionIfDebuggedExecutionIsFinished.
	self debugSession stepInto.
	stepHooks do: [ :aBlock | aBlock value ]
]

{ #category : #'stepping - steps' }
SindarinDebugger >> step: anInt [
	"Call the #step method @anInt times"

	anInt timesRepeat: [ self step ]
]

{ #category : #'stepping - echo' }
SindarinDebugger >> stepBatchAndReturnNodeHashAndStackSize [
	"For EchoDebugger"
	| nodesHashAndStackSize count |
	count := 0.
	nodesHashAndStackSize := OrderedCollection new.
	[ [ count <= 1000] whileTrue: [ count := count + 1. nodesHashAndStackSize add: {self node dictionaryRepresentation hash. self stack size}. self step ]] on: DebuggedExecutionException do: [ "when debugged execution is over or signals exception, stop and return the result data" ^ nodesHashAndStackSize ].
	^ nodesHashAndStackSize
	
]

{ #category : #'stepping - steps' }
SindarinDebugger >> stepBytecode [
	"Executes the next bytecode"

	self flag: 'Needs to be tested'.
	self signalExceptionIfDebuggedExecutionHasSignalledUnhandledException.
	process completeStep: self debugSession context.
	self debugSession updateContextTo: process suspendedContext
]

{ #category : #'stepping - steps' }
SindarinDebugger >> stepOver [
	| startContext |
	startContext := self context.
	self step.
	[ self context == startContext
		or: [ (startContext isDead or: [ self context isDead ])
				or: [ startContext hasSender: self context ]]]
		whileFalse: [ self step ]
]

{ #category : #'stepping - steps' }
SindarinDebugger >> stepOver: anInt [
	"Call the #stepOver method @anInt times"

	anInt timesRepeat: [ self stepOver ]
]

{ #category : #'stepping - steps' }
SindarinDebugger >> stepThrough [
	"Hacked for demonstration purposes to have a stepThrough"

	self signalExceptionIfDebuggedExecutionHasSignalledUnhandledException.
	self debugSession stepThrough.
	stepHooks do: [ :aBlock | aBlock value ]
]

{ #category : #'stepping - steps' }
SindarinDebugger >> stepToMethodEntry [
	self stepUntil: [ self context instructionStream willSend ].
	process step: self context.
	self debugSession updateContextTo: process suspendedContext
]

{ #category : #'stepping - steps' }
SindarinDebugger >> stepToReturn [

	| oldContext methodAST |
	oldContext := self outerMostContextOf: self context.
	methodAST := self context method ast.

	[ 
	((self outerMostContextOf: self context) = oldContext and: [ 
		 self context instructionStream willReturn ]) or: [ 
		self hasSignalledUnhandledException ] ] whileFalse: [ 
		(self shouldStepIntoInMethod: methodAST)
			ifTrue: [ self debugSession stepInto ]
			ifFalse: [ self debugSession stepOver ] ]
	"[ 
	self context instructionStream willReturn or: [ self hasSignalledUnhandledException ] ] 
		whileFalse: [ self debugSession stepOver ]"
]

{ #category : #'stepping - steps' }
SindarinDebugger >> stepUntil: aBlock [
	"Steps the execution until aBlock evaluates to true"

	aBlock whileFalse: [ self step ]
]

{ #category : #stackAccessHelpers }
SindarinDebugger >> temporaryNamed: aSymbol [
	^self context tempNamed: aSymbol
]

{ #category : #process }
SindarinDebugger >> terminate [
	sindarinSession terminate
]

{ #category : #stackAccessHelpers }
SindarinDebugger >> topStack [
	^self context top
]

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
	#name : #ScriptableDebugger,
	#superclass : #Object,
	#instVars : [
		'process',
		'debugSession',
		'stepHooks'
	],
	#category : #ScriptableDebugger
}

{ #category : #start }
ScriptableDebugger class >> attachTo: aDebugSession [
	"Returns a new instance of ScriptableDebugger attached to aDebugSession"
	^ self new attachTo: aDebugSession.

]

{ #category : #start }
ScriptableDebugger class >> debug: aBlock [
	"Creates an execution of aBlock and returns an instance of ScriptableDebugger attached to this execution"
	^ self new debug: aBlock

]

{ #category : #'graphical debugger' }
ScriptableDebugger >> activateAutoRefreshOfAttachedGraphicalDebugger [
	"Does not work for the GT debugger"
	debugSession activateEventTriggering.
	self refreshAttachedGraphicalDebugger.
]

{ #category : #'step hook' }
ScriptableDebugger >> addStepHook: aBlock [
	"Adds aBlock to the list of step hooks. Step hooks are executed after each step of the execution"
	stepHooks add: aBlock
]

{ #category : #stackAccessHelpers }
ScriptableDebugger >> arguments [
	"Returns the arguments of the current stack-frame."
	^ self context arguments
]

{ #category : #stackAccessHelpers }
ScriptableDebugger >> assignmentValue [
	"Returns the value about to be assigned, if the current node is an assignment node."
	(self currentNode isAssignment) ifFalse: [ Error signal: 'Not about to perform a assignment' ].
	^ self context at: self currentContextStackSize.
]

{ #category : #stackAccessHelpers }
ScriptableDebugger >> assignmentVariableName [
	"Returns the variable name about to be assigned to, if the current node is an assignment node."
	(self currentNode isAssignment) ifFalse: [ Error signal: 'Not about to perform a assignment' ].
	^ self currentNode variable name.
]

{ #category : #start }
ScriptableDebugger >> attachTo: aDebugSession [
	"Attaches this scriptable debugger to an already existing instance of DebugSession or DebugSessionPlus"
	debugSession := aDebugSession.
	aDebugSession isDebugSessionPlus ifFalse: [ debugSession := DebugSessionPlus forDebugSession: aDebugSession ] .
	process := debugSession interruptedProcess.
	debugSession deactivateEventTriggering.
	^ self
]

{ #category : #stackAccess }
ScriptableDebugger >> context [
	"Returns a reification of the current stack-frame."
	^ debugSession interruptedContext.
]

{ #category : #private }
ScriptableDebugger >> contextIsAboutToSignalException: aContext [
	"Returns whether aContext is about to execute a message-send of selector #signal to an instance of the Exception class (or one of its subclasses)"
	| node |
	node := aContext method sourceNodeForPC: aContext pc.
	(node isMessage) ifFalse: [ ^false ].
	(node selector = #signal) ifFalse: [ ^false ].
	(aContext basicSize >= 1) ifFalse: [ ^false ].
	(Exception allSubclasses includes: (aContext at: (aContext basicSize))) ifTrue: [ ^true ]. "#signal sent to a subclass of Exception"
	(Exception allSubclasses includes: ((aContext at: (aContext basicSize)) class)) ifTrue: [ ^true ]. "#signal sent to an instance of a subclass of Exception"
	^ false
	
]

{ #category : #stepping }
ScriptableDebugger >> continue [
	"Steps the execution until it:
	- is about to signal a Halt exception. In this case return #halt.
	- is about to signal a Break exception. In this case return #breakpoint.
	- has reached a virtual breakpoint. In this case return the virtual breakpoint.
	- has finished. In this case return nil."
	| signalMessageNode exceptionClassBeingSignalled stepHook |
	stepHook := [ VirtualBreakpoint all detect: [ :vbrkpt | vbrkpt hitTest: self currentNode] ifFound: [ :vbrkpt | self removeStepHook: stepHook. ^vbrkpt ]].
	self addStepHook: stepHook.
	[ (self isExecutionFinished) or: [ self contextIsAboutToSignalException: self context]] whileFalse: [ self step ].
	self isExecutionFinished ifTrue: [ ^nil ].
	signalMessageNode := self currentNode.
	exceptionClassBeingSignalled := self context at: ((self context size) - signalMessageNode arguments size).
	(exceptionClassBeingSignalled == Halt) ifTrue: [ 
		"Encountered a Halt (typically signalled by a 'self halt')"
		self skip.
		self removeStepHook: stepHook.
		^ #halt.
	].
	(exceptionClassBeingSignalled == Break) ifTrue: [ 
		"Encountered a Break (i.e. a breakpoint)"
		self skip.
		self removeStepHook: stepHook.
		^ #breakpoint.
	].
	
]

{ #category : #private }
ScriptableDebugger >> currentContextStackSize [
	^ self context basicSize.
]

{ #category : #astAndAstMapping }
ScriptableDebugger >> currentNode [
	"Returns the AST node about to be executed by the top context of the execution"
	^ self context method sourceNodeForPC: self context pc.
]

{ #category : #'graphical debugger' }
ScriptableDebugger >> deactivateAutoRefreshOfAttachedGraphicalDebugger [
	"Does not work for the GT debugger"
	debugSession deactivateEventTriggering.
]

{ #category : #start }
ScriptableDebugger >> debug: aBlock [
	process := aBlock newProcess name: 'ExecutionDebuggedByScriptableDebugger'.
	"process on: Exception do: [:ex | DebuggedExecutionSignalledAnException signalWithException: ex. ex resume ]."
	debugSession := DebugSessionPlus newWithName: 'ScriptableDebuggerDebugSession' forProcess: process.
		debugSession deactivateEventTriggering.
	[ self selector = #newProcess] whileFalse: [ self step]. "Step the process to get out of the on:do: context added at the bottom of its stack"
	[self selector = #newProcess] whileTrue: [ self step ]. "Step the process so that it leaves BlockClosure>>#newProcess and enters the block for which a process was created"
	^ self
]

{ #category : #accessing }
ScriptableDebugger >> debugSession [
	"Returns the DebugSession representing the execution this ScriptableDebugger is debugging"
	^ debugSession 
]

{ #category : #initialization }
ScriptableDebugger >> initialize [
	stepHooks := OrderedCollection new.
]

{ #category : #stackAccess }
ScriptableDebugger >> isExecutionFinished [
	"Returns whether the debugged execution is finished"
	^ process isTerminating
]

{ #category : #stackAccessHelpers }
ScriptableDebugger >> messageArguments [
	"Returns the arguments of the message about to be sent, if the current node is a message node."
	| argumentNumber arguments i |
	(self currentNode isMessage) ifFalse: [ Error signal: 'Not about to send a message' ].
	argumentNumber := self currentNode arguments size.
	arguments := OrderedCollection new.
	i := 0.
	[i = argumentNumber] whileFalse: [ 
		arguments add: (self context at: self currentContextStackSize - argumentNumber + i + 1).
		i := i + 1.
	].
	^ arguments.
]

{ #category : #stackAccessHelpers }
ScriptableDebugger >> messageReceiver [
	"Returns the receiver of the message about to be sent, if the current node is a message node."
	(self currentNode isMessage) ifFalse: [ Error signal: 'Not about to send a message' ].
	^ self context at: (self currentContextStackSize) - (self currentNode arguments size).
]

{ #category : #stackAccessHelpers }
ScriptableDebugger >> messageSelector [
	"Returns the selector of the message about to be sent, if the current node is a message node."
	(self currentNode isMessage) ifFalse: [ Error signal: 'Not about to send a message' ].
	^ self currentNode selector.
]

{ #category : #stackAccessHelpers }
ScriptableDebugger >> method [
	"Returns the method of the current stack-frame."
	^ self context method
]

{ #category : #'graphical debugger' }
ScriptableDebugger >> openInGraphicalDebugger [
	debugSession canBeTerminated: false. "Prevents the graphical debugger from terminating the debug session when it's closed."
	GTGenericStackDebugger openOn: debugSession withFullView: true.
]

{ #category : #stackAccessHelpers }
ScriptableDebugger >> receiver [
	"Returns the receiver of the current stack-frame."
	^ self context receiver
]

{ #category : #'graphical debugger' }
ScriptableDebugger >> refreshAttachedGraphicalDebugger [
	"Does not work for the GT debugger"
	debugSession refreshAttachedDebugger.
]

{ #category : #'step hook' }
ScriptableDebugger >> removeStepHook: aBlock [
	"Remove aBlock from the list of step hooks"
	stepHooks remove: aBlock
]

{ #category : #stackAccessHelpers }
ScriptableDebugger >> selector [
	"Returns the selector of the current stack-frame."
	^ self context selector
]

{ #category : #breakpoints }
ScriptableDebugger >> setBreakpoint [
	"Sets a breakpoint on the current node, returns an object reifying the breakpoint."
	^ self setBreakpointOn: self currentNode.
]

{ #category : #breakpoints }
ScriptableDebugger >> setBreakpointOn: target [
	"Sets a breakpoint on target (a node or a compiled method), returns an object reifying the breakpoint."
	| astTarget|
	astTarget := target.
	(target isKindOf: CompiledMethod) ifTrue: [ astTarget := target ast ].
	^ VirtualBreakpoint newOnNode: astTarget setBy: self.
]

{ #category : #private }
ScriptableDebugger >> signalExceptionIfDebuggedExecutionHasSignalledException [
	| unhandledException |
	((self currentNode isMessage) and: [(self messageSelector = #unhandledErrorDefaultAction:) and: [ self messageReceiver isKindOf: UIManager ]]) ifTrue: [ 
	"The debugged execution signalled an exception, this exception was not handled and is about to cause a debugger to open."
	"Signalling an exception **in the scriptable debugger's process** to inform the user of this"
		unhandledException := self messageArguments at: 1.
		UnhandledExceptionSignalledByADebuggedExecution signalWithException: unhandledException.
	].
]

{ #category : #stepping }
ScriptableDebugger >> skip [
	"If it is a message send or assignment, skips the execution of the current instruction, and puts nil on the execution stack."
	self skipWith: nil.
]

{ #category : #stepping }
ScriptableDebugger >> skipWith: replacementValue [
	"If it is a message-send or assignment, skips the execution of the current instruction, and puts the replacementValue on the execution stack."
	"If the current node is a message send or assignment"
	((self currentNode isMessage not) and: [ self currentNode isAssignment not]) ifTrue: [ ^false ].
	self currentNode isMessage ifTrue: [
		"Pop the arguments of the message send from the context's value stack"
		self currentNode arguments do: [ :arg | self context pop ].
		"Pop the receiver from the context's value stack"
		self context pop.
		"Push the replacement value on the context's value stack, to simulate that the message send happened and returned nil"
		self context push: replacementValue.
		"Increase the pc to go over the message send"
		self context pc: self context pc + 1.
		"Execute bytecodes the debugger usually executes without stopping the execution (for example popping the return value of the just executed message send if it is not used afterwards)"
		self debugSession stepToFirstInterestingBytecodeIn: self debugSession interruptedProcess.
		^ self.
	].
	self currentNode isAssignment ifTrue: [
		"Pop the value to be assigned"
		self context pop.
		"Push the replacement value on the context's value stack, to simulate that the assignment happened and had value nil"
		self context push: replacementValue.
		"Increase the pc to go over the assignment"
		self context pc: self context pc + 2.
		"Execute bytecodes the debugger usually executes without stopping the execution (for example popping the return value of the just executed message send if it is not used afterwards)"
		self debugSession stepToFirstInterestingBytecodeIn: self debugSession interruptedProcess.
		^ self.
	].
]

{ #category : #stackAccess }
ScriptableDebugger >> stack [
	"Returns a list of context objects representing the current call stack."
	^ debugSession stack
]

{ #category : #stepping }
ScriptableDebugger >> step [
	"Executes the next instruction. If the instruction is a message-send, step inside it."
	self signalExceptionIfDebuggedExecutionHasSignalledException.
	debugSession stepInto.
	stepHooks do: [ :aBlock | aBlock value ].
]

{ #category : #stepping }
ScriptableDebugger >> stepOver [
	|startContext|
	startContext := self context.
	self step.
	[ (self context == startContext) or: [ (startContext sender isNil) or: [startContext hasSender: self context] ] ] whileFalse: [ self step.].
]

{ #category : #stepping }
ScriptableDebugger >> stepUntil: aBlock [
	"Steps the execution until aBlock evaluates to true"
	aBlock whileFalse: [ self step ]
]

{ #category : #stackAccessHelpers }
ScriptableDebugger >> temporaries [
	"Returns the temporary variables of the current stack-frame."
	^ self context temporaries.
]

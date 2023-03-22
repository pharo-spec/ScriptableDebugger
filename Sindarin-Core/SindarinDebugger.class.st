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
		'sindarinSession',
		'blockToDebug'
	],
	#category : #'Sindarin-Core'
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

{ #category : #stackAccessHelpers }
SindarinDebugger >> arguments [
	"Returns the arguments of the current stack-frame."

	^ self context arguments
]

{ #category : #cleaning }
SindarinDebugger >> cleanStack [

	[ self context stackPtr > self context numTemps ] whileTrue: [ 
		self context pop ]
]

{ #category : #stackAccess }
SindarinDebugger >> context [
	"Returns a reification of the current stack-frame."

	^ self debugSession interruptedContext
]

{ #category : #private }
SindarinDebugger >> currentContextStackSize [

	^ self context basicSize
]

{ #category : #process }
SindarinDebugger >> currentProcess [

	^ process
]

{ #category : #start }
SindarinDebugger >> debug: aBlock [

	blockToDebug := aBlock.
	process := aBlock newProcess name:
		           'ExecutionDebuggedByScriptableDebugger'.
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
SindarinDebugger >> instanceCreationPrimitives [
	"* 70 */ primitiveNew,
	/* 71 */ primitiveNewWithArg,
	/* 79 */ primitiveNewMethod,
	/* 148 */ primitiveClone,
	/* 160 */ primitiveAdoptInstance"

	self flag: 'These numbers may have changed. This is to be checked'.
	^ #( 70 71 79 148 160 )
]

{ #category : #accessing }
SindarinDebugger >> instructionStream [

	^ self context instructionStream
]

{ #category : #stackAccess }
SindarinDebugger >> isExecutionFinished [
	"Returns whether the debugged execution is finished"

	^ process isTerminated
]

{ #category : #stackAccessHelpers }
SindarinDebugger >> method [
	"Returns the method of the current stack-frame."

	self flag:
		'There is something bad here. Context>>#method returns a CompiledCode that can be a CompiledBlock. So the naming of the method is not completely correct. We should distinguish method and methodOrBlock'.
	^ self context method
]

{ #category : #accessing }
SindarinDebugger >> methodNode [

	self flag:
		'There is something bad here. This method returns the node of the compiled code (so a block node for a block). We should distinguish methodNode and methodOrBlockNode. See flag in #method'.
	^ self method ast
]

{ #category : #astAndAstMapping }
SindarinDebugger >> node [
	"Returns the AST node about to be executed by the top context of the execution"

	^ self nodeForContext: self context
]

{ #category : #astAndAstMapping }
SindarinDebugger >> nodeForContext: aContext [
	"Returns the AST node about to be executed by the top context of the execution"

	^ self method sourceNodeForPC: aContext pc
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

{ #category : #stackAccessHelpers }
SindarinDebugger >> readVariableNamed: aSymbol [

	^ self context readVariableNamed: aSymbol
]

{ #category : #stackAccessHelpers }
SindarinDebugger >> receiver [
	"Returns the receiver of the current stack-frame."

	^ self context receiver
]

{ #category : #stackAccessHelpers }
SindarinDebugger >> selector [
	"Returns the selector of the current stack-frame."

	^ self context selector
]

{ #category : #accessing }
SindarinDebugger >> sindarinSession: aSindarinDebugSession [

	sindarinSession := aSindarinDebugSession
]

{ #category : #'stepping -  skip' }
SindarinDebugger >> skipPcToNextBytecode [

	| currentBytecode |
	currentBytecode := self nextBytecode.
	self context pc: self context pc + currentBytecode bytes size
]

{ #category : #stackAccess }
SindarinDebugger >> stack [
	"Returns a list of context objects representing the current call stack."

	^ self debugSession stack
]

{ #category : #accessing }
SindarinDebugger >> symbolicBytecodesForCurrent [

	^ self method symbolicBytecodes
]

{ #category : #process }
SindarinDebugger >> terminate [

	sindarinSession terminate
]

{ #category : #stackAccessHelpers }
SindarinDebugger >> topStack [

	^ self context top
]

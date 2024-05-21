"
I am a trait that contains the core API that a scriptable debugger should use
"
Trait {
	#name : 'TSindarin',
	#instVars : [
		'process',
		'sindarinSession',
		'blockToDebug'
	],
	#category : 'Sindarin-Core',
	#package : 'Sindarin',
	#tag : 'Core'
}

{ #category : 'start' }
TSindarin classSide >> attachTo: aDebugSession [
	"Returns a new instance of ScriptableDebugger attached to aDebugSession"

	^ self new attachTo: aDebugSession
]

{ #category : 'actions' }
TSindarin classSide >> closeAllDebuggers [
	<script>
	
	self allInstances do: [ :dbg | dbg terminate ]
]

{ #category : 'start' }
TSindarin classSide >> debug: aBlock [
	"Creates an execution of aBlock and returns an instance of ScriptableDebugger attached to this execution"

	^ self new debug: aBlock
]

{ #category : 'instance creation' }
TSindarin classSide >> debugSession: aDebugSession [

	^ self attachTo: aDebugSession
]

{ #category : 'stack access - helpers' }
TSindarin >> arguments [
	"Returns the arguments of the current stack-frame."

	^ self context arguments
]

{ #category : 'start' }
TSindarin >> attachTo: aDebugSession [
	"Attaches this scriptable debugger to an already existing instance of DebugSession or SindarinDebugSession"

	sindarinSession := aDebugSession asSindarinDebugSession.
	process := aDebugSession interruptedProcess.
	sindarinSession deactivateEventTriggering
]

{ #category : 'debug - stepping' }
TSindarin >> basicStep [

	self debugSession stepInto
]

{ #category : 'debug - stepping' }
TSindarin >> basicStepOver [

	^ self debugSession stepOver
]

{ #category : 'debug - stepping' }
TSindarin >> basicStepThrough [

	self debugSession stepThrough
]

{ #category : 'cleaning' }
TSindarin >> cleanStack [

	[ self context stackPtr > self context numTemps ] whileTrue: [ 
		self context pop ]
]

{ #category : 'stack access' }
TSindarin >> context [
	"Returns a reification of the current stack-frame."

	^ self debugSession interruptedContext
]

{ #category : 'private' }
TSindarin >> currentContextStackSize [

	^ self context basicSize
]

{ #category : 'process' }
TSindarin >> currentProcess [

	^ process
]

{ #category : 'start' }
TSindarin >> debug: aBlock [

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

{ #category : 'accessing' }
TSindarin >> debugSession [
	"Returns the DebugSession representing the execution this ScriptableDebugger is debugging"

	^ sindarinSession debugSession
]

{ #category : 'private' }
TSindarin >> instanceCreationPrimitives [
	"* 70 */ primitiveNew,
	/* 71 */ primitiveNewWithArg,
	/* 79 */ primitiveNewMethod,
	/* 148 */ primitiveClone,
	/* 160 */ primitiveAdoptInstance"

	self flag: 'These numbers may have changed. This is to be checked'.
	^ #( 70 71 79 148 160 )
]

{ #category : 'accessing' }
TSindarin >> instructionStream [

	^ self context instructionStream
]

{ #category : 'stack access - testing' }
TSindarin >> isAssignment [
	^self node isAssignment 
]

{ #category : 'stack access' }
TSindarin >> isExecutionFinished [
	"Returns whether the debugged execution is finished"

	^ process isTerminated
]

{ #category : 'stack access - testing' }
TSindarin >> isMessageSend [
	^self node isMessage
]

{ #category : 'stack access - helpers' }
TSindarin >> method [
	"Returns the method of the current stack-frame."

	self flag:
		'There is something bad here. Context>>#method returns a CompiledCode that can be a CompiledBlock. So the naming of the method is not completely correct. We should distinguish method and methodOrBlock'.
	^ self context method
]

{ #category : 'accessing' }
TSindarin >> methodNode [

	self flag:
		'There is something bad here. This method returns the node of the compiled code (so a block node for a block). We should distinguish methodNode and methodOrBlockNode. See flag in #method'.
	^ self method ast
]

{ #category : 'astAndAstMapping' }
TSindarin >> node [
	"Returns the AST node about to be executed by the top context of the execution"

	^ self nodeForContext: self context
]

{ #category : 'astAndAstMapping' }
TSindarin >> nodeForContext: aContext [
	"Returns the AST node about to be executed by the top context of the execution"

	^ self method sourceNodeForPC: aContext pc
]

{ #category : 'accessing - context' }
TSindarin >> outerMostContextOf: aContext [

	| currentContext oldContext |
	currentContext := aContext.
	oldContext := nil.
	[currentContext ~= oldContext] whileTrue: [ 
		oldContext := currentContext.
		currentContext := currentContext outerMostContext ].
	^ currentContext
]

{ #category : 'accessing' }
TSindarin >> pc [

	^ self context pc
]

{ #category : 'stack access - helpers' }
TSindarin >> readVariableNamed: aSymbol [

	^ self context readVariableNamed: aSymbol
]

{ #category : 'stack access - helpers' }
TSindarin >> receiver [
	"Returns the receiver of the current stack-frame."

	^ self context receiver
]

{ #category : 'start' }
TSindarin >> restart [
	"Resets this debugger on a new execution of the block passed as argument to the initial call to #debug:"

	self initialize.
	self debug: blockToDebug
]

{ #category : 'stepping - auto' }
TSindarin >> resume [

	sindarinSession resumeAndClear
]

{ #category : 'stack access - helpers' }
TSindarin >> selector [
	"Returns the selector of the current stack-frame."

	^ self context selector
]

{ #category : 'accessing' }
TSindarin >> sindarinSession: aSindarinDebugSession [

	sindarinSession := aSindarinDebugSession
]

{ #category : 'stepping -  skip' }
TSindarin >> skipPcToNextBytecode [

	| currentBytecode |
	currentBytecode := self nextBytecode.
	self context pc: self context pc + currentBytecode bytes size
]

{ #category : 'stack access' }
TSindarin >> stack [
	"Returns a list of context objects representing the current call stack."

	^ self debugSession stack
]

{ #category : 'accessing' }
TSindarin >> symbolicBytecodesForCurrent [

	^ self method symbolicBytecodes
]

{ #category : 'process' }
TSindarin >> terminate [

	sindarinSession terminate
]

{ #category : 'stack access - helpers' }
TSindarin >> topStack [

	^ self context top
]

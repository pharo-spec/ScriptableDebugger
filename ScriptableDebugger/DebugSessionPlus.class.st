"
stepRecord: StepRecord

StepRecords: LinkedList[StepRecord]
"
Class {
	#name : #DebugSessionPlus,
	#superclass : #DebugSession,
	#instVars : [
		'stepRecord',
		'triggerEventOn'
	],
	#classVars : [
		'StepRecords'
	],
	#category : #ScriptableDebugger
}

{ #category : #'as yet unclassified' }
DebugSessionPlus class >> StepRecords [
	^ StepRecords
]

{ #category : #'as yet unclassified' }
DebugSessionPlus class >> StepRecords: aValue [
	StepRecords := aValue
]

{ #category : #'as yet unclassified' }
DebugSessionPlus class >> clearStepRecords [
	<script>
	StepRecords := LinkedList new.
]

{ #category : #'class initialization' }
DebugSessionPlus class >> initialize [
	StepRecords := LinkedList new.
]

{ #category : #'as yet unclassified' }
DebugSessionPlus class >> inspectStepRecords [
	<script>
	StepRecords inspect.
]

{ #category : #initialization }
DebugSessionPlus >> activateEventTriggering [
	triggerEventOn := true.
	self refreshAttachedDebugger.
]

{ #category : #testing }
DebugSessionPlus >> canStepSkip [
	^ StepSkip isValidForDebugSession: self.
]

{ #category : #'as yet unclassified' }
DebugSessionPlus >> canStepToNextDoIteration: aContext [
	^ StepToNextDoIteration isValidForContext: aContext
]

{ #category : #'debugging actions' }
DebugSessionPlus >> contextChanged [
	triggerEventOn ifTrue: [ self triggerEvent: #contextChanged ]
]

{ #category : #initialization }
DebugSessionPlus >> deactivateEventTriggering [
	triggerEventOn := false.
]

{ #category : #'as yet unclassified' }
DebugSessionPlus >> getApplicableStepRecords [
	^ self class StepRecords select: [ :stepRecord_ | stepRecord_ isApplicableOn: interruptedContext] 
]

{ #category : #initialization }
DebugSessionPlus >> initialize [
	stepRecord := StepRecord new.
	triggerEventOn := true.
	super initialize.
]

{ #category : #initialization }
DebugSessionPlus >> process: aProcess context: aContext [
	super process: aProcess context: aContext.
	(aContext sender isNotNil)
		ifTrue: [ stepRecord senderMethodAST: (aContext sender method ast) ]
		"Not sure setting senderMethodAST to nil actually works"
		ifFalse: [ stepRecord senderMethodAST: (aContext sender) ]
	
]

{ #category : #initialization }
DebugSessionPlus >> refreshAttachedDebugger [
	"The following lines are to force the debugger to update itself based on its debugSession"
	self triggerEvent: #contextChanged.
	self triggerEvent: #stepInto
]

{ #category : #'debugging actions' }
DebugSessionPlus >> restart: aContext [

	"vv original restart: method from DebugSession below (except the added check on triggerEvent:) vv"
	"Proceed from the initial state of selectedContext." 
	"Closing now depends on a setting (RestartAlsoProceeds class variable) --> not supported in this version"

	(self isContextPostMortem: aContext) ifTrue: [^ self].
	self unwindAndRestartToContext: aContext.
	
	"Issue 3015 - Hernan"
	self isInterruptedContextATest ifTrue: [ self prepareTestToRunAgain ].
	
	triggerEventOn ifTrue: [self triggerEvent: #restart]		
	
]

{ #category : #'debugging actions' }
DebugSessionPlus >> resume [

	"vv original resume method from DebugSession below (except the added check on triggerEvent:) vv"
	"Proceed execution of the receiver's model, starting after the expression at 
	which an interruption occurred."

	"If the user of this session does not plan to reuse it, it should call 'self clean' "

	Smalltalk okayToProceedEvenIfSpaceIsLow
		ifFalse: [ ^ self ].
	(self isContextPostMortem: self interruptedContext)
		ifTrue: [ ^ self ].
	self resumeProcess.
	triggerEventOn ifTrue: [self triggerEvent: #resume]
]

{ #category : #'debugging actions' }
DebugSessionPlus >> resume: aValue [

	"vv original resume: method from DebugSession below (except the added check on triggerEvent:) vv"
	"Proceed execution of the receiver's model, starting after the expression at 
	which an interruption occurred."

	"If the user of this session does not plan to reuse it, it should call 'self clean' "

	Smalltalk okayToProceedEvenIfSpaceIsLow
		ifFalse: [ ^ self ].
	(self isContextPostMortem: self interruptedContext)
		ifTrue: [ ^ self ].
	self resumeProcessWithValue: aValue.
	triggerEventOn ifTrue: [self triggerEvent: #resume]
]

{ #category : #'debugging actions' }
DebugSessionPlus >> stepInto: aContext [
	stepRecord add: (RegisteredStep new stepCommand: #stepInto; sourceAstNode: aContext sourceNodeExecuted; yourself).
	
	"Should not step more a process that is terminating, otherwise the image will get locked."
	self interruptedProcess isTerminating ifTrue: [ SteppingATerminatingProcess signal ].
	
	"vv original stepInto: method from DebugSession below (except the added check on triggerEvent:) vv"
	"Send the selected message in selectedContext, and take control in 
	the method invoked to allow further step or send."

	(self isContextPostMortem: aContext) ifTrue: [^ self].

	interruptedProcess step: aContext.
	self updateContextTo: (self stepToFirstInterestingBytecodeIn: interruptedProcess).
	
	triggerEventOn ifTrue: [self triggerEvent: #stepInto]
]

{ #category : #'debugging actions' }
DebugSessionPlus >> stepOver: aContext [
	| newContext |
	stepRecord add: (RegisteredStep new stepCommand: #stepOver; sourceAstNode: aContext sourceNodeExecuted; yourself).
	
	"Should not step more a process that is terminating, otherwise the image will get locked."
	self interruptedProcess isTerminating ifTrue: [ SteppingATerminatingProcess signal ].

	"vv original stepOver: method from DebugSession below (except the added check on triggerEvent:) vv"
	"Send the selected message in selectedContext, and regain control 
	after the invoked method returns."	
	(self isContextPostMortem: aContext) ifTrue: [^ self].
	
	newContext := interruptedProcess completeStep: aContext.
	self updateContextTo:  
		(newContext == aContext
			ifTrue: [ (self stepToFirstInterestingBytecodeIn: interruptedProcess) ]
			ifFalse: [ newContext ]).

	triggerEventOn ifTrue: [self triggerEvent: #stepOver]
]

{ #category : #accessing }
DebugSessionPlus >> stepRecord [
	^ stepRecord
]

{ #category : #accessing }
DebugSessionPlus >> stepRecord: anObject [
	stepRecord := anObject
]

{ #category : #'as yet unclassified' }
DebugSessionPlus >> stepSkip [
	StepSkip executeOnDebugSession: self.
]

{ #category : #'debugging actions' }
DebugSessionPlus >> stepThrough: aContext [
	stepRecord add: (RegisteredStep new stepCommand: #stepThrough; sourceAstNode: aContext sourceNodeExecuted; yourself).
	
	"Should not step more a process that is terminating, otherwise the image will get locked."
	self interruptedProcess isTerminating ifTrue: [ SteppingATerminatingProcess signal ].
	
	"vv original stepThrough: method from DebugSession below (except the added check on triggerEvent:) vv"
	"Send messages until you return to selectedContext.
	 Used to step into a block in the method."
	
	(self isContextPostMortem: aContext) ifTrue: [^ self].
	
	interruptedProcess stepToHome: aContext.
	self updateContextTo: (self stepToFirstInterestingBytecodeIn: interruptedProcess).
			
	triggerEventOn ifTrue: [self triggerEvent: #stepThrough]
]

{ #category : #'as yet unclassified' }
DebugSessionPlus >> stepToNextDoIteration [
	StepToNextDoIteration executeOnDebugSession: self onContext: self interruptedContext.
]

{ #category : #'as yet unclassified' }
DebugSessionPlus >> stepToNextDoIteration: aContext [
	StepToNextDoIteration executeOnDebugSession: self onContext: aContext.
]

{ #category : #'as yet unclassified' }
DebugSessionPlus >> stepUntilAboutToSignalException [
	StepUntilAboutToSignalException executeOnDebugSession: self onContext: self interruptedContext.
]

{ #category : #'as yet unclassified' }
DebugSessionPlus >> stepUntilAboutToSignalException: aContext [
	StepUntilAboutToSignalException executeOnDebugSession: self onContext: aContext.
]

{ #category : #'debugging actions' }
DebugSessionPlus >> terminate [
	self stepRecord isEmpty ifFalse: [self class StepRecords add: self stepRecord].
	^ super terminate.
]

"
stepRecord: StepRecord

StepRecords: LinkedList[StepRecord]
"
Class {
	#name : #DebugSessionPlus,
	#superclass : #DebugSession,
	#instVars : [
		'triggerEventOn',
		'canBeTerminated'
	],
	#category : #ScriptableDebugger
}

{ #category : #initialization }
DebugSessionPlus >> activateEventTriggering [
	triggerEventOn := true.
	self refreshAttachedDebugger.
]

{ #category : #accessing }
DebugSessionPlus >> canBeTerminated [
	^ canBeTerminated
]

{ #category : #accessing }
DebugSessionPlus >> canBeTerminated: anObject [
	canBeTerminated := anObject
]

{ #category : #'debugging actions' }
DebugSessionPlus >> contextChanged [
	triggerEventOn ifTrue: [ self triggerEvent: #contextChanged ]
]

{ #category : #initialization }
DebugSessionPlus >> deactivateEventTriggering [
	triggerEventOn := false.
]

{ #category : #initialization }
DebugSessionPlus >> initialize [
	triggerEventOn := true.
	canBeTerminated := true.
	super initialize.
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

{ #category : #'debugging actions' }
DebugSessionPlus >> stepThrough: aContext [
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

{ #category : #'debugging actions' }
DebugSessionPlus >> terminate [
	canBeTerminated ifTrue: [ ^ super terminate ].
]

"
stepRecord: StepRecord

StepRecords: LinkedList[StepRecord]
"
Class {
	#name : #SindarinDebugSession,
	#superclass : #DebugSession,
	#instVars : [
		'triggerEventOn',
		'canBeTerminated'
	],
	#category : #Sindarin
}

{ #category : #'instance creation' }
SindarinDebugSession class >> forDebugSession: aDebugSession [
	"Creates a DebugSessionPlus on the same execution as aDebugSession"
	^ self newWithName: aDebugSession name forProcess: aDebugSession interruptedProcess.
	
]

{ #category : #'instance creation' }
SindarinDebugSession class >> newWithName: aString forProcess: aProcess [
	^ self new name: aString; process: aProcess context: aProcess suspendedContext; yourself.
]

{ #category : #initialization }
SindarinDebugSession >> activateEventTriggering [
	triggerEventOn := true.
	"self refreshAttachedDebugger."
]

{ #category : #accessing }
SindarinDebugSession >> canBeTerminated [
	^ canBeTerminated
]

{ #category : #accessing }
SindarinDebugSession >> canBeTerminated: anObject [
	canBeTerminated := anObject
]

{ #category : #initialization }
SindarinDebugSession >> deactivateEventTriggering [
	triggerEventOn := false.
]

{ #category : #initialization }
SindarinDebugSession >> initialize [
	super initialize.
	triggerEventOn := true.
	canBeTerminated := true
]

{ #category : #testing }
SindarinDebugSession >> isSindarinDebugSession [
	^ true
]

{ #category : #initialization }
SindarinDebugSession >> refreshAttachedDebugger [
	"The following lines are to force the debugger to update itself based on its debugSession"
	self triggerEvent: #contextChanged.
	"self triggerEvent: #stepInto" "Since SpecDebugger's #updateContextChanged eventually calls the same #updateStep method that its #updateStepInto method does, there is no point in causing a double refresh by also triggering the #stepInto event"
]

{ #category : #'debugging actions' }
SindarinDebugSession >> stepInto: aContext [
	"Should not step more a process that is terminating, otherwise the image will get locked."
	self flag: 'Why the image gets locked? Please investigate.'.

	self interruptedProcess isTerminating
		ifTrue: [ SteppingATerminatingProcess signal ].
	^ super stepInto: aContext
]

{ #category : #'debugging actions' }
SindarinDebugSession >> stepOver: aContext [
	"Should not step more a process that is terminating, otherwise the image will get locked."
	self flag: 'Why the image gets locked? Please investigate.'.
	
	self interruptedProcess isTerminating
		ifTrue: [ SteppingATerminatingProcess signal ].
	^ super stepOver: aContext
]

{ #category : #'debugging actions' }
SindarinDebugSession >> terminate [
	canBeTerminated ifTrue: [ ^ super terminate ].
]

{ #category : #'debugging actions' }
SindarinDebugSession >> triggerEvent: anEventSelector [
	triggerEventOn
		ifTrue: [ ^ super triggerEvent: anEventSelector ]
]

{ #category : #accessing }
SindarinDebugSession >> triggerEventOn [
	^ triggerEventOn
]

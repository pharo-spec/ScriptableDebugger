"
stepRecord: StepRecord

StepRecords: LinkedList[StepRecord]
"
Class {
	#name : 'SindarinDebugSession',
	#superclass : 'Object',
	#instVars : [
		'triggerEventOn',
		'canBeTerminated',
		'debugSession'
	],
	#category : 'Sindarin-Core',
	#package : 'Sindarin',
	#tag : 'Core'
}

{ #category : 'instance creation' }
SindarinDebugSession class >> newWithName: aString forProcess: aProcess [

	^ DebugSession new
		  name: aString;
		  process: aProcess context: aProcess suspendedContext;
		  asSindarinDebugSession
]

{ #category : 'converting' }
SindarinDebugSession >> asSindarinDebugSession [

	^ self
]

{ #category : 'api - debug session' }
SindarinDebugSession >> basicStepInto: aContext [

	^ self debugSession stepInto: aContext
]

{ #category : 'api - debug session' }
SindarinDebugSession >> basicStepOver: aContext [

	^ self debugSession stepOver: aContext
]

{ #category : 'api - debug session' }
SindarinDebugSession >> basicStepThrough: aContext [

	^ self debugSession stepThrough: aContext
]

{ #category : 'accessing' }
SindarinDebugSession >> canBeTerminated [

	^ canBeTerminated
]

{ #category : 'accessing' }
SindarinDebugSession >> canBeTerminated: anObject [

	canBeTerminated := anObject
]

{ #category : 'initialization' }
SindarinDebugSession >> deactivateEventTriggering [

	triggerEventOn := false
]

{ #category : 'accessing' }
SindarinDebugSession >> debugSession [

	^ debugSession
]

{ #category : 'accessing' }
SindarinDebugSession >> debugSession: anObject [

	debugSession := anObject
]

{ #category : 'initialization' }
SindarinDebugSession >> initialize [

	super initialize.
	triggerEventOn := true.
	canBeTerminated := true
]

{ #category : 'initialization' }
SindarinDebugSession >> refreshAttachedDebugger [
	"The following lines are to force possible debuggers observing the same debug session to update themselves based"

	self debugSession triggerEvent: #contextChanged
]

{ #category : 'debugging actions' }
SindarinDebugSession >> resumeAndClear [

	self debugSession
		resume;
		clear
]

{ #category : 'debugging actions' }
SindarinDebugSession >> stepInto: aContext [
	"Should not step more a process that is terminating, otherwise the image will get locked.
	The image freeze is due to the stepping of the ensure block in doTerminationFromYourself that unwind the terminating context to nil and executes a jump.
	The ensure executes the (fake) primitive 198 which actually freezes (see issue https://github.com/pharo-spec/ScriptableDebugger/issues/105), and prevents the jump to execute which in turn provokes other freezes when trying to close opened debugger on that partially ended process."

	self debugSession interruptedProcess isTerminating
		ifTrue: [ SteppingATerminatingProcess signal ].
	^ self basicStepInto: aContext
]

{ #category : 'debugging actions' }
SindarinDebugSession >> stepOver: aContext [
	"Should not step more a process that is terminating, otherwise the image will get locked.
	The image freeze is due to the stepping of the ensure block in doTerminationFromYourself that unwind the terminating context to nil and executes a jump.
	The ensure executes the (fake) primitive 198 which actually freezes (see issue https://github.com/pharo-spec/ScriptableDebugger/issues/105), and prevents the jump to execute which in turn provokes other freezes when trying to close opened debugger on that partially ended process."
	
	
	self debugSession interruptedProcess isTerminating
		ifTrue: [ SteppingATerminatingProcess signal ].
	^ self basicStepOver: aContext
]

{ #category : 'debugging actions' }
SindarinDebugSession >> terminate [

	canBeTerminated ifTrue: [ ^ self debugSession terminate ]
]

{ #category : 'debugging actions' }
SindarinDebugSession >> triggerEvent: anEventSelector [

	triggerEventOn ifTrue: [ 
		^ self debugSession triggerEvent: anEventSelector ]
]

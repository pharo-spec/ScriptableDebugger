"
This class is no longer necessary since the skip operator has been added to the ScriptableDebugger API
"
Class {
	#name : #StepSkipDbgScript,
	#superclass : #DebuggerScript,
	#instVars : [
		'scdbg'
	],
	#category : #ScriptableDebugger
}

{ #category : #accessing }
StepSkipDbgScript class >> scriptName [
	^ 'skip'
]

{ #category : #running }
StepSkipDbgScript >> execute: aScriptableDebugger [
	self execute: aScriptableDebugger withArgs: { nil }
]

{ #category : #running }
StepSkipDbgScript >> execute: aScriptableDebugger withArgs: anOrderedCollection [
	| replacementValue |
	scdbg := aScriptableDebugger.
	self isValid ifFalse: [ ^ self ].
	(anOrderedCollection size ~= 1) ifTrue: [ ^ self ].
	replacementValue := anOrderedCollection at: 1.
	scdbg currentNode isMessage ifTrue: [
		"Pop the arguments of the message send from the context's value stack"
		scdbg currentNode arguments do: [ :arg | scdbg currentContext pop ].
		"Pop the receiver from the context's value stack"
		scdbg currentContext pop.
		"Push the replacement value on the context's value stack, to simulate that the message send happened and returned nil"
		scdbg currentContext push: replacementValue.
		"Increase the pc to go over the message send"
		scdbg currentContext pc: scdbg currentContext pc + 1.
		"Execute bytecodes the debugger usually executes without stopping the execution (for example popping the return value of the just executed message send if it is not used afterwards)"
		scdbg debugSession stepToFirstInterestingBytecodeIn: scdbg debugSession interruptedProcess.
		^ self.
	].
	scdbg currentNode isAssignment ifTrue: [
		"Pop the value to be assigned"
		scdbg currentContext pop.
		"Push the replacement value on the context's value stack, to simulate that the assignment happened and had value nil"
		scdbg currentContext push: replacementValue.
		"Increase the pc to go over the assignment"
		scdbg currentContext pc: scdbg currentContext pc + 2.
		"Execute bytecodes the debugger usually executes without stopping the execution (for example popping the return value of the just executed message send if it is not used afterwards)"
		scdbg debugSession stepToFirstInterestingBytecodeIn: scdbg debugSession interruptedProcess.
		^ self.
	].
	
]

{ #category : #testing }
StepSkipDbgScript >> isValid [
	scdbg currentNode isMessage ifTrue: [ ^true ].
	scdbg currentNode isAssignment ifTrue: [ ^true ].
	^ false.
]

Class {
	#name : #SindarinStepOverCommand,
	#superclass : #SindarinCommand,
	#category : #'Sindarin-Tools'
}

{ #category : #default }
SindarinStepOverCommand class >> defaultCommandName [
	^ 'Step Over'
]

{ #category : #default }
SindarinStepOverCommand class >> defaultDescription [
	^ 'Step over'
]

{ #category : #initialization }
SindarinStepOverCommand class >> defaultIconName [
	^#glamorousOver
]

{ #category : #hooks }
SindarinStepOverCommand >> execute [
	self context stepOver
]

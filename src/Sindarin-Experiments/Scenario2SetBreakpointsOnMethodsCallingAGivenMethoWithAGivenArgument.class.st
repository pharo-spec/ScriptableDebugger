Class {
	#name : 'Scenario2SetBreakpointsOnMethodsCallingAGivenMethoWithAGivenArgument',
	#superclass : 'Object',
	#category : 'Sindarin-Experiments',
	#package : 'Sindarin-Experiments'
}

{ #category : 'file support' }
Scenario2SetBreakpointsOnMethodsCallingAGivenMethoWithAGivenArgument >> openFile: aString [
	^ self
]

{ #category : 'as yet unclassified' }
Scenario2SetBreakpointsOnMethodsCallingAGivenMethoWithAGivenArgument >> stepA [
	self stepB: 'myFile.txt'.
	self stepB: 'hello.txt'.
	self stepC.
	self stepD.
]

{ #category : 'as yet unclassified' }
Scenario2SetBreakpointsOnMethodsCallingAGivenMethoWithAGivenArgument >> stepB: aString [
	self openFile: aString
]

{ #category : 'as yet unclassified' }
Scenario2SetBreakpointsOnMethodsCallingAGivenMethoWithAGivenArgument >> stepC [
	^ self
]

{ #category : 'as yet unclassified' }
Scenario2SetBreakpointsOnMethodsCallingAGivenMethoWithAGivenArgument >> stepD [
	self openFile: 'myFile.txt'
]

"
An abstract class representing a script for the ScriptableDebugger.
Has an automatic mechanism to register its script on the ScriptableDebugger class.
"
Class {
	#name : #DebuggerScript,
	#superclass : #Object,
	#category : #ScriptableDebugger
}

{ #category : #running }
DebuggerScript >> execute: aScriptableDebugger [
	self subclassResponsibility
]

{ #category : #running }
DebuggerScript >> execute: aScriptableDebugger withArgs: anOrderedCollection [
	self subclassResponsibility.
]

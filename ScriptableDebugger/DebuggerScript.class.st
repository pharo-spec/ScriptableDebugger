"
An abstract class representing a script for the ScriptableDebugger.
Has an automatic mechanism to register its script on the ScriptableDebugger class.
"
Class {
	#name : #DebuggerScript,
	#superclass : #Object,
	#category : #ScriptableDebugger
}

{ #category : #initialize }
DebuggerScript class >> initialize [
	ScriptableDebugger2 registerDebuggerScript: self underName: self scriptName.
]

{ #category : #initialize }
DebuggerScript class >> registerAllSubclasses [
	<script>
	self allSubclassesDo: [ :aSubclass | ScriptableDebugger2 registerDebuggerScript: aSubclass underName: aSubclass scriptName. ]
	
]

{ #category : #accessing }
DebuggerScript class >> scriptName [
	self subclassResponsibility.
]

{ #category : #running }
DebuggerScript >> execute: aScriptableDebugger [
	self subclassResponsibility
]

{ #category : #running }
DebuggerScript >> execute: aScriptableDebugger withArgs: anOrderedCollection [
	self subclassResponsibility.
]

Class {
	#name : 'SindarinScriptTest',
	#superclass : 'TestCase',
	#category : 'Sindarin-Scripts-Tests-tests',
	#package : 'Sindarin-Scripts-Tests',
	#tag : 'tests'
}

{ #category : 'tests' }
SindarinScriptTest >> testAnonymousScript [
]

{ #category : 'tests' }
SindarinScriptTest >> testAsAnonymousCommand [
]

{ #category : 'tests' }
SindarinScriptTest >> testAsCommand [
]

{ #category : 'tests' }
SindarinScriptTest >> testDebuggerForScript [
	|debugger script|
	debugger := SindarinDebugger new.
	script := SindarinScript new.
	script executeWith: debugger.
	self assert: script debugger identicalTo: debugger
	
]

{ #category : 'tests' }
SindarinScriptTest >> testExecute [
]

{ #category : 'tests' }
SindarinScriptTest >> testExecuteWithArguments [
]

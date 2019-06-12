Class {
	#name : #StepUntilAboutToSignalExceptionDbgScript,
	#superclass : #DebuggerScript,
	#category : #ScriptableDebugger
}

{ #category : #accessing }
StepUntilAboutToSignalExceptionDbgScript class >> scriptName [
	^ 'StepUntilAboutToSignalException'
]

{ #category : #running }
StepUntilAboutToSignalExceptionDbgScript >> execute: aScriptableDebugger [
	aScriptableDebugger stepWhileFalse: [ aScriptableDebugger contextIsAboutToSignalException: aScriptableDebugger currentContext ]
]

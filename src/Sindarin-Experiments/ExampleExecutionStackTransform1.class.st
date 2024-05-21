"
Code snippet for echo debugging on this example execution:

testExec1 := ExampleExecutionStackTransform1 new setUp.
testExec2 := ExampleExecutionStackTransform2 new setUp.
scdbg1 := ScriptableDebugger debug: [ testExec1 testTransformStack ].
scdbg2 := ScriptableDebugger debug: [ testExec2 testTransformStack ].
[scdbg1 currentSelector = scdbg2 currentSelector] whileTrue: [ scdbg1 step. scdbg2 step. ].
scdbg1 openInGraphicalDebugger. scdbg2 openInGraphicalDebugger.

scdbg1 activateAutoRefreshOfAttachedGraphicalDebugger. scdbg2 activateAutoRefreshOfAttachedGraphicalDebugger.
scdbg2 refreshAttachedGraphicalDebugger 
"
Class {
	#name : 'ExampleExecutionStackTransform1',
	#superclass : 'TestCase',
	#instVars : [
		'stack',
		'expected'
	],
	#category : 'Sindarin-Experiments',
	#package : 'Sindarin-Experiments'
}

{ #category : 'running' }
ExampleExecutionStackTransform1 >> setUp [
	stack := Stack new.
	stack push: $3; push: 'b'; push: $a.
	expected := Stack new.
	expected push: '3'; push: 'b'; push: 'a'.
]

{ #category : 'tests' }
ExampleExecutionStackTransform1 >> testTransformStack [
	[expected isEmpty] whileFalse: [ self transformTopStack. self assert: (stack pop) equals: (expected pop) ].
]

{ #category : 'tests' }
ExampleExecutionStackTransform1 >> transformTopStack [
	(stack top isInteger) ifTrue: [ stack push: (stack pop asCharacterDigit) ].
	(stack top isCharacter) ifTrue: [ stack push: (stack pop asString) ].
]

Class {
	#name : #ExampleExecutionStackTransform2,
	#superclass : #ExampleExecutionStackTransform1,
	#category : #'ScriptableDebugger-Tests'
}

{ #category : #running }
ExampleExecutionStackTransform2 >> setUp [
	stack := Stack new.
	stack push: 3; push: 'b'; push: $a.
	expected := Stack new.
	expected push: $3; push: 'b'; push: 'a'.
]

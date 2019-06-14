Class {
	#name : #Scenario2SetBreakpointsOnMethodsCallingAGivenMethoWithAGivenArgument,
	#superclass : #Object,
	#category : #'ScriptableDebugger-Tests'
}

{ #category : #run }
Scenario2SetBreakpointsOnMethodsCallingAGivenMethoWithAGivenArgument class >> runScenario [
	"When ran, this code sets breakpoints on the methods that call the method openFile: with argument 'myFile.txt'. Do not forget to remove the breakpoints manually after running this method."
	<script>
	| scdbg |
	scdbg := ScriptableDebuggerOld debug: [ self class new stepA ].
	[scdbg isExecutionFinished ] whileFalse: [ 
		((scdbg currentSelector = #openFile:) and:
		[(scdbg currentContext arguments at: 1) = 'myFile.txt'])
			ifTrue: [ scdbg setVBreakpointOnMethod: (scdbg previousMethod) ].
	 	scdbg step. ].
	scdbg commitVBreakpoints.
]

{ #category : #run }
Scenario2SetBreakpointsOnMethodsCallingAGivenMethoWithAGivenArgument class >> runScenario2 [
	"An alternative version of runScenario"
	<script>
	| scdbg |
	scdbg := ScriptableDebuggerOld debug: [ self class new stepA ].
	scdbg runExecutionWhilePlacingBreakpointsWhen: [
		((scdbg currentNode isMessage) and:
		[ scdbg currentNode selector = #openFile: ]) and:
		[ (scdbg at: 0 fromTheEndOfValueStackOfContext: (scdbg currentContext)) = 'myFile.txt']
	].	
]

{ #category : #'file support' }
Scenario2SetBreakpointsOnMethodsCallingAGivenMethoWithAGivenArgument >> openFile: aString [
	^ self
]

{ #category : #'as yet unclassified' }
Scenario2SetBreakpointsOnMethodsCallingAGivenMethoWithAGivenArgument >> stepA [
	self stepB: 'myFile.txt'.
	self stepB: 'hello.txt'.
	self stepC.
	self stepD.
]

{ #category : #'as yet unclassified' }
Scenario2SetBreakpointsOnMethodsCallingAGivenMethoWithAGivenArgument >> stepB: aString [
	self openFile: aString
]

{ #category : #'as yet unclassified' }
Scenario2SetBreakpointsOnMethodsCallingAGivenMethoWithAGivenArgument >> stepC [
	^ self
]

{ #category : #'as yet unclassified' }
Scenario2SetBreakpointsOnMethodsCallingAGivenMethoWithAGivenArgument >> stepD [
	self openFile: 'myFile.txt'
]

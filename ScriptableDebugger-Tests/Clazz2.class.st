Class {
	#name : #Clazz2,
	#superclass : #ScenarioSetBreakpointsOnMethodsCallingAGivenMethoWithAGivenArgument,
	#category : #'ScriptableDebugger-Tests'
}

{ #category : #run }
Clazz2 class >> runScenario [
	"When ran, this code sets breakpoints on the methods that call the method openFile: with argument 'myFile.txt'. Do not forget to remove the breakpoints manually after running this method."
	<script>
	| scdbg |
	scdbg := ScriptableDebugger2 debug: [ Clazz2 new stepA ].
	[scdbg isExecutionFinished ] whileFalse: [ 
		((scdbg currentSelector = #openFile:) and:
		[(scdbg currentContext arguments at: 1) = 'myFile.txt'])
			ifTrue: [ scdbg setVBreakpointOnMethod: (scdbg previousMethod) ].
	 	scdbg step. ].
	scdbg commitVBreakpoints.
]

{ #category : #run }
Clazz2 class >> runScenario2 [
	"An alternative version of runScenario"
	<script>
	| scdbg |
	scdbg := ScriptableDebugger2 debug: [ Clazz2 new stepA ].
	scdbg runExecutionWhilePlacingBreakpointsWhen: [
		((scdbg currentNode isMessage) and:
		[ scdbg currentNode selector = #openFile: ]) and:
		[ (scdbg at: 0 fromTheEndOfValueStackOfContext: (scdbg currentContext)) = 'myFile.txt']
	].	
]

{ #category : #'file support' }
Clazz2 >> openFile: aString [
	^ self
]

{ #category : #'as yet unclassified' }
Clazz2 >> stepA [
	self stepB: 'myFile.txt'.
	self stepB: 'hello.txt'.
	self stepC.
	self stepD.
]

{ #category : #'as yet unclassified' }
Clazz2 >> stepB: aString [
	self openFile: aString
]

{ #category : #'as yet unclassified' }
Clazz2 >> stepC [
	^ self
]

{ #category : #'as yet unclassified' }
Clazz2 >> stepD [
	self openFile: 'myFile.txt'
]

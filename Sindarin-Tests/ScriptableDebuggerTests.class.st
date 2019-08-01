Class {
	#name : #ScriptableDebuggerTests,
	#superclass : #TestCase,
	#instVars : [
		'breakpointsBeforeTest',
		'installedMetalinkBreakpoints'
	],
	#category : #'Sindarin-Tests'
}

{ #category : #tests }
ScriptableDebuggerTests >> helperMethod1 [
	| a |
	a := 5.
	^ Point x: 5 y: '3' asInteger.
]

{ #category : #tests }
ScriptableDebuggerTests >> helperMethod10 [
	| a |
	a := 5.
	^ Point x: 5 y: '3' asInteger.
]

{ #category : #tests }
ScriptableDebuggerTests >> helperMethod11 [
	| a |
	a := 5.
	self helperMethod12.
	self helperMethod12.
	^ 3
]

{ #category : #tests }
ScriptableDebuggerTests >> helperMethod12 [
	| i |
	i := 5.
	[ i=0 ] whileFalse: [ i := i - 1 ].
]

{ #category : #tests }
ScriptableDebuggerTests >> helperMethod13 [
	| a |
	a := 5.
	^ Point x: 5 y: '3' asInteger.
]

{ #category : #tests }
ScriptableDebuggerTests >> helperMethod14 [
	| a |
	a := 5.
	^ Point x: 5 y: '3' asInteger.
]

{ #category : #tests }
ScriptableDebuggerTests >> helperMethod15 [
	| a |
	a := 5.
	^ Point x: 5 y: '3' asInteger.
]

{ #category : #tests }
ScriptableDebuggerTests >> helperMethod16 [
	^ 1+1.
]

{ #category : #tests }
ScriptableDebuggerTests >> helperMethod17: storeContextBlock [
	storeContextBlock value: thisContext.
	Point x:5 y: 7.
]

{ #category : #tests }
ScriptableDebuggerTests >> helperMethod18: anArg with: anotherArg [
	Point x: 5 y: 7.
]

{ #category : #tests }
ScriptableDebuggerTests >> helperMethod19 [
	| a |
	a := 5.
	^ Point x: 5 y: '3' asInteger.
]

{ #category : #tests }
ScriptableDebuggerTests >> helperMethod2 [
	| a |
	a := 5.
	^ Point x: 5 y: '3' asInteger.
]

{ #category : #tests }
ScriptableDebuggerTests >> helperMethod20 [
	| a |
	a := 5.
	^ Point x: 5 y: '3' asInteger.
]

{ #category : #tests }
ScriptableDebuggerTests >> helperMethod21 [
	self helperMethod22
]

{ #category : #tests }
ScriptableDebuggerTests >> helperMethod22 [
	^ Point new
]

{ #category : #tests }
ScriptableDebuggerTests >> helperMethod23 [
	<haltOrBreakpointForTesting>
	| a |
	a := 5.
	Point x: 5 y: '3' asInteger.
	self halt.
]

{ #category : #tests }
ScriptableDebuggerTests >> helperMethod24 [
	Point new.
	self helperMethod25.
]

{ #category : #tests }
ScriptableDebuggerTests >> helperMethod25 [
	<haltOrBreakpointForTesting>
	Point x: 1 y: 2.
]

{ #category : #tests }
ScriptableDebuggerTests >> helperMethod3 [
	| a |
	a := 5.
	^ Point x: 5 y: '3' asInteger.
]

{ #category : #tests }
ScriptableDebuggerTests >> helperMethod4 [
	| a |
	a := 5.
	^ Point x: 5 y: '3' asInteger.
]

{ #category : #tests }
ScriptableDebuggerTests >> helperMethod5 [
	| a |
	a := 5.
	^ Point x: 5 y: '3' asInteger.
]

{ #category : #tests }
ScriptableDebuggerTests >> helperMethod6 [
	| a |
	a := 5.
	^ Point x: 5 y: '3' asInteger.
]

{ #category : #tests }
ScriptableDebuggerTests >> helperMethod7 [
	| a |
	a := 5.
	^ Point x: 5 y: '3' asInteger.
]

{ #category : #tests }
ScriptableDebuggerTests >> helperMethod8 [
	| a |
	a := 5.
	^ Point x: 5 y: '3' asInteger.
]

{ #category : #tests }
ScriptableDebuggerTests >> helperMethod9 [
	| a |
	a := 5.
	^ Point x: 5 y: '3' asInteger.
]

{ #category : #tests }
ScriptableDebuggerTests >> runCaseManaged [
	^ self runCase
]

{ #category : #running }
ScriptableDebuggerTests >> setUp [
	super setUp.
	
	breakpointsBeforeTest := VirtualBreakpoint all.
	VirtualBreakpoint all removeAll.
	installedMetalinkBreakpoints := OrderedCollection new.
]

{ #category : #running }
ScriptableDebuggerTests >> tearDown [
	VirtualBreakpoint all removeAll.
	breakpointsBeforeTest do: [ :brkpt | VirtualBreakpoint all add: brkpt ].
	installedMetalinkBreakpoints do: [ :each | each remove ].
	super tearDown.
]

{ #category : #tests }
ScriptableDebuggerTests >> testAddStepHook [
	| stepCounter stepHook scdbg |
	scdbg := SindarinDebugger debug: [ self helperMethod11 ].
	stepCounter := 0.
	stepHook := [ stepCounter := stepCounter + 1 ].
	scdbg addStepHook: stepHook.
	scdbg step.
	self assert: stepCounter equals: 1.
	scdbg step; stepOver.
	self assert: stepCounter equals: 21.
	scdbg removeStepHook: stepHook.
	scdbg stepOver.
	self assert: stepCounter equals: 21.
]

{ #category : #tests }
ScriptableDebuggerTests >> testArguments [
	| p scdbg |
	p := Point new.
	scdbg := SindarinDebugger debug: [ self helperMethod18: 1 with: p ].
	scdbg step.
	self assert: scdbg arguments size equals: 2.
	self assert: (scdbg arguments at: 1) equals: 1.
	self assert: (scdbg arguments at: 2) equals: p.
	
]

{ #category : #tests }
ScriptableDebuggerTests >> testAssignmentValue [
	| scdbg |
	scdbg := SindarinDebugger debug: [ self helperMethod2 ].
	scdbg step.
	self assert: scdbg assignmentValue equals: 5.
]

{ #category : #tests }
ScriptableDebuggerTests >> testAssignmentVariableName [
	| scdbg |
	scdbg := SindarinDebugger debug: [ self helperMethod3 ].
	scdbg step.
	self assert: scdbg assignmentVariableName equals: #a.
]

{ #category : #tests }
ScriptableDebuggerTests >> testContext [
	| scdbg |
	scdbg := SindarinDebugger debug: [ self helperMethod15 ].
	self assert: scdbg context equals: scdbg debugSession interruptedContext.
	scdbg step.
	self assert: scdbg context equals: scdbg debugSession interruptedContext.
]

{ #category : #tests }
ScriptableDebuggerTests >> testContinue [
	| scdbg vBreakpoint continueResult |
	scdbg := SindarinDebugger debug: [ self helperMethod19 ].
	scdbg step; step.
	self assert: scdbg currentNode isMessage.
	self assert: scdbg currentNode selector equals: #asInteger.
	vBreakpoint := scdbg setBreakpoint.
	scdbg := SindarinDebugger debug: [ self helperMethod19 ].
	continueResult := scdbg continue.
	self assert: scdbg currentNode isMessage.
	self assert: scdbg currentNode selector equals: #asInteger.
	self assert: continueResult isVirtualBreakpoint.
	self assert: continueResult virtualBreakpoint identicalTo: vBreakpoint.
	
]

{ #category : #tests }
ScriptableDebuggerTests >> testContinueBreakpoint [
	| scdbg continueResult breakpoint |
	breakpoint := Breakpoint new node: (self class >>#helperMethod25) ast; always.
	installedMetalinkBreakpoints add: breakpoint.
	breakpoint install.
	scdbg := SindarinDebugger debug: [ self helperMethod24 ].
	continueResult := scdbg continue.
	"self assert: scdbg currentNode isMethod.
	self assert: scdbg currentNode selector equals: #now."
	self assert: continueResult isBreak.
	
]

{ #category : #tests }
ScriptableDebuggerTests >> testContinueHalt [
	| scdbg continueResult |
	scdbg := SindarinDebugger debug: [ self helperMethod23 ].
	continueResult := scdbg continue.
	self assert: scdbg currentNode isMethod.
	self assert: scdbg currentNode selector equals: #now.
	self assert: continueResult isHalt.
	
]

{ #category : #tests }
ScriptableDebuggerTests >> testContinueUntilTheEnd [
	"Test the #continue method when no breakpoint/halt is set. It should step the execution until the end and NOT freeze the image"
	| scdbg semaphore continueResult |
	"VVV Setup code for the timeout"
	semaphore := Semaphore new.
	[
	"^^^ Setup code for the timeout"
	
	scdbg := SindarinDebugger debug: [ self helperMethod20 ].
	continueResult := scdbg continue.
	self assert: scdbg isExecutionFinished.
	self assert: continueResult isExecutionFinished.
	
	"VVV Code for the timeout"
	semaphore signal
	] fork.
	semaphore wait: 5 seconds onCompletion: [ 'success' ] onTimeout: [ self assert: false description: 'Test timed out' ].
	"^^^ Setup code for the timeout"
]

{ #category : #tests }
ScriptableDebuggerTests >> testCurrentNode [
	| node scdbg |
	scdbg := SindarinDebugger debug: [ self helperMethod1 ].
	node := scdbg currentNode.
	self assert: node isMessage.
	self assert: node selector equals: #helperMethod1.
	scdbg step.
	node := scdbg currentNode.
	self assert: node isAssignment.
	self assert: node variable name equals: #a.
	scdbg step.
	node := scdbg currentNode.
	self assert: node isMessage.
	self assert: node selector equals: #asInteger.
]

{ #category : #tests }
ScriptableDebuggerTests >> testIsExecutionFinished [
	| scdbg |
	scdbg := SindarinDebugger debug: [ self helperMethod16 ].
	self assert: scdbg isExecutionFinished not.
	scdbg stepOver; step; step; stepOver; step; stepOver; step.
	"Reached `self isActiveProcess` in Process>>#terminate"
	self assert: scdbg isExecutionFinished.
]

{ #category : #tests }
ScriptableDebuggerTests >> testMessageArguments [
	| scdbg |
	scdbg := SindarinDebugger debug: [ self helperMethod4 ].
	scdbg step; step.
	self assert: scdbg messageArguments isEmpty.
	scdbg stepOver.
	self assert: (scdbg messageArguments at: 1) equals: 5.
	self assert: (scdbg messageArguments at: 2) equals: 3.
]

{ #category : #tests }
ScriptableDebuggerTests >> testMessageReceiver [
	| scdbg |
	scdbg := SindarinDebugger debug: [ self helperMethod5 ].
	self assert: scdbg messageReceiver equals: self.
	scdbg step; step.
	self assert: scdbg messageReceiver equals: '3'.
]

{ #category : #tests }
ScriptableDebuggerTests >> testMessageSelector [
	| scdbg |
	scdbg := SindarinDebugger debug: [ self helperMethod6 ].
	self assert: scdbg messageSelector equals: #helperMethod6.
	scdbg step; step.
	self assert: scdbg messageSelector equals: #asInteger.
	scdbg stepOver.
	self assert: scdbg messageSelector equals: #x:y:.
]

{ #category : #tests }
ScriptableDebuggerTests >> testMethod [
	| scdbg |
	scdbg := SindarinDebugger debug: [ self helperMethod7 ].
	self assert: scdbg method equals: ScriptableDebuggerTests>>#testMethod.
	scdbg step.
	self assert: scdbg method equals: ScriptableDebuggerTests>>#helperMethod7.
	scdbg step; step.
	self assert: scdbg method equals: String>>#asInteger.
]

{ #category : #tests }
ScriptableDebuggerTests >> testOnceBreakpoint [
	| breakpoint scdbg |
	scdbg := SindarinDebugger debug: [ self helperMethod19 ].
	scdbg step; step.
	self assert: scdbg currentNode isMessage.
	self assert: scdbg currentNode selector equals: #asInteger.
	breakpoint := scdbg setBreakpoint.
	breakpoint once.
	scdbg := SindarinDebugger debug: [ self helperMethod19 ].
	scdbg continue.
	scdbg := SindarinDebugger debug: [ self helperMethod19 ].
	scdbg continue.
	self assert: scdbg isExecutionFinished.
]

{ #category : #tests }
ScriptableDebuggerTests >> testReceiver [
	| scdbg |
	scdbg := SindarinDebugger debug: [ self helperMethod8 ].
	self assert: scdbg receiver equals: self.
	scdbg step.
	self assert: scdbg receiver equals: self.
	scdbg step; step.
	self assert: scdbg receiver equals: '3'.
]

{ #category : #tests }
ScriptableDebuggerTests >> testRemoveBreakpoint [
	| breakpoint scdbg |
	scdbg := SindarinDebugger debug: [ self helperMethod19 ].
	scdbg step; step.
	self assert: scdbg currentNode isMessage.
	self assert: scdbg currentNode selector equals: #asInteger.
	breakpoint := scdbg setBreakpoint.
	breakpoint remove.
	scdbg := SindarinDebugger debug: [ self helperMethod19 ].
	scdbg continue.
	self assert: scdbg isExecutionFinished.
]

{ #category : #tests }
ScriptableDebuggerTests >> testSelector [
	| scdbg |
	scdbg := SindarinDebugger debug: [ self helperMethod9 ].
	self assert: scdbg selector equals: #testSelector.
	scdbg step.
	self assert: scdbg selector equals: #helperMethod9.
	scdbg step; step.
	self assert: scdbg selector equals: #asInteger.
]

{ #category : #tests }
ScriptableDebuggerTests >> testSetBreakpoint [
	self testContinue.
]

{ #category : #tests }
ScriptableDebuggerTests >> testSkip [
	|a p scdbg |
	a := 1.
	scdbg := SindarinDebugger debug: [ a := 2. p := Point x: 2 y: 3].
	scdbg skip.
	self assert: a equals: 1.
	scdbg skip.
	scdbg step.
	self assert: p equals: nil.
]

{ #category : #tests }
ScriptableDebuggerTests >> testSkipWith [
	|a p scdbg |
	a := 1.
	scdbg := SindarinDebugger debug: [ a := 2. p := Point x: 2 y: 3].
	scdbg skipWith: 3.
	self assert: a equals: 1.
	scdbg skipWith: 5.
	scdbg step.
	self assert: p equals: 5.
]

{ #category : #tests }
ScriptableDebuggerTests >> testStack [
	| context1 context2 storeContextBlock scdbg |
	storeContextBlock := [ :thisCtx | context2 := thisCtx ].
	scdbg := SindarinDebugger debug: [ context1 := thisContext. self helperMethod17: storeContextBlock ].
	scdbg step.
	self assert: scdbg stack first equals: context1.
	scdbg step; stepOver.
	self assert: scdbg stack first equals: context2.
	self assert: (scdbg stack at: 2) equals: context1.
]

{ #category : #tests }
ScriptableDebuggerTests >> testStep [
	| node scdbg |
	scdbg := SindarinDebugger debug: [ self helperMethod13 ].
	scdbg step.
	node := scdbg currentNode.
	self assert: node isAssignment.
	self assert: node variable name equals: #a.
	scdbg step.
	node := scdbg currentNode.
	self assert: node isMessage.
	self assert: node selector equals: #asInteger.
]

{ #category : #tests }
ScriptableDebuggerTests >> testStepOver [
	|scdbg|
	scdbg := SindarinDebugger debug: [ self helperMethod14 ].
	scdbg stepOver.
	self assert: scdbg currentNode isBlock.
]

{ #category : #tests }
ScriptableDebuggerTests >> testStepOverReturnNode [
	|scdbg|
	scdbg := SindarinDebugger debug: [ self helperMethod21 ].
	scdbg step; step.
	scdbg stepOver.
	self shouldnt: [scdbg stepOver] raise: SteppingATerminatingProcess.
	self assert: scdbg selector equals: #helperMethod21.
	self assert: scdbg currentNode isMethod.
"	self assert: scdbg currentNode isBlock."
]

{ #category : #tests }
ScriptableDebuggerTests >> testStepUntil [
	| i scdbg |
	i := 20.
	scdbg := SindarinDebugger debug: [ [i = 0] whileFalse: [i := i - 1]].
	scdbg stepUntil: [ i = 12 ].
	self assert: i equals: 12.
]

{ #category : #tests }
ScriptableDebuggerTests >> testSteppingAnExecutionSignalingExceptions [
	| scdbg |
	scdbg := SindarinDebugger debug: [ 1/0. 2/0. 3/0. ].
	self should: [ 
		scdbg stepOver; stepOver; stepOver.
	] raise: UnhandledExceptionSignalledByADebuggedExecution.
]

{ #category : #tests }
ScriptableDebuggerTests >> testTemporaries [
	| scdbg |
	scdbg := SindarinDebugger debug: [ self helperMethod10 ].
	self assert: scdbg temporaries size equals: 1.
	scdbg step.
	self assert: scdbg temporaries size equals: 1.
	self assert: (scdbg temporaries at: #a) equals: nil.
	scdbg step.
	self assert: scdbg temporaries size equals: 1.
	self assert: (scdbg temporaries at: #a) equals: 5.
]

{ #category : #tests }
ScriptableDebuggerTests >> testWhenHitBreakpoint [
	| breakpoint toggle scdbg |
	toggle := false.
	scdbg := SindarinDebugger debug: [ self helperMethod19 ].
	scdbg step; step.
	self assert: scdbg currentNode isMessage.
	self assert: scdbg currentNode selector equals: #asInteger.
	breakpoint := scdbg setBreakpoint.
	breakpoint whenHit: [ toggle := true ].
	scdbg := SindarinDebugger debug: [ self helperMethod19 ].
	scdbg continue.
	self assert: toggle.
]

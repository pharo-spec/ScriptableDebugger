Class {
	#name : #ScriptableDebugger2Tests,
	#superclass : #TestCase,
	#instVars : [
		'scdbg'
	],
	#category : #'ScriptableDebugger-Tests'
}

{ #category : #'as yet unclassified' }
ScriptableDebugger2Tests >> helperToSetBreakpointsOn [
	self asString.
	self isClass.
]

{ #category : #tests }
ScriptableDebugger2Tests >> runCaseManaged [
	"This prevents the TestExecutionEnvironment from trying to kill processes created during the test. Without it, it adds on:do: contexts on the process, and this somehow makes the process answers true to isTerminating, triggering the protection against stepping terminating processes from DebugSessionPlus>>stepInto:
	It is not necessary to terminate processes created by ScriptableDebugger because these processes are not scheduled."
	^ self runCase
]

{ #category : #halting }
ScriptableDebugger2Tests >> sendHalt [
	self halt.
]

{ #category : #running }
ScriptableDebugger2Tests >> setUp [
	"Hooks that subclasses may override to define the fixture of test."
	scdbg := nil
]

{ #category : #'exec example - sumXPoint' }
ScriptableDebugger2Tests >> sumXPoint_v1 [
	|p xSum|
	p := Point x: 1 y: 1.
	xSum := { p. Point x: 2 y: 2. Point x: 3 y: 3.} inject: 0 into: [ :sum :point | sum + point x ].
	^ xSum.
]

{ #category : #'exec example - sumXPoint' }
ScriptableDebugger2Tests >> sumXPoint_v2 [
	|p xSum|
	p := Point x: 1 y: 1.
	xSum := { p. Point x: 2 y: 2. Point x: 4 y: 4.} inject: 0 into: [ :sum :point | sum + point x ].
	^ xSum
]

{ #category : #tests }
ScriptableDebugger2Tests >> testAssignmentValue [
	scdbg := ScriptableDebugger2 debug: [ |a| a := 2 ].
	self assert: (scdbg assignmentValue) equals: 2.
]

{ #category : #tests }
ScriptableDebugger2Tests >> testAssignmentVariableName [
	scdbg := ScriptableDebugger2 debug: [ |a| a := 2 ].
	self assert: (scdbg assignmentVariableName) equals: #a.
]

{ #category : #tests }
ScriptableDebugger2Tests >> testContinue [
	|a|
	scdbg := ScriptableDebugger2 debug: [ a:=0. self sendHalt. a:=1. self sendHalt. ].
	scdbg continue.
	self assert: a equals: 0.
	scdbg continue.
	self assert: a equals: 1.
	self shouldnt: [ scdbg continue ] raise: Exception.
]

{ #category : #'as yet unclassified' }
ScriptableDebugger2Tests >> testSetBreakpoints [
"Not a real test"
	| node1 node2 |
	scdbg := ScriptableDebugger2 debug: [ self helperToSetBreakpointsOn ].
	scdbg step.
	node1 := scdbg currentNode.
	scdbg stepOver.
	node2 := scdbg currentNode.
	scdbg setBreakpointOnASTNode: node1.
	scdbg setBreakpointOnASTNode: node2.
	scdbg removeAllBreakpointsSetByMe.
]

{ #category : #tests }
ScriptableDebugger2Tests >> testSkipWith [
	"Skips the #new message send, pushing 5 instead. Then step once to fo the assignment to 'a'. After this, 'a' should be worth 5"
	scdbg := ScriptableDebugger2 debug: [ |a| a := Point new. ].
	scdbg skipWith: 5.
	"scdbg executeDebuggerScriptNamed: #skip withArgs: { 5}."
	scdbg step.
	self assert: (scdbg context: scdbg currentContext hasTemporaryNamed: #a).
	self assert: (scdbg temporaryNamed: #a ofContext: scdbg currentContext ) equals: 5.
]

{ #category : #tests }
ScriptableDebugger2Tests >> testTemporaryVariables [

	scdbg := ScriptableDebugger2 debug: [ |a| a := 5. ].
	self assert: (scdbg context: scdbg currentContext hasTemporaryNamed: #a).
	self assert: (scdbg temporaryNamed: #a ofContext: scdbg currentContext) equals: nil.
	scdbg temporaryNamed: #a ofContext: scdbg currentContext put: 2.
	self assert: (scdbg temporaryNamed: #a ofContext: scdbg currentContext) equals: 2.
	self assert: (scdbg temporaryNamesOfContext: scdbg currentContext) equals: #(#a).
	scdbg step.
	self assert: (scdbg temporaryNamed: #a ofContext: scdbg currentContext) equals: 5.
]

{ #category : #'bug example - transformStack' }
ScriptableDebugger2Tests >> transformStack_v1 [

	| data d |
	"transformation: char -> string"
	data := Stack new push: 3; push: $b; push: 'a'; yourself. "top ->{ 'a'. $b. 3 }"
	"goal: {'a'. 'b'. 3}"
	self transformTopDataOnce_v1: data.
	d := data pop. "returns 'a'. data = {$b. 3}"
	self assert: d equals: 'a'.
	self transformTopDataOnce_v1: data.
	d := data pop. "returns 'b'. data = {3}"
	self assert: d equals: 'b'.
	self transformTopDataOnce_v1: data.
	d := data pop. "returns 3. data = {}"
	self assert: d equals: 3
]

{ #category : #'bug example - transformStack' }
ScriptableDebugger2Tests >> transformStack_v2 [
	"Adding that Integers should be transformed into characters"
	| data d |
	"transformation: int -> char -> string"
	data := Stack new push: 3; push: $b; push: 'a'; yourself. "top ->{ 'a'. $b. 3 }"
	"goal: {'a'. 'b'. $3}"
	self transformTopDataOnce_v2: data.
	d := data pop. "returns 'a'. data = {$b. 3}"
	self assert: d equals: 'a'.
	self transformTopDataOnce_v2: data.
	d := data pop. "returns 'b'. data = {3}"
	self assert: d equals: 'b'.
	self transformTopDataOnce_v2: data.
	d := data pop. "returns '3' instead of the expected $3. data = {}"
	self assert: d equals: $3. "Fails because the integer 3 has been transformed two times (into a string) instead of just into a character"
]

{ #category : #'bug example - transformStack' }
ScriptableDebugger2Tests >> transformTopDataOnce_v1: data [
	| d |
	"(data top isInteger) ifTrue: [ d := data pop. data push: d asCharacterDigit ]."
	(data top isCharacter) ifTrue: [ d := data pop. data push: d asString ].
]

{ #category : #'bug example - transformStack' }
ScriptableDebugger2Tests >> transformTopDataOnce_v2: data [
	| d |
	(data top isInteger) ifTrue: [ d := data pop. data push: d asCharacterDigit ].
	(data top isCharacter) ifTrue: [ d := data pop. data push: d asString ].
]

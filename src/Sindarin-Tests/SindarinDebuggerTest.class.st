Class {
	#name : #SindarinDebuggerTest,
	#superclass : #TestCase,
	#instVars : [
		'testObjectPoint'
	],
	#category : #'Sindarin-Tests-Base'
}

{ #category : #helpers }
SindarinDebuggerTest >> methodNonLocalReturn [
	| block |
	block := [ ^ 42 ].
	block value.
	^ 43
]

{ #category : #helpers }
SindarinDebuggerTest >> methodReturn: bool with: anObject [

	| a |
	a := bool.
	a ifTrue: [ ^ 1 ].
	^ anObject
]

{ #category : #helpers }
SindarinDebuggerTest >> methodReturnWithException [

	| a |
	a := 0.
	1 / 0.
	^ a + 1
]

{ #category : #helpers }
SindarinDebuggerTest >> methodReturnWithHalt [
	<haltOrBreakpointForTesting>

	| a |
	a := 0.
	self halt.
	^ a + 1
]

{ #category : #helpers }
SindarinDebuggerTest >> methodWithBlockWithNoReturn [

	| block a |
	block := [ a := 1 ].
	block value.
	^ 43
]

{ #category : #helpers }
SindarinDebuggerTest >> methodWithContextPassedToBlockParameter: storeContextBlock [

	storeContextBlock value: thisContext
]

{ #category : #helpers }
SindarinDebuggerTest >> methodWithDoubleAssignment [

	| b a |
	a := b :=  1
]

{ #category : #helpers }
SindarinDebuggerTest >> methodWithEmbeddedBlock [

	| a |
	a := 1.
	[ :each | a := a + each. [ a := a + 1 ]. a * 42 ].
	a := a + 2.
	^ a * 42
]

{ #category : #helpers }
SindarinDebuggerTest >> methodWithEvaluatedBlock [

	| a b block |
	a := 1.
	block := [ a := 2. b := 3 + 2 ].
	block value.
	^ 42
	
]

{ #category : #helpers }
SindarinDebuggerTest >> methodWithIfTrueBlock [

	| a |
	a := 1.
	a = 2 ifTrue: [ a := 3 ].
	a := 4
]

{ #category : #tests }
SindarinDebuggerTest >> methodWithIfTrueIfFalse [

	| a |
	a := true.
	a
		ifFalse: [ a := 1 ]
		ifTrue: [ a := 2 ].
	a := 3
]

{ #category : #helpers }
SindarinDebuggerTest >> methodWithImplicitReturn [

	testObjectPoint sign.
	testObjectPoint extent: (Point x: 3 y: 4).
	Point new
]

{ #category : #helpers }
SindarinDebuggerTest >> methodWithNotEvaluatedBlock [

	| a |
	a := 1.
	[ a := a + 1 ].
	a := a + 2.
	^ a * 42
]

{ #category : #helpers }
SindarinDebuggerTest >> methodWithOneAssignment [

	| a |
	a := 5.
	^ Point x: 5 y: '3' asInteger
]

{ #category : #helpers }
SindarinDebuggerTest >> methodWithSeveralInstructionsInBlock [

	| a b block |
	a := 3.
	block := [ 
	         a := 1.
	         b := 2.
	         1 + 2 ].
	b := block value.
	^ 42
]

{ #category : #helpers }
SindarinDebuggerTest >> methodWithTwoAssignments [

	| a |
	a := 1.
	a := 5.
	^ Point x: 5 y: '3' asInteger
]

{ #category : #running }
SindarinDebuggerTest >> runCaseManaged [
	^ self runCase
]

{ #category : #running }
SindarinDebuggerTest >> setUp [
	"Hooks that subclasses may override to define the fixture of test."

	super setUp.

	testObjectPoint := Point x: 1 y: 2
]

{ #category : #running }
SindarinDebuggerTest >> tearDown [

	super tearDown
]

{ #category : #tests }
SindarinDebuggerTest >> testArguments [
	| p scdbg |
	p := Point new.
	scdbg := SindarinDebugger debug: [ self methodReturn: 1 with: p ].
	scdbg step.
	self assert: scdbg arguments size equals: 2.
	self assert: (scdbg arguments at: 1) equals: 1.
	self assert: (scdbg arguments at: 2) equals: p
	
]

{ #category : #tests }
SindarinDebuggerTest >> testAssignmentValue [
	| scdbg |
	scdbg := SindarinDebugger debug: [ self methodWithOneAssignment ].
	scdbg step.
	self assert: scdbg assignmentValue equals: 5
]

{ #category : #tests }
SindarinDebuggerTest >> testAssignmentVariableName [
	| scdbg |
	scdbg := SindarinDebugger debug: [ self methodWithOneAssignment ].
	scdbg step.
	self assert: scdbg assignmentVariableName equals: #a
]

{ #category : #tests }
SindarinDebuggerTest >> testCanStillExecuteWhenAimedNodePcIsAfterInAnyContext [

	| sdbg aimedNodeInContext aimedNodeOutsideContext |
	sdbg := SindarinDebugger debug: [ 
		        self methodWithSeveralInstructionsInBlock ].
	sdbg
		step;
		stepOver;
		stepOver;
		stepOver;
		stepThrough;
		stepOver.

	aimedNodeInContext := sdbg methodNode body statements last.

	self assert: sdbg pc
		< (sdbg methodNode lastPcForNode: aimedNodeInContext).
	self assert: (sdbg canStillExecute: aimedNodeInContext).

	aimedNodeOutsideContext := sdbg node methodNode body statements last.

	self assert: (sdbg outerMostContextOf: sdbg context) pc
		< (sdbg node methodNode lastPcForNode:
				 aimedNodeOutsideContext).
	self assert: (sdbg canStillExecute: aimedNodeOutsideContext)
]

{ #category : #tests }
SindarinDebuggerTest >> testCanStillExecuteWhenAimedNodePcIsBeforeInAnyContext [

	| sdbg aimedNodeInContext aimedNodeOutsideContext |
	sdbg := SindarinDebugger debug: [ 
		        self methodWithSeveralInstructionsInBlock ].
	sdbg
		step;
		stepOver;
		stepOver;
		stepOver;
		stepThrough;
		stepOver.

	aimedNodeInContext := sdbg methodNode body statements first.

	self deny: sdbg pc
		< (sdbg methodNode lastPcForNode: aimedNodeInContext).
	self deny: (sdbg canStillExecute: aimedNodeInContext).

	aimedNodeOutsideContext := sdbg node methodNode body statements second.

	self deny: (sdbg outerMostContextOf: sdbg context) pc
		< (sdbg node methodNode lastPcForNode:
				 aimedNodeOutsideContext).
	self deny: (sdbg canStillExecute: aimedNodeOutsideContext)
]

{ #category : #tests }
SindarinDebuggerTest >> testChangingPcAssociatedToMethodOrSequenceNodeKeepsStackAsItIs [

	| scdbg newPc newNode expectedStackTop |
	scdbg := SindarinDebugger debug: [ 
		         self methodWithDoubleAssignment ].

	scdbg
		step;
		stepOver.
	newNode := scdbg methodNode.
	newPc := scdbg methodNode firstPcForNode: newNode.
	expectedStackTop := scdbg topStack.

	scdbg pc: newPc.

	self assert: scdbg node equals: newNode.
	self assert: scdbg pc equals: newPc.
	self assert: scdbg topStack equals: expectedStackTop
]

{ #category : #tests }
SindarinDebuggerTest >> testChangingPcInTheMiddleOfStatementSkipsTheBeginningOfStatement [

	| scdbg newPc newNode expectedStackTop |
	scdbg := SindarinDebugger debug: [ self methodWithTwoAssignments ].

	scdbg
		step;
		stepOver;
		stepOver;
		stepOver.
	"pc of Point x: y:"
	newNode := scdbg node.
	newPc := scdbg pc.
	expectedStackTop := scdbg topStack.

	scdbg := SindarinDebugger debug: [ self methodWithTwoAssignments ].

	scdbg
		step;
		stepOver.
	"pc of a := 5"

	self assert: (scdbg readVariableNamed: #a) equals: 1.

	scdbg pc: newPc.
	"It should skip the assignment a:=5 AND skip the beginning of the statement ('3' asInteger)"

	self assert: (scdbg readVariableNamed: #a) equals: 1.
	self assert: scdbg node equals: newNode.
	self assert: scdbg pc equals: newPc.
	self deny: scdbg topStack equals: expectedStackTop.
	self assert: scdbg topStack equals: '3' "topStack is nil because the message send asInteger to the receiver '3' has been skipped"
]

{ #category : #tests }
SindarinDebuggerTest >> testChangingPcKeepsSameStateAndPushesCorrectElementsOnStack [

	| scdbg newPc newNode expectedStackTop |
	scdbg := SindarinDebugger debug: [ self methodWithTwoAssignments ].

	scdbg
		step;
		stepOver.
	"pc of a := 5"
	newNode := scdbg node.
	newPc := scdbg pc.
	expectedStackTop := scdbg topStack.
	scdbg
		stepOver;
		stepOver.

	self assert: (scdbg readVariableNamed: #a) equals: 5.

	scdbg pc: newPc.

	self assert: (scdbg readVariableNamed: #a) equals: 5.
	self assert: scdbg node equals: newNode.
	self assert: scdbg pc equals: newPc.
	self assert: scdbg topStack equals: expectedStackTop
]

{ #category : #tests }
SindarinDebuggerTest >> testChangingPcRaisesErrorWhenPcIsGreaterThanEndPC [

	| oldPC sdbg |
	sdbg := SindarinDebugger debug: [ self methodWithTwoAssignments ].
	sdbg
		step;
		stepOver;
		stepOver.
	oldPC := sdbg pc.
	self
		shouldnt: [ sdbg pc: sdbg method endPC ] raise: NotValidPcError;
		deny: sdbg pc equals: oldPC.
	sdbg := SindarinDebugger debug: [ self methodWithTwoAssignments ].
	sdbg
		step;
		stepOver;
		stepOver.
	oldPC := sdbg pc.
	self
		should: [ sdbg pc: sdbg method endPC + 1 ] raise: NotValidPcError;
		assert: sdbg pc equals: oldPC
]

{ #category : #tests }
SindarinDebuggerTest >> testChangingPcRaisesErrorWhenPcIsLowerThanInitialPC [

	| scdbg |
	scdbg := SindarinDebugger debug: [ self methodWithTwoAssignments ].

	scdbg
		step;
		stepOver;
		stepOver.
	
	self shouldnt: [ scdbg pc: scdbg method initialPC ] raise: NotValidPcError.
	
	scdbg := SindarinDebugger debug: [ self methodWithTwoAssignments ].

	scdbg
		step;
		stepOver;
		stepOver.

	self should: [ scdbg pc: scdbg method initialPC - 1 ] raise: NotValidPcError.
]

{ #category : #tests }
SindarinDebuggerTest >> testChangingPcToNonExistingBytecodeOffsetGoesToPreviousPcWithExistingBytecodeOffset [

	| scdbg newPc newNode |
	scdbg := SindarinDebugger debug: [ 
		         self methodWithDoubleAssignment ].

	scdbg step.
	"pc of b := 1 from `a:= b:= 1` This is associated to the pc of a storeIntoTemp bytecode, of length 2 bytes. So we add 1 to get a pc that is in the middle of the bytecode"
	newNode := scdbg methodNode statements first value.
	newPc := (scdbg methodNode firstPcForNode: newNode) + 1.

	self assert: (scdbg methodNode sourceNodeForPC: newPc) identicalTo: newNode.
	
	scdbg pc: newPc.

	self assert: scdbg node equals: newNode.
	self assert: scdbg pc equals: newPc - 1.
]

{ #category : #tests }
SindarinDebuggerTest >> testContext [
	| scdbg |
	scdbg := SindarinDebugger debug: [ self methodWithOneAssignment ].
	self assert: scdbg context equals: scdbg debugSession interruptedContext.
	scdbg step.
	self assert: scdbg context equals: scdbg debugSession interruptedContext
]

{ #category : #tests }
SindarinDebuggerTest >> testContinue [

	| scdbg |
	scdbg := SindarinDebugger debug: [ self methodWithOneAssignment ].

	"We step to the first assignement"
	scdbg step.
	self assert: scdbg node isAssignment.

	"We continue the execution and it should terminate"
	scdbg continue.
	self assert: scdbg isExecutionFinished
]

{ #category : #tests }
SindarinDebuggerTest >> testContinueEncoutersAnException [

	| scdbg |
	scdbg := SindarinDebugger debug: [ self methodReturnWithException ].

	"We step to the first assignement"
	scdbg step.
	self assert: scdbg node isAssignment.

	"We continue the execution and it should terminate"
	scdbg continue.	
	self assert: scdbg isAboutToSignalException
]

{ #category : #'tests - execution predicates' }
SindarinDebuggerTest >> testIsAboutToInstantiateClass [

	|debugger session|
	debugger := SindarinDebugger new.
	session := SindarinDebugSessionMock new.
	debugger sindarinSession: session.
	
	session isMessage: false.	
	self deny: debugger isAboutToInstantiateClass.
	
	session isMessage: true.
	session receiver: Object new.
	session selector: #yourself.
	self deny: debugger isAboutToInstantiateClass.
	
	session receiver: Object new.
	session selector: #toto.
	self deny: debugger isAboutToInstantiateClass.
	
	session receiver: Behavior new.
	session selector: #basicNew. "Primitive 70"
	self assert: debugger isAboutToInstantiateClass.
	
	session selector: #basicNew:. "Primitive 71"
	self assert: debugger isAboutToInstantiateClass.
	
	session selector: #adoptInstance:. "Primitive 160"
	self assert: debugger isAboutToInstantiateClass.
	
	session receiver: Object new.
	session selector: #clone. "Primitive 148"
	self assert: debugger isAboutToInstantiateClass.
		
	session receiver: CompiledCode.
	session selector: #newMethod:header:. "Primitive 79"
	self assert: debugger isAboutToInstantiateClass
	
]

{ #category : #tests }
SindarinDebuggerTest >> testIsAssignment [

	| scdbg |
	scdbg := SindarinDebugger debug: [ self methodWithOneAssignment ].
	self deny: scdbg isAssignment.
	scdbg step.
	self assert: scdbg isAssignment.
	scdbg step.
	self deny: scdbg isAssignment
]

{ #category : #tests }
SindarinDebuggerTest >> testIsExecutionFinished [

	| scdbg |
	scdbg := SindarinDebugger debug: [ self methodWithTwoAssignments  ].
	self deny: scdbg isExecutionFinished.

	[ scdbg isExecutionFinished ] whileFalse: [ scdbg stepOver ].

	self assert: scdbg currentProcess isTerminated
]

{ #category : #tests }
SindarinDebuggerTest >> testIsMessageSend [

	| scdbg |
	scdbg := SindarinDebugger debug: [ self methodWithOneAssignment ].
	self assert: scdbg isMessageSend.
	scdbg step.
	self deny: scdbg isMessageSend.
	scdbg step.
	self assert: scdbg isMessageSend
]

{ #category : #tests }
SindarinDebuggerTest >> testMessage [

	| scdbg |
	scdbg := SindarinDebugger debug: [ self methodWithOneAssignment ].
	self assert: (scdbg message: #methodWithOneAssignment)
]

{ #category : #tests }
SindarinDebuggerTest >> testMessageArguments [
	| scdbg |
	scdbg := SindarinDebugger debug: [ self methodWithOneAssignment ].
	scdbg step; step.
	self assert: scdbg messageArguments isEmpty.
	scdbg stepOver.
	self assert: (scdbg messageArguments at: 1) equals: 5.
	self assert: (scdbg messageArguments at: 2) equals: 3
]

{ #category : #tests }
SindarinDebuggerTest >> testMessageReceiver [
	| scdbg |
	scdbg := SindarinDebugger debug: [ self methodWithOneAssignment ].
	self assert: scdbg messageReceiver equals: self.
	scdbg step; step.
	self assert: scdbg messageReceiver equals: '3'
]

{ #category : #tests }
SindarinDebuggerTest >> testMessageSelector [
	| scdbg |
	scdbg := SindarinDebugger debug: [ self methodWithOneAssignment ].
	self assert: scdbg messageSelector equals: #methodWithOneAssignment.
	scdbg step; step.
	self assert: scdbg messageSelector equals: #asInteger.
	scdbg stepOver.
	self assert: scdbg messageSelector equals: #x:y:
]

{ #category : #tests }
SindarinDebuggerTest >> testMessageTo [
	| scdbg |
	scdbg := SindarinDebugger debug: [ self methodWithImplicitReturn ].
	scdbg step.	"Step to <testObjectPoint sign.> call"
	self assert: (scdbg message: #sign to: testObjectPoint).
	scdbg
		stepOver;
		stepOver.	"Step to <testObjectPoint extent: ...> call"
	self assert: (scdbg message: #extent: to: testObjectPoint).
	
	"Should return false with wrong selector but correct receiver"
	self deny: (scdbg message: #bogus to: testObjectPoint).
	
	"Should return false with correct selector but wrong receiver"
	self deny: (scdbg message: #extent: to: Point new)	
]

{ #category : #tests }
SindarinDebuggerTest >> testMessageToInstanceOf [
	| scdbg |
	scdbg := SindarinDebugger debug: [ self methodWithImplicitReturn ].
	scdbg step. "Step to <testObjectPoint sign> call"
	self assert: (scdbg message: #sign toInstanceOf: Point).
	self assert: (scdbg message: #sign toInstanceOf: Object).
	self deny: (scdbg message: #sign toInstanceOf: Rectangle).
	self deny: (scdbg message: #bogus toInstanceOf: Point)
]

{ #category : #tests }
SindarinDebuggerTest >> testMethod [
	| scdbg |
	scdbg := SindarinDebugger debug: [ self methodWithOneAssignment  ].	
	self assert: scdbg method equals: [ self methodWithOneAssignment ] method.
	scdbg step.
	self assert: scdbg method equals: SindarinDebuggerTest>>#methodWithOneAssignment.
	scdbg step; step.
	self assert: scdbg method equals: String>>#asInteger
]

{ #category : #tests }
SindarinDebuggerTest >> testMoveToNodeInTheMiddleOfStatementSkipsTheBeginningOfStatement [

	| scdbg newPc newNode expectedStackTop |
	scdbg := SindarinDebugger debug: [ self methodWithTwoAssignments ].

	scdbg
		step;
		stepOver;
		stepOver;
		stepOver.
	"pc of Point x: y:"
	newNode := scdbg node.
	newPc := scdbg pc.
	expectedStackTop := scdbg topStack.

	scdbg := SindarinDebugger debug: [ self methodWithTwoAssignments ].

	scdbg
		step;
		stepOver.
	"pc of a := 5"

	self assert: (scdbg readVariableNamed: #a) equals: 1.

	scdbg moveToNode: newNode.
	"It should skip the assignment a:=5 AND skip the beginning of the statement ('3' asInteger)"

	self assert: (scdbg readVariableNamed: #a) equals: 1.
	self assert: scdbg node equals: newNode.
	self assert: scdbg pc equals: newPc.
	self deny: scdbg topStack equals: expectedStackTop.
	self assert: scdbg topStack equals: '3' "topStack is nil because the message send asInteger to the receiver '3' has been skipped"
]

{ #category : #tests }
SindarinDebuggerTest >> testMoveToNodeKeepsSameStateAndPushesCorrectElementsOnStack [

	| scdbg newPc newNode expectedStackTop |
	scdbg := SindarinDebugger debug: [ self methodWithTwoAssignments ].

	scdbg
		step;
		stepOver.
	"pc of a := 5"
	newNode := scdbg node.
	newPc := scdbg pc.
	expectedStackTop := scdbg topStack.
	scdbg
		stepOver;
		stepOver.

	self assert: (scdbg readVariableNamed: #a) equals: 5.

	scdbg moveToNode: newNode.

	self assert: (scdbg readVariableNamed: #a) equals: 5.
	self assert: scdbg node equals: newNode.
	self assert: scdbg pc equals: newPc.
	self assert: scdbg topStack equals: expectedStackTop
]

{ #category : #tests }
SindarinDebuggerTest >> testMoveToNodeKeepsStackWhenAimedNodeIsMethodNode [

	| scdbg newPc newNode expectedStackTop |
	scdbg := SindarinDebugger debug: [ 
		         self methodWithDoubleAssignment ].

	scdbg
		step;
		stepOver.
	"pc of a := 5"
	newNode := scdbg methodNode.
	newPc := scdbg methodNode firstPcForNode: scdbg methodNode.
	expectedStackTop := scdbg topStack.

	scdbg moveToNode: newNode.

	self assert: scdbg node equals: newNode.
	self assert: scdbg pc equals: newPc.
	self assert: scdbg topStack equals: expectedStackTop
]

{ #category : #tests }
SindarinDebuggerTest >> testMoveToNodeKeepsStackWhenAimedNodeIsMethodNodeThatDoesNotHaveAssociatedPC [

	| scdbg newPc newNode realPC realNode |
	scdbg := SindarinDebugger debug: [ self methodWithTwoAssignments ].

	scdbg
		step;
		stepOver.
	"pc of a := 5"
	newNode := scdbg methodNode.
	newPc := scdbg methodNode firstPcForNode: scdbg methodNode.


	self assert: newPc isNil.

	scdbg moveToNode: newNode.

	realPC := scdbg pc.
	realNode := scdbg node.

	self assert: scdbg pc equals: scdbg method endPC.
	self
		assert: scdbg node
		identicalTo: (scdbg methodNode sourceNodeForPC: scdbg pc)
]

{ #category : #tests }
SindarinDebuggerTest >> testMoveToNodeRaisesErrorWhenNodeIsNotIdenticalToANodeInMethod [

	| oldNode sdbg aimedNode |
	sdbg := SindarinDebugger debug: [ self methodWithTwoAssignments ].
	sdbg
		step;
		stepOver.
	aimedNode := sdbg node.
	sdbg
		stepOver;
		stepOver.
	oldNode := sdbg node.
	self
		shouldnt: [ sdbg moveToNode: aimedNode ] raise: NodeNotInASTError;
		assert: sdbg node equals: aimedNode.
	sdbg := SindarinDebugger debug: [ self methodWithTwoAssignments ].
	sdbg
		step;
		stepOver;
		stepOver.
	oldNode := sdbg node.
	self
		should: [ sdbg moveToNode: (RBLiteralValueNode value: 1) ]
		raise: NodeNotInASTError;
		assert: sdbg node equals: oldNode
]

{ #category : #tests }
SindarinDebuggerTest >> testMoveToNodeRaisesErrorWhenNodeIsNotInMethod [

	| oldNode sdbg |
	sdbg := SindarinDebugger debug: [ self methodWithTwoAssignments ].
	sdbg
		step;
		stepOver;
		stepOver.
	oldNode := sdbg node.
	self
		shouldnt: [ sdbg moveToNode: sdbg methodNode statements last ]
		raise: NodeNotInASTError;
		deny: sdbg node equals: oldNode.
	sdbg := SindarinDebugger debug: [ self methodWithTwoAssignments ].
	sdbg
		step;
		stepOver;
		stepOver.
	oldNode := sdbg node.
	self
		should: [ sdbg moveToNode: (RBLiteralValueNode value: 2) ]
		raise: NodeNotInASTError;
		assert: sdbg node equals: oldNode
]

{ #category : #tests }
SindarinDebuggerTest >> testMoveToNodeWhenFromNonInlinedBlockToOuterContext [

	| oldNode sdbg aimedNode oldContext aimedPC methodNode |
	sdbg := SindarinDebugger debug: [ 
		        self methodWithNotEvaluatedBlock ].
	sdbg
		step;
		stepOver;
		stepOver.

	"stops on block creation"
	oldNode := sdbg node.
	oldContext := sdbg context.
	methodNode := sdbg methodNode.

	"We want to move to node 'a + 1' in [a := a +1]"
	aimedNode := sdbg methodNode statements second statements first value.
	aimedPC := sdbg methodNode firstPcForNode: aimedNode.

	self assert: aimedPC isNil.
	self assert: (sdbg readVariableNamed: #a) equals: 1.

	sdbg moveToNode: aimedNode.

	self assert: (sdbg readVariableNamed: #a) equals: 1.

	self assert: sdbg context home identicalTo: oldContext.
	self
		assert: sdbg methodNode
		identicalTo: methodNode statements second.

	sdbg stepOver.

	"2 is going to be assigned to a"
	self assert: (sdbg readVariableNamed: #a) equals: 1.
	self assert: sdbg topStack equals: 2.

	sdbg moveToNode: methodNode statements third.
	"We jump to node outside of block"
	self assert: sdbg methodNode identicalTo: methodNode.
	self assert: sdbg node identicalTo: methodNode statements third.
	"We went back to the home context"
	self assert: sdbg context identicalTo: oldContext.
	"2 has not been assigned to a"
	self assert: (sdbg readVariableNamed: #a) equals: 1.
	self assert: sdbg topStack equals: 1
]

{ #category : #tests }
SindarinDebuggerTest >> testMoveToNodeWhenFromNonInlinedEmbeddedBlockToHomeContext [

	| oldNode sdbg aimedNode oldContext aimedPC methodNode |
	sdbg := SindarinDebugger debug: [ 
		        self methodWithEmbeddedBlock ].
	sdbg
		step;
		stepOver;
		stepOver.

	"stops on block creation"
	oldNode := sdbg node.
	oldContext := sdbg context.
	methodNode := sdbg methodNode.

	"We want to move to node 'a + 1' in [a := a +1]"
	aimedNode := sdbg methodNode statements second statements second statements first value.
	aimedPC := sdbg methodNode firstPcForNode: aimedNode.

	self assert: aimedPC isNil.
	self assert: (sdbg readVariableNamed: #a) equals: 1.

	sdbg moveToNode: aimedNode.

	self assert: (sdbg readVariableNamed: #a) equals: 1.

	self assert: sdbg context home identicalTo: oldContext.
	self
		assert: sdbg methodNode
		identicalTo: methodNode statements second statements second.

	sdbg stepOver.

	"2 is going to be assigned to a"
	self assert: (sdbg readVariableNamed: #a) equals: 1.
	self assert: sdbg topStack equals: 2.

	sdbg moveToNode: methodNode statements third.
	"We jump to node in home context of embedded block"
	self assert: sdbg methodNode identicalTo: methodNode.
	self assert: sdbg node identicalTo: methodNode statements third.
	"We went back to the home context"
	self assert: sdbg context identicalTo: oldContext.
	"2 has not been assigned to a"
	self assert: (sdbg readVariableNamed: #a) equals: 1.
	self assert: sdbg topStack equals: 1
]

{ #category : #tests }
SindarinDebuggerTest >> testMoveToNodeWhenFromNonInlinedEmbeddedBlockToNodeThatIsNotInHomeContext [

	| oldNode oldPC sdbg aimedNode oldContext aimedPC methodNode |
	sdbg := SindarinDebugger debug: [ self methodWithEmbeddedBlock ].
	sdbg
		step;
		stepOver;
		stepOver.

	"stops on block creation"
	oldNode := sdbg node.
	oldContext := sdbg context.
	methodNode := sdbg methodNode.

	"We want to move to node 'a + 1' in [a := a +1]"
	aimedNode := sdbg methodNode statements second statements second
		             statements first value.
	aimedPC := sdbg methodNode firstPcForNode: aimedNode.

	self assert: aimedPC isNil.
	self assert: (sdbg readVariableNamed: #a) equals: 1.

	sdbg moveToNode: aimedNode.

	self assert: (sdbg readVariableNamed: #a) equals: 1.

	self assert: sdbg context home identicalTo: oldContext.
	self
		assert: sdbg methodNode
		identicalTo: methodNode statements second statements second.

	sdbg stepOver.

	"2 is going to be assigned to a"
	self assert: (sdbg readVariableNamed: #a) equals: 1.
	self assert: sdbg topStack equals: 2.

	oldNode := sdbg node.
	oldPC := sdbg pc.
	oldContext := sdbg context.

	self
		should: [ sdbg moveToNode: (RBLiteralValueNode value: 1) ]
		raise: NodeNotInASTError.
	"We jump to node in home context of embedded block"
	self assert: sdbg node identicalTo: oldNode.
	"We went back to the home context"
	self assert: sdbg context identicalTo: oldContext.
	"2 has not been assigned to a"
	self assert: (sdbg readVariableNamed: #a) equals: 1.
	self assert: sdbg topStack equals: 2
]

{ #category : #tests }
SindarinDebuggerTest >> testMoveToNodeWhenNodeIsInBlockThatCreatesContextAndBlockHasBeenCreated [

	| oldNode sdbg aimedNode oldContext aimedPC |
	sdbg := SindarinDebugger debug: [ 
		        self methodWithNotEvaluatedBlock ].
	sdbg
		step;
		stepOver;
		stepOver;
		stepOver.

	sdbg moveToNode: sdbg methodNode statements first.

	"It is going to execute the comparison a := 1"
	oldNode := sdbg node.
	oldContext := sdbg context.

	"We want to enter the block, to get to execute a + 1 in the block"
	aimedNode := sdbg methodNode statements second body statements first
		             value.
	aimedPC := sdbg methodNode firstPcForNode: aimedNode.

	self assert: aimedPC isNil.
	self assert: (sdbg readVariableNamed: #a) equals: 1.

	sdbg moveToNode: aimedNode.

	self assert: (sdbg readVariableNamed: #a) equals: 1.

	self assert: sdbg node identicalTo: aimedNode.
	self assert: sdbg context sender identicalTo: oldContext.

	sdbg
		stepOver;
		stepOver;
		stepOver.

	self assert: (sdbg readVariableNamed: #a) equals: 2.

	"When you perform a stepOver, you quit the block and continue right where you were before moving to caret"
	self assert: sdbg node identicalTo: sdbg methodNode statements third value.
	self assert: sdbg context identicalTo: oldContext.
	self assert: sdbg topStack equals: 2
]

{ #category : #tests }
SindarinDebuggerTest >> testMoveToNodeWhenNodeIsInBlockThatCreatesContextAndBlockHasBeenCreatedBackward [

	| oldNode sdbg aimedNode oldContext aimedPC |
	sdbg := SindarinDebugger debug: [ 
		        self methodWithNotEvaluatedBlock ].
	sdbg
		step;
		stepOver;
		stepOver;
		stepOver;
		stepOver.

	"It is going to execute a := a + 2"
	oldNode := sdbg node.
	oldContext := sdbg context.

	"We want to enter the block, to get to execute a + 1 in the block"
	aimedNode := sdbg methodNode statements second body statements first
		             value.
	aimedPC := sdbg methodNode firstPcForNode: aimedNode.

	self assert: aimedPC isNil.
	self assert: (sdbg readVariableNamed: #a) equals: 1.

	sdbg moveToNode: aimedNode.

	self assert: (sdbg readVariableNamed: #a) equals: 1.

	self assert: sdbg node identicalTo: aimedNode.
	self assert: sdbg context sender identicalTo: oldContext.

	sdbg
		stepOver;
		stepOver;
		stepOver.

	self assert: (sdbg readVariableNamed: #a) equals: 2.

	"When you perform a stepOver, you quit the block and continue right where you were before moving to caret"
	self assert: sdbg node identicalTo: oldNode value.
	self assert: sdbg context identicalTo: oldContext.
	self assert: sdbg topStack equals: 2
]

{ #category : #tests }
SindarinDebuggerTest >> testMoveToNodeWhenNodeIsInIfTrueIfFalseBlock [

	| oldNode sdbg aimedNode oldContext aimedPC |
	sdbg := SindarinDebugger debug: [ self methodWithIfTrueBlock ].
	sdbg
		step;
		stepOver.

	"It is going to execute the comparison a = 2"
	oldNode := sdbg node.
	oldContext := sdbg context.

	"We want to enter the block, to get to execute a:=3"
	aimedNode := sdbg methodNode statements second arguments first body
		             statements first.
	aimedPC := sdbg methodNode firstPcForNode: aimedNode.

	self assert: aimedPC isNotNil.
	self assert: (sdbg readVariableNamed: #a) equals: 1.

	sdbg moveToNode: aimedNode.

	self assert: (sdbg readVariableNamed: #a) equals: 1.

	self assert: sdbg node identicalTo: aimedNode.
	self assert: sdbg pc identicalTo: aimedPC.
	self assert: sdbg context identicalTo: oldContext.

	sdbg stepOver.

	self assert: (sdbg readVariableNamed: #a) equals: 3.

	sdbg stepOver.
	"When you perform a stepOver, you quit the block and continue just after the ifTrue: message"
	self assert: (sdbg readVariableNamed: #a) equals: 4
]

{ #category : #tests }
SindarinDebuggerTest >> testMoveToNodeWhenNodeIsLiteralOrVariableExecutesAssociatedBytecodesBecauseRelatedToStack [

	| oldNode sdbg aimedNode siblingsAfterAimedNode indexOfAimedNode realNode indexOfRealNode |
	sdbg := SindarinDebugger debug: [ self methodWithTwoAssignments ].
	sdbg step.
	oldNode := sdbg node.
	"This is the literal variable Point from `Point x: 5 y: '3' asInteger"
	aimedNode := sdbg methodNode statements last value receiver.
	indexOfAimedNode := sdbg methodNode allChildrenPostOrder identityIndexOf: aimedNode.
	siblingsAfterAimedNode := sdbg methodNode allChildrenPostOrder
		                          withIndexSelect: [ :value :index | 
		                          index > indexOfAimedNode ].

	self deny: (sdbg methodNode pcsForNode: aimedNode) isEmpty.
	self assert: aimedNode isVariable.

	sdbg moveToNode: aimedNode.

	realNode := sdbg node.
	indexOfRealNode := siblingsAfterAimedNode indexOf: realNode.

	self deny: realNode identicalTo: aimedNode.
	siblingsAfterAimedNode
		from: 1
		to: indexOfRealNode - 1
		do: [ :each | 
		self assert: (each isVariable or: [ each isLiteralNode ]) ].

	self deny: (realNode isLiteralNode or: [ realNode isVariable ])
]

{ #category : #tests }
SindarinDebuggerTest >> testMoveToNodeWhenNodeIsLiteralOrVariableThatHasNoAssociatedBytecodesMovesToNextNodeThatIsNotLiteralNorVariableThatHasAnAssociatedPC [

	| oldNode sdbg aimedNode siblingsAfterAimedNode indexOfAimedNode realNode indexOfRealNode |
	sdbg := SindarinDebugger debug: [ 
		        self methodWithDoubleAssignment ].
	sdbg step.
	oldNode := sdbg node.
	"This is the variable node b from `a:= b:= 1`"
	aimedNode := sdbg methodNode statements first value variable.
	indexOfAimedNode := sdbg methodNode allChildrenPostOrder identityIndexOf:
		                    aimedNode.
	siblingsAfterAimedNode := sdbg methodNode allChildrenPostOrder 
		                          withIndexSelect: [ :value :index | 
		                          index > indexOfAimedNode ].

	self assert: (sdbg methodNode pcsForNode: aimedNode) isEmpty.

	sdbg moveToNode: aimedNode.

	realNode := sdbg node.
	indexOfRealNode := siblingsAfterAimedNode identityIndexOf: realNode.

	self deny: realNode identicalTo: aimedNode.
	siblingsAfterAimedNode
		from: 1
		to: indexOfRealNode - 1
		do: [ :each | 
			self assert: (each isVariable or: [ 
					 each isLiteralNode or: [ 
						 (sdbg methodNode pcsForNode: each) isEmpty ] ]) ].

	" Why doesn't it work ??
	self deny: (realNode isLiteralNode or: [   realNode isVariable or: [   (sdbg methodNode pcsForNode: realNode) isEmpty  ] ]) "
	
	self
		deny: realNode isLiteralNode;
		deny: realNode isVariable;
		deny: (sdbg methodNode pcsForNode: realNode) isEmpty
]

{ #category : #tests }
SindarinDebuggerTest >> testMoveToNodeWhenNodeIsNonInlinedAndEmbeddedInNonInlinedBlock [

	| oldNode sdbg aimedNode oldContext aimedPC methodNode |
	sdbg := SindarinDebugger debug: [ 
		        self methodWithEmbeddedBlock ].
	sdbg
		step;
		stepOver;
		stepOver. 
		
	"stops on outer block creation"
	oldNode := sdbg node.
	oldContext := sdbg context.
	methodNode := sdbg methodNode.
	
	"We want to move to node 'a + 1' in [a := a +1] (embedded block)"
	aimedNode := sdbg methodNode statements second statements second statements first value.
	aimedPC := sdbg methodNode firstPcForNode: aimedNode.
	
	self assert: aimedPC isNil.
	self assert: (sdbg readVariableNamed: #a) equals: 1.

	sdbg moveToNode: aimedNode.

	self assert: (sdbg readVariableNamed: #a) equals: 1.

	self assert: sdbg node identicalTo: aimedNode.
	self assert: sdbg context home identicalTo: oldContext.
	self assert: sdbg methodNode identicalTo: methodNode statements second statements second.

	sdbg
		stepOver;
		stepOver;
		stepOver.

	self assert: (sdbg readVariableNamed: #a) equals: 2.

	"When you perform a stepOver, you quit the block and continue after the embedded block creation in the embedding block context"
	self assert: sdbg methodNode identicalTo: methodNode statements second.
	self assert: sdbg node identicalTo: methodNode statements second statements third.
	self assert: sdbg context sender identicalTo: oldContext.
	
	sdbg
		stepOver;
		stepOver;
		stepOver.
		
	self assert: (sdbg readVariableNamed: #a) equals: 2.

	"When you perform stepOver again, you quit the embedding block and continue after the embedding block creation in the old context"
	self assert: sdbg methodNode identicalTo: methodNode.
	self assert: sdbg node identicalTo: sdbg methodNode statements third.
	self assert: sdbg context identicalTo: oldContext.
]

{ #category : #tests }
SindarinDebuggerTest >> testNode [
	| node scdbg |
	scdbg := SindarinDebugger debug: [ self methodWithTwoAssignments ].
	node := scdbg node.
	self assert: node isMessage.
	self assert: node selector equals: #methodWithTwoAssignments.
	scdbg step.
	node := scdbg node.
	self assert: node isAssignment.
	self assert: node variable name equals: #a.
	scdbg stepOver.
	scdbg stepOver.
	node := scdbg node.
	self assert: node isMessage.
	self assert: node selector equals: #asInteger
]

{ #category : #tests }
SindarinDebuggerTest >> testPc [
	| dbg |
	dbg := SindarinDebugger
		debug: [ | a p |
			a := 2.
			p := Point x: 2 y: 3 ].
	dbg step; step; step.
	self assert: dbg pc equals: dbg context pc
]

{ #category : #tests }
SindarinDebuggerTest >> testReceiver [
	| scdbg |
	scdbg := SindarinDebugger debug: [ self methodWithOneAssignment ].
	self assert: scdbg receiver equals: self.
	scdbg step.
	self assert: scdbg receiver equals: self.
	scdbg step; step.
	self assert: scdbg receiver equals: '3'
]

{ #category : #tests }
SindarinDebuggerTest >> testSelector [
	| scdbg |
	scdbg := SindarinDebugger debug: [ self methodWithOneAssignment ].
	self assert: scdbg selector equals: #testSelector.
	scdbg step.
	self assert: scdbg selector equals: #methodWithOneAssignment.
	scdbg step; step.
	self assert: scdbg selector equals: #asInteger
]

{ #category : #'tests - skipping' }
SindarinDebuggerTest >> testSkip [
	| a p scdbg |
	a := 1.
	scdbg := SindarinDebugger
		debug: [ a := 2.
			p := Point x: 2 y: 3 ].
	scdbg skip.
	self assert: a equals: 1.
	scdbg skip.
	scdbg step.
	self assert: p equals: Point
]

{ #category : #'tests - skipping' }
SindarinDebuggerTest >> testSkipAssignmentWithStoreIntoBytecodePushesReplacementValueButNotWithPopIntoBytecode [

	| a b dbg aFormerValue bFormerValue |
	dbg := SindarinDebugger debug: [ 
		       b := 1.
		       [ 
		       a := 2.
		       a := b := 3 + 4 ] value.
		       ^ 42 ].
	dbg step.
	dbg step.
	dbg stepThrough. "we enter the block"

	dbg skip. "we skip the assignment a:= 2"
	self assert: dbg topStack equals: 4.
	self assert: a equals: nil.

	bFormerValue := b.
	dbg step. dbg skip. "we skip the assignment b := 3 + 4"
	self assert: dbg topStack equals: bFormerValue.
	self assert: b equals: bFormerValue.

	aFormerValue := a.
	dbg skip. "we skip the assignment a:= (b := 3 + 4)"
	self assert: dbg topStack equals: aFormerValue.
	self assert: a equals: aFormerValue
]

{ #category : #tests }
SindarinDebuggerTest >> testSkipBlockNode [

	| scdbg targetContext |
	scdbg := SindarinDebugger debug: [ self methodNonLocalReturn ].

	scdbg
		step;
		step.

	self assert: scdbg topStack isBlock.

	scdbg stepUntil: [ 
		scdbg node isMessage and: [ scdbg messageSelector = #value ] ].

	targetContext := scdbg context sender.
	scdbg stepOver.

	self assert: scdbg context identicalTo: targetContext.
	self assert: scdbg topStack equals: 42.

	scdbg := SindarinDebugger debug: [ self methodNonLocalReturn ].

	scdbg
		step;
		skip.

	self assert: scdbg topStack isNil.

	scdbg stepUntil: [ 
		scdbg node isMessage and: [ scdbg messageSelector = #value ] ].

	targetContext := scdbg context.

	scdbg stepOver.

	self assert: scdbg context identicalTo: targetContext.
	self assert: scdbg topStack equals: 43
]

{ #category : #tests }
SindarinDebuggerTest >> testSkipDoesNotSkipReturn [

	| a scdbg |
	scdbg := SindarinDebugger debug: [ a := 1. ^ 42  ].
	
	self shouldnt: [ scdbg skip ] raise: SindarinSkippingReturnWarning.
	self should: [ scdbg skip ] raise: SindarinSkippingReturnWarning
]

{ #category : #tests }
SindarinDebuggerTest >> testSkipSkipsMessagesByPuttingReceiverOnStack [

	| a scdbg |
 	a := 1.
 	scdbg := SindarinDebugger
 		debug: [ a := a + 2 ].
 	self assert: a equals: 1.

 	scdbg skip.
 	scdbg step.

 	self assert: a equals: 1
]

{ #category : #tests }
SindarinDebuggerTest >> testSkipSkipsSuperSendBytecodesCorrectly [

	| a scdbg oldValueOfA negatedContext |
	a := ScaledDecimal newFromNumber: 3 scale: 2.
	scdbg := SindarinDebugger debug: [ a := a negated ].
	oldValueOfA := a.

	scdbg
		step;
		stepOver;
		skip.
	negatedContext := scdbg context.
	scdbg stepUntil: [ scdbg context == negatedContext ].
	scdbg stepOver.

	self assert: a equals: oldValueOfA
]

{ #category : #tests }
SindarinDebuggerTest >> testSkipStepsMethodNodes [

	| scdbg realExecNode realExecPc realTopStack |
	scdbg := SindarinDebugger debug: [ 
		         self methodWithBlockWithNoReturn ].

	scdbg step.
	scdbg stepOver.

	realExecNode := scdbg node.
	realExecPc := scdbg pc.
	realTopStack := scdbg topStack.

	scdbg := SindarinDebugger debug: [ 
		         self methodWithBlockWithNoReturn ].

	scdbg
		step;
		skip.

	self assert: scdbg node identicalTo: realExecNode.
	self assert: scdbg pc identicalTo: realExecPc.
	self assert: scdbg topStack equals: realTopStack
]

{ #category : #'tests - skipping' }
SindarinDebuggerTest >> testSkipThroughNode [
	| dbg realExecPC realValueOfA targetExecNode realExecTopStack nodeAfterSkipThrough |

	dbg := SindarinDebugger
		debug: [ self methodWithTwoAssignments  ].
	dbg step; stepOver; stepOver.	
	targetExecNode := dbg node.
	realValueOfA := (dbg readVariableNamed: #a).	
	dbg stepOver.
	nodeAfterSkipThrough := dbg node.
	realExecTopStack := dbg topStack.
	realExecPC := dbg pc.
	
	dbg := SindarinDebugger
		debug: [ self methodWithTwoAssignments  ].
	
	dbg step; stepOver; skipThroughNode: targetExecNode.
		
	self assert: dbg pc equals: realExecPC.
	self assert: dbg node identicalTo: nodeAfterSkipThrough.
	self assert: realValueOfA equals: 5.
	self assert: (dbg readVariableNamed: #a) equals: 1.
	self assert: realExecTopStack equals: 3.
	self assert: dbg topStack equals: '3'
]

{ #category : #'tests - skipping' }
SindarinDebuggerTest >> testSkipToPC [
	| dbg realExecPC realValueOfA realExecNode realExecTopStack |

	dbg := SindarinDebugger
		debug: [ self methodWithTwoAssignments  ].
	dbg step; stepOver; stepOver.
	realExecPC := dbg pc.
	realExecNode := dbg node.
	realValueOfA := (dbg readVariableNamed: #a).
	realExecTopStack := dbg topStack.

	dbg := SindarinDebugger
		debug: [ self methodWithTwoAssignments  ].

	dbg step; stepOver; skipToPC: realExecPC. 
	self assert: dbg pc equals: realExecPC.
	self assert: dbg node equals: realExecNode.
	self assert: realValueOfA equals: 5.
	self assert: (dbg readVariableNamed: #a) equals: 1.
	self assert: dbg topStack equals: realExecTopStack
]

{ #category : #tests }
SindarinDebuggerTest >> testSkipToPcDoesNotLoopWhenAimedPcIsAfterEndPc [

	| sdbg aimedPc pcBeforeSkip |
	sdbg := SindarinDebugger debug: [ 
		        self methodWithSeveralInstructionsInBlock ].
	sdbg
		step;
		stepOver.

	sdbg stepOver.
	pcBeforeSkip := sdbg pc.
	aimedPc := sdbg context endPC + 1.

	sdbg skipToPC: aimedPc.

	self assert: sdbg pc equals: sdbg context endPC.
]

{ #category : #tests }
SindarinDebuggerTest >> testSkipToPcDoesNotLoopWhenAimedPcIsBeforeCurrentPc [

	| sdbg aimedPc pcBeforeSkip |
	sdbg := SindarinDebugger debug: [ 
		        self methodWithSeveralInstructionsInBlock ].
	sdbg
		step;
		stepOver.

	aimedPc := sdbg pc.

	sdbg stepOver.
	pcBeforeSkip := sdbg pc.

	sdbg skipToPC: aimedPc.

	self assert: sdbg pc equals: pcBeforeSkip.
]

{ #category : #tests }
SindarinDebuggerTest >> testSkipUpToIgnoresJumps [

	| sdbg aimedNode aimedPC a |
	sdbg := SindarinDebugger debug: [ self methodWithIfTrueIfFalse ].

	sdbg step.

	aimedNode := sdbg methodNode statements second arguments first
		             statements first.
	aimedPC := sdbg methodNode firstPcForNode: aimedNode.

	a := sdbg readVariableNamed: #a.

	self assert: a isNil.

	sdbg skipUpToNode: aimedNode.

	self
		assert: a isNil;
		assert: sdbg node identicalTo: aimedNode;
		assert: sdbg pc equals: aimedPC.

	aimedNode := sdbg methodNode statements second arguments second
		             statements first.
	aimedPC := sdbg methodNode firstPcForNode: aimedNode.

	a := sdbg readVariableNamed: #a.

	self assert: a isNil.

	sdbg skipUpToNode: aimedNode .

	self
		assert: a isNil;
		assert: sdbg node identicalTo: aimedNode;
		assert: sdbg pc equals: aimedPC.

	aimedNode := sdbg methodNode statements third.
	aimedPC := sdbg methodNode firstPcForNode: aimedNode.

	a := sdbg readVariableNamed: #a.

	self assert: a isNil.

	sdbg skipUpToNode: aimedNode.

	self
		assert: a isNil;
		assert: sdbg node identicalTo: aimedNode;
		assert: sdbg pc equals: aimedPC
]

{ #category : #'tests - skipping' }
SindarinDebuggerTest >> testSkipUpToNode [
	| dbg realExecPC realValueOfA realExecNode realExecTopStack |

	dbg := SindarinDebugger
		debug: [ self methodWithTwoAssignments  ].
	dbg step; stepOver; stepOver.
	realExecPC := dbg pc.
	realExecNode := dbg node.
	realValueOfA := (dbg readVariableNamed: #a).
	realExecTopStack := dbg topStack.
	
	dbg := SindarinDebugger
		debug: [ self methodWithTwoAssignments  ].
	
	dbg step; stepOver; skipUpToNode: realExecNode. 
	self assert: dbg pc equals: realExecPC.
	self assert: dbg node identicalTo: realExecNode.
	self assert: realValueOfA equals: 5.
	self assert: (dbg readVariableNamed: #a) equals: 1.
	self assert: dbg topStack equals: realExecTopStack
]

{ #category : #tests }
SindarinDebuggerTest >> testSkipUpToNodeDoesNotLoopWhenAimedNodeIsBeforeCurrentNode [

	| sdbg aimedNode nodeBeforeSkip |
	sdbg := SindarinDebugger debug: [ 
		        self methodWithSeveralInstructionsInBlock ].
	sdbg
		step;
		stepOver.

	aimedNode := sdbg node.
	sdbg stepOver.
	nodeBeforeSkip := sdbg node.

	sdbg skipUpToNode: aimedNode.

	self assert: sdbg node identicalTo: nodeBeforeSkip
]

{ #category : #'tests - skipping' }
SindarinDebuggerTest >> testSkipUpToNodeInEvaluatedBlock [

	| dbg realExecPC realExecNode realExecTopStack oldValueOfA valueOfBAfterSkipAndStep |
	dbg := SindarinDebugger debug: [ self methodWithEvaluatedBlock ].
	"after stepping, we stop at the beginning of the block"
	dbg
		step;
		step;
		stepOver;
		stepOver;
		stepOver;
		stepThrough.
	oldValueOfA := dbg readVariableNamed: #a.
	"after stepping, we stop on  b: = 3 + 2 assignment node"
	dbg stepOver.

	self assert: dbg node isMessage.
	valueOfBAfterSkipAndStep := dbg node receiver value.
	
	dbg stepOver.
	
	realExecPC := dbg pc.
	realExecNode := dbg node.
	realExecTopStack := dbg topStack.

	dbg := SindarinDebugger debug: [ self methodWithEvaluatedBlock ].

	dbg
		step;
		step;
		stepOver;
		stepOver;
		stepOver;
		stepThrough;
		skipUpToNode: realExecNode.
	self assert: dbg pc equals: realExecPC.
	self assert: dbg node identicalTo: realExecNode.
	self assert: (dbg readVariableNamed: #a) equals: oldValueOfA.
	self assert: dbg topStack equals: valueOfBAfterSkipAndStep.

	dbg stepOver.
	"3 is on the stack so stepping over the assignment should put 3 into b"
	self assert: (dbg readVariableNamed: #b) equals: valueOfBAfterSkipAndStep 
]

{ #category : #'tests - skipping' }
SindarinDebuggerTest >> testSkipUpToNodeStopsOnImplicitReturnIfAimedNodeCanStillBeExecuted [

	| scdbg implicitReturnPc implicitReturnNode realExecPc realExecNode |
	scdbg := SindarinDebugger debug: [ 
		         self methodWithBlockWithNoReturn ].

	scdbg
		step;
		stepOver;
		stepOver;
		stepOver;
		stepThrough;
		stepOver.

	implicitReturnPc := scdbg pc.
	implicitReturnNode := scdbg node.
	scdbg stepOver.

	realExecPc := scdbg pc.
	realExecNode := scdbg node.

	self assert: realExecPc ~= implicitReturnPc.

	scdbg := SindarinDebugger debug: [ 
		         self methodWithBlockWithNoReturn ].

	scdbg
		step;
		stepOver;
		stepOver;
		stepOver;
		stepThrough.

	self assert: (scdbg canStillExecute: realExecNode).

	scdbg skipUpToNode: realExecNode.

	self assert: scdbg pc equals: implicitReturnPc.
	self assert: scdbg node identicalTo: implicitReturnNode
]

{ #category : #'tests - skipping' }
SindarinDebuggerTest >> testSkipUpToNodeStopsOnReturnNodes [

	| scdbg returnInBlock realExecNode |
	scdbg := SindarinDebugger debug: [ self methodNonLocalReturn ].


	scdbg
		step;
		stepOver;
		stepOver;
		stepThrough.
	returnInBlock := scdbg node.
	realExecNode := scdbg node methodNode body statements last.

	self assert: returnInBlock isReturn.
	self assert: realExecNode isReturn.


	scdbg := SindarinDebugger debug: [ self methodNonLocalReturn ].
	scdbg
		step;
		stepOver;
		stepOver;
		stepThrough;
		skipUpToNode: realExecNode.

	self assert: scdbg node identicalTo: returnInBlock
]

{ #category : #'tests - skipping' }
SindarinDebuggerTest >> testSkipWith [
	| a p scdbg |

	a := 1.
	scdbg := SindarinDebugger
		debug: [ a := 2.
			p := Point x: 2 y: 3  ].
	scdbg skipWith: 3.
	self assert: a equals: 3.
	scdbg skipWith: 5.
	scdbg step.
	self assert: p equals: 5
]

{ #category : #tests }
SindarinDebuggerTest >> testStack [

	| contextStoreBlock contextHere calleeContext scdbg |
	contextStoreBlock := [ :localContext | calleeContext := localContext ].
	scdbg := SindarinDebugger debug: [ "We capture the local context here, that should be the bottom context""stack = contextHere"
		         contextHere := thisContext.
		         "We send a block as paremeter of a method call that will capture the local context of the callee method"
		         "After returning from the call, 
					stack = calleeContext (callee)<< contextHere (sender)"

		         self methodWithContextPassedToBlockParameter: contextStoreBlock ].
	"We step the contextHere := thisContext instruction"
	scdbg step.
	"The stack has contextHere on top."
	self assert: scdbg stack first equals: contextHere.

	"We step into methodWithContextPassedToBlockParameter: and over the first statement (the execution of the block passed as parameter)"
	scdbg step.
	scdbg stepOver.

	"The stack has calleeContext on top and contextHere as sender"
	self assert: scdbg stack first identicalTo: calleeContext.
	self assert: scdbg stack first sender identicalTo: contextHere.
	self assert: scdbg stack second identicalTo: contextHere
]

{ #category : #tests }
SindarinDebuggerTest >> testStatementNodeContaining [

	| sdbg |
	sdbg := SindarinDebugger debug: [ self methodWithTwoAssignments ].
	sdbg step; stepOver; stepOver; stepOver. "pc of Point x: y:"
	
	self assert: (sdbg statementNodeContaining: sdbg node) identicalTo: sdbg methodNode statements last
]

{ #category : #tests }
SindarinDebuggerTest >> testStatementNodeContainingReturnsStatementNodeThatContainsTheIdenticalSubtree [

	| sdbg |
	sdbg := SindarinDebugger debug: [ self methodWithTwoAssignments ].
	sdbg step.

	"1 is in the tree but it should return its parent only if we provide the exact literal node"
	self
		should: [ sdbg statementNodeContaining: (RBLiteralNode value: 1) ]
		raise: NodeNotInASTError
]

{ #category : #tests }
SindarinDebuggerTest >> testStatementNodeContainingWhenNodeIsNotInAST [

	| sdbg |
	sdbg := SindarinDebugger debug: [ self methodWithTwoAssignments ].
	sdbg step.

	self
		should: [ sdbg statementNodeContaining: (RBLiteralNode value: 2) ]
		raise: NodeNotInASTError
]

{ #category : #tests }
SindarinDebuggerTest >> testStep [
	| node scdbg |
	scdbg := SindarinDebugger debug: [ self methodWithOneAssignment ].
	scdbg step.
	node := scdbg node.
	self assert: node isAssignment.
	self assert: node variable name equals: #a.
	scdbg step.
	node := scdbg node.
	self assert: node isMessage.
	self assert: node selector equals: #asInteger
]

{ #category : #tests }
SindarinDebuggerTest >> testStepOver [
	| scdbg |
	scdbg := SindarinDebugger debug: [ self methodWithOneAssignment ].
	scdbg step. "Enters the call of helperMethod14. Current node should be: a:=5"
	scdbg stepOver. "After this, current node should be: '3' asInteger"
	scdbg stepOver. "After this, current node should be: Point x:5 y:'3' asInteger"
	self assert: scdbg node isMessage.
	self assert: scdbg node selector equals: #x:y:
]

{ #category : #tests }
SindarinDebuggerTest >> testStepOverFinishedExecution [
	"This test tries to show is that using Sindarin on a block, it should raise an exception if you continue stepping over that code in your Sindarin script while the execution of that code is already finished (nothing more to step)"

	|scdbg|
	scdbg := SindarinDebugger debug: [ self methodWithImplicitReturn ].
	
	"Stepping until the implicit return of #methodWithImplicitReturn"
	scdbg stepOver: 2.		
	self should: [scdbg stepOver] raise: DebuggedExecutionIsFinished
]

{ #category : #'tests - step return' }
SindarinDebuggerTest >> testStepToImplicitReturn [
	| dbg |

	dbg := SindarinDebugger debug: [ self methodWithImplicitReturn ].
	dbg stepToMethodEntry.
	dbg stepToReturn.
	
	self assert: dbg node isMethod.
	dbg step.		
	self assert: dbg topStack equals: self.
	
	

	
]

{ #category : #'tests - step return' }
SindarinDebuggerTest >> testStepToMethodEntry [
	| dbg |

	dbg := SindarinDebugger debug: [ self methodReturn: true with: 42].
	dbg stepToMethodEntry.
		
	self assert: dbg pc equals: dbg method initialPC.
	self assert: dbg method identicalTo: (self class >> #methodReturn:with:).	
	
	
]

{ #category : #'tests - step return' }
SindarinDebuggerTest >> testStepToNonLocalReturn [
	| dbg |
	
	dbg := SindarinDebugger debug: [ self methodNonLocalReturn ].
	dbg stepToMethodEntry.
	dbg stepToReturn.
	
	self assert: dbg node isReturn.
	self assert: dbg topStack equals: 42
	
	

	
]

{ #category : #'tests - step return' }
SindarinDebuggerTest >> testStepToReturn [

	| dbg |

	"First return node"
	dbg := SindarinDebugger debug: [
		       self methodReturn: true with: 42 ].
	dbg stepToMethodEntry.
	dbg stepToReturn.

	self assert: dbg node isReturn.
	self assert: dbg topStack equals: 1.

	"Second return node"
	dbg := SindarinDebugger debug: [ self methodReturn: false with: 2 ].
	dbg stepToMethodEntry.
	dbg stepToReturn.

	self assert: dbg node isReturn.
	self assert: dbg topStack equals: 2
]

{ #category : #'tests - step return' }
SindarinDebuggerTest >> testStepToReturnWithException [
	| dbg |

	"First return node"
	dbg := SindarinDebugger debug: [ self methodReturnWithException ].
	dbg stepToMethodEntry.
	dbg stepToReturn.
	
	self assert: dbg receiver class identicalTo: ZeroDivide.
	self assert: dbg method equals: (Exception >> #signal)
]

{ #category : #'tests - step return' }
SindarinDebuggerTest >> testStepToReturnWithHalt [
	| dbg |
	"First return node"
	dbg := SindarinDebugger debug: [ self methodReturnWithHalt ].
	dbg stepToMethodEntry.
	dbg stepToReturn.
	
	self assert: dbg context instructionStream willReturn.
	self assert: dbg node isReturn.
	self assert: dbg topStack equals: 1
]

{ #category : #tests }
SindarinDebuggerTest >> testStepUntil [
	| i scdbg |
	i := 20.
	scdbg := SindarinDebugger
		debug: [ [ i = 0 ] whileFalse: [ i := i - 1 ] ].
	scdbg stepUntil: [ i = 12 ].
	self assert: i equals: 12
]

{ #category : #tests }
SindarinDebuggerTest >> testSteppingAnExecutionSignalingExceptions [
	| scdbg |
	scdbg := SindarinDebugger
		debug: [ 1 / 0.
			2 / 0.
			3 / 0 ].
	self
		should: [ scdbg
				stepOver;
				stepOver;
				stepOver ]
		raise: UnhandledExceptionSignalledByADebuggedExecution
]

{ #category : #tests }
SindarinDebuggerTest >> testTemporaryNamed [
	| dbg |
	dbg := SindarinDebugger debug: [ self methodWithOneAssignment ].
	dbg step.
	self assert: (dbg readVariableNamed: #a) equals: nil.
	dbg step.
	self assert: (dbg readVariableNamed: #a) equals: 5
]

{ #category : #tests }
SindarinDebuggerTest >> testTerminate [
	| dbg |
	dbg := SindarinDebugger debug: [ self helperMethod13 ].
	self assert: dbg debugSession interruptedContext notNil.
	self assert: dbg debugSession interruptedProcess notNil.
	dbg terminate.
	self assert: dbg debugSession interruptedContext isNil.
	self assert: dbg debugSession interruptedProcess isNil.
]

{ #category : #tests }
SindarinDebuggerTest >> testTopStack [
	| a dbg |
	a := 1.
	dbg := SindarinDebugger debug: [ a := 2 ].
	dbg step.
	self assert: dbg topStack equals: 2
]

{ #category : #'tests - skipping' }
SindarinDebuggerTest >> testskipUpToNodeSkipTargetNode [
	"The tested method takes two params: 
		- the node up to which we want to skip execution
		- a boolean telling if we want to skip through the node or give back control to users before that node.
	Variations of these two params are tested by testSkipUpToNode and testSkipThroughNode.
	The following just test the remaining aspect of that API, that is we do not skip through a return node."
	| dbg returnNode |	

	dbg := SindarinDebugger
		debug: [ self methodWithTwoAssignments  ].
		
	returnNode := (self class >> #methodWithTwoAssignments) ast statements last.
	dbg step; skipThroughNode: returnNode.
	self assert: dbg node equals: returnNode.
	self assert: dbg topStack equals: Point
]

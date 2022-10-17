Extension { #name : #RBMethodNode }

{ #category : #'*Sindarin' }
RBMethodNode >> firstPCOfStatement: aStatementNode [

	| indexOfStatementNode statementBefore lastPcInStatementBefore |
	indexOfStatementNode := self statements identityIndexOf:
		                        aStatementNode.
	indexOfStatementNode == 1 ifTrue: [ 
		^ self bcToASTCache bcToASTMap keys sorted detect: [ :key | 
			  (self sourceNodeForPC: key) statementNode == aStatementNode ] ].
	statementBefore := self statements at: indexOfStatementNode - 1.
	lastPcInStatementBefore := self lastPcForNode: statementBefore.
	^ self bcToASTCache bcToASTMap keys sorted detect: [ :key | 
		  key > lastPcInStatementBefore ]
]

{ #category : #'*Sindarin' }
RBMethodNode >> parentOfIdenticalSubtree: subtree [

	^ self allChildren reversed
		  detect: [ :e | e == subtree ]
		  ifFound: [ :e | e parent ]
		  ifNone: [ nil ]
]

{ #category : #'*Sindarin' }
RBMethodNode >> statementNodeContaining: aNode [

	| statementNode parentOfStatementNode |
	statementNode := aNode.
	parentOfStatementNode := self parentOfIdenticalSubtree:
		                         statementNode.
	parentOfStatementNode
		ifNil: [ ^ NodeNotInASTError signal ]
		ifNotNil: [ 
			[ parentOfStatementNode isSequence ] whileFalse: [ 
				statementNode := parentOfStatementNode.
				parentOfStatementNode := parentOfStatementNode parent ] ].
	^ statementNode
]

Extension { #name : #RBMethodNode }

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

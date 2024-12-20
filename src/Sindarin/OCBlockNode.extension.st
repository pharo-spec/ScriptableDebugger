Extension { #name : 'OCBlockNode' }

{ #category : '*Sindarin' }
OCBlockNode >> executedNodesAfter: aNode [

	"Gives all nodes that are executed after aNode. Assuming that aNode is a recursive child, then all nodes executed after it are all nodes after it in allChildrenPostOrder"

	| nodesAfter indexOfNode |
	nodesAfter := self allChildrenPostOrder.
	indexOfNode := nodesAfter identityIndexOf: aNode.
	nodesAfter := nodesAfter withIndexSelect: [ :value :index | 
		              index > indexOfNode ].
	^ nodesAfter
]

{ #category : '*Sindarin' }
OCBlockNode >> firstPCOfStatement: aStatementNode [

	^ self bcToASTCache firstRecursiveBcOffsetForStatementNode: aStatementNode
]

{ #category : '*Sindarin' }
OCBlockNode >> nextExecutedNodeAfter: aNode [

	"Find first node that is after aNode that has an associated pc in method node all children (post-order)"

	| indexOfNextNode nodesAfter |
	nodesAfter := self executedNodesAfter: aNode.
	indexOfNextNode := nodesAfter findFirst: [ :each | 
		                   (self firstPcForNode: each) isNotNil ].
	^ nodesAfter at: indexOfNextNode
]

{ #category : '*Sindarin' }
OCBlockNode >> parentOfIdenticalSubtree: subtree [

	^ self allChildren reversed
		  detect: [ :e | e == subtree ]
		  ifFound: [ :e | e parent ]
		  ifNone: [ nil ]
]

{ #category : '*Sindarin' }
OCBlockNode >> skipWithDebugger: aSindarinDebugger [

	aSindarinDebugger skipBlockNode 
]

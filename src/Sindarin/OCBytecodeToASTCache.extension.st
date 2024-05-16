Extension { #name : 'OCBytecodeToASTCache' }

{ #category : '*Sindarin' }
OCBytecodeToASTCache >> firstRecursiveBcOffsetForStatementNode: aStatementNode [

	^ self methodOrBlockNode bcToASTCache bcToASTMap keys sorted detect: [ 
		  :key | (self nodeForPC: key) statementNode == aStatementNode ]
]

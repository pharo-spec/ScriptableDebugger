Extension { #name : #RBMethodNode }

{ #category : #'*Sindarin' }
RBMethodNode >> parentOfIdenticalSubtree: subtree [

	^ self allChildren reversed
		  detect: [ :e | e == subtree ]
		  ifFound: [ :e | e parent ]
		  ifNone: [ nil ]
]

Extension { #name : #Context }

{ #category : #'*Sindarin' }
Context >> temporaries [
	"Returns the temporary variables of this context."
	| dictionary |
	dictionary := Dictionary new.
	self tempNames do: [ :name | dictionary at: name put: (self tempNamed: name) ].
	^ dictionary.
]

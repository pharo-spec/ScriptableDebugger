Class {
	#name : #'SindarinDemo_AutoStepLibraryCode',
	#superclass : #Object,
	#category : #'Sindarin-Demo'
}

{ #category : #accessing }
SindarinDemo_AutoStepLibraryCode >> start [
	self sum
]

{ #category : #accessing }
SindarinDemo_AutoStepLibraryCode >> sum [
	| count |
	self halt.
	count := 0.
	{ 2. 3. 5. 7. 10. 11. 13. 17. 19. 23 } do: [:int | count := count + int ]
	
]

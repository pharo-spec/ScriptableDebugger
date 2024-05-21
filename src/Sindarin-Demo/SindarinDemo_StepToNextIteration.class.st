Class {
	#name : 'SindarinDemo_StepToNextIteration',
	#superclass : 'Object',
	#category : 'Sindarin-Demo',
	#package : 'Sindarin-Demo'
}

{ #category : 'accessing' }
SindarinDemo_StepToNextIteration >> start [
	self sum
]

{ #category : 'accessing' }
SindarinDemo_StepToNextIteration >> sum [
	| count |
	self halt.
	count := 0.
	{ 2. 3. 5. 7. 10. 11. 13. 17. 19. 23 } do: [:int | count := count + int ]
	
]

Class {
	#name : 'SindarinDemo',
	#superclass : 'Object',
	#instVars : [
		'count'
	],
	#category : 'Sindarin-Demo',
	#package : 'Sindarin-Demo'
}

{ #category : 'as yet unclassified' }
SindarinDemo >> doThings1 [
	1+1.
	ZeroDivide signal.
]

{ #category : 'as yet unclassified' }
SindarinDemo >> doThings2 [
	Point x: 2 y: 2.
	SubscriptOutOfBounds signal.
]

{ #category : 'as yet unclassified' }
SindarinDemo >> doThingsAndSignalExceptions [
	self doThings1.
	Error signal.
	self doThings2.
]

{ #category : 'as yet unclassified' }
SindarinDemo >> primeCount [
	count := 0.
	{ 2. 3. 5. 7. 10. 11. 13. 17. 19. 23 } do: [:int | count := count + int ]

]

{ #category : 'as yet unclassified' }
SindarinDemo >> primeCountHalt [.
	count := 0.
	self halt.
	{ 2. 3. 5. 7. 10. 11. 13. 17. 19. 23 } do: [:int | count := count + int ]
]

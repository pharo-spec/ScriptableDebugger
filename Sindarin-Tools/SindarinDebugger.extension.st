Extension { #name : #SindarinDebugger }

{ #category : #'*Sindarin-Tools' }
SindarinDebugger >> sindarinDebuggerInspection [
	<inspectorPresentationOrder: 1>

	^ StSindarinDebuggerPresenter on: self
]

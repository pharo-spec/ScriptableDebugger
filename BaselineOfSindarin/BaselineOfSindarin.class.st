Class {
	#name : #BaselineOfSindarin,
	#superclass : #BaselineOf,
	#category : #BaselineOfSindarin
}

{ #category : #baselines }
BaselineOfSindarin >> baseline: spec [
	<baseline>
	spec
		for: #common
		do: [ spec
				package: 'Sindarin';
				package: 'Sindarin-Tests';
				package: 'Sindarin-Experiments';
				package: 'Sindarin-Tools' ]
]

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
		do: [
			spec
				package: 'Sindarin';
				package: 'Sindarin-Tests';
				package: 'Sindarin-Experiments' ].
			
	spec 
		group: 'default' with: #( 'Sindarin' 'Sindarin-Tests');
		group: 'experiments' with: #('default' 'Sindarin-Experiments')
]

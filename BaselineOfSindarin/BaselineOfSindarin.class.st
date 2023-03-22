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
				package: 'Sindarin-Core';
				package: 'Sindarin';
				package: 'Sindarin-Tests';
				package: 'Sindarin-Experiments' ].
			
	spec 
		group: 'default' with: #( 'Sindarin-Core' 'Sindarin' 'Sindarin-Tests');
		group: 'experiments' with: #('default' 'Sindarin-Experiments')
]

Class {
	#name : #DepProjectHistory,
	#superclass : #Object,
	#instVars : [
		'commitDictionary',
		'methodDictionary',
		'methodChanges'
	],
	#category : #'DepMiner-Models'
}

{ #category : #adding }
DepProjectHistory >> addMethodIfDoesNotExist: aMethod [
	methodDictionary at: aMethod signature
		ifAbsentPut: [ aMethod asDepMethod ]
]

{ #category : #accessing }
DepProjectHistory >> commitDictionary [
	^ commitDictionary
]

{ #category : #enumerating }
DepProjectHistory >> commitThatMatches: aShaShortShaOrTag ifNone: anAbsentBlock [
	"Return a commit that has a SHA, short SHA, or a tag that matches the given string. If none, evaluate the given block"
	
	^ commitDictionary at: aShaShortShaOrTag
		ifAbsent: [ commitDictionary values
			detect: [ :commit | commit matches: aShaShortShaOrTag ]
			ifNone: [ anAbsentBlock value ] ]
]

{ #category : #initialization }
DepProjectHistory >> initialize [
	super initialize.
	commitDictionary := Dictionary new.
	methodDictionary := Dictionary new.
]

{ #category : #accessing }
DepProjectHistory >> methodChanges [
	^ methodChanges
]

{ #category : #accessing }
DepProjectHistory >> methodChanges: anObject [
	methodChanges := anObject
]

{ #category : #accessing }
DepProjectHistory >> methodDictionary [
	^ methodDictionary
]

{ #category : #'as yet unclassified' }
DepProjectHistory >> relevantMethodChanges [
	^ methodChanges select: [ :each | each isRelevant ]
]

{ #category : #accessing }
DepProjectHistory >> sortedCommits [
	^ commitDictionary values sorted: [ :a :b |
		a date > b date or: [
			a date = b date and: [ a time > b time ] ] ]
]

{ #category : #accessing }
DepProjectHistory >> sortedMethods [
	^ methodDictionary values sorted: [ :a :b |
		a signature > b signature ]
]
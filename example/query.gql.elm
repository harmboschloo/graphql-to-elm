module ToDo

[
	{
		"id": 0,
		"type": "Query",
		"namedType": "Query",
		"nullableType": "Query",
		"nullable": true,
		"list": false,
		"name": "TestQuery",
		"depth": 0,
		"children": [
			3
		]
	},
	{
		"id": 1,
		"type": "User!",
		"namedType": "User",
		"nullableType": "User",
		"nullable": false,
		"list": false,
		"name": "i",
		"depth": 1,
		"children": [
			2
		]
	},
	{
		"id": 2,
		"type": "String!",
		"namedType": "String",
		"nullableType": "String",
		"nullable": false,
		"list": false,
		"name": "name",
		"depth": 2,
		"children": null
	},
	{
		"id": 3,
		"type": "Int",
		"namedType": "Int",
		"nullableType": "Int",
		"nullable": true,
		"list": false,
		"name": "version",
		"depth": 1,
		"children": null
	},
	{
		"id": 4,
		"type": "User!",
		"namedType": "User",
		"nullableType": "User",
		"nullable": false,
		"list": false,
		"name": "me",
		"depth": 1,
		"children": [
			5,
			6
		]
	},
	{
		"id": 5,
		"type": "String!",
		"namedType": "String",
		"nullableType": "String",
		"nullable": false,
		"list": false,
		"name": "name",
		"depth": 2,
		"children": null
	},
	{
		"id": 6,
		"type": "Int",
		"namedType": "Int",
		"nullableType": "Int",
		"nullable": true,
		"list": false,
		"name": "age",
		"depth": 2,
		"children": null
	},
	{
		"id": 7,
		"type": "User",
		"namedType": "User",
		"nullableType": "User",
		"nullable": true,
		"list": false,
		"name": "you",
		"depth": 1,
		"children": [
			8
		]
	},
	{
		"id": 8,
		"type": "String!",
		"namedType": "String",
		"nullableType": "String",
		"nullable": false,
		"list": false,
		"name": "name",
		"depth": 2,
		"children": null
	},
	{
		"id": 9,
		"type": "[User!]",
		"namedType": "User",
		"nullableType": "[User!]",
		"nullable": true,
		"list": true,
		"name": "friends",
		"depth": 2,
		"children": [
			10,
			11
		]
	},
	{
		"id": 10,
		"type": "ID!",
		"namedType": "ID",
		"nullableType": "ID",
		"nullable": false,
		"list": false,
		"name": "id",
		"depth": 3,
		"children": null
	},
	{
		"id": 11,
		"type": "Int",
		"namedType": "Int",
		"nullableType": "Int",
		"nullable": true,
		"list": false,
		"name": "age",
		"depth": 3,
		"children": null
	},
	{
		"id": 12,
		"type": "[User!]!",
		"namedType": "User",
		"nullableType": "[User!]",
		"nullable": false,
		"list": true,
		"name": "them",
		"depth": 1,
		"children": [
			13,
			14
		]
	},
	{
		"id": 13,
		"type": "Int",
		"namedType": "Int",
		"nullableType": "Int",
		"nullable": true,
		"list": false,
		"name": "age",
		"depth": 2,
		"children": null
	},
	{
		"id": 14,
		"type": "String!",
		"namedType": "String",
		"nullableType": "String",
		"nullable": false,
		"list": false,
		"name": "name",
		"depth": 2,
		"children": null
	},
	{
		"id": 15,
		"type": "[User]",
		"namedType": "User",
		"nullableType": "[User]",
		"nullable": true,
		"list": true,
		"name": "maybeThem",
		"depth": 1,
		"children": [
			16
		]
	},
	{
		"id": 16,
		"type": "Int",
		"namedType": "Int",
		"nullableType": "Int",
		"nullable": true,
		"list": false,
		"name": "age",
		"depth": 2,
		"children": null
	}
]
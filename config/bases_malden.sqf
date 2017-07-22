/*
	0 - West Bases
		0 - Base Type (Main, FOB) [Can only have 1 main base]
		1 - Reference position (used to spawn groups that don't have a specific starting position)
		2 - Spawn positions array
			0 - Group type array (one or more groups that can use this)
			1 - Reference position/object (depends on the group)
	
	1 - East Bases
		- See above
*/

DNC_Data_Bases =
[
	[
		[
			"Main",
			getMarkerPos "startLoc_west",
			[
				[
					["airborne", "gunship"],
					HeliPadWest_0
				],
				[
					["airborne", "gunship"],
					HeliPadWest_1
				]
			]
		]
	],
	
	[
		[
			"Main",
			getMarkerPos "startLoc_east",
			[
				[
					["airborne", "gunship"],
					HeliPadEast_0
				],
				[
					["airborne", "gunship"],
					HeliPadEast_1
				]
			]
			
		]
	]
];
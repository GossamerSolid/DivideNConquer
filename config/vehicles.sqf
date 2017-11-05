/*
	0 - Unique Identifier (use this so we can duplicate classnames if needed)
	1 - Classname
	2 - Display name
	3 - Variant of ("" means base vehicle, otherwise put name of base unique identifier)
	4 - Cost
	5 - Factions that can purchase (see factions configuration)
*/

DNC_Data_Vehicles =
[
	/* RHS USA */
	[
		"rhsRG33Unarmed",
		"rhsusf_rg33_usmc_wd",
		"RG-33 (Unarmed)",
		"",
		200,
		["usa"]
	],
	
	/* RHS RUSSIA */
	[
		"rhsTigrUnarmed",
		"rhs_tigr_msv",
		"Tigr (Unarmed)",
		"",
		200,
		["rus"]
	],
	
	/* RHS RESISTANCE */
	[
		"rhsUAZSpg9Nat",
		"rhsgref_nat_uaz_spg9",
		"UAZ (SPG-9)",
		"",
		700,
		["resistance"]
	],
	[
		"rhsUralZU23Nat",
		"rhsgref_nat_ural_Zu23",
		"Ural (ZU-23)",
		"",
		1000,
		["resistance"]
	],
	[
		"rhsBTR70Nat",
		"rhsgref_nat_btr70",
		"BTR-70",
		"",
		1000,
		["resistance"]
	]
];
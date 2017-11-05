/*
Data structure for valid locations
0 - Distance to origin
1 - Origin Position
2 - Type ("zone", "base")
3 - Subtype (for zone - "flag", "outpost"  for base - "temp", "main")
4 - Extra array (any extra details per each type/subtype)
	For zones:
	0 - friendly?
4 - Position variance from origin
	0 - Minimum
	1 - Maximum
*/

private _side = _this select 0;
private _referencePos = _this select 1;
private _validLocations = [];

//Go through each zone
private _hasFriendlyZones = false;
{
	private _distance = _referencePos distance2D (_x select 0);
	private _friendly = if ((_x select 5) == _side) then {true} else {false};
	if (_friendly || (_distance <= DNC_DATA_RESPAWN_FLAG_DISTANCE)) then 
	{
		private _zonePos = getPosATL (_x select 0);
		_validLocations pushBack [_distance, _zonePos, "zone", "flag", [_friendly], [(_x select 3) + 100, DNC_DATA_RESPAWN_FLAG_DISTANCE]];
		
		if (_friendly) then {_hasFriendlyZones = true};
	};
} forEach DNC_Zones;

//Get any bases
private _basesArray = if (_side == west) then {DNC_Data_Bases select 0} else {DNC_Data_Bases select 1};
{
	private _basePos = _x select 1;
	switch (toLower(_x select 0)) do
	{
		case "main":
		{
			_validLocations pushBack [(_referencePos distance2D _basePos), _basePos, "base", "main", [], [0, 100]];
		};
		case "temp":
		{			
			if (!_hasFriendlyZones) then
			{
				_validLocations pushBack [(_referencePos distance2D _basePos), _basePos, "base", "temp", [], [0, 100]];
			};
		};
	};
} forEach _basesArray;

//Sort valid locations, closest first
_validLocations sort true;

_validLocations
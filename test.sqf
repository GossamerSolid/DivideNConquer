fnc_getNearestFlag =
{
	private _zonePos = _this;
	private _returnFlag = objNull;
	
	private _flagArray =+ G_Flags_Data;
	_flagArray = _flagArray apply { [_x distance2D _zonePos, _x] };
	_flagArray sort true;

	_returnFlag =+ (_flagArray select 0) select 1;
	
	_returnFlag
};

fnc_getFlagArray =
{
	private _flagToFind = _this;
	private _returnFlagArr = [];
	
	{
		private _arrIdx = _x find _flagToFind;
		if (_arrIdx != -1) exitWith {_returnFlagArr =+ _x};
	} forEach G_Flags;
	
	_returnFlagArr
};

fnc_getArrayIndex =
{
	private _searchValue = "";
	private _searchIndex = -1;
	private _searchArray = [];
	private _returnIndex = -1;

	if (count(_this) == 2) then
	{
		_searchValue = _this select 0;
		_searchArray = _this select 1;

		{
			if (_x == _searchValue) exitWith {_returnIndex = _forEachIndex};
		} forEach _searchArray;
	}
	else
	{
		_searchValue = _this select 0;
		_searchIndex = _this select 1;
		_searchArray = _this select 2;
		
		{
			private _currVal = if (typeName _x == "ARRAY") then {_x select _searchIndex} else {_x};
			if (_currVal == _searchValue) exitWith {_returnIndex = _forEachIndex};
		} forEach _searchArray;
	};

	_returnIndex
};

fnc_dumpArray =
{
	diag_log text format ["### Start Dumping Array"];
	{
		diag_log text format ["%2", _forEachIndex, _x];
	} forEach _this;
	diag_log text format ["### Done Dumping Array"];
};
	
//Generation run
if (isNil "G_Zones") then
{
	private _worldSizeX = 100; //abs(getNumber (configFile >> "CfgWorlds" >> worldName >> "Grid" >> "Zoom2" >> "stepX"));
	private _worldSizeY = 100; //abs(getNumber (configFile >> "CfgWorlds" >> worldName >> "Grid" >> "Zoom2" >> "stepY"));
	private _mapSize = 12800; //getNumber (configFile >> "CfgWorlds" >> worldName >> "mapSize");

	private _currX = _worldSizeX / 2;
	private _currY = _mapSize - (_worldSizeY / 2);
	private _cnt = 0;
	G_Zones = [];

	//Get all flags
	G_Flags = allMissionObjects "Flag_Green_F";
	private _flagsLocal = [];
	{
		if (!isObjectHidden _x) then {_flagsLocal pushBack _x};
	} forEach G_Flags;
	G_Flags =+ _flagsLocal;
	G_Flags_data =+ G_Flags;

	//Assign colors to flags
	private _colorClasses = [];
	private _newFlags = [];
	configProperties [configFile >> "CfgMarkerColors", "_colorClasses pushBack (configName _x)", true];
	{
		private _currEntry = [_x];
		_currEntry pushBack (selectRandom _colorClasses);
		_currEntry pushBack [];
		_newFlags pushBack _currEntry;
	} forEach G_Flags;
	G_Flags =+ _newFlags;

	//Build all zones
	while {_currY >= 0} do
	{
		//Figure out if area has any land in it
		private _cntSub = 0;
		private _waterCheck = [];
		private _hasLand = false;
		private _closeToSpawn = false;
		private _currSubX = _currX - _worldSizeX;
		private _currSubY = _currY + _worldSizeY;
		while {_currSubY >= (_currY - _worldSizeY)} do
		{
			if (!surfaceIsWater [_currSubX, _currSubY]) exitWith {_hasLand = true};

			if (_currSubX >= (_currX + _worldSizeX)) then
			{
				_currSubY = _currSubY - (_worldSizeY / 2);
				_currSubX = _currX - _worldSizeX;
			}
			else
			{
				_currSubX = _currSubX + (_worldSizeX / 2);
			};
			
			_cntSub = _cntSub + 1;
		};
		//{deleteMarker _x} forEach _waterCheck;
		
		//Check to see if it's close to spawn locations
		{
			if (((getMarkerPos _x) distance2D [_currX, _currY]) < 1000) exitWith {_closeToSpawn = true};
		} forEach ["respawn_west", "respawn_east"];
		
		//Create marker for visual representation
		if (_hasLand && !_closeToSpawn) then 
		{
			private _marker = createMarker [format["MapZone_%1", _cnt], [_currX, _currY]];
			_marker setMarkerShape "RECTANGLE";
			_marker setMarkerSize [_worldSizeX, _worldSizeY];
			_marker setMarkerBrush "Solid";
			_marker setMarkerColor "ColorBlack";
			_marker setMarkerAlpha 0.3;
			
			G_Zones pushBack (format["MapZone_%1", _cnt]);
		}; 
		
		//Move down if we hit the side boundary, otherwise keep going right
		if (_currX >= (_mapSize - _worldSizeX)) then
		{
			_currX = _worldSizeX / 2;
			_currY = _currY - (_worldSizeY * 2);
		}
		else
		{
			_currX = _currX + (_worldSizeX * 2);
		};

		_cnt = _cnt + 1;
	};

	//Assign zones to flags
	{     
		private _nearestFlag = (getMarkerPos _x) call fnc_getNearestFlag;
		if (!isNull _nearestFlag) then
		{
			private _flagArr = _nearestFlag call fnc_getFlagArray;
			
			_x setMarkerColor (_flagArr select 1);
			
			//Add zone to flag array
			private _flagArrIdx = [_flagArr select 0, 0, G_Flags] Call fnc_getArrayIndex;
			if (_flagArrIdx != -1) then
			{
				private _flagZones = (G_Flags select _flagArrIdx) select 2;
				_flagZones pushBack [_x, (getMarkerPos _x), [_worldSizeX, _worldSizeY]];
			};
		};
	} forEach G_Zones;

	//Assign values to flags
	{
		private _amtZone = 2.5 * (count (_x select 2));
		_x pushBack _amtZone;
		player globalChat format["%1 - $%2", _x select 0, _amtZone];
		
	} forEach G_Flags;
}
else //Already built zones
{
	{
		_x call fnc_dumpArray;
		(_x select 2) call fnc_dumpArray;
	} forEach G_Flags;	
};
/*
Author(s):
GossamerSolid

Description:
Update the markers array which will be used for map and 3d markers

Notes:
Parameters
None

Returns
Nothing

Data Structure:
0 - ASL Position of Object
1 - Icon
2 - Direction
3 - Display Text
4 - RGBA Colour
5 - Visual Position
6 - 3D Marker specific icon
7 - is cursor target
8 - Marker is the player (Useful for hiding on 3d markers)
9 - Object reference (Use this to make smooth 3d markers)
10 - Size array (width, height)
11 - Object type (inf, veh, zone)
12 - Is visible to player's eyes
*/

private _infantryIcon = getText(configFile >> "CfgMarkers" >> "n_inf" >> "Icon");

while {true} do //TODO
{
	//Local array which will replace the global afterwards
	private _markerArray = [];

	//Get all side members
	private _sideMembers = [(side player), "obj"] call fnc_cmn_getSideMembers;

	//Get all grunts
	private _gruntObjs = [];
	{
		if (!isNull _x) then
		{
			//Iterate through each grunt group
			{
				if (alive _x) then {_gruntObjs pushBack _x;};
			} forEach (units _x);
		};
	} forEach DNC_CVAR_GRUNT_GROUPS;

	//Merge together and work from that
	private _fullSideArray = [_sideMembers, _gruntObjs] call fnc_cmn_mergeArrays;

	//Build some markers
	private _vehiclesArray = [];
	{
		//Marked objects come in array format
		private _objRef = if (typeName _x == "ARRAY") then {_x select 0} else {_x};

		if (alive _objRef) then
		{
			if (_objRef isKindOf "Man" && ((vehicle _objRef) == _objRef)) then //Infantry
			{
				private _name = "";
				private _3dMarkerImage = "\A3\ui_f\data\map\markers\military\dot_CA.paa";

				//Get display name
				if (isPlayer _objRef) then 
				{
					_name = name _objRef;
				} 
				else 
				{
					if (_objRef == (leader (group _objRef))) then
					{
						_name = missionNameSpace getVariable [format["%1_Name",str(group _objRef)], ""]
					};
				};

				//Figure out colour
				private _colour = ([format["side%1", (side _objRef)], "RGBA"] call fnc_clt_getColour);

				//Figure out position
				private _visualPos = [_objRef, "inf"] Call fnc_clt_getVisible3DPos;

				//Size
				private _sizeArray = [20,20];

				//Check if infantry is visible to player
				private _isVisible = true;

				_markerArray pushBack
				[
					(getPosASL _objRef),
					_infantryIcon,
					0,
					_name,
					_colour,
					_visualPos,
					_3dMarkerImage,
					(cursorObject == _objRef),
					(player == _objRef),
					_objRef,
					_sizeArray,
					"inf",
					_isVisible
				];
			}
			else //Vehicles or Structures
			{
				if (typeName _x == "ARRAY") then
				{
					_objRef = _x select 0;
					private _found = false;
					{
						if (typeName _x == "ARRAY") then
						{
							if ((_x select 0) == _objRef) then {_found = true};
						}
						else
						{
							if (_x == _objRef) then {_found = true};
						};

						if (_found) exitWith {};
					} forEach _vehiclesArray;

					if (!_found) then {_vehiclesArray pushBack _x};
				}
				else
				{
					private _vehicleIndex = _vehiclesArray find (vehicle _x);
					if (_vehicleIndex == -1) then {_vehiclesArray pushBack (vehicle _x)};
				};
			};
		};
	} forEach _fullSideArray;

	//Parse out them vehicles
	{
		//Marked objects come in array format
		private _objRef = if (typeName _x == "ARRAY") then {_x select 0} else {_x};

		private _crewText = "";

		private _isPlayer = false;
		private _colour = ([format["side%1", (side _objRef)], "RGBA"] call fnc_clt_getColour);

		private _visualPos = [_objRef, "veh"] call fnc_clt_getVisible3DPos;
		
		//Get icon
		private _icon = "";
		if ((typeOf (vehicle _objRef)) isKindOf "Car") then {_icon = "n_motor_inf"};
		if ((typeOf (vehicle _objRef)) isKindOf "Tank") then {_icon = "n_armor"};
		if ((typeOf (vehicle _objRef)) isKindOf "Helicopter") then {_icon = "n_air"};
		if ((typeOf (vehicle _objRef)) isKindOf "Plane") then {_icon = "n_plane"};
		if ((typeOf (vehicle _objRef)) isKindOf "Ship") then {_icon = "n_naval"};
		if (_icon != "") then {_icon = getText(configFile >> "CfgMarkers" >> _icon >> "Icon")};
		
		//Get crew text
		{
			if (alive _x) then
			{
				if (player == _x) then {_isPlayer = true};
				private _name = "";
				if (isPlayer _x) then 
				{
					_name = name _x;
				} 
				else 
				{
					if (_x == (leader (group _x))) then 
					{
						_name = missionNameSpace getVariable [format["%1_Name",str(group _x)], ""];
					};
				};
				
				if (_name != "") then
				{
					if (_crewText == "") then {_crewText = _name} else {_crewText = _crewText + format[", %1",_name]};
				};
			};
		} forEach (crew (vehicle _objRef));

		private _sizeArray = [20, 20];

		//Check if infantry is visible to player
		private _isVisible = true;

		_markerArray pushBack
		[
			(getPosASL (vehicle _objRef)),
			_icon,
			0,
			_crewText,
			_colour,
			_visualPos,
			"\A3\ui_f\data\map\markers\military\dot_CA.paa",
			(cursorObject == _objRef),
			_isPlayer,
			_objRef,
			_sizeArray,
			"veh",
			_isVisible
		];
	} forEach _vehiclesArray;

	//Zones
	{
		private _zoneStrengthPercentage = ((((_x select 6) select 0) / ((_x select 6) select 1)) * 100);
		private _zoneStrengthImgNum = ceil((8 * _zoneStrengthPercentage) / 100);
		private _zoneStrengthImg = format["%1resources\images\zone_%2.paa", DNC_MISSIONROOT, _zoneStrengthImgNum max 1];
		private _zoneText = "%1 [%2/%3]";
		if (_x select 10) then
		{
			_zoneText = _zoneText + " (CONTESTED)";
		};
		
		_markerArray pushBack
		[
			(getPosASL (_x select 0)),
			"",
			0,
			format[_zoneText,(_x select 1),((_x select 6) select 0),((_x select 6) select 1)],
			([format["side%1", (_x select 5)], "RGBA"] call fnc_clt_getColour),
			([(_x select 0), "zone"] call fnc_clt_getVisible3DPos),
			_zoneStrengthImg,
			(cursorTarget == (_x select 0)),
			false,
			(_x select 0),
			[32, 32],
			"zone",
			true
		];
	} forEach DNC_Zones;

	//Copy temp array into global
	DNC_CVAR_DYN_MARKERS =+ _markerArray;

	uiSleep DNC_DATA_MARKERUPDATE_RATE;
};
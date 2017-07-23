//Common functions
fnc_cmn_getAllNetIDs = compile preprocessFileLineNumbers "functions\common\getAllNetIDs.sqf";
fnc_cmn_getArrayIndex = compile preprocessFileLineNumbers "functions\common\getArrayIndex.sqf";
fnc_cmn_getObjFromUID = compile preprocessFileLineNumbers "functions\common\getObjFromUID.sqf";
fnc_cmn_getRandomSafePos = compile preprocessFileLineNumbers "functions\common\getRandomSafePos.sqf";
fnc_cmn_getSideMembers = compile preprocessFileLineNumbers "functions\common\getSideMembers.sqf";
fnc_cmn_getSideName = compile preprocessFileLineNumbers "functions\common\getSideName.sqf";
fnc_cmn_mergeArrays = compile preprocessFileLineNumbers "functions\common\mergeArrays.sqf";
fnc_cmn_setNearestZones = compile preprocessFileLineNumbers "functions\common\getNearestZones.sqf";
fnc_cmn_setPosAGLS = compile preprocessFileLineNumbers "functions\common\setPosAGLS.sqf";

//Configuration Loading
private _generalConfig = compile preprocessFileLineNumbers "config\general.sqf";
[] call _generalConfig;

private _gruntConfig = compile preprocessFileLineNumbers "config\grunts.sqf";
[] call _gruntConfig;

private _zoneConfig = compile preprocessFileLineNumbers (format["config\zones_%1.sqf", worldName]);
if (!isNil "_zoneConfig") then 
{
	[] call _zoneConfig;
} 
else 
{
	[__FILE__, "error", format["Unable to find zone configuration for %1", worldName]] call fnc_sys_writeError;
};

private _basesConfig = compile preprocessFileLineNumbers (format["config\bases_%1.sqf", worldName]);
if (!isNil "_basesConfig") then 
{
	[] call _basesConfig;
	
	//parse out bases for side separation
	DNC_Bases_West = [];
	DNC_Bases_East = [];
	{
		switch (_forEachIndex) do
		{
			case 0: {DNC_Bases_West pushBack (_x select 0)};
			case 1: {DNC_Bases_East pushBack (_x select 0)};
		};
	} forEach DNC_Data_Bases;
} 
else 
{
	[__FILE__, "error", format["Unable to find bases configuration for %1", worldName]] call fnc_sys_writeError;
};
if (!("server" call fnc_sys_verifyContext)) exitWith {[__FILE__, "error", "Unable to run script due to incorrect context"] spawn fnc_sys_writeError;};

//Initialize common
private _commonInit = compileFinal preprocessFileLineNumbers "init\common.sqf";
private _commonInitCall = [] spawn _commonInit;
waitUntil {scriptDone _commonInitCall};

DNC_ServerInit = false;
DNC_SESSIONUIDS = [];
DNC_INCOME_WEST = 0;
DNC_INCOME_EAST = 0;
DNC_INCOME_TIME = diag_tickTime;
publicVariable "DNC_INCOME_TIME";

//Server gameflow
gf_srv_updateGarbageCollector = compile preprocessFileLineNumbers "gameflow\server\updateGarbageCollector.sqf";
gf_srv_updateGruntGroup = compile preprocessFileLineNumbers "gameflow\server\updateGruntGroup.sqf";
gf_srv_updateIncome = compile preprocessFileLineNumbers "gameflow\server\updateIncome.sqf";
gf_srv_updateZone = compile preprocessFileLineNumbers "gameflow\server\updateZone.sqf";

//Server functions
fnc_srv_addToGarbageCollector = compile preprocessFileLineNumbers "functions\server\addToGarbageCollector.sqf";
fnc_srv_changeMoney = compile preprocessFileLineNumbers "functions\server\changeMoney.sqf";
fnc_srv_createUnit = compile preprocessFileLineNumbers "functions\server\createUnit.sqf";
fnc_srv_createVehicle = compile preprocessFileLineNumbers "functions\server\createVehicle.sqf";
fnc_srv_unitKilled = compile preprocessFileLineNumbers "functions\server\unitKilled.sqf";
fnc_srv_clientFncExec = CompileFinal preprocessFileLineNumbers "functions\server\clientFncExec.sqf";
fnc_srv_requestClientExec = CompileFinal preprocessFileLineNumbers "functions\server\requestClientExec.sqf";
fnc_srv_playerConnected = compile preprocessFileLineNumbers "functions\server\playerConnected.sqf";
fnc_srv_playerDisconnected = compile preprocessFileLineNumbers "functions\server\playerDisconnected.sqf";

//Handle player joins and leaves
["plyConnectHandler", "onPlayerConnected", {[_uid, _name] spawn fnc_srv_playerConnected}] call BIS_fnc_addStackedEventHandler;
addMissionEventHandler ["HandleDisconnect",{ _this spawn fnc_srv_playerDisconnected; true }];

//Client remote execution
DNC_CLIENT_FNC_EXEC = [];
"DNC_CLIENT_FNC_EXEC" addPublicVariableEventHandler
{
	[_this select 1] spawn fnc_srv_clientFncExec;
};

//Initialize zones //TODO - Move updates to HC2 (we want defenders on their own HC)
DNC_Zones = [];
{
	DNC_Zones pushBack [_x select 0, _x select 1, _x select 2, _x select 4, [0, 0, 0], resistance, [_x select 5, _x select 5], false, diag_tickTime, [], false];
	
	_forEachIndex spawn gf_srv_updateZone;
} forEach DNC_Data_Zones;
publicVariable "DNC_Zones";

//Garbage Collector
DNC_SVAR_GARBAGE_LOCKED = false;
DNC_SVAR_GARBAGE_ARRAY = [];
[] spawn gf_srv_updateGarbageCollector;

//BIS Group system
["Initialize"] call BIS_fnc_dynamicGroups;

//Allow spawning of units without one group
DNC_WESTHQC = createCenter west;
DNC_EASTHQC = createCenter east;
DNC_GUERHQC = createCenter guer;

//Spawn & Update Grunt Groups for each side //TODO - Move to HC1
DNC_GruntGroups_West = [];
DNC_GruntGroups_East = [];
{
	[west, _x] spawn gf_srv_updateGruntGroup;
} forEach (DNC_Data_Grunts select 0);
{
	[east, _x] spawn gf_srv_updateGruntGroup;
} forEach (DNC_Data_Grunts select 1);
waitUntil{((count DNC_GruntGroups_West) == (count (DNC_Data_Grunts select 0))) && ((count DNC_GruntGroups_East) == (count (DNC_Data_Grunts select 1)))};
publicVariable "DNC_GruntGroups_West";
publicVariable "DNC_GruntGroups_East";

//Update income
[] spawn gf_srv_updateIncome;

//Mark server as initialized
DNC_ServerInit = true;
publicVariable "DNC_ServerInit";
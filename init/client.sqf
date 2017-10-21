disableSerialization;
if (!("client" call fnc_sys_verifyContext)) exitWith {[__FILE__, "error", "Unable to run script due to incorrect context"] spawn fnc_sys_writeError;};

//Initialize common
private _commonInit = compileFinal preprocessFileLineNumbers "init\common.sqf";
private _commonInitCall = [] spawn _commonInit;
waitUntil {scriptDone _commonInitCall};

//Client Globals
DNC_CVAR_DYN_MARKERS = [];
DNC_CVAR_GRUNT_GROUPS = [];
DNC_3DMarkers = true;
if (isNil "DNC_CVAR_INCOME") then {DNC_CVAR_INCOME = 0};

//Client functions
fnc_clt_draw3DMarkers = compile preprocessFileLineNumbers "functions\client\draw3DMarkers.sqf";
fnc_clt_drawMapMarkers = compile preprocessFileLineNumbers "functions\client\drawMapMarkers.sqf";
fnc_clt_getColour = compile preprocessFileLineNumbers "functions\client\getColour.sqf";
fnc_clt_getVisible3DPos = compile preprocessFileLineNumbers "functions\client\getVisible3DPos.sqf";
fnc_clt_requestServerExec = compile preprocessFileLineNumbers "functions\client\requestServerExec.sqf";
fnc_clt_serverFncExec = compile preprocessFileLineNumbers "functions\client\serverFncExec.sqf";
fnc_clt_zoneCaptured = compile preprocessFileLineNumbers "functions\client\zoneCaptured.sqf";

//Client gameflow
gf_clt_updateDynamicMarkers = compile preprocessFileLineNumbers "gameflow\client\updateDynamicMarkers.sqf";
gf_clt_updateHUD = compile preprocessFileLineNumbers "gameflow\client\updateHUD.sqf";
gf_clt_updateHUDSlave = compile preprocessFileLineNumbers "gameflow\client\updateHUDSlave.sqf";
gf_clt_updateZones = compile preprocessFileLineNumbers "gameflow\client\updateZones.sqf";

//Server remote execution
DNC_SERVER_FNC_EXEC = [];
"DNC_SERVER_FNC_EXEC" addPublicVariableEventHandler
{
	(_this select 1) spawn fnc_clt_serverFncExec;
};

//Wait for server to initialize
waitUntil{!isNil "DNC_ServerInit"};
waitUntil{DNC_ServerInit};

//Set proper grunt groups
waitUntil{!isNil "DNC_GruntGroups_West" && !isNil "DNC_GruntGroups_East"};
if (side player == west) then {DNC_CVAR_GRUNT_GROUPS = DNC_GruntGroups_West} else {DNC_CVAR_GRUNT_GROUPS = DNC_GruntGroups_East};

//Initialize zones
waitUntil {!isNil "DNC_Zones"};
//Have to do multiple loops due to "layering"
{
	//Create zone markers
	private _zoneDataArr = DNC_Data_Zones select _forEachIndex;
	private _zoneCaptureObj = _x select 0;
	private _captureRadius = _x select 4;
	private _zoneOwner = _x select 5;
	{
		private _currMarker = createMarkerLocal [(_x select 0), (_x select 1)];
		_currMarker setMarkerShapeLocal "Rectangle";
		_currMarker setMarkerBrushLocal "Solid";
		_currMarker setMarkerSizeLocal (_x select 2);
		_currMarker setMarkerColorLocal ([format["side%1",_zoneOwner], "class"] call fnc_clt_getColour);
		_currMarker setMarkerAlphaLocal 0.3;
		
	} forEach (_zoneDataArr select 3);
} forEach DNC_Zones;

//Create zone capture markers
{
	private _captureMarker = createMarkerLocal [format["%1_Flag", str(_x select 1)], getPosASL (_x select 0)];
	_captureMarker setMarkerTextLocal format["%1 ($%2) [%3/%4]",(_x select 1),(_x select 2),((_x select 6) select 0),((_x select 6) select 1)];
	_captureMarker setMarkerColorLocal (["zoneName", "class"] call fnc_clt_getColour);
	_captureMarker setMarkerTypeLocal "mil_flag";
	_captureMarker setMarkerSizeLocal [0.6, 0.6];
} forEach DNC_Zones;

//Zone Display updates
[] spawn gf_clt_updateZones;

//HUD
waitUntil{!isNil "DNC_CVAR_MONEY"};
DNC_CVAR_UI_SideGruntCounts = [0, 0];
[] spawn gf_clt_updateHUD;
[] spawn gf_clt_updateHUDSlave;

//Dev mode
if (DNC_DEVMODE) then
{
	onMapSingleClick "(vehicle player) setPos _pos";
};

//BIS Group System
["InitializePlayer", [player]] call BIS_fnc_dynamicGroups;

//Run marker updates
[] spawn gf_clt_updateDynamicMarkers;

//3D Markers
addMissionEventHandler ["Draw3D",{[] call fnc_clt_draw3DMarkers;}];

//TODO: Equip Player

//Move player to initial spawn location
private _spawnPos = getMarkerPos format["startLoc_%1", side player];
private _initialPos = [_spawnPos, random(20 * 0.25), random(50), false, [false], typeOf player] Call fnc_cmn_getRandomSafePos;
while {(_initialPos select 0) == -1} do {_initialPos = [_spawnPos, random(20 * 0.25), random(50), false, [false], typeOf player] Call fnc_cmn_getRandomSafePos;};		
player setDir (random 360);
player setPosATL _initialPos;

//Main map markers
waitUntil {!isNull (findDisplay 12)};
((findDisplay 12) displayCtrl 51) ctrlRemoveAllEventHandlers "Draw";
private _mapIcons = ((findDisplay 12) displayCtrl 51) ctrlAddEventHandler ["Draw",{[(_this select 0), false] call fnc_clt_drawMapMarkers;}];
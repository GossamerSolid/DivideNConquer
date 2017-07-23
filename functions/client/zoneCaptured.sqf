private _zoneIdx = _this select 0;
private _zoneDefender = _this select 1;
private _zoneAttacker = _this select 2;

//Get zone arrays
private _zoneArr = DNC_Zones select _zoneIdx;
private _zoneArrData  = DNC_Data_Zones select _zoneIdx;

//Message to tell player
private _defenderName = _zoneDefender call fnc_cmn_getSideName;
private _attackerName = _zoneAttacker call fnc_cmn_getSideName;
[side player, "HQ"] commandChat format["%1 has been captured by %2 from %3",(_zoneArr select 1), _attackerName, _defenderName];

//Play sound
if (_zoneAttacker == (side player)) then {playSound "friendlyCapture"} else {playSound "enemyCapture"};

//Update marker colours
{
	(_x select 0) setMarkerColorLocal ([format["side%1",_zoneAttacker], "class"] call fnc_clt_getColour);
} forEach (_zoneArrData select 3)
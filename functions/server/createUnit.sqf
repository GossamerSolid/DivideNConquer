private _side = _this select 0;
private _unitGroup = _this select 1;
private _createPos = _this select 2;
private _unitClass = _this select 3;

if (!("server" call fnc_sys_verifyContext)) exitWith {[__FILE__, "error", "Unable to run script due to incorrect context"] spawn fnc_sys_writeError;};

private _unit = _unitGroup createUnit [_unitClass, _createPos, [], 0, "FORM"];
//[_unit, _createPos] call fnc_cmn_setPosAGLS;
_unit setSkill ["courage", 1];
_unit setSkill ["commanding", 1];
_unit setSkill ["spotDistance", 0.7];
_unit setSkill ["spotTime", 0.7];
_unit setSkill ["aimingSpeed", 0.7];
_unit setSkill ["aimingAccuracy", 0.35];
_unit enableFatigue false;

call compile format['
_unit addMPEventHandler ["MPKilled",
{
	if (local (_this select 0)) then 
	{
		(_this select 0) addRating 99999;
	}; 
	
	if (isServer) then 
	{
		[(_this select 0), %1, false, (_this select 1), (side (group (_this select 1))), (isPlayer (_this select 1))] call fnc_srv_unitKilled;
	};
}];
', _side];

_unit 
private _side = _this select 0;
private _creationPos = _this select 1;
private _direction = _this select 2;
private _vehClassname = _this select 3;

if (!("server" call fnc_sys_verifyContext)) exitWith {[__FILE__, "error", "Unable to run script due to incorrect context"] spawn fnc_sys_writeError;};

private _vehicle = createVehicle [_vehClassname, _creationPos, [], 0, "NONE"];
_vehicle setDir _direction;
_vehicle setPosATL _creationPos;
_vehicle setVectorUp (surfaceNormal (getPos _vehicle));
_vehicle setVelocity [0,0,-1];

call compile format['
_vehicle addMPEventHandler ["MPKilled",
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

_vehicle 
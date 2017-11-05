private _side = _this select 0;
private _creationPos = _this select 1;
private _direction = _this select 2;
private _vehID = _this select 3;

private _vehicle = objNull;

if (!("server" call fnc_sys_verifyContext)) exitWith {[__FILE__, "error", "Unable to run script due to incorrect context"] spawn fnc_sys_writeError;};

//Find vehicle config
private _vehConfigArr = _vehID call fnc_cmn_getVehicleConfig;
if (!isNil "_vehConfigArr") then
{
	//Create vehicle and set basic positioning
	_vehicle = createVehicle [(_vehConfigArr select 1), _creationPos, [], 0, "NONE"];
	_vehicle setDir _direction;
	_vehicle setPosATL _creationPos;
	_vehicle setVectorUp (surfaceNormal (getPos _vehicle));
	_vehicle setVelocity [0,0,-1];
	
	//Set identifier so we can lookup information on the vehicle later
	_vehicle setVariable ["DNC_VehID", _vehID, false];

	//Add kill event
	call compile format['
	_vehicle addMPEventHandler ["MPKilled",
	{
		if (isServer) then 
		{
			[(_this select 0), %1, false, (_this select 1), (side (group (_this select 1))), (isPlayer (_this select 1))] call fnc_srv_unitKilled;
		};
	}];
	', _side];
};

_vehicle 
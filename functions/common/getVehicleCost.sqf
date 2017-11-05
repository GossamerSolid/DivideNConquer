private _vehID = _this;
private _vehCost = -1;

private _vehArray = _vehID call fnc_cmn_getVehicleConfig;
if (!isNil "_vehArray") then
{
	_vehCost = _vehArray select 4;
};

_vehCost
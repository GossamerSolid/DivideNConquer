private _vehID = _this;
private _vehArray = nil;

private _vehIdx = [_vehID, 0, DNC_Data_Vehicles] call fnc_cmn_getArrayIndex;
if (_vehIdx != -1) then
{
	_vehArray =+ (DNC_Data_Vehicles select _vehIdx);
};

_vehArray
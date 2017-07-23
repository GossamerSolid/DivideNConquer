private _objUID = _this;
private _returnedObj = objNull;

while {isNull _returnedObj} do
{
	{
		if ((getPlayerUID _x) == _objUID) exitWith {_returnedObj = _x};
	} forEach playableUnits;
};

_returnedObj 
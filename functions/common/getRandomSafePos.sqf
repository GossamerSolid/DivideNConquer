private _position = _this select 0;
private _minRadius = _this select 1;
private _maxRadius = _this select 2;
private _allowedWater = _this select 3;
private _direction = random 360;
private _checkHostiles = _this select 4;
private _objectType = _this select 5;

private _radius = (random (_maxRadius - _minRadius)) + _minRadius;
private _position = [(_position select 0) + ((sin _direction) * _radius), (_position select 1) + ((cos _direction) * _radius), (_position select 2)];

//If an object type is passed, assume it needs to be a safe position (for spawning vehicle/unit);
if (_objectType != "") then
{
	private _emptyPos = _position findEmptyPosition [5, 20, _objectType];
	if ((count _emptyPos) == 0) then
	{
		_position = [-1, -1, -1];
	}
	else
	{
		_position = _emptyPos;
	};
	
	/*
	private _near = nearestObjects [_position, ["Thing", "AllVehicles","Building","House"], 20];
	{
		_box = boundingBoxReal _x;
		_width = ((_box select 1) select 0);
		_length = ((_box select 1) select 1);
		_longest = (sqrt((_width * _width) + (_length * _length))) / 2;
		if (((_position distance _x) - _longest) < 10) exitWith
		{
			_position = [-1,-1,-1];
		};
	} forEach _near;
	*/
};

//Check for hostiles in an area
/*
if (!_fail && (_checkHostiles select 0)) then
{
	_hostileCount = [(_checkHostiles select 1), _newPos, (_checkHostiles select 2)] Call fnc_shr_getHostilesInArea;
	if (_hostileCount > 0) then {_fail = true};
};*/

//Should the spawn be allowed on water
if (((_position select 0) != -1) && !_allowedWater && surfaceIsWater _position) then {_position = [-1,-1,-1]};

_position 
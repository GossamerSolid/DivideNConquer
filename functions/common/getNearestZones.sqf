private _referencePos = _this select 0;
private _maxZoneCount = _this select 1;
private _distanceArr = [];
private  _closestDistance = [];

//Iterate through zones finding distance against reference
{
	private _distance = _referencePos distance2D (_x select 0);
	_distanceArr pushBack [_distance, _forEachIndex];
} forEach DNC_Zones;

//Sort ascending (lowest distance should be first index)
_distanceArr sort true;

//Trim array to max size requested
if (_maxZoneCount != -1) then
{
	private _newDistanceArr = [];
	{
		_newDistanceArr pushBack _x;
		if (_maxZoneCount == (count _newDistanceArr)) exitWith {};
	} forEach _distanceArr;
	
	_distanceArr =+ _newDistanceArr;
};

_distanceArr 
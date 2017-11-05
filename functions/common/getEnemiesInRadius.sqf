private _referencePos = _this select 0;
private _detectionRadius = _this select 1;
private _sideFriendly = _this select 2;

private _enemiesInRadius = [];
private _sideEnemyArr = [];
switch (_sideFriendly) do 
{
	case west:
	{
		_sideEnemyArr = [east, resistance];
	};
	
	case east:
	{
		_sideEnemyArr = [west, resistance];
	};
	
	case resistance:
	{
		_sideEnemyArr = [west, east];
	};
};

private _inZoneObjects = _referencePos nearEntities [["Car","Tank","Air","Ship","CAManBase"], _detectionRadius];
{
	if (alive _x) then
	{
		if ((side _x) in _sideEnemyArr) then
		{
			_sideEnemyArr pushBack _x;
		};
	};
} forEach _inZoneObjects;

_enemiesInRadius
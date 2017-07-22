private _mapControl = _this select 0;
private _isGPS = _this select 1;

//Draw friendly markers
private _drawMarker = false;
{
	if ((_x select 11) != "zone") then
	{
		_mapControl drawIcon
		[
			(_x select 1),
			(_x select 4),
			(_x select 0),
			(_x select 10) select 0,
			(_x select 10) select 1,
			(_x select 2),
			(_x select 3),
			1,
			0.035,
			"EtelkaMonospacePro",
			"right"
		];
	};
} forEach DNC_CVAR_DYN_MARKERS;
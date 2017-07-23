while {true} do //TODO
{
	//Update zone text markers
	{
		private _currMarker = format["%1_Flag", str(_x select 1)];
		_currMarker setMarkerTextLocal format["%1 ($%2) [%3/%4]",(_x select 1),(_x select 2),((_x select 6) select 0),((_x select 6) select 1)];
	} forEach DNC_Zones;
	
	uiSleep 1;
};
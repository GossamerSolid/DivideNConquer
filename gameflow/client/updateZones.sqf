while {true} do //TODO
{
	//Update zone text markers
	{
		private _currMarker = format["%1_Flag", str(_x select 1)];
		private _zoneText = "%1 ($%2) [%3/%4]";
		private _currFill = if (_x select 10) then {"Cross"} else {"Solid"};
		
		_currMarker setMarkerTextLocal format[_zoneText,(_x select 1),(_x select 2),((_x select 6) select 0),((_x select 6) select 1)];
		_currMarker setMarkerBrushLocal _currFill;
	} forEach DNC_Zones;
	
	uiSleep 1;
};
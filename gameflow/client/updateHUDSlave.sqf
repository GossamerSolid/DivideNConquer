//Used to update information that appears on the HUD, but doesn't need to be updated frequently

while {true} do //TODO
{
	//Calculate how many grunts are alive on each side
	{
		private _aliveCnt = 0;
		private _gruntGroups = if (_x == west) then {DNC_GruntGroups_West} else {DNC_GruntGroups_East};
		{
			{
				if (alive _x) then {_aliveCnt = _aliveCnt + 1};
			} forEach (units _x);
		} forEach _gruntGroups;
		
		DNC_CVAR_UI_SideGruntCounts set[_forEachIndex, _aliveCnt];
	} forEach [west, east];
	
	uiSleep 3;
};
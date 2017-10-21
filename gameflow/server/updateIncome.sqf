//We don't want to give income instantly
private _performUpdate = false;
private _updateIncome = DNC_DATA_INCOME_RATE;
private _updateInterval = 1;

while {true} do //TODO
{
	if (_updateIncome < 1) then
	{
		_performUpdate = true;
		_updateIncome = DNC_DATA_INCOME_RATE;
	}
	else
	{
		_updateIncome = _updateIncome - _updateInterval;
	};

	{
		private _income = DNC_DATA_BASE_INCOME;
		private _side = _x;

		//Go through each zone
		{
			private _zoneOwner = _x select 5;
			private _zoneIncome = _x select 2;

			if (_zoneOwner == _side) then {_income = _income + _zoneIncome};
		} forEach DNC_Zones;

		//Divide the income by every grunt group and player alive
		private _divisor = if (_side == west) then {count DNC_GruntGroups_West} else {count DNC_GruntGroups_East};
		_divisor = _divisor + count([_side, "obj"] call fnc_cmn_getSideMembers);
		_income = round(_income / _divisor);

		//Update income and cash values
		if (_side == west) then
		{
			DNC_INCOME_WEST = _income;
			DNC_CVAR_INCOME = DNC_INCOME_WEST;

			//Players
			private _teamList = [_side, "netid"] call fnc_cmn_getSideMembers;
			{
				_x publicVariableClient "DNC_CVAR_INCOME";
			} forEach _teamList;

			if (_performUpdate) then
			{
				private _teamList = [_side, "uid"] call fnc_cmn_getSideMembers;
				{
					[_x, "player", "+", _income] spawn fnc_srv_changeMoney;
				} forEach _teamList;

				//Grunt groups
				{
					[_x, "grunt", "+", _income] spawn fnc_srv_changeMoney;
				} forEach DNC_GruntGroups_West;
			};
		}
		else
		{
			DNC_INCOME_EAST = _income;
			DNC_CVAR_INCOME = DNC_INCOME_EAST;

			//Players
			private _teamList = [_side, "netid"] call fnc_cmn_getSideMembers;
			{
				_x publicVariableClient "DNC_CVAR_INCOME";
			} forEach _teamList;

			if (_performUpdate) then
			{
				private _teamList = [_side, "uid"] call fnc_cmn_getSideMembers;
				{
					[_x, "player", "+", _income] spawn fnc_srv_changeMoney;
				} forEach _teamList;

				//Grunt groups
				{
					[_x, "grunt", "+", _income] spawn fnc_srv_changeMoney;
				} forEach DNC_GruntGroups_West;
			};
		};

	} forEach [west, east];
	
	DNC_INCOME_TIME = _updateIncome;
	publicVariable "DNC_INCOME_TIME";
	
	if (_performUpdate) then 
	{
		_performUpdate = false;
	};

	uiSleep _updateInterval;
};
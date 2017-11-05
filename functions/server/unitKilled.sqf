private _objVictim = _this select 0;
private _sideVictim = _this select 1;
private _isVictimPlayer = _this select 2;
private _objKiller = _this select 3;
private _sideKiller = _this select 4;
private _isKillerPlayer = _this select 5;

if (!("server" call fnc_sys_verifyContext)) exitWith {[__FILE__, "error", "Unable to run script due to incorrect context"] spawn fnc_sys_writeError;};


//DEBUG
[__FILE__, "info", format["Unit Killed - %1", _this]] spawn fnc_sys_writeError;

//Add dead body to garbage collection (30 seconds till it's cleaned up)
[_objVictim, 30] spawn fnc_srv_addToGarbageCollector;

//TODO - Show death position to victim's side
if (_sideVictim != sideUnknown) then
{
	_victimTeamList = [_sideVictim, "netid"] call fnc_cmn_getSideMembers;
	//[_victimTeamList, "marker", "", [objNull, (getPosASL _objVictim), [0.75, 0.75], ["Class", "KIA"], ([_sideVictim, "class"] Call fnc_shr_getSideColour), 0, 1, "", 60, ""]] Spawn fnc_srv_requestClientExec;
};

//Detach anything attached to victim and detach victim from anything they are attached to
if (!isNull (attachedTo _objVictim)) then {detach _objVictim; _objVictim setVelocity [0, 0, -1]};
private _attachedObjs = attachedObjects _objVictim;
{
	detach _x;
	_x setVelocity [0, 0, -1];
} forEach _attachedObjs;

//Can't proceed if we don't know the victim's side
if (_sideVictim == sideUnknown) exitWith {[__FILE__, "error", "Unable to determine side of victim"] spawn fnc_sys_writeError;};

//Don't need to do anything if the killer is null
if (isNull _objKiller) exitWith {[__FILE__, "info", "Killer is null, nothing to do"] spawn fnc_sys_writeError;};

//Get the unit's cost and display name
private _unitCost = -1;
private _displayName = "enemy";
if (_objVictim isKindOf "Man") then
{
	_unitCost = DNC_DATA_BASE_MONEY_KILL_INF;
	_displayName = "infantry";
	if (isPlayer _objVictim) then
	{
		_unitCost = _unitCost + DNC_DATA_BONUS_MONEY_KILL_PLAYER;
		_displayName = name _objVictim;
	};
}
else
{
	private _vehID = _objVictim getVariable ["DNC_VehID", nil];
	if (!isNil "_vehID") then
	{
		private _vehConfigArr = _vehID call fnc_cmn_getVehicleConfig;
		if (!isNil "_vehConfigArr") then
		{
			_unitCost = round((_vehConfigArr select 4) * DNC_DATA_BASE_MONEY_KILL_VEH_FACTOR);
			_displayName = _vehConfigArr select 2;
		};
	};
};

//Cannot proceed if we couldn't figure out the unit's cost for some reason
if (_unitCost != -1) then
{
	//Killed an enemy
	if (_sideVictim != _sideKiller) then
	{
		//Kills will award income to every player and grunt group on the team (much like the regular income)
		private _teamList = [_sideKiller, "all"] call fnc_cmn_getSideMembers;
		
		//Figure out how much each gets
		private _divisor = if (_sideKiller == west) then {count DNC_GruntGroups_West} else {count DNC_GruntGroups_East};
		_divisor = _divisor + count _teamList;
		private _income = round(_unitCost / _divisor);
		if (_income < 1) then {_income = 1};
		
		//Players
		{
			//Current player is the killer
			private _pronoun = "teammate";
			if ((_x select 1) == _objKiller) then
			{
				_income = _income * 2;
				_pronoun = "you";
			};
			
			//Add money to player
			[(_x select 2), "player", "+", _income, false] spawn fnc_srv_changeMoney;
			
			//Message to tell player what they earned
			_killText = format["$%1 for %2 killing %3", _income, _pronoun, _displayName];
			[[(_x select 0)], "messages", "", ["yellowChat", _killText, ""]] spawn fnc_srv_requestClientExec;
		} forEach _teamList;

		//Grunt groups
		private _gruntGroups = if (_sideKiller == west) then {DNC_GruntGroups_West} else {DNC_GruntGroups_East};
		{
			[_x, "grunt", "+", _income, false] spawn fnc_srv_changeMoney;
		} forEach _gruntGroups;
	}
	else //Teamkill
	{
		//Only deal with this if a player
		if (isPlayer _objKiller) then
		{
			//Teamkills punish the killer rather than the entire team
			private _killerUID = getPlayerUID _objKiller;
			
			//Subtract money from player
			[_killerUID, "player", "-", _unitCost, false] spawn fnc_srv_changeMoney;
				
			//Message to tell player what they earned
			_killText = format["-$%1 for teamkilling %2", _unitCost, _displayName];
			[[(owner _objKiller)], "messages", "", ["yellowChat", _killText, ""]] spawn fnc_srv_requestClientExec;
		};
	};
}
else
{
	[__FILE__, "error", format["Unable to find unit's cost - %1", _this]] spawn fnc_sys_writeError;
};
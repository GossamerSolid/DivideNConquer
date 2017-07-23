private _zoneDataArr = DNC_Data_Zones select _this;

if (!("server" call fnc_sys_verifyContext)) exitWith {[__FILE__, "error", "Unable to run script due to incorrect context"] spawn fnc_sys_writeError;};

//Spread it out a bit
uiSleep random(5);

_fncUpdateDefenders =
{
	private _defenseGroups = _this select 0;
	private _zoneIdx = _this select 1;
	private _keepGoing = true;
	private _updateOrders = -1000;
	
	while {_keepGoing} do
	{
		private _zoneArr = DNC_Zones select _zoneIdx;
		
		//No defense groups
		if (_keepGoing) then
		{
			if (count(_zoneArr select 9) == 0) then {_keepGoing = false};
		};
		
		//Nobody is alive
		if (_keepGoing) then
		{
			private _aliveCount = 0;
			{
				private _units = units _x;
				{
					if (alive _x) then {_aliveCount = _aliveCount + 1};
				} forEach _units;
			} forEach (_zoneArr select 9);
			if (_aliveCount == 0) then {_keepGoing = false};
		};
		
		//Stop update
		if (_keepGoing) then
		{
			//Issue orders if necessary
			if ((diag_tickTime - _updateOrders) > 60) then
			{
				_updateOrders = diag_tickTime;
				
				{
					private _currGroup = _x;
					
					//Delete all waypoints
					private _waypoints = waypoints _currGroup;
					{deleteWaypoint [_currGroup, _forEachIndex]} forEach _waypoints;
					
					//Issue S&D order
					private _attackPos = [getPosATL (_zoneArr select 0), random(25 * 0.25), random(_zoneArr select 3), false, [false], ""] Call fnc_cmn_getRandomSafePos;

					private _wp = _currGroup addWaypoint [_attackPos, random(50)];
					_wp setWaypointType "SAD";
					_wp setWaypointCompletionRadius 0;
					_wp setWaypointBehaviour "AWARE";
					_wp setWaypointCombatMode "RED";
					_wp setWaypointSpeed "NORMAL";
					_currGroup setCurrentWaypoint _wp;
				} forEach (_zoneArr select 9);
			};
		};
		
		uiSleep random(5 + 10);
	};
};

while {true} do //Main logic loop TODO - only when gamestate is active
{
	private _markerArray = _zoneDataArr select 3;
	private _zoneDefenderTemplates = _zoneDataArr select 7;
	
	private _zoneArr =+ DNC_Zones select _this;
	
	private _zoneObj = _zoneArr select 0;
	private _displayName = _zoneArr select 1;
	private _zoneIncome = _zoneArr select 2;
	private _captureRadius = _zoneArr select 3;
	private _inZoneArray = _zoneArr select 4;
	private _zoneOwner = _zoneArr select 5;
	private _zoneStrengthArr = _zoneArr select 6;
	private _hostilesPresent = _zoneArr select 7;
	private _inactTimeout = _zoneArr select 8;
	private _defenseGroups = _zoneArr select 9;
	
	//Detect incoming enemies (only count west and east, who cares about resistance as they cannot recapture)
	private _incomingEnemies = [0, 0];
	private _incomingObjects = (getPosATL _zoneObj) nearEntities [["Car","Tank","Air","Ship","CAManBase"], _captureRadius + 200];
	{
		if (alive _x) then
		{
			switch (side _x) do
			{
				case west: {_incomingEnemies set [0, (_incomingEnemies select 0) + 1];};
				case east: {_incomingEnemies set [0, (_incomingEnemies select 0) + 1];};
			};
		};
	} forEach _incomingObjects;
	if (((_incomingEnemies select 0) > 0) && (_zoneOwner == east || _zoneOwner == resistance)) then {_hostilesPresent = true};
	if (((_incomingEnemies select 1) > 0) && (_zoneOwner == west || _zoneOwner == resistance)) then {_hostilesPresent = true};
	
	//Hostiles are present, spawn in defenders (for resistance only)
	if (_zoneOwner == resistance && _hostilesPresent) then
	{	
		_inactTimeout = diag_tickTime;
		
		//No defense groups, we should spawn some
		if ((count _defenseGroups) == 0) then
		{
			//Create defenders
			_defenseGroups = [];
			{
				private _vehClass = _x select 0;
				private _unitArray = _x select 1;
				private _groupVehicle = objNull;
				private _currGroup = createGroup _zoneOwner;
				_currGroup deleteGroupWhenEmpty true;
				
				private _classForPosition = if (_vehClass != "") then {_vehClass} else {"rhsusf_usmc_marpat_wd_squadleader"};
				
				private _groupPos = [(getPosATL _zoneObj), random(50), random(_captureRadius), false, [false], _classForPosition] Call fnc_cmn_getRandomSafePos;
				while {(_groupPos select 0) == -1} do {_groupPos = [(getPosATL _zoneObj), random(50), random(_captureRadius), false, [false], _classForPosition] Call fnc_cmn_getRandomSafePos;};
				
				//Create a vehicle if the group has one
				if (_vehClass != "") then
				{
					_groupVehicle = [_zoneOwner, _groupPos, random(360), _vehClass] call fnc_srv_createVehicle;
					_groupVehicle setVariable ["DNC_ZoneDefense", true];
				};
				
				//Create units
				{
					private _unit = [_zoneOwner, _currGroup, _groupPos, _x] call fnc_srv_createUnit;
				} forEach _unitArray;
				
				//Move units into vehicle if they have one
				if (!isNull _groupVehicle) then
				{
					{_x moveInAny _groupVehicle} forEach (units _currGroup);
				};
				
				//Add group to defense groups
				_defenseGroups pushBack _currGroup;
				
			} forEach _zoneDefenderTemplates;
			
			//Handle update of defenders
			[_defenseGroups, _this] spawn _fncUpdateDefenders;
		}
		else
		{
			//We have defense groups, but do they still need to exist?
			if ((diag_tickTime - _inactTimeout) > 120) then
			{
				//Cleanup defenses
				private _defenseVehicles = [];
				{
					//Delete units inside group
					{
						if (alive _x) then {deleteVehicle _x};
					} forEach (units _x);

					//Delete group
					deleteGroup _x;
				} forEach _defenseGroups;
				
				//Delete vehicles
				private _nearVehicles = (getPosATL _zoneObj) nearEntities [["Car","Tank","Air","Ship"], _captureRadius + 300];
				{
					private _isZoneVehicle = _x getVariable ["DNC_ZoneDefense", false];
					if (_isZoneVehicle) then
					{
						private _hasPlayers = false;
						private _vehCrew = crew _x;
						{
							if (isPlayer _x) exitWith {_hasPlayers = true};
						} forEach _vehCrew;
						
						//Player took the vehicle, remove variable saying it's a zone defender
						if (_hasPlayers) then
						{
							_x setVariable ["DNC_ZoneDefense", false];
						}
						else
						{
							deleteVehicle _x;
						};
					};
				} forEach _nearVehicles;
				
				_hostilesPresent = false;
			};
		};
	}
	else
	{
		_inactTimeout = diag_tickTime;
	};
	_zoneArr set [7, _hostilesPresent];
	_zoneArr set [8, _inactTimeout];
	_zoneArr set [9, _defenseGroups];
	
	//Get units within capture radius
	_inZoneArray = [0, 0, 0];
	private _inZoneObjectsActual = [];
	private _inZoneObjects = (getPosATL _zoneObj) nearEntities [["Car","Tank","Air","Ship","CAManBase"], _captureRadius];
	{
		if (alive _x) then
		{
			switch (side _x) do
			{
				case west: 
				{
					_inZoneArray set [0, (_inZoneArray select 0) + 1];
				};
				case east: 
				{
					_inZoneArray set [1, (_inZoneArray select 1) + 1];
				};
				case resistance: 
				{
					_inZoneArray set [2, (_inZoneArray select 2) + 1];
				};
			};
			
			_inZoneObjectsActual pushBack _x;
		};
	} forEach _inZoneObjects;
	_zoneArr set [4, _inZoneArray];
	
	//If there's units within the zone, check capture logic
	if (count _inZoneObjectsActual > 0) then
	{
		//Figure out who's capturing
		private _westCapture = _inZoneArray select 0;
		private _eastCapture = _inZoneArray select 1;
		private _resistanceCapture = _inZoneArray select 2;
		private _sideCapturing = _zoneOwner;
		private _sideCaptureAmt = 0;
		if (_westCapture > (_eastCapture + _resistanceCapture)) then
		{
			_sideCapturing = west;
			_sideCaptureAmt = (_westCapture - _eastCapture - _resistanceCapture) min DNC_DATA_MAX_CAPTURE_SPEED;
		};
		if (_eastCapture > (_westCapture + _resistanceCapture)) then
		{
			_sideCapturing = east;
			_sideCaptureAmt = (_eastCapture - _westCapture - _resistanceCapture) min DNC_DATA_MAX_CAPTURE_SPEED;
		};
		if(_resistanceCapture > (_westCapture + _eastCapture)) then
		{
			_sideCapturing = resistance;
			_sideCaptureAmt = (_resistanceCapture - _westCapture - _eastCapture) min DNC_DATA_MAX_CAPTURE_SPEED;
		};
		
		//Update zone strength accordingly
		if (_sideCapturing != _zoneOwner) then
		{
			//Attacker is winning
			_zoneStrengthArr set [0, (((_zoneStrengthArr select 0) - _sideCaptureAmt) max 0)];
		}
		else
		{
			//Defender is winning
			_zoneStrengthArr set [0, (((_zoneStrengthArr select 0) + _sideCaptureAmt) min (_zoneStrengthArr select 1))];
		};
		_zoneArr set [6, _zoneStrengthArr];
		
		//The owner needs to be updated if the strength is lower than 1
		if ((_zoneStrengthArr select 0) < 1) then
		{
			//Broadcast capture to clients (change marker colours and such)
			[([] Call fnc_cmn_getAllNetIDs), "zone", "capture", [_this, _zoneOwner, _sideCapturing]] spawn fnc_srv_requestClientExec;
			
			//TODO - Award players directly responsible for capture
			
			//Update the zone owner
			_zoneOwner = _sideCapturing;
			_zoneArr set [5, _zoneOwner];
			
			//Set strength back to 100%
			_zoneStrengthArr set [0, (_zoneStrengthArr select 1)];
			_zoneArr set [6, _zoneStrengthArr];
			
			//Cleanup defenses
			private _defenseVehicles = [];
			{
				//Delete units inside group
				{
					if (alive _x) then {deleteVehicle _x};
				} forEach (units _x);

				//Delete group
				deleteGroup _x;
			} forEach _defenseGroups;
			
			//Delete vehicles
			private _nearVehicles = (getPosATL _zoneObj) nearEntities [["Car","Tank","Air","Ship"], _captureRadius + 300];
			{
				private _isZoneVehicle = _x getVariable ["DNC_ZoneDefense", false];
				if (_isZoneVehicle) then
				{
					private _hasPlayers = false;
					private _vehCrew = crew _x;
					{
						if (isPlayer _x) exitWith {_hasPlayers = true};
					} forEach _vehCrew;
					
					//Player took the vehicle, remove variable saying it's a zone defender
					if (_hasPlayers) then
					{
						_x setVariable ["DNC_ZoneDefense", false];
					}
					else
					{
						deleteVehicle _x;
					};
				};
			} forEach _nearVehicles;
		};
	}
	else
	{
		//Nobody in the zone, strength should start raising back up to 100%
		if ((_zoneStrengthArr select 0) < (_zoneStrengthArr select 1)) then
		{
			//Raise strength back by 1
			_zoneStrengthArr set [0, (((_zoneStrengthArr select 0) + 1) min (_zoneStrengthArr select 1))];
			_zoneArr set [6, _zoneStrengthArr];
		};
	};
	
	//if (_this == 0) then {player globalChat format["%1",_zoneArr];}; //DEBUG
	
	//Broadcast changes?
	private _hasChanges = !(_zoneArr isEqualTo (DNC_Zones select _this));
	if (_hasChanges) then 
	{
		DNC_Zones set [_this, _zoneArr];
		publicVariable "DNC_Zones";
	};
	
	uiSleep 1;
};
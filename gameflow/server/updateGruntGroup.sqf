private _side = _this select 0;
private _gruntConfig = _this select 1;

if (!("server" call fnc_sys_verifyContext)) exitWith {[__FILE__, "error", "Unable to run script due to incorrect context"] spawn fnc_sys_writeError;};

//Create group
private _group = createGroup _side;
_group deleteGroupWhenEmpty false;
if (_side == west) then {DNC_GruntGroups_West pushBack _group;} else {DNC_GruntGroups_East pushBack _group;};
private _firstSpawn = true;

//Store the group's current order information in here
private _groupOrderArr = [];
missionNameSpace setVariable [format["%1_Orders",str(_group)], _groupOrderArr];
missionNameSpace setVariable [format["%1_Money",str(_group)], DNC_DATA_BASE_MONEY];

//Store the group's current vehicle
private _groupVehicle = objNull;

//Parse out vehicle/unit configs
private _groupType = _gruntConfig select 1;
private _vehClass = (_gruntConfig select 2) select 0;
private _unitArray = (_gruntConfig select 2) select 1;
private _groupRespawnTime = _gruntConfig select 3;

/* DEBUG - Override everything till it's fleshed out correctly */
_groupType = "motorized";
private _vehID = if (_side == west) then {"rhsRG33Unarmed"} else {"rhsTigrUnarmed"};
_unitArray = if (_side == west) then {["rhsusf_usmc_marpat_wd_squadleader", "rhsusf_usmc_marpat_wd_grenadier", "rhsusf_usmc_marpat_wd_autorifleman_m249", "rhsusf_usmc_marpat_wd_machinegunner", "rhsusf_usmc_marpat_wd_smaw", "rhsusf_usmc_marpat_wd_stinger"]} else {["rhs_msv_emr_sergeant", "rhs_msv_emr_grenadier", "rhs_msv_emr_RShG2", "rhs_msv_emr_machinegunner", "rhs_msv_emr_at", "rhs_msv_emr_aa"]};
_groupRespawnTime = 30;
missionNameSpace setVariable [format["%1_Type",str(_group)], _groupType];

//Find vehicle config array
private _vehConfigArr = _vehID call fnc_cmn_getVehicleConfig;
_vehClass = _vehConfigArr select 1;
private _vehCost = _vehConfigArr select 4;

//Create a name for the grunt group
private _groupName = _gruntConfig select 0;
missionNameSpace setVariable [format["%1_Name",str(_group)], _groupName, true];

//Detecting if group vehicle is stuck
private _groupVehiclePos = getPosASL (leader _group);
private _groupVehicleStuck = 0;
private _groupVehicleTimeout = 0;

//Get main base information
private _basesArray = if (_side == west) then {DNC_Bases_West} else {DNC_Bases_East};
private _mainBase = [];
private _mainBaseIdx = ["Main", 0, _basesArray] Call fnc_cmn_getArrayIndex;
if (_mainBaseIdx != -1) then {_mainBase = _basesArray select _mainBaseIdx};

//Used for respawn positions
private _lastKnownPosition = getMarkerPos(format["startLoc_%1",_side]);

//Issue orders function
_fncIssueOrders =
{
	private _group = _this select 0;
	private _ordersArr = _this select 1;
	private _groupName = missionNameSpace getVariable [format["%1_Name",str(_group)], ""];
	
	//Delete old waypoints
	private _waypoints = waypoints _group;
	{deleteWaypoint [_group, _forEachIndex]} forEach _waypoints;

	//Issue new order
	switch (toLower(_ordersArr select 0)) do
	{
		case "attack":
		{
			private _zoneArr =+ DNC_Zones select (_ordersArr select 1);
			
			private _attackPos = [getPosATL (_zoneArr select 0), random(25 * 0.25), 50, false, [false], ""] call fnc_cmn_getRandomSafePos;
			
			private _wp = _group addWaypoint [_attackPos, random(50)];
			_wp setWaypointType "MOVE";
			_wp setWaypointCompletionRadius 0;
			_wp setWaypointBehaviour "AWARE";
			_wp setWaypointCombatMode "RED";
			_wp setWaypointSpeed "NORMAL";
			_wp setWaypointStatements ['true', 'missionNameSpace setVariable [format["%1_OrdersRefresh",str(group this)], true];'];
			_group setCurrentWaypoint _wp;
		
			//[side _group, "HQ"] commandChat format["Group %1 attacking %2",_groupName, (_zoneArr select 1)];
		};
		
		case "support":
		{
			private _friendlyGroup = (_ordersArr select 1 select 0);
			private _friendlyGroupOrderArray = _ordersArr select 1;
			
			private _friendlyGroupName = missionNameSpace getVariable [format["%1_Name",str(_friendlyGroup)], ""];
			private _zoneArr =+ DNC_Zones select ((_friendlyGroupOrderArray select 1) select 1);
			
			private _supportPos = [getPosATL (_zoneArr select 0), random(25 * 0.25), 50, false, [false], ""] call fnc_cmn_getRandomSafePos;
			
			private _wp = _group addWaypoint [_supportPos, random(50)];
			_wp setWaypointType "SAD";
			_wp setWaypointCompletionRadius 0;
			_wp setWaypointBehaviour "COMBAT";
			_wp setWaypointCombatMode "RED";
			_wp setWaypointSpeed "NORMAL";
			_wp setWaypointStatements ['true', 'missionNameSpace setVariable [format["%1_OrdersRefresh",str(group this)], true];'];
			_group setCurrentWaypoint _wp;
		
			//[side _group, "HQ"] commandChat format["Group %1 supporting group %2 at %3",_groupName, _friendlyGroupName, (_zoneArr select 1)];
		};
		
		case "defend":
		{
			private _zoneArr =+ DNC_Zones select (_ordersArr select 1);
			
			private _defendPos = [getPosATL (_zoneArr select 0), random(25 * 0.25), 50, false, [false], ""] call fnc_cmn_getRandomSafePos;
			
			private _wp = _group addWaypoint [_defendPos, random(50)];
			_wp setWaypointType "SAD";
			_wp setWaypointCompletionRadius 0;
			_wp setWaypointBehaviour "AWARE";
			_wp setWaypointCombatMode "RED";
			_wp setWaypointSpeed "NORMAL";
			_wp setWaypointStatements ['true', 'missionNameSpace setVariable [format["%1_OrdersRefresh",str(group this)], true];'];
			_group setCurrentWaypoint _wp;
		
			//[side _group, "HQ"] commandChat format["Group %1 attacking %2",_groupName, (_zoneArr select 1)];
		};
	};
	
	//Update
	missionNameSpace setVariable [format["%1_Orders",str(_group)], _ordersArr];
};

//Validate group orders
_fncValidateOrders =
{
	private _group = _this select 0;
	private _ordersArr = _this select 1;
	private _ordersValid = true;
	
	switch (toLower(_ordersArr select 0)) do
	{
		case "attack":
		{
			private _zoneArr =+ DNC_Zones select (_ordersArr select 1);
			
			//If side now owns the zone
			if ((_zoneArr select 5) == (side _group)) exitWith 
			{
				private _zoneStrengthFull = if (((_zoneArr select 6) select 0) == ((_zoneArr select 6) select 1)) then {true} else {false};
				private _enemiesPresent = [getPosATL (_zoneArr select 0), (_zoneArr select 3) + 200, (side _group)] call fnc_cmn_getEnemiesInRadius;
				
				//Zone is secure, clear orders
				if (_zoneStrengthFull && ((count _enemiesPresent) == 0)) then 
				{
					_ordersValid = false; 
					missionNameSpace setVariable [format["%1_Orders",str(_group)], []];
				}
				else //Change to defend order
				{
					missionNameSpace setVariable [format["%1_Orders",str(_group)], ["defend", (_ordersArr select 1)]];
					missionNameSpace setVariable [format["%1_OrdersRefresh",str(_group)], true];
				};
			};
		};
		
		case "support":
		{
			private _friendlyGroup = (_ordersArr select 1) select 0;
			private _friendlyGroupZone = ((_ordersArr select 1) select 1) select 1;
			
			//Is anybody in the group alive?
			private _aliveGroupMembers = 0;
			{
				if (alive _x) then {_aliveGroupMembers = _aliveGroupMembers + 1};
			} forEach (units _friendlyGroup);
			if (_aliveGroupMembers == 0) then
			{
				_ordersValid = false; 
				missionNameSpace setVariable [format["%1_Orders",str(_group)], []];
			}
			else
			{
				//If support zone doesn't match current friendly group's orders
				private _friendlyGroupCurrentOrders = missionNameSpace getVariable [format["%1_Orders",str(_friendlyGroup)], []];
				if (count(_friendlyGroupCurrentOrders) != 0) then
				{
					if (_friendlyGroupZone != (_friendlyGroupCurrentOrders select 1)) then
					{
						_ordersValid = false; 
						missionNameSpace setVariable [format["%1_Orders",str(_group)], []];
					};
				}
				else
				{
					_ordersValid = false; 
					missionNameSpace setVariable [format["%1_Orders",str(_group)], []];
				};
			};
		};
		
		case "defend":
		{
			private _zoneArr =+ DNC_Zones select (_ordersArr select 1);
			
			//If the enemy now owns this zone, counter attack
			if ((_zoneArr select 5) != (side _group)) exitWith
			{
				missionNameSpace setVariable [format["%1_Orders",str(_group)], ["defend", (_ordersArr select 1)]];
				missionNameSpace setVariable [format["%1_OrdersRefresh",str(_group)], true];
			};
			
			//If the zone is at 100% strength and there's no enemies within the radius, then clear orders
			private _zoneStrengthFull = if (((_zoneArr select 6) select 0) == ((_zoneArr select 6) select 1)) then {true} else {false};
			private _enemiesPresent = [getPosATL (_zoneArr select 0), (_zoneArr select 3) + 200, (side _group)] call fnc_cmn_getEnemiesInRadius;
			if (_zoneStrengthFull && ((count _enemiesPresent) == 0)) exitWith 
			{
				_ordersValid = false; 
				missionNameSpace setVariable [format["%1_Orders",str(_group)], []];
			};
		};
	};
	
	_ordersValid 
};

//Get spawn location based on orders
_fncGetSpawnLocation =
{
	private _group = _this select 0;
	private _lastKnownPosition = _this select 1;
	
	private _spawnLocationArr = [getMarkerPos(format["startLoc_%1", (side _group)]), 25, 50];
	
	//Get an array of valid spawn locations
	private _validSpawnLocs = [(side _group), _lastKnownPosition] call fnc_cmn_getValidSpawnLocations;

	//Find a location based off of current orders
	private _groupOrdersArr = missionNameSpace getVariable [format["%1_Orders",str(_group)], []];
	private _groupType = missionNameSpace getVariable [format["%1_Type",str(_group)], "infantry"];
	if ((count _groupOrdersArr) > 0) then
	{
		//Based on group type (TODO - DO THE OTHER TYPES!!!)
		private _groupOrderPos = [0, 0, 0];
		switch (toLower(_groupType)) do
		{
			case "infantry";
			case "motorized";
			case "armored":
			{
				//Based on order type (TODO - DO SUPPORT TYPE!!!)
				switch (toLower(_groupOrdersArr select 0)) do
				{
					case "attack";
					case "defend":
					{
						private _zoneArr = DNC_Zones select (_groupOrdersArr select 1);
						_groupOrderPos = getPosATL (_zoneArr select 0);
					};
					default
					{
						[__FILE__, "error", "fncGetSpawnLocation - Unknown group order: %1 %2", toLower(_groupOrdersArr select 0), _this] spawn fnc_sys_writeError;
					};
				};
			};
			default
			{
				[__FILE__, "error", "fncGetSpawnLocation - Unknown group type: %1 %2", toLower(_groupType), _this] spawn fnc_sys_writeError;
			};
			
			//Against the valid spawn locations, find the closest one to our group order position
			private _sortedLocationsByOrders = [];
			{
				private _currEntry =+ _x;
				private _currDistance = _groupOrderPos distance2D (_currEntry select 1);
				_currEntry set [0, _currDistance];
				
				_sortedLocationsByOrders pushBack _currEntry;
			} forEach _validSpawnLocs;
			if ((count _sortedLocationsByOrders) > 0) then
			{
				_sortedLocationsByOrders sort true;
				_spawnLocationArr = _validSpawnLocs select 0;
			}
			else
			{
				[__FILE__, "error", "fncGetSpawnLocation - Unable to pick a spawn location based off of orders: %1", _this] spawn fnc_sys_writeError;
			};
		};
	}
	else
	{
		//No orders, pick a random spawn location
		private _randomSpawnLoc = selectRandom _validSpawnLocs;
		_spawnLocationArr = [_randomSpawnLoc select 1, (_randomSpawnLoc select 4) select 0, (_randomSpawnLoc select 4) select 1];
	};
	
	_spawnLocationArr
};

//Main logic loop TODO - only when gamestate is active
while {true} do
{
	//Refresh orders local variable
	_groupOrderArr = missionNameSpace getVariable [format["%1_Orders",str(_group)], []];
	private _refreshOrders = missionNameSpace getVariable [format["%1_OrdersRefresh",str(_group)], false];
	
	//Does the group have any units alive?
	private _unitCount = 0;
	{
		if (alive _x) then {_unitCount = _unitCount + 1};
	} forEach (units _group);
	
	//No units, spawn the group in
	if (_unitCount == 0) then
	{	
		//Group respawning
		private _spawnPositionArr = [getMarkerPos(format["startLoc_%1",_side]), 25, 50];
		if (!_firstSpawn) then 
		{
			{deleteVehicle _x} forEach (units _group);
			uiSleep _groupRespawnTime;
			missionNameSpace setVariable [format["%1_OrdersRefresh",str(_group)], true];
			
			//Figure out new spawn location based on previous orders and current situation
			_spawnPositionArr = [_group, _lastKnownPosition] call _fncGetSpawnLocation;
		};
		_firstSpawn = false;
		
		//Nullify group's previous vehicle
		_groupVehicle = objNull;
		_groupVehicleTimeout = -999999999;
		_groupVehicleStuck = 0;
		
		switch (toLower(_groupType)) do
		{
			case "infantry";
			case "motorized":
			{
				//Get creation position
				private _createPos = [(_spawnPositionArr select 0), (_spawnPositionArr select 1), (_spawnPositionArr select 2), false, [false], _vehClass] Call fnc_cmn_getRandomSafePos;
				while {(_createPos select 0) == -1} do {_createPos = [(_spawnPositionArr select 0), (_spawnPositionArr select 1), (_spawnPositionArr select 2), false, [false], _vehClass] Call fnc_cmn_getRandomSafePos;};
				
				//Create units
				{
					private _unit = [_side, _group, _createPos, _x] call fnc_srv_createUnit;
				} forEach _unitArray;
			};
			
			//Instantly spawn group vehicle and move crew inside
			case "armored":
			{
				//Group can't do anything if they can't afford the vehicle
				private _groupMoney = missionNameSpace getVariable [format["%1_Money", str(_group)], 0];
				if (_groupMoney >= _vehCost) then
				{
					//Get creation position
					private _createPos = [(_spawnPositionArr select 0), (_spawnPositionArr select 1), (_spawnPositionArr select 2), false, [false], _vehClass] Call fnc_cmn_getRandomSafePos;
					while {(_createPos select 0) == -1} do {_createPos = [(_spawnPositionArr select 0), (_spawnPositionArr select 1), (_spawnPositionArr select 2), false, [false], _vehClass] Call fnc_cmn_getRandomSafePos;};
					
					//Create armored vehicle
					_groupVehicle = [_side, _createPos, (random 360), _vehID] call fnc_srv_createVehicle;
					
					//Create units and put them inside the armored vehicle
					{
						private _unit = [_side, _group, getMarkerPos(format["startLoc_%1",_side]), _x] call fnc_srv_createUnit;
						_unit moveInAny _groupVehicle;
					} forEach _unitArray;
					
					//Remove money from group for vehicle cost
					[_group, "grunt", "-", _vehCost] spawn fnc_srv_changeMoney;
				}
				else
				{
					uiSleep 15;
				};
			};
			
			//Airborne needs to spawn on a main base helipad (can deploy helicopter in the field afterwards)
			//Gunship always needs to spawn on a main base helipad
			case "airborne";
			case "gunship":
			{
				//Group can't do anything if they can't afford the vehicle
				private _groupMoney = missionNameSpace getVariable [format["%1_Money", str(_group)], 0];
				if (_groupMoney >= _vehCost) then
				{
					//Figure out which helipad the gunship can spawn at
					private _helipadObj = objNull;
					private _heliPads = [];
					{
						private _currSpawnArr = _x;
						if (toLower(_groupType) in (_currSpawnArr select 0)) then {_heliPads pushBack (_currSpawnArr select 1);};
					} forEach (_mainBase select 2);
					{
						//Check if there are objects blocking the helipad
						private _nearEntities = [];
						private _nearEntities = nearestObjects [(getPosATL _x), ["Car","Tank","Air","Ship","CAManBase"], 10];
									
						//If nearest object is dead, clean it up
						if ((count _nearEntities) > 0) then
						{
							private _nearest = _nearEntities select 0;
							if (!alive _nearest) then 
							{
								deleteVehicle _nearest;
								_nearEntities = _nearEntities - [_nearest];
							};
						};
						
						if ((count _nearEntities) == 0) exitWith {_helipadObj = _x};
					} forEach _heliPads;
					
					//If we found a valid helipad
					if (!isNull _heliPadObj) then
					{
						//Create helicopter
						_groupVehicle = [_side, (getPosATL _helipadObj), (getDir _helipadObj), _vehID] call fnc_srv_createVehicle;
						
						//Set Flight Heights
						switch (toLower(_groupType)) do
						{
							case "airborne": { _groupVehicle flyInHeight 25; };
							case "gunship": { _groupVehicle flyInHeight 150; };
						};

						//Create units and put them in the helicopter
						{
							private _unit = [_side, _group, getMarkerPos(format["startLoc_%1",_side]), _x] call fnc_srv_createUnit;
							_unit moveInAny _groupVehicle;
						} forEach _unitArray;
						
						//Remove money from group for vehicle cost
						[_group, "grunt", "-", _vehCost] spawn fnc_srv_changeMoney;
					}
					else
					{
						//[side _group, "HQ"] commandChat format["Group %1 no helipad available!",_groupName];
						uiSleep 15;
					};
				}
				else
				{
					uiSleep 15;
				};
			};
			
			//Instantly spawn group vehicle and move crew inside, start vehicle in air with thrust
			case "cas":
			{
			
			};
		};
		
		//Engage at will
		_group setCombatMode "RED";
		
		//Delete the default waypoints so we can issue orders
		private _waypoints = waypoints _group;
		{deleteWaypoint [_group, _forEachIndex]} forEach _waypoints;
		
		//Update last known position
		_lastKnownPosition = getPosATL (leader _group);
	}
	else
	{
		/* DO WE REALLY WANT THIS?
		//Check how many units are still alive (we don't want groups with less than 2 people alive to still exist - respawn them)
		if (_unitCount <= 2) then
		{
			{
				_x setDamage 1;
			} forEach (units _group);
		};
		*/
	};
	
	//Group is alive, perform updates
	if (_unitCount >= 1) then
	{
		//Update last known position
		_lastKnownPosition = getPosATL (leader _group);
		
		//Group has no orders, issue new ones
		if ((count _groupOrderArr) == 0) then
		{
			//[side _group, "HQ"] commandChat format["Group %1 needs orders!",_groupName];
			
			//Orders based on group type
			switch (toLower(_groupType)) do
			{
				case "infantry";
				case "motorized";
				case "airborne":
				{
					//Get reasonable ranges based on group type
					private _reasonableRange = 0;
					switch (toLower(_groupType)) do
					{
						case "infantry": {_reasonableRange = 1000};
						case "motorized": {_reasonableRange = 2000};
						case "airborne": {_reasonableRange = 5000};
					};
					
					//Sort zones by distance
					private _sortedNearest = [getPosATL (leader _group), -1] call fnc_cmn_setNearestZones;
					
					//Defend a zone if need be (Zone must be under attack and be within a reasonable range)
					private _nearestSideZones = [];
					{
						private _currArr = DNC_Zones select (_x select 1);
						if (((_currArr select 5) == (side _group)) && ((getPosASL (leader _group) distance2D (_currArr select 0)) <= _reasonableRange)) then {_nearestSideZones pushBack _currArr};
					} forEach _sortedNearest;
					while {(count _nearestSideZones) > 0} do
					{
						private _randIdx = round(random(count _nearestSideZones - 1));
						private _zoneToDefend = _nearestSideZones select _randIdx;
						private _zoneStrengthFull = if (((_zoneToDefend select 6) select 0) == ((_zoneToDefend select 6) select 1)) then {true} else {false};
						private _enemiesPresent = [getPosATL (_zoneToDefend select 0), (_zoneToDefend select 3) + 200, (side _group)] call fnc_cmn_getEnemiesInRadius;
						
						//Need to defend the zone
						if (!_zoneStrengthFull || ((count _enemiesPresent) > 0)) exitWith 
						{
							_groupOrderArr = ["Defend", _randIdx];
							private _issueOrderCall = [_group, _groupOrderArr] spawn _fncIssueOrders;
							waitUntil {scriptDone _issueOrderCall};
						};
						
						//If the zone is ok, remove it from the array and select the next one
						_nearestSideZones deleteAt _randIdx;
					};
					
					//Attack a zone
					if ((count _groupOrderArr) == 0) then
					{
						private _iterations = 0;
						private _nearestEnemyZones = [];
						while {(count(_nearestEnemyZones) <= 0) && (_iterations < 8)} do //Infantry range at 8 iterations is over 20km, no way that should happen
						{
							{
								private _currArr = DNC_Zones select (_x select 1);
								if (((_currArr select 5) != (side _group)) && (((getPosASL (leader _group)) distance2D (_currArr select 0)) <= _reasonableRange)) then {_nearestEnemyZones pushBackUnique (_x select 1)};
							} forEach _sortedNearest;
							
							//If we didn't find any zones to attack, try looking further
							_resonableRange = _reasonableRange * 1.5;
							_iterations = _iterations + 1;
						};

						//Attack a zone. If there is none, game should be over
						if ((count _nearestEnemyZones) > 0) then
						{
							private _zoneToAttack = selectRandom _nearestEnemyZones;
							_groupOrderArr = ["Attack", _zoneToAttack];
							
							private _issueOrderCall = [_group, _groupOrderArr] spawn _fncIssueOrders;
							waitUntil {scriptDone _issueOrderCall};
						};
					};
				};
				
				case "armored";
				case "gunship";
				case "cas":
				{
					//Support attack/defense on a zone that is the objective of another friendly group (only support infantry, motorized and airborne)
					private _friendlyGroups = if (_side == west) then {DNC_GruntGroups_West} else {DNC_GruntGroups_East};
					private _friendlyGroupsWithOrders = [];
					{
						private _friendlyGroupOrders = missionNameSpace getVariable [format["%1_Orders",str(_x)], []];
						if (count _friendlyGroupOrders > 0) then
						{
							if ((_friendlyGroupOrders select 0) == "attack" || (_friendlyGroupOrders select 0) == "defend") then
							{
								_friendlyGroupsWithOrders pushBack [_x, _friendlyGroupOrders];
							};
						};
					} forEach _friendlyGroups;
					
					//Is there anybody to support?
					if (count _friendlyGroupsWithOrders > 0) then
					{
						private _groupSelected = selectRandom _friendlyGroupsWithOrders;
						_groupOrderArr = ["support", _groupSelected];
						
						private _issueOrderCall = [_group, _groupOrderArr] spawn _fncIssueOrders;
						waitUntil {scriptDone _issueOrderCall};
					}
					else
					{
						//Nobody to support (wait 15 seconds)
						//[side _group, "HQ"] commandChat format["Group %1 has nobody to support!",_groupName];
						uiSleep 15;
					};
				};
				
				case "interceptor":
				{
					//Combat patrol on random zones
				};
				
			};
		}
		else //Group has orders, check if they're still good
		{
			//Does this group require an order refresh (waypoint probably expired)
			if (_refreshOrders) then
			{
				missionNameSpace setVariable [format["%1_OrdersRefresh",str(_group)], false];
				
				private _issueOrderCall = [_group, _groupOrderArr] spawn _fncIssueOrders;
				waitUntil {scriptDone _issueOrderCall};
			}
			else
			{
				//Validate the group's orders to make sure they don't need to be switched
				private _ordersValidated = [_group, _groupOrderArr] call _fncValidateOrders;
				if (_ordersValidated) then
				{
					//Orders update based on group type
					switch (toLower(_groupType)) do
					{
						case "infantry";
						case "motorized";
						case "mechanized";
						case "airborne":
						{
							//If the group has a vehicle assigned to it
							if (_vehClass != "") then
							{
								//Can the group afford a vehicle
								private _groupMoney = missionNameSpace getVariable [format["%1_Money",str(_group)], 0];
								if (_groupMoney >= _vehCost) then
								{
									//If the group is far enough away from their object, spawn in their vehicle and use that to get closer
									if (isNull _groupVehicle) then
									{
										//Don't spawn the vehicle so soon again
										if ((diag_tickTime - _groupVehicleTimeout) > 60) then
										{
											//If group is not under attack
											if (behaviour (leader _group) != "STEALTH" && behaviour (leader _group) != "COMBAT") then
											{
												//Get the zone array
												private _zoneArr =+ DNC_Zones select (_groupOrderArr select 1);
												if (((leader _group) distance2D (_zoneArr select 0)) > 300 ) then
												{
													//Get creation position
													private _createPos = [getPosATL (leader _group), random(25 * 0.25), 50, false, [false], _vehClass] Call fnc_cmn_getRandomSafePos;
													while {(_createPos select 0) == -1} do {_createPos = [getPosATL (leader _group), random(25 * 0.25), 50, false, [false], _vehClass] Call fnc_cmn_getRandomSafePos;};
					
													//Create the group vehicle
													_groupVehicle = [_side, _createPos, random(360), _vehID] call fnc_srv_createVehicle;
													if (_groupType == "airborne") then {_groupVehicle flyInHeight 25;};												
													
													//Move units of group into vehicle
													{_x moveInAny _groupVehicle} forEach (units _group);
													
													//Update waypoint type to move
													{
														_x setWaypointType "MOVE";
														_x setWaypointSpeed "NORMAL";
													} forEach (waypoints _group);
													
													//Remove money from group for vehicle cost
													[_group, "grunt", "-", _vehCost] spawn fnc_srv_changeMoney;

													//[side _group, "HQ"] commandChat format["Group %1 driving to objective!",_groupName];
												};
											};
										};
									};
								};
								
								//Does the group still need to be in the vehicle?
								if (!isNull _groupVehicle) then
								{
									//Vehicle is dead
									if (!(alive _groupVehicle)) then
									{
										_groupVehicle = objNull;
									}
									else //Vehicle is alive
									{
										_disembarkVehicle = false;
										
										//If group is under attack
										if (behaviour (leader _group) == "STEALTH" || behaviour (leader _group) == "COMBAT") then
										{
											_disembarkVehicle = true;
										};
										
										//Make sure vehicle has fuel
										if (!_disembarkVehicle) then
										{
											if (fuel _groupVehicle <= 0.01) then {_disembarkVehicle = true};
										};
										
										//The group isn't in the vehicle (flipped over maybe?)
										if (!_disembarkVehicle) then
										{	
											private _unitCount = 0;
											{
												if (alive _x) then {_unitCount = _unitCount + 1};
											} forEach (units _group);
											if (count (crew _groupVehicle) < _unitCount) then
											{
												_disembarkVehicle = true;
											};
										};
										
										//Is the vehicle stuck/not moving?
										if (!_disembarkVehicle) then
										{
											if (((getPosATL _groupVehicle) distance2D _groupVehiclePos) <= 2) then
											{
												if (_groupVehicleStuck == 0) then 
												{
													_groupVehicleStuck = diag_tickTime;
												}
												else
												{	
													if ((diag_tickTime - _groupVehicleStuck) >= 60) then
													{
														_disembarkVehicle = true;
														_groupVehicleStuck = 0;
														missionNameSpace setVariable [format["%1_OrdersRefresh",str(_group)], true];
														//[side _group, "HQ"] commandChat format["Group %1 stuck for too long", _groupName];
													};
												};
											}
											else
											{
												_groupVehicleStuck = 0;
											};
										};
										_groupVehiclePos = getPosATL _groupVehicle;

										//Group is close enough to destination or there's another reason to disembark, walk from here
										private _zoneArr = DNC_Zones select (_groupOrderArr select 1);
										if (((_groupVehicle distance2D (_zoneArr select 0)) <= 400) || _disembarkVehicle) then
										{
											//Timeout for vehicle usage
											_groupVehicleTimeout = diag_tickTime;
											
											//[side _group, "HQ"] commandChat format["Group %1 dismounting from vehicle!",_groupName];
											
											//Stop vehicle if it's not an airborne unit
											if (_groupType != "airborne") then {_groupVehicle setVelocity [0, 0, 0];};
											
											//Kick everybody out and delete vehicle
											{
												_x action["engineOff", _groupVehicle];
												_x leaveVehicle _groupVehicle;
												_x action ["eject", _groupVehicle];
											} forEach (units _group);
											
											//Wait till the vehicle has nobody alive in it anymore
											while {true} do
											{
												private _aliveCrew = 0;
												private _vehCrew = crew (vehicle _groupVehicle);
												{
													if (alive _x) then {_aliveCrew = _aliveCrew + 1};
												} forEach _vehCrew;
												
												if (_aliveCrew == 0) exitWith {};
												uiSleep 1;
											};
											
											//Update waypoint type to search and destroy
											if (!_disembarkVehicle) then
											{
												{
													_x setWaypointType "SAD";
													_x setWaypointSpeed "NORMAL";
												} forEach (waypoints _group);
											};
											
											//Delete the group vehicle and refund the group the value of the vehicle
											uiSleep 5;
											if (alive _groupVehicle) then
											{
												//Refund if it's still alive
												[_group, "grunt", "+", _vehCost] spawn fnc_srv_changeMoney;
											};
											deleteVehicle _groupVehicle;
										};
									};
								};
							};
						};
						
						case "armored";
						case "gunship";
						case "cas":
						{
							//Does vehicle exist?
							if (!isNull _groupVehicle) then
							{
								private _disembarkVehicle = false;
								
								//Vehicle is out of gas
								if (fuel _groupVehicle == 0) then {_disembarkVehicle = true};
								
								//The group isn't in the vehicle (flipped over maybe?)
								if (!_disembarkVehicle) then
								{	
									private _unitCount = 0;
									{
										if (alive _x) then {_unitCount = _unitCount + 1};
									} forEach (units _group);
									if (count (crew _groupVehicle) < _unitCount) then
									{
										_disembarkVehicle = true;
									};
								};
								
								//TODO: Low on ammo
								
								//Is the vehicle stuck/not moving?
								if (!_disembarkVehicle) then
								{
									if (((getPosATL _groupVehicle) distance2D _groupVehiclePos) <= 2) then
									{
										if (_groupVehicleStuck == 0) then 
										{
											_groupVehicleStuck = diag_tickTime;
										}
										else
										{	
											if ((diag_tickTime - _groupVehicleStuck) >= 60) then
											{
												_groupVehicleStuck = 0;
												missionNameSpace setVariable [format["%1_OrdersRefresh",str(_group)], true];
												//[side _group, "HQ"] commandChat format["Group %1 stuck for too long", _groupName];
											};
										};
									}
									else
									{
										_groupVehicleStuck = 0;
									};
								};
								_groupVehiclePos = getPosATL _groupVehicle;

								
								//If vehicle is determined to be garbage, group serves no purpose
								if (_disembarkVehicle) then
								{
									{_x setDamage 1} forEach (units _group);
									_groupVehicle setDamage 1;
								};
							}
							else
							{
								//If vehicle doesn't exist, group serves no purpose
								{_x setDamage 1} forEach (units _group);
							};
							
						};
						
						case "interceptor":
						{
							//TODO
						};
					};
				};
			};
		};
	};
	
	uiSleep random(2 + 5);
};
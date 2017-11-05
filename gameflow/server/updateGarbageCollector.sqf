if (!("server" call fnc_sys_verifyContext)) exitWith {[__FILE__, "error", "Unable to run script due to incorrect context"] spawn fnc_sys_writeError;};

while {true} do //todo
{
	//Make sure garbage isn't being updated
	waitUntil {!DNC_SVAR_GARBAGE_LOCKED};
	
	//Don't allow other changes to garbage array
	DNC_SVAR_GARBAGE_LOCKED = true;
	
	//Update garbage queue contents
	{
		//Only update if array - otherwise it's an item that should be removed from the queue
		if (typeName _x == "ARRAY") then
		{
			_object = _x select 0;
			_timer = _x select 1;
			
			//Delete object and remove if time is lower than 1
			if (diag_tickTime >= _timer || isNull _object) then
			{
				//If object isn't null, delete it
				if (!isNull _object) then 
				{
					//If it's infantry, clean up the weapon holders on the ground
					if (_object isKindOf "Man") then
					{
						{
							if (typeOf _x == "GroundWeaponHolder") then {deleteVehicle _x};
						} forEach ((getPosATL _object) nearObjects 15);
					};
					
					deleteVehicle _object;
				};
				
				//Remove the element from the garbage collector array
				DNC_SVAR_GARBAGE_ARRAY deleteAt _forEachIndex;
			};
		};
	} forEach DNC_SVAR_GARBAGE_ARRAY;
	
	//Allow changes to garbage array
	DNC_SVAR_GARBAGE_LOCKED = false;
	
	uiSleep 10;
};
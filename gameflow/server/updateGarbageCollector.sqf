if (!("server" call fnc_sys_verifyContext)) exitWith {[__FILE__, "error", "Unable to run script due to incorrect context"] spawn fnc_sys_writeError;};

while {true} do //todo
{
	//Make sure garbage isn't being updated
	waitUntil {!DNC_SVAR_GARBAGE_LOCKED};
	
	//Don't allow other changes to garbage array
	DNC_SVAR_GARBAGE_LOCKED = true;
	
	//Update garbage queue contents
	private _idxToDelete = [];
	{
		//Only update if array - otherwise it's an item that should be removed from the queue
		if (typeName _x == "ARRAY") then
		{
			_object = _x select 0;
			_timer = _x select 1;
			
			//Delete object and mark index for removal if time is lower than 1, otherwise decrement time
			if (diag_tickTime >= _timer || isNull _object) then
			{
				deleteVehicle _object;
				_idxToDelete pushBack _forEachIndex;
			};
		};
	} forEach DNC_SVAR_GARBAGE_ARRAY;
	
	//Run through and remove deleted indexes
	{
		DNC_SVAR_GARBAGE_ARRAY deleteAt _x;
	} forEach _idxToDelete;
	
	//Allow changes to garbage array
	DNC_SVAR_GARBAGE_LOCKED = false;
	
	uiSleep 10;
};
private _garbObj = _this select 0;
private _timeout = _this select 1;

if (!("server" call fnc_sys_verifyContext)) exitWith {[__FILE__, "error", "Unable to run script due to incorrect context"] spawn fnc_sys_writeError;};

//Make sure garbage array isn't locked
waitUntil {!DNC_SVAR_GARBAGE_LOCKED};

//Add to garbage array
DNC_SVAR_GARBAGE_LOCKED = true;
DNC_SVAR_GARBAGE_ARRAY pushBack [_garbObj, (diag_tickTime + _timeout)];
DNC_SVAR_GARBAGE_LOCKED = false;
private _objVictim = _this select 0;
private _sideVictim = _this select 1;
private _isVictimPlayer = _this select 2;
private _objKiller = _this select 3;
private _sideKiller = _this select 4;
private _isKillerPlayer = _this select 5;

if (!("server" call fnc_sys_verifyContext)) exitWith {[__FILE__, "error", "Unable to run script due to incorrect context"] spawn fnc_sys_writeError;};

//Add dead body to garbage collection (30 seconds till it's cleaned up)
[_objVictim, 30] spawn fnc_srv_addToGarbageCollector;
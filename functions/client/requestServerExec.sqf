/*
Author(s):
GossamerSolid

Description:
Requests a remote function to be executed on the server. Data may or may not be returned depending on what's getting executed.

Notes:
Parameters
0 - String - Function to execute
1 - String - Sub Function to execute
2 - Array - Array of arguments to pass to said function
3 - String - Name of global variable to store result in, leave empty string for none (This will mean it's a synchronous call)

Returns:
Nothing
*/

if (!("client" call fnc_sys_verifyContext)) exitWith {[__FILE__, "error", "Unable to run script due to incorrect context"] spawn fnc_sys_writeError;};

DNC_CLIENT_FNC_EXEC = [player, _this select 0, _this select 1, _this select 2, _this select 3];
publicVariableServer "DNC_CLIENT_FNC_EXEC";

/*
To use a synchronized call, you must initialize your global var (which has the data returned to it) like so:
FS_YOUR_GLOBAL = ["DNC_NETCALL_WAITING"];
Additionally, you must assign a handle for this Spawned function and wait on it to be done:
_myNetCall = [args] Spawn fnc_clt_requestServerData;
waitUntil {scriptDone _myNetCall};
*/

private _sync = if ((_this select 3) != "") then {true} else {false};
if (_sync) then
{
	private _timeout = 60;
	private _gvar = [];
	private _waiting = true;
	while {_waiting} do
	{
		uiSleep 0.1;
		_timeout = _timeout - 0.1;
		Call Compile Format ["_gvar = %1",_this select 3];
		if (_timeout <= 0) then {_waiting = false};
		if (count _gvar == 0) exitWith {_waiting = false};
		if ((typeName (_gvar select 0)) == "STRING") then
		{
			if ((_gvar select 0) != "DNC_NETCALL_WAITING") then
			{
				_waiting = false;
			};
		}
		else
		{
			_waiting = false;
		};
	};
	
	if (_timeout <= 0) then
	{
		[__FILE__, "error", format["Did not get a response from the server - %1", _this]] spawn fnc_sys_writeError;
	};
};
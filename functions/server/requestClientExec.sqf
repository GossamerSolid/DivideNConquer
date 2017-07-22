//Written by: GossamerSolid
//Requests a remote function to be executed on the client
//@param 0 - Array of client IDs to send to
//@param 1 - Function to execute
//@param 2 - Subfunction of function
//@param 3 - Array of parameters to pass to said function

if (!("server" call fnc_sys_verifyContext)) exitWith {[__FILE__, "error", "Unable to run script due to incorrect context"] spawn fnc_sys_writeError;};

if ((count (_this select 0)) > 0) then
{
	{
		DNC_SERVER_FNC_EXEC = [_this select 1, _this select 2, _this select 3];
		_x publicVariableClient "DNC_SERVER_FNC_EXEC";
	} forEach (_this select 0);
};
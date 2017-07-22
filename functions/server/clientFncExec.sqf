/*
Author(s):
GossamerSolid

Description:
Receive a request from the client to execute code on the server. Might return data depending on if the client expected a result or not.

Notes:
Parameters
0 - Object - Client Object
1 - String - Function to execute
2 - String - Sub Function to execute
3 - Array - Array of arguments to pass to said function
4 - String - Global variable to return data to on the client (Will be empty string if no return is expected)

Returns:
Nothing
*/

if (!("server" call fnc_sys_verifyContext)) exitWith {[__FILE__, "error", "Unable to run script due to incorrect context"] spawn fnc_sys_writeError;};

private _passedParams = _this select 0;
private _clientObj = _passedParams select 0;
private _function = _passedParams select 1;
private _subFunction = _passedParams select 2;
private _parameters = _passedParams select 3;
private _synchedCallVar = _passedParams select 4;
private _returnData = [""];

//Run request from client
switch (_function) do
{
	default
	{
		[__FILE__, "error", format["Received unknown request from client - %1",_this select 0]] spawn fnc_sys_writeError;
		_returnData = "DNCBADREQUEST";
	};
};

//If it's a synched call, return the result to the client
if (_synchedCallVar != "") then
{
	Call Compile Format ["%1 = _returnData", _synchedCallVar];
	Call Compile Format ["%1 publicVariableClient ""%2""", (owner _clientObj), _synchedCallVar];
};
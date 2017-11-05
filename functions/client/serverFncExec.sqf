/*
Filename:
fnc_serverFncExec.sqf

Author(s):
GossamerSolid

Description:
Receive a request from the server to execute code on the client. This cannot return data to the server directly.

Notes:
Parameters
0 - String - Function to execute
1 - String - Sub Function to execute
2 - Array - Array of arguments to pass to said function

Returns:
Nothing
*/

private["_function", "_subFunction", "_parameters"];
_function = _this select 0;
_subFunction = _this select 1;
_parameters = _this select 2;

//Run request from server
switch (_function) do
{
	//Zones
	case "zone":
	{
		switch (_subFunction) do
		{
			case "capture":
			{
				_parameters spawn fnc_clt_zoneCaptured;
			};
			
			default
			{
				[__FILE__, "error", format["Received an unknown request from the server - %1", _this]] spawn fnc_sys_writeError;
			};
		};
	};
	
	//Sounds
	case "sound":
	{
		switch (_subFunction) do
		{
			case "playSound":
			{
				playSound _parameters;
			};
			
			default
			{
				[__FILE__, "error", format["Received an unknown request from the server - %1", _this]] spawn fnc_sys_writeError;
			};
		};
	};
	
	//Messages
	case "messages":
	{	
		_parameters spawn fnc_clt_messages;
	};
		
	default
	{
		[__FILE__, "error", format["Received an unknown request from the server - %1", _this]] spawn fnc_sys_writeError;
	};
};
/*
Filename:
fnc_getSideMembers.sqf

Author(s):
GossamerSolid

Description:
Gets the members of a specified side

Notes:
Parameters
0 - Side - Side of Members - The side of the elements that will be returned
1 - String - Return Type - What values should be in the return array ("netid", "obj", "uid", "varname")

Returns
Array - Array of elements (self explanatory given the parameters)
*/

private ["_sideOn", "_retType", "_obj", "_sideObj", "_returnArray", "_varName"];

_sideOn = _this select 0;
_retType = _this select 1;

_returnArray = [];
{
	if (!isNull _x) then
	{
		if ((side _x) == _sideOn) then
		{
			switch (_retType) do 
			{
				case "netid":
				{
					_returnArray set [count _returnArray, (owner _x)];
				};
				case "obj":
				{
					_returnArray set [count _returnArray, _x];
				};
				case "uid":
				{
					_returnArray set [count _returnArray, (getPlayerUID _x)];
				};
				case "varname":
				{
					_returnArray set [count _returnArray, (vehicleVarName _x)];
				};
			};
		};
	};
} forEach allPlayers;

_returnArray 
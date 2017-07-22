/*
Filename:
fnc_arrayGetIndex.sqf

Author(s):
GossamerSolid

Description:
Get the index of an element of a multidimensional array

Notes:
Parameters
0 - String - Search Value - Value to search against
1 - Scalar - Search Index - Index of sub-array to search at
2 - Array - Search Array - Array to search through

Returns
Scalar - Index of given element (Returns -1 if not found)
*/

private ["_searchValue", "_searchIndex", "_searchArray", "_returnIndex"];

_searchValue = "";
_searchIndex = -1;
_searchArray = [];
_returnIndex = -1;

if (count(_this) == 2) then
{
	_searchValue = _this select 0;
	_searchArray = _this select 1;

	{
		if (_x isEqualTo _searchValue) exitWith {_returnIndex = _forEachIndex};
	} forEach _searchArray;
}
else
{
	_searchValue = _this select 0;
	_searchIndex = _this select 1;
	_searchArray = _this select 2;

	{
		_currVal = if (typeName _x == "ARRAY") then {_x select _searchIndex} else {_x};
		if (_currVal isEqualTo _searchValue) exitWith {_returnIndex = _forEachIndex};
	} forEach _searchArray;
};

_returnIndex
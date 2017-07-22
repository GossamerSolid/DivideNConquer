/*
Script: fnc_mergeArrays.sqf
Written by: GossamerSolid

Given any amount of arrays, a single array with all elements will be returned
*/

private["_arrays","_returnArray"];

_arrays = _this;
_returnArray = [];

{
	_returnArray append _x;
} forEach _arrays;

/*
{
	_currArr = _x;
	{
		_returnArray pushBack _x;
	} forEach _currArr;
} forEach _arrays;
*/

_returnArray 
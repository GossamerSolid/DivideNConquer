/*
Filename:
fnc_setPosAGLS.sqf

Author(s):
https://community.bistudio.com/wiki/Position#setPosAGLS

Description:
The function will place passed object onto walkable surface, if there is one, otherwise on the ground.
If only x and y of the position are supplied, the object will be placed on surface, if z is supplied, it will
be treated as offset from the surface level.

Notes:
Parameters
0 - Object - The obj reference to move
1 - Position - The desired position to work off of
2 - Integer - Additional height offset

Returns
Nothing
*/

params ["_obj", "_pos", "_offset"];
_offset = _pos select 2;
if (isNil "_offset") then {_offset = 0};
_pos set [2, worldSize];
_obj setPosASL _pos;
_pos set [2, vectorMagnitude (_pos vectorDiff getPosVisual _obj) + _offset];
_obj setPosASL _pos;

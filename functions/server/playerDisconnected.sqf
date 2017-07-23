private _playerObj = _this select 0;
private _uid = _this select 2;
private _name = _this select 3;

//Don't do anything for the server
if (_name != "__SERVER__") then
{
	//Leave current group
	["KickPlayer", [_playerObj]] call BIS_fnc_dynamicGroups;
	
	//Move player to spawn area
	private _initialPos = [(getMarkerPos format["respawn_%1",side _playerObj]), random(20 * 0.25), random(50), false, [false], typeOf player] Call fnc_cmn_getRandomSafePos;
	while {(_initialPos select 0) == -1} do {_initialPos = [(getMarkerPos format["respawn_%1",side _playerObj]), random(20 * 0.25), random(50), false, [false], typeOf player] Call fnc_cmn_getRandomSafePos;};		
	_playerObj setPosATL _initialPos;
	
	//Strip equipment
	removeAllWeapons _playerObj;
};
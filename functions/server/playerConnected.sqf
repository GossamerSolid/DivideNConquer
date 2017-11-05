
private _uid = _this select 0;
private _name = _this select 1;
private _returnData = [];

[__FILE__, "info", format["Player Connected - %1 (%2)",  _name, _uid]] spawn fnc_sys_writeError;

//Don't do anything for the server
if (_name != "__SERVER__") then
{
	//Wait till server is initialized
	waitUntil{!isNil "DNC_ServerInit"};
	waitUntil{DNC_ServerInit};
	
	//Get the player's object
	private _playerObj = _uid Call fnc_cmn_getObjFromUID;

	//Is this player a new connection or not?
	private _sessionProfile = [];
	if (_uid in DNC_SESSIONUIDS) then
	{
		//Reconnect
		_sessionProfile = missionNamespace getVariable (format["DNC_PROF_%1",_uid]);
		if (!isNil "_sessionProfile") then
		{
			//TODO reconnect logic
		}
		else
		{
			[__FILE__, "error", format["Session profile is missing for a reconnected player - %1 (%2)",  _name, _uid]] spawn fnc_sys_writeError;
		};
	}
	else
	{
		//Create session profile
		_sessionProfile =
		[
			DNC_DATA_BASE_MONEY, //Money
			DNC_DATA_BASE_LP, //Max loadout points
			[1, 1, 1, 1], //Experience level per class (TODO: Persist in DB)
			[0, 0, 0, 0] //XP
		];

		//Add player UID to session uids
		DNC_SESSIONUIDS pushBack _uid;
	};
	
	//Commit session profile
	missionNamespace setVariable [(format["DNC_PROF_%1",_uid]), _sessionProfile];
	
	//Killed event handler
	_playerObj removeAllMPEventHandlers "MPKilled";
	if ((side _playerObj) == west) then
	{
		_playerObj addMPEventHandler ["MPKilled",{if (isServer) then {[(_this select 0), west, true, (_this select 1), (side (group (_this select 1))), (isPlayer (_this select 1))] call fnc_srv_unitKilled;};}];
	}
	else
	{
		_playerObj addMPEventHandler ["MPKilled",{if (isServer) then {[(_this select 0), east, true, (_this select 1), (side (group (_this select 1))), (isPlayer (_this select 1))] call fnc_srv_unitKilled;};}];
	};
	
	//Send variables to client
	DNC_CVAR_MONEY = _sessionProfile select 0;
	(owner _playerObj) publicVariableClient "DNC_CVAR_MONEY";
	
	DNC_PLAYER_LP = _sessionProfile select 1;
	(owner _playerObj) publicVariableClient "DNC_PLAYER_LP";
	
	DNC_CVAR_LEVEL = _sessionProfile select 2;
	(owner _playerObj) publicVariableClient "DNC_CVAR_LEVEL";
	
	DNC_CVAR_XP = _sessionProfile select 3;
	(owner _playerObj) publicVariableClient "DNC_CVAR_XP";
};
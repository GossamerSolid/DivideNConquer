disableSerialization;

//Developer mode enabled or not
DNC_DEVMODE = true;

//Get root dir of mission in order to use with commands like drawIcon/drawIcon3D
DNC_MISSIONROOT = Call 
{
    private "_arr";
    _arr = toArray __FILE__;
    _arr resize (count _arr - 8);
    toString _arr
};

//Fix for making side constants work
guer = resistance;
civ = civilian;

//Disable raycast sensors (apparently meant to make client performance much better)
//disableRemoteSensors true;

//Compile these functions because we might need it right away
fnc_sys_writeError = compile preprocessFileLineNumbers "functions\system\writeError.sqf";
fnc_sys_getContext = compile preprocessFileLineNumbers "functions\system\getContext.sqf";
fnc_sys_verifyContext = compile preprocessFileLineNumbers "functions\system\verifyContext.sqf";

//Server initialization
if (isServer) then
{
	private  _serverInit = compile preprocessFileLineNumbers "init\server.sqf";
	[] spawn _serverInit;	
};

//Client initialization
if ((!isDedicated)) then
{
	private  _clientInit = compile preprocessFileLineNumbers "init\client.sqf";
	[] spawn _clientInit;
};

//Disable rodents and shit
waitUntil {time > 0};
enableEnvironment false;
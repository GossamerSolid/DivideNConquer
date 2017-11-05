private _messageType = _this select 0;
private _messageText = _this select 1;
private _messageSound = if ((count _this) > 2) then {_this select 2} else {""};

switch (_messageType) do
{
	case "system":
	{	
		systemChat _messageText;
	};
	
	case "blueChat":
	{
		[DNC_CVAR_SIDE, "HQ"] sideChat _messageText;
	};
	
	case "yellowChat":
	{
		[DNC_CVAR_SIDE, "HQ"] commandChat _messageText;
	};
	
	case "notification":
	{
		//[_messageText select 0,_messageText select 1] Spawn fnc_clt_showNotification;
	};
	
	case "onscreen":
	{
		//[_messageText select 0, _messageText select 1] Spawn fnc_clt_drawScreenText;
	};
};

//Play a sound if there's one attached
if (_messageSound != "") then {playSound _messageSound};

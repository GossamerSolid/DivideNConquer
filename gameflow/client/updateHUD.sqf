while {true} do //TODO
{
	_textBuild = format["Money: $%1 ($%2)", DNC_CVAR_MONEY, DNC_CVAR_INCOME];
	_textBuild = _textBuild + format["<br/>Time to Income: %1", ([round(DNC_DATA_INCOME_RATE - (diag_tickTime - DNC_INCOME_TIME)) max 0, "MM:SS"] call BIS_fnc_secondsToString)];
	_textBuild = _textBuild + format["<br/>XP: %1", DNC_CVAR_XP];
	_textBuild = _textBuild + format["<br/>Level: %1", DNC_CVAR_LEVEL];
	_textBuild = _textBuild + format["<br/>Grunts Alive: %1", DNC_CVAR_UI_SideGruntCounts];
	
	hintSilent (parseText format["<t align='right' font='PuristaMedium' color='#FFFFFF' shadow='1'>%1</t>", _textBuild]);
	uiSleep 0.1;
};
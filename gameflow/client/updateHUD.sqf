while {true} do //TODO
{
	_textBuild = format["Money: $%1", DNC_PLAYER_MONEY];
	_textBuild = _textBuild + format["<br/>XP: %1", DNC_PLAYER_XP];
	_textBuild = _textBuild + format["<br/>Level: %1", DNC_PLAYER_LEVEL];
	
	hintSilent (parseText format["<t align='right' font='PuristaMedium' color='#FFFFFF' shadow='1'>%1</t>", _textBuild]);
	uiSleep 0.1;
};
private _contextAllowed = _this;
private _isAllowed = false;

switch (toLower(_contextAllowed)) do
{
	case "server":
	{
		if (isServer) then {_isAllowed = true};
	};
	
	case "client":
	{
		if (!isDedicated) then {_isAllowed = true};
	};
	
	default
	{
		[__FILE__, format["Unknown context provided: %1", _contextAllowed]] spawn fnc_sys_writeError;
	};
};

_isAllowed 
private _colourType = _this select 0;
private _colourReturnType = _this select 1;

private _colourClass = "Default";
private _colourReturn = nil;

if (!("client" call fnc_sys_verifyContext)) exitWith {[__FILE__, "error", "Unable to run script due to incorrect context"] spawn fnc_sys_writeError;};

switch (toLower(_colourType)) do
{
	case "sidewest";
	case "sidefriendly":
	{
		_colourClass = profileNameSpace getVariable ["DNC_ColourFriendly", "ColorBlue_Goss"];
	};
	
	case "sideeast";
	case "sideenemy":
	{
		_colourClass = profileNameSpace getVariable ["DNC_ColourEnemy", "ColorOrangeRed_Goss"];
	};
	
	case "sideresistance";
	case "sideguer";
	case "sideneutral":
	{
		_colourClass = profileNameSpace getVariable ["DNC_ColourResistance", "ColorGold_Goss"];
	};
	
	case "zonename":
	{
		_colourClass = profileNameSpace getVariable ["DNC_ColourZoneName", "ColorDimGrey_Goss"];
	}
};

switch (toLower(_colourReturnType)) do
{
	case "class":
	{
		_colourReturn = _colourClass;
	};
	
	case "rgba";
	case "rgb":
	{
		_colourReturn = getArray(configfile >> "CfgMarkerColors" >> _colourClass >> "color");		
		if (_colourReturnType == "RGB") then {_colourReturn resize 3};
	};
	
	case "hex":
	{
		_colourReturn = getText(configfile >> "CfgMarkerColors" >> _colourClass >> "colorHex");
	};
};

_colourReturn 
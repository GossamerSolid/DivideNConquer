private _objRef = _this select 0;
private _objType = _this select 1;

private _visualPos = if (surfaceIsWater (visiblePositionASL _objRef)) then {visiblePositionASL _objRef} else {getPosATLVisual _objRef};
switch (_objType) do
{
	case "inf":
	{
		switch (toLower(stance _objRef)) do
		{
			case "stand":
			{
				_visualPos set [2, (_visualPos select 2) + 1];
			};
			case "crouch":
			{
				_visualPos set [2, (_visualPos select 2) + 0.5];
			};
		};
	};

	case "veh":
	{
		_visualPos set [2, (_visualPos select 2) + 1];
	};

	case "zone":
	{
		_visualPos set [2, (_visualPos select 2) + 5];
	};
};

_visualPos
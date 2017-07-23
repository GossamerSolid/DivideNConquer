private["_icon","_distance","_icon","_iconSize","_textSize","_colourMod","_currentMarkerEntry","_visualPos"];

if (DNC_3DMarkers) then
{
	//Draw friendly markers
	{
		_currentMarkerEntry = _x;

		_distance = (getPosATL player) distance (_currentMarkerEntry select 5); //TODO - watch position
		if (((_distance <= 100) && !(_currentMarkerEntry select 8)) || (_currentMarkerEntry select 7)) then
		{
			_icon = _currentMarkerEntry select 1;
			if ((_currentMarkerEntry select 6) != "") then {_icon = _currentMarkerEntry select 6};

			_iconSize = 1;
			_textSize = 0.04;
			if (_distance > 20 && _distance <= 30) then {_iconSize = 0.9; _textSize = 0.0375};
			if (_distance > 30 && _distance <= 40) then {_iconSize = 0.8; _textSize = 0.035};
			if (_distance > 40 && _distance <= 50) then {_iconSize = 0.7; _textSize = 0.0325};
			if (_distance > 50 && _distance <= 75) then {_iconSize = 0.6; _textSize = 0.03};
			if (_distance > 75 && _distance <= 100) then {_iconSize = 0.5; _textSize = 0.0275};
			if (_distance > 100 && _distance <= 150) then {_iconSize = 0.4; _textSize = 0.0250};
			if (_distance > 150) then {_iconSize = 0.3; _textSize = 0.0200};
			
			/* TODO - work with this
			_minSize = 0.25;
			_furthestDistance = 20;
			_iconSize = linearConversion[ 0, 20, player distance2D _target, 1, _minSize, true ];
			 */

			//Modify alpha based off of client settings
			_colourMod = _currentMarkerEntry select 4;
			_colourMod set [3, 1]; //TODO Configurable

			//Visual Position (Make it look smooth)
			_visualPos = (_currentMarkerEntry select 5);

			drawIcon3D
			[
				_icon,
				_colourMod,
				_visualPos,
				_iconSize,
				_iconSize,
				0,
				(_currentMarkerEntry select 3),
				2,
				_textSize,
				"EtelkaMonospacePro"
			];
		};
	} forEach DNC_CVAR_DYN_MARKERS;
};

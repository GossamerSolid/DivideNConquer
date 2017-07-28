private _changeID = _this select 0;
private _changeType = _this select 1;
private _operation = _this select 2;
private _value = _this select 3;

//Make sure money is defined
if (!isNil "_value") then
{
	switch (toLower(_changeType)) do
	{
		case "player":
		{
			private _sessionContainer = missionNamespace getVariable(format["DNC_PROF_%1",_changeID]);
			if (!isNil "_sessionContainer") then
			{
				private _currMoney = _sessionContainer select 0;
				switch (_operation) do
				{
					case "-": {_currMoney = _currMoney - _value};
					case "+": {_currMoney = _currMoney + _value};
					case "*": {_currMoney = _currMoney * _value};
					case "/": {_currMoney = _currMoney / _value};
					case "=": {_currMoney = _value};
				};
				_currMoney = floor(_currMoney);
				
				//Can't have negative money
				if (_currMoney < 0) then {_currMoney = 0};
				
				//Update var within container
				_sessionContainer set [0, _currMoney];
				
				//Update container
				missionNamespace setVariable [format["DNC_PROF_%1",_changeID], _sessionContainer];
				
				//Update client money global
				DNC_CVAR_MONEY = _currMoney;
				private _clientID = owner(_changeID Call fnc_cmn_getObjFromUID);
				_clientID publicVariableClient "DNC_CVAR_MONEY";
				
				//Play sound on client
				[[_clientID], "sound", "playSound", "changeMoney"] spawn fnc_srv_requestClientExec;
			}
			else
			{
				//TO-DO error no container available
			};
		};
		
		case "grunt":
		{
			private _currMoney = missionNameSpace getVariable [format["%1_Money",str(_changeID)], 0];
			switch (_operation) do
			{
				case "-": {_currMoney = _currMoney - _value};
				case "+": {_currMoney = _currMoney + _value};
				case "*": {_currMoney = _currMoney * _value};
				case "/": {_currMoney = _currMoney / _value};
				case "=": {_currMoney = _value};
			};
			_currMoney = floor(_currMoney);
			
			//Can't have negative money
			if (_currMoney < 0) then {_currMoney = 0};
			
			//Update var
			missionNameSpace setVariable [format["%1_Money",str(_changeID)], _currMoney];
		};
	};
};
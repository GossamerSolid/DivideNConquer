private _scriptName = _this select 0;
private _errorType = _this select 1;
private _message = _this select 2;

diag_log text "";
if (_errorType == "error") then {diag_log text format["******** ERROR IN %1 ********", _scriptName];} else {diag_log text format["******** WARNING IN %1 ********", _scriptName];};
diag_log text format["CONTEXT: %1", [] Call fnc_sys_getContext];
diag_log text format["RUN TIME: %1", ([diag_tickTime/60/60] call BIS_fnc_timeToString)];
diag_log text format["FRAMERATE: %1 / %2", diag_fpsMin, diag_fps];
diag_log text format["DETAILS: %1", _message];
diag_log text format["*****************************", _scriptName];
diag_log text "";
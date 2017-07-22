private _context = "Unknown";

if (isServer) then {_context = "server"};
if (!isDedicated) then
{
	if (_context != "server") then
	{
		_context = "client";
	}
	else
	{
		_context = "hosted server";
	};
};

_context 
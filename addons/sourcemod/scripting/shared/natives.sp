
static GlobalForward OnWin;
static GlobalForward OnRankUp;
static GlobalForward OnRankDown;
static GlobalForward OnClientWorldmodel;


void Natives_PluginLoad()
{
	RegPluginLibrary("turbo_gungame");
	
	OnWin = new GlobalForward("TGG_OnWin", ET_Ignore, Param_Cell);
	OnRankUp = new GlobalForward("TGG_OnRankUp", ET_Ignore, Param_Cell, Param_Cell);
	OnRankDown = new GlobalForward("TGG_OnRankDown", ET_Ignore, Param_Cell, Param_Cell);
	OnClientWorldmodel = new GlobalForward("TGG_OnClientWorldmodel", ET_Event, Param_Cell, Param_Cell, Param_CellByRef, Param_CellByRef, Param_CellByRef, Param_CellByRef);
	
	CreateNative("TGG_GetPlacements", Native_GetPlacements);
}

void Native_OnWin(int client)
{
	Call_StartForward(OnWin);
	Call_PushCell(client);
	Call_Finish();
}

void Native_OnRankUp(int client, int ranks)
{
	Call_StartForward(OnRankUp);
	Call_PushCell(client);
	Call_PushCell(ranks);
	Call_Finish();
}

void Native_OnRankDown(int client, int attacker)
{
	Call_StartForward(OnRankDown);
	Call_PushCell(client);
	Call_PushCell(attacker);
	Call_Finish();
}

bool Native_OnClientWorldmodel(int client, TFClassType class, int &worldmodel, int &bodyOverride, bool &animOverride, bool &noCosmetic)
{
	Action action;

	Call_StartForward(OnClientWorldmodel);
	Call_PushCell(client);
	Call_PushCell(class);
	Call_PushCellRef(worldmodel);
	Call_PushCellRef(bodyOverride);
	Call_PushCellRef(animOverride);
	Call_PushCellRef(noCosmetic);
	Call_Finish(action);

	return action >= Plugin_Changed;
}

any Native_GetPlacements(Handle plugin, int numParams)
{
	ArrayList list = GetPlacementsArray();
	return list;
}
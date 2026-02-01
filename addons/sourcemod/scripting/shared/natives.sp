
static GlobalForward OnWin;
static GlobalForward OnClientWorldmodel;
void Natives_PluginLoad()
{
	OnWin = new GlobalForward("TGG_OnWin", ET_Ignore, Param_Cell);
	OnClientWorldmodel = new GlobalForward("TGG_OnClientWorldmodel", ET_Event, Param_Cell, Param_Cell, Param_CellByRef, Param_CellByRef, Param_CellByRef, Param_CellByRef);
}

void Native_OnWin(int client)
{
	Call_StartForward(OnWin);
	Call_PushCell(client);
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

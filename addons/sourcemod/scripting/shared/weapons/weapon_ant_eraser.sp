#pragma semicolon 1
#pragma newdecls required


static Handle Local_Timer[MAXPLAYERS] = {null, ...};
public void AntEraser_Created(int client, int weapon)
{
	if (Local_Timer[client] != null)
	{
		delete Local_Timer[client];
		Local_Timer[client] = null;
	}

	DataPack pack;
	Local_Timer[client] = CreateDataTimer(0.1, Timer_Local, pack, TIMER_REPEAT);
	pack.WriteCell(client);
	pack.WriteCell(EntIndexToEntRef(client));
	pack.WriteCell(EntIndexToEntRef(weapon));
}

static Action Timer_Local(Handle timer, DataPack pack)
{
	pack.Reset();
	int clientidx = pack.ReadCell();
	int client = EntRefToEntIndex(pack.ReadCell());
	int weapon = EntRefToEntIndex(pack.ReadCell());
	if(!IsValidClient(client) || !IsClientInGame(client) || !IsPlayerAlive(client) || !IsValidEntity(weapon))
	{
		Local_Timer[clientidx] = null;

		return Plugin_Stop;
	}	
	if (!(GetEntityFlags(client) & FL_ONGROUND))
	{
		Local_Timer[clientidx] = null;
		DataPack pack1 = new DataPack();
		pack1.WriteCell(EntIndexToEntRef(client));
		pack1.WriteCell(EntIndexToEntRef(weapon));
		RequestFrames(AntEraser_SlamDown, RoundToNearest(66.0 * 0.35), pack1);
		return Plugin_Stop;
	}
	return Plugin_Continue;
}


void AntEraser_SlamDown(DataPack pack)
{
	pack.Reset();
	int client = EntRefToEntIndex(pack.ReadCell());
	int weapon = EntRefToEntIndex(pack.ReadCell());
	if(!IsValidClient(client) || !IsClientInGame(client) || !IsPlayerAlive(client) || !IsValidEntity(weapon))
	{
		return;
	}
	if ((GetEntityFlags(client) & FL_ONGROUND))
	{
		AntEraser_Created(client, weapon);
		return;
	}
	
	float newVel[3];
	
	newVel[0] = GetEntPropFloat(client, Prop_Send, "m_vecVelocity[0]");
	newVel[1] = GetEntPropFloat(client, Prop_Send, "m_vecVelocity[1]");
	newVel[2] = -2000.0;
	TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, newVel);
	AntEraser_Created(client, weapon);
}
#pragma semicolon 1
#pragma newdecls required


static Handle Local_Timer[MAXPLAYERS] = {null, ...};
public void TheToucher_WeaponCreated(int client, int weapon)
{
	
	SDKUnhook(client, SDKHook_Touch, OnToucher_Touch);
	SDKHook(client, SDKHook_Touch, OnToucher_Touch);
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
		if(IsValidClient(client))
			SDKUnhook(client, SDKHook_Touch, OnToucher_Touch);
		return Plugin_Stop;
	}	
	return Plugin_Continue;
}

public Action OnToucher_Touch(int entity, int target)
{
	if(IsValidEnemy(entity, target))
	{
		SDKHooks_TakeDamage(target, entity, entity, 10.0, DMG_PREVENT_PHYSICS_FORCE|DMG_CRUSH, _, {0.0, 0.0, 0.0});
	}

	return Plugin_Continue;
}
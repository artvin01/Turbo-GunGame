#pragma semicolon 1
#pragma newdecls required


static Handle Local_Timer[MAXPLAYERS] = {null, ...};
public void KamikazeMapStart()
{
	PrecacheSound("mvm/mvm_tank_explode.wav");
	PrecacheSound("mvm/sentrybuster/mvm_sentrybuster_intro.wav");
}
public void KamikazteForceTaunt(int client, int weapon, bool crit, int slot)
{
	FakeClientCommand(client, "taunt");
}
public void KamikazeCreate(int client, int weapon)
{
	if (Local_Timer[client] != null)
	{
		delete Local_Timer[client];
		Local_Timer[client] = null;
	}

	EmitSoundToAll("mvm/sentrybuster/mvm_sentrybuster_intro.wav", client, SNDCHAN_STATIC, 80, _, 0.65);
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
	if (TF2_IsPlayerInCondition(client, TFCond_Taunting))
	{
		Local_Timer[clientidx] = null;
		int viewmodelModel;
		viewmodelModel = EntRefToEntIndex(i_Viewmodel_PlayerModel[client]);
		
		float flPos[3]; // original
		float flAng[3]; // original
		if(IsValidEntity(viewmodelModel))
		{
			GetAttachment(viewmodelModel, "effect_hand_r", flPos, flAng);
			int Particle = ParticleEffectAt(flPos, "raygun_projectile_red_crit", 1.0);
			SetParent(viewmodelModel, Particle, "effect_hand_r");
		}
		//1.5 seconds very accurate
		EmitGameSoundToAll ("Soldier.CritDeath", client);
		DataPack pack1 = new DataPack();
		pack1.WriteCell(EntIndexToEntRef(client));
		pack1.WriteCell(EntIndexToEntRef(weapon));
		RequestFrames(Kamikaze_ExplodeMeNow, RoundToNearest(66.0 * 1.0), pack1);
		return Plugin_Stop;
	}
	return Plugin_Continue;
}


void Kamikaze_ExplodeMeNow(DataPack pack)
{
	pack.Reset();
	int client = EntRefToEntIndex(pack.ReadCell());
	int weapon = EntRefToEntIndex(pack.ReadCell());
	if(!IsValidClient(client) || !IsClientInGame(client) || !IsPlayerAlive(client) || !IsValidEntity(weapon))
	{
		return;
	}
	if (!TF2_IsPlayerInCondition(client, TFCond_Taunting))
	{
		return;
	}
	
	static float startPosition[3];
	WorldSpaceCenter(client, startPosition);
	TF2_Explode(client, startPosition, 1000.0, 130.0, "hightower_explosion", "common/null.wav");
	EmitSoundToAll("mvm/mvm_tank_explode.wav", client, SNDCHAN_STATIC, 90, _, 0.8);
}
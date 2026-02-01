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
	CurrentClass[client] = TFClass_Soldier;
	TF2_SetPlayerClass_ZR(client, TFClass_Soldier, _, false);
	FakeClientCommand(client, "taunt");
}
public void LaughAndEraseTauntFix(int client, int weapon)
{
	RequestFrames(DelayFrame_SetFakeClass,5, GetClientUserId(client));
}

stock void DelayFrame_SetFakeClass(int userid)
{
	int client = GetClientOfUserId(userid);
	if(!IsValidEntity(client))
		return;

	CurrentClass[client] = TFClass_Heavy;
}
public void KamikazeCreate(int client, int weapon)
{
	if (Local_Timer[client] != null)
	{
		delete Local_Timer[client];
		Local_Timer[client] = null;
	}

	EmitSoundToAll("mvm/sentrybuster/mvm_sentrybuster_intro.wav", client, SNDCHAN_STATIC, 60, _, 0.65);
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
		TF2_AddCondition(client, TFCond_MegaHeal, 1.2);
		EmitGameSoundToAll ("Soldier.CritDeath", client);
		DataPack pack1 = new DataPack();
		pack1.WriteCell(EntIndexToEntRef(client));
		pack1.WriteCell(EntIndexToEntRef(weapon));
		RequestFrames(Kamikaze_ExplodeMeNow, RoundToNearest(45.0 * 1.0), pack1);
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
		KamikazeCreate(client, weapon);
		return;
	}
	
	static float startPosition[3];
	WorldSpaceCenter(client, startPosition);
	f_PreventKillCredit[client] = GetGameTime() + 0.1;
	TF2_Explode(client, startPosition, 1000.0, 200.0, "", "common/null.wav");
	TE_Particle("hightower_explosion", startPosition, NULL_VECTOR, NULL_VECTOR, -1, _, _, _, _, _, _, _, _, _, 0.0, .clientspec = client);
	TE_Particle("rd_robot_explosion", startPosition, NULL_VECTOR, NULL_VECTOR, _, _, _, _, _, _, _, _, _, _, 0.0);
	EmitSoundToAll("mvm/mvm_tank_explode.wav", 0, SNDCHAN_STATIC, 60, _, 0.5,_,_,startPosition);
}
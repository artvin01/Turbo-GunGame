#pragma semicolon 1
#pragma newdecls required

bool DoingDupstep[MAXPLAYERS] = {false, ...};
static Handle Local_Timer[MAXPLAYERS] = {null, ...};
public void DupStepGunMapStart()
{
	Zero(DoingDupstep);
	PrecacheSound("music/hl1_song10.mp3", true);
}

public void DupStepGun_Create(int client, int weapon)
{
	if (Local_Timer[client] != null)
	{
		delete Local_Timer[client];
		Local_Timer[client] = null;
	}
	if(DoingDupstep[client])
		EmitSoundToAll("music/hl1_song10.mp3", client, SNDCHAN_STATIC, 80, SND_STOP, 1.0);
	DoingDupstep[client] = false;
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
		if(IsValidClient(client))
		{
			EmitSoundToAll("music/hl1_song10.mp3", client, SNDCHAN_STATIC, 80, SND_STOP, 1.0);
		}
		Local_Timer[clientidx] = null;

		return Plugin_Stop;
	}	

	bool Mouse1 = (GetClientButtons(client) & IN_ATTACK) != 0;
	if(Mouse1)
	{
		char particle[32];
		if(GetRandomInt(0,1))
		{
			Format(particle, sizeof(particle), "%s", "raygun_projectile_red_crit");
		}
		else
		{
			Format(particle, sizeof(particle), "%s", "raygun_projectile_blue_crit");
		}
		float fAng[3];
		GetClientEyeAngles(client, fAng);
		fAng[0] += GetRandomFloat(-3.0,3.0);
		fAng[1] += GetRandomFloat(-3.0,3.0);
	//	Client_Shake(client, 0, 5.0, 3.0, 0.15);

		int projectile = Wand_Projectile_Spawn(client, 2000.0, 10.0, 25.0, 0, weapon, particle, fAng);
		WandProjectile_ApplyFunctionToEntity(projectile, Want_DefaultWandTouch);
		if(!DoingDupstep[client])
		{
			EmitSoundToAll("music/hl1_song10.mp3", client, SNDCHAN_STATIC, 80, _, 1.0, .soundtime = GetGameTime() - 26.0);
			DoingDupstep[client] = true;
		}
	}
	else
	{
		if(DoingDupstep[client])
		{
			EmitSoundToAll("music/hl1_song10.mp3", client, SNDCHAN_STATIC, 80, SND_STOP, 1.0);
			DoingDupstep[client] = false;
		}
	}
	return Plugin_Continue;
}

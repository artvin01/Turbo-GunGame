#pragma semicolon 1
#pragma newdecls required


/*
	//to use EntityFuncTakeDamage, copypaste this on take damage, the wepaon will be your wepaon ez gg
	//make your own file like all other weapons.

*/
public void SharedTakeDamage_Mapstart()
{
	PrecacheSound("items/powerup_pickup_knockout_melee_hit.wav");
}
public Action AntiGravityGrenade_TakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Attributes_Set(victim, Attrib_MultiplyFallDamage, 100.0);
	CreateTimer(0.35, Timer_SlamVictimDown, EntIndexToEntRef(victim), TIMER_FLAG_NO_MAPCHANGE);
	TeleportEntity(victim, NULL_VECTOR, NULL_VECTOR, {0.0,0.0, 1000.0});
	return Plugin_Continue;
}

public Action Timer_SlamVictimDown(Handle timer, any entid)
{
	int victim = EntRefToEntIndex(entid);
	if(!IsEntityAlive(victim))
		return Plugin_Stop;

	TeleportEntity(victim, NULL_VECTOR, NULL_VECTOR, {0.0,0.0, -2000.0});
	return Plugin_Stop;
}


public Action ImpactLance_TakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	DataPack pack = new DataPack();
	pack.WriteCell(EntIndexToEntRef(attacker));
	pack.WriteCellArray(damagePosition, 3);
	RequestFrame(ImpactLance_TakeDamageFrame, pack);
	return Plugin_Continue;
}
void ImpactLance_TakeDamageFrame(DataPack pack)
{
	pack.Reset();
	int attacker = EntRefToEntIndex(pack.ReadCell());
	float damagePosition[3];
	pack.ReadCellArray(damagePosition, 3);
	if(IsValidClient(attacker))
	{
		TF2_Explode(attacker, damagePosition, 100.0, 120.0, "ExplosionCore_MidAir", "weapons/airstrike_small_explosion_01.wav");
	}
	delete pack;
}


static Handle SpartaTimer[MAXPLAYERS] = {null, ...};
static int WhoSpartaredMe[MAXPLAYERS] = {0, ...};

public Action ThisIsSparta_FuncTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	if(victim > MaxClients)
	{
		damage *= 100.0;
		return Plugin_Continue;
	}
	EmitAmbientSound("items/powerup_pickup_knockout_melee_hit.wav", damagePosition, _, 90, _,0.7, 100);
	TE_Particle("mvm_soldier_shockwave", damagePosition, NULL_VECTOR, NULL_VECTOR, -1, _, _, _, _, _, _, _, _, _, 0.0);
	WhoSpartaredMe[victim] = EntIndexToEntRef(attacker);
	if (SpartaTimer[victim] != null)
	{
		delete SpartaTimer[victim];
		SpartaTimer[victim] = null;
	}
	SDKUnhook(victim, SDKHook_Touch, ThisIsSparta_Touch);
	SDKHook(victim, SDKHook_Touch, ThisIsSparta_Touch);
	DataPack pack;
	SpartaTimer[victim] = CreateDataTimer(0.1, Timer_SpartaKicked, pack, TIMER_REPEAT);
	pack.WriteCell(victim);
	pack.WriteCell(EntIndexToEntRef(victim));
	return Plugin_Continue;
}

static Action Timer_SpartaKicked(Handle timer, DataPack pack)
{
	pack.Reset();
	int clientidx = pack.ReadCell();
	int client = EntRefToEntIndex(pack.ReadCell());
	if(!IsValidClient(client) || !IsClientInGame(client) || !IsPlayerAlive(client))
	{
		SpartaTimer[clientidx] = null;
		if(IsValidClient(client))
			SDKUnhook(client, SDKHook_Touch, ThisIsSparta_Touch);
		return Plugin_Stop;
	}	
	return Plugin_Continue;
}


public Action ThisIsSparta_Touch(int entity, int target)
{
	int Attacker = EntRefToEntIndex(WhoSpartaredMe[entity]);
	if(IsValidEnemy(Attacker, target))
	{
		SDKHooks_TakeDamage(target, Attacker, Attacker, 3000.0, DMG_ALWAYSGIB|DMG_BLAST, _, {0.0, 0.0, 0.0});
		SDKHooks_TakeDamage(entity, Attacker, Attacker, 3000.0, DMG_ALWAYSGIB|DMG_BLAST, _, {0.0, 0.0, 0.0});
	}
	if(target == 0)
	{
		SDKHooks_TakeDamage(entity, Attacker, Attacker, 3000.0, DMG_ALWAYSGIB|DMG_BLAST, _, {0.0, 0.0, 0.0});
	}

	return Plugin_Continue;
}


public Action TheFish_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	float fAng[3];
	GetClientEyeAngles(victim, fAng);
	fAng[1] += 180.0;
	SnapEyeAngles(victim, fAng);
	return Plugin_Continue;
}
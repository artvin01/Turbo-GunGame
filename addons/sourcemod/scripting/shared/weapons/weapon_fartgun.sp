#pragma semicolon 1
#pragma newdecls required

static char g_Boowomp[][] = {
	"player/taunt_gas_blast.wav",
};
void FartGun_Precache()
{
	PrecacheSoundArray(g_Boowomp);
	PrecacheModel("models/props_spytech/tv001.mdl");
}

public void Weapon_FartGun(int client, int weapon, bool crit)
{
	float damage = 65.0;
	damage *= Attributes_Get(weapon, 2, 1.0);
	
	int projectile = Wand_Projectile_Spawn(client, 1200.0, 0.22, damage, 0, weapon, "pumpkin_cloud");
	WandProjectile_ApplyFunctionToEntity(projectile, FartShotTouch);
	EmitSoundToAll(g_Boowomp[GetRandomInt(0, sizeof(g_Boowomp) - 1)], client, SNDCHAN_STATIC, 80, _, 1.0, 70, .soundtime = GetGameTime() - (4.75 * (1.0 / 0.7)));
}


public void FartShotTouch(int entity, int target)
{
	if (target > 0)	
	{
		//Code to do damage position and ragdolls
		static float angles[3];
		GetEntPropVector(entity, Prop_Send, "m_angRotation", angles);
		float vecForward[3];
		GetAngleVectors(angles, vecForward, NULL_VECTOR, NULL_VECTOR);
		static float Entity_Position[3];
		WorldSpaceCenter(target, Entity_Position);

		int owner = EntRefToEntIndex(i_WandOwner[entity]);

		float Dmg_Force[3]; CalculateDamageForce(vecForward, 10000.0, Dmg_Force);
		if(target <= MaxClients)
		{
			TF2_MakeBleed(target, owner, 3.0);
			TF2_StunPlayer(target, 2.0, 0.1, TF_STUNFLAG_SLOWDOWN);
		}
	}
}
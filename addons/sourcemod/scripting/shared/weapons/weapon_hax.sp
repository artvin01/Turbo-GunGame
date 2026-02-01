#pragma semicolon 1
#pragma newdecls required

static char g_HaxWeapon[][] = {
	"vo/npc/male01/hacks01.wav",
};
void Hax_Precache()
{
	PrecacheSoundArray(g_HaxWeapon);
	PrecacheModel("models/props_spytech/tv001.mdl");
}

public void Weapon_HaxShoot(int client, int weapon, bool crit)
{
	float damage = 65.0;
	damage *= Attributes_Get(weapon, 2, 1.0);
	
	//This spawns the projectile, this is a return int, if you want, you can do extra stuff with it, otherwise, it can be used as a void.
	int projectile = Wand_Projectile_Spawn(client, 1500.0, 10.0, damage, 0, weapon, "");
	WandProjectile_ApplyFunctionToEntity(projectile, HaxShotTouch);
	ApplyCustomModelToWandProjectile(projectile, "models/props_spytech/tv001.mdl", 0.85, "scythe_spin");
	EmitSoundToAll(g_HaxWeapon[GetRandomInt(0, sizeof(g_HaxWeapon) - 1)], projectile, SNDCHAN_STATIC, 80, _, 1.0, 100);
}

public void HaxShotTouch(int entity, int target)
{
	int particle = EntRefToEntIndex(i_WandParticle[entity]);
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
		int weapon = EntRefToEntIndex(i_WandWeapon[entity]);

		float Dmg_Force[3]; CalculateDamageForce(vecForward, 10000.0, Dmg_Force);
		SDKHooks_TakeDamage(target, owner, owner, f_WandDamage[entity], DMG_PLASMA, weapon, Dmg_Force, Entity_Position);	// 2048 is DMG_NOGIB?
		EmitSoundToAll(g_HaxWeapon[GetRandomInt(0, sizeof(g_HaxWeapon) - 1)], entity, SNDCHAN_STATIC, 80, SND_STOP, 1.0, 100);
		if(IsValidEntity(particle))
		{
			RemoveEntity(particle);
		}
		RemoveEntity(entity);
	}
	else if(target == 0)
	{
		EmitSoundToAll(g_HaxWeapon[GetRandomInt(0, sizeof(g_HaxWeapon) - 1)], entity, SNDCHAN_STATIC, 80, SND_STOP, 1.0, 100);
		if(IsValidEntity(particle))
		{
			RemoveEntity(particle);
		}
		RemoveEntity(entity);
	}
}
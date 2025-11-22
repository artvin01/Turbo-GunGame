#pragma semicolon 1
#pragma newdecls required

static char g_MooSound[][] = {
	"ambient_mp3/cow1.mp3",
};
void CowMangler_Precache()
{
	PrecacheSoundArray(g_MooSound);
	PrecacheModel("models/props_2fort/cow001_reference.mdl");
}

public void Weapon_CowManglerShoot(int client, int weapon, bool crit)
{
	float damage = 65.0;
	damage *= Attributes_Get(weapon, 2, 1.0);
	
	//This spawns the projectile, this is a return int, if you want, you can do extra stuff with it, otherwise, it can be used as a void.
	int projectile = Wand_Projectile_Spawn(client, 1500.0, 10.0, damage, 0, weapon, "");
	WandProjectile_ApplyFunctionToEntity(projectile, CowShotTouch);
	EmitSoundToAll(g_MooSound[GetRandomInt(0, sizeof(g_MooSound) - 1)], projectile, SNDCHAN_STATIC, 80, _, 1.0, 120, .soundtime = GetGameTime() - 0.5);
	EmitSoundToAll(g_MooSound[GetRandomInt(0, sizeof(g_MooSound) - 1)], projectile, SNDCHAN_STATIC, 80, _, 1.0, 120, .soundtime = GetGameTime() - 0.5);
	EmitSoundToAll(g_MooSound[GetRandomInt(0, sizeof(g_MooSound) - 1)], projectile, SNDCHAN_STATIC, 80, _, 1.0, 120, .soundtime = GetGameTime() - 0.5);
	ApplyCustomModelToWandProjectile(projectile, "models/props_2fort/cow001_reference.mdl", 0.5, "scythe_spin");
}

public void CowShotTouch(int entity, int target)
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
		if(IsValidEntity(particle))
		{
			RemoveEntity(particle);
		}
		RemoveEntity(entity);
	}
	else if(target == 0)
	{
		if(IsValidEntity(particle))
		{
			RemoveEntity(particle);
		}
		RemoveEntity(entity);
	}
}
#pragma semicolon 1
#pragma newdecls required


#define WAND_FIREBALL_SOUND "misc/halloween/spell_fireball_cast.wav"
#define SOUND_FIREBALL_EXPLODE		"misc/halloween/spell_fireball_impact.wav"
public void Spell_MapStart()
{
	PrecacheSound(WAND_FIREBALL_SOUND);
	PrecacheSound(SOUND_FIREBALL_EXPLODE);
}
public void Spell_Fire(int client, int weapon, bool crit)
{
	float damage = 65.0;
	damage *= Attributes_Get(weapon, 2, 1.0);
	int projectile = Wand_Projectile_Spawn(client, 1000.0, 10.0, damage, 0, weapon, "spell_fireball_small_red");
	WandProjectile_ApplyFunctionToEntity(projectile, Fireball_Explode);
	EmitSoundToAll(WAND_FIREBALL_SOUND, client, SNDCHAN_AUTO, 80, _, 0.5);
}



public void Fireball_Explode(int entity, int target)
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
		GetAbsOrigin(entity, Entity_Position);

		int owner = EntRefToEntIndex(i_WandOwner[entity]);

		float Dmg_Force[3]; CalculateDamageForce(vecForward, 10000.0, Dmg_Force);
		TF2_Explode(owner, Entity_Position, f_WandDamage[entity], 90.0, "spell_fireball_tendril_parent_red", SOUND_FIREBALL_EXPLODE);
		if(IsValidEntity(particle))
		{
			RemoveEntity(particle);
		}
		RemoveEntity(entity);
	}
	else if(target == 0)
	{
		int owner = EntRefToEntIndex(i_WandOwner[entity]);
		static float Entity_Position[3];
		GetAbsOrigin(entity, Entity_Position);
		TF2_Explode(owner, Entity_Position, f_WandDamage[entity], 90.0, "spell_fireball_tendril_parent_red", SOUND_FIREBALL_EXPLODE);
		if(IsValidEntity(particle))
		{
			RemoveEntity(particle);
		}
		RemoveEntity(entity);
	}
}
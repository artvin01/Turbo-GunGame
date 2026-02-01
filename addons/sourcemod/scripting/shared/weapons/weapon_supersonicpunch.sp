#pragma semicolon 1
#pragma newdecls required

static char g_SonicPunch[][] = {
	"weapons/gauss/fire1.wav",
};

static int LaserIndex;
void SuperSonic_Precache()
{
	PrecacheSoundArray(g_SonicPunch);
	LaserIndex = PrecacheModel("materials/sprites/laserbeam.vmt");
}
public void Weapon_SuperSonicPunch(int client, int weapon, bool crit)
{
	static float Entity_Position[3];
	WorldSpaceCenter(client, Entity_Position);
	EmitAmbientSound(g_SonicPunch[GetRandomInt(0, sizeof(g_SonicPunch) - 1)], Entity_Position, _, 90, _,0.7, 100);
	TE_Particle("mvm_soldier_shockwave", Entity_Position, NULL_VECTOR, NULL_VECTOR, -1, _, _, _, _, _, _, _, _, _, 0.0);
}
public Action Weapon_SonicPunchHit(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	int color[4];
	color[0] = 240;
	color[1] = 240;
	color[2] = 0;
	color[3] = 120;

	static float attackerpos[3];
	WorldSpaceCenter(attacker, attackerpos);
	static float victimpos[3];
	WorldSpaceCenter(victim, victimpos);
	TE_SetupBeamPoints(attackerpos, victimpos, LaserIndex, 0, 0, 0, 0.25, 2.5, 2.5, 1, 4.0, color, 0);
	TE_SendToAll();
	TE_Particle("mvm_soldier_shockwave", victimpos, NULL_VECTOR, NULL_VECTOR, -1, _, _, _, _, _, _, _, _, _, 0.0);
	EmitAmbientSound("items/powerup_pickup_knockout_melee_hit.wav", victimpos, _, 80, _,0.6, 100);
	return Plugin_Continue;
}

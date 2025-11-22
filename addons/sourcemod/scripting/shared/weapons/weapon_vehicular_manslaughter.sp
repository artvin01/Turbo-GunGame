#pragma semicolon 1
#pragma newdecls required

static char g_strKartSounds[][] = {
	")weapons/bumper_car_accelerate.wav",
	")weapons/bumper_car_decelerate.wav",
	")weapons/bumper_car_decelerate_quick.wav",
	")weapons/bumper_car_go_loop.wav",
	")weapons/bumper_car_hit_ball.wav",
	")weapons/bumper_car_hit_ghost.wav",
	")weapons/bumper_car_hit_hard.wav",
	")weapons/bumper_car_hit_into_air.wav",
	"weapons/bumper_car_hit1.wav",
	"weapons/bumper_car_hit2.wav",
	"weapons/bumper_car_hit3.wav",
	"weapons/bumper_car_hit4.wav",
	"weapons/bumper_car_hit5.wav",
	"weapons/bumper_car_hit6.wav",
	"weapons/bumper_car_hit7.wav",
	"weapons/bumper_car_hit8.wav",
	")weapons/bumper_car_jump.wav",
	")weapons/bumper_car_jump_land.wav",
	")weapons/bumper_car_screech.wav",
	")weapons/bumper_car_spawn.wav",
	")weapons/bumper_car_spawn_from_lava.wav",
	")weapons/bumper_car_speed_boost_start.wav",
	")weapons/bumper_car_speed_boost_stop.wav"
};

public void VehicularManslaughter_WeaponCreated(int client, int weapon)
{
	SDKUnhook(client, SDKHook_StartTouchPost, VehicularManslaughter_StartTouchPost);
	SDKHook(client, SDKHook_StartTouchPost, VehicularManslaughter_StartTouchPost);
	
	TF2_AddCondition(client, TFCond_HalloweenKart);
}

public void VehicularManslaughter_WeaponRemoved(int client, int weapon)
{
	SDKUnhook(client, SDKHook_StartTouchPost, VehicularManslaughter_StartTouchPost);
	TF2_RemoveCondition(client, TFCond_HalloweenKart);
	TF2_RemoveCondition(client, TFCond_HalloweenKartDash);
}

public void VehicularManslaughter_Precache()
{
	for (int i = 0; i < sizeof(g_strKartSounds); i++)
		PrecacheSound(g_strKartSounds[i]);
}

void VehicularManslaughter_StartTouchPost(int client, int other)
{
	// We can't bump teammates, so we run them over instead
	if (!IsValidClient(other) || TF2_GetClientTeam(client) != TF2_GetClientTeam(other))
		return;
	
	if (!TF2_IsPlayerInCondition(client, TFCond_HalloweenKart))
	{
		SDKUnhook(client, SDKHook_StartTouchPost, VehicularManslaughter_StartTouchPost);
		return;
	}
	
	// Kart dash sets your speed to 1000.0, 333 dmg at max speed vs ~285 from bumping enemies, but no knockback
	float damage = GetClientSpeed(client) * 0.33;
	SDKHooks_TakeDamage(other, client, client, damage, DMG_PREVENT_PHYSICS_FORCE, _, {0.0, 0.0, 0.0});
}
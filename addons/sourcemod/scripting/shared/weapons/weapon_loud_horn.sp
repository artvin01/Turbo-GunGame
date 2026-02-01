#pragma semicolon 1
#pragma newdecls required

float HornCooldown[MAXPLAYERS] = {0.0, ...};
static Handle Local_Timer[MAXPLAYERS] = {null, ...};
static char g_HornSound[][] = {
	"weapons/buff_banner_horn_red.wav",
	"weapons/buff_banner_horn_blue.wav",
};
public void LoudHornMapStart()
{
	PrecacheSoundArray(g_HornSound);
	PrecacheSound("ambient/atmosphere/terrain_rumble1.wav");
	Zero(HornCooldown);
}

public void LoudHorn_Create(int client, int weapon)
{
	if (Local_Timer[client] != null)
	{
		delete Local_Timer[client];
		Local_Timer[client] = null;
	}
	HornCooldown[client] = 0.0;
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

	bool Mouse1 = (GetClientButtons(client) & IN_ATTACK) != 0;
	if(Mouse1)
	{
		if(HornCooldown[client] < GetGameTime())
		{
			HornCooldown[client] = GetGameTime() + 1.5;
			
			static float startPosition[3];
			WorldSpaceCenter(client, startPosition);
			startPosition[2] -= 20.0;
			TF2_Explode(client, startPosition, 100.0, 150.0, "", "common/null.wav");
			EmitSoundToAll(g_HornSound[GetRandomInt(0, sizeof(g_HornSound) - 1)], client, SNDCHAN_STATIC, 80, _, 0.65, 110);
			ParticleEffectAt(startPosition, "hammer_impact_button", 1.0);
			EmitSoundToAll("ambient/atmosphere/terrain_rumble1.wav", client, SNDCHAN_STATIC, 80, SND_STOP, 0.9);
			EmitSoundToAll("ambient/atmosphere/terrain_rumble1.wav", client, SNDCHAN_STATIC, 80, _, 0.9);
			CreateEarthquake(startPosition, 0.75, 350.0, 16.0, 255.0);
		}
	}
	return Plugin_Continue;
}

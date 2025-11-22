#pragma semicolon 1
#pragma newdecls required


public void SkullcutterCritGive(int client, int weapon, bool crit, int slot)
{
	TF2_AddCondition(client, TFCond_CritCanteen, 1.0);
}
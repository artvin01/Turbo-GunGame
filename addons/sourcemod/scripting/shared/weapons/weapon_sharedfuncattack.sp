#pragma semicolon 1
#pragma newdecls required


public void SkullcutterCritGive(int client, int weapon, bool crit, int slot)
{
	TF2_AddCondition(client, TFCond_CritCanteen, 1.0);
}

public void GiveShieldCharge(int client, int weapon, bool crit, int slot)
{
	int wearable = GiveWearable(client, 406, true);
	Attributes_Set(wearable, 249, 5.0);
	Attributes_Set(wearable, 248, 20.0);
	Attributes_Set(wearable, 246, 0.0);
}

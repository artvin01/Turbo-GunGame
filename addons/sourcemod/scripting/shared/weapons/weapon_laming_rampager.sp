#pragma semicolon 1
#pragma newdecls required


static Handle Revert_Weapon_Back_Timer[MAXPLAYERS]={null, ...};
static int attacks_mode[MAXPLAYERS]={12, ...};
static int weapon_id[MAXPLAYERS]={12, ...};
void LamingRampager_Precache()
{

}
public void Weapon_LamingRampager_Create(int client, int weapon)
{
	weapon_id[client] = EntIndexToEntRef(weapon);
	attacks_mode[client] = 1;
	if(Revert_Weapon_Back_Timer[client] != null)
		delete Revert_Weapon_Back_Timer[client];
	Attributes_Set(weapon, 396, PurgingRampagerAttackSpeed(attacks_mode[client]));

}
public void Weapon_LamingRampager_Attack(int client, int weapon, bool crit)
{
	weapon_id[client] = EntIndexToEntRef(weapon);
	attacks_mode[client] += 1;
			
	if (attacks_mode[client] >= 25)
	{
		PrintCenterText(client, "Overheating, let it cooldown!!!");
		attacks_mode[client] = 25;
	}

	Attributes_Set(weapon, 396, PurgingRampagerAttackSpeed(attacks_mode[client]));
	if(Revert_Weapon_Back_Timer[client] != null)
		delete Revert_Weapon_Back_Timer[client];
	Revert_Weapon_Back_Timer[client] = CreateTimer(2.0, Reset_weapon_purging_rampager, client);
}

public float PurgingRampagerAttackSpeed(int number)
{
	switch(number)
	{	
		case 1,2:
		{
			return 0.2;
		} 
		case 3,4:
		{
			return 0.25;
		} 
		case 5,6:
		{
			return 0.35;
		}
		case 7,8:
		{
			return 0.4;
		} 
		case 9,10:
		{
			return 0.5;
		} 
		case 11,12:
		{
			return 0.6;
		} 
		case 13,14:
		{
			return 0.7;
		} 
		case 15,16:
		{
			return 0.8;
		} 
		case 17,18:
		{
			return 1.2;
		} 
		case 19,20:
		{
			return 1.4;
		} 
		case 21,22:
		{
			return 1.6;
		} 
		case 23,24:
		{
			return 1.7;
		} 
		default:
		{
			return 2.0;
		} 
	}
}

public Action Reset_weapon_purging_rampager(Handle cut_timer, int client)
{
	if(IsValidClient(client))
	{
		attacks_mode[client] = 1;
		if(IsValidEntity(EntRefToEntIndex(weapon_id[client])))
		{
			PrintCenterText(client, "");
			Attributes_Set((EntRefToEntIndex(weapon_id[client])), 396, PurgingRampagerAttackSpeed(attacks_mode[client]));
			ClientCommand(client, "playgamesound items/medshotno1.wav");
		}
	}
	Revert_Weapon_Back_Timer[client] = null;
	return Plugin_Handled;
}
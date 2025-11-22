#pragma semicolon 1
#pragma newdecls required


float delay_hud[MAXPLAYERS];
void SDKHooks_ClearAll()
{

}

Handle SyncHud_GunGame;
void SDKHook_PluginStart()
{
	SyncHud_GunGame = CreateHudSynchronizer();
	HookUserMessage(GetUserMessageId("PlayerJarated"), OnPlayerJarated);
}


void SDKHook_MapStart()
{
	Zero(delay_hud);
}


stock void SDKHook_HookClient(int client)
{
	SDKUnhook(client, SDKHook_PostThink, OnPostThink);
	SDKHook(client, SDKHook_PostThink, OnPostThink);
	SDKUnhook(client, SDKHook_WeaponSwitchPost, OnWeaponSwitchPost);
	SDKHook(client, SDKHook_WeaponSwitchPost, OnWeaponSwitchPost);
	SDKUnhook(client, SDKHook_TraceAttack, Player_TraceAttack);
	SDKHook(client, SDKHook_TraceAttack, Player_TraceAttack);
	SDKUnhook(client, SDKHook_OnTakeDamage, Player_OnTakeDamage);
	SDKHook(client, SDKHook_OnTakeDamage, Player_OnTakeDamage);
}

public void OnPostThink(int client)
{
	float GameTime = GetGameTime();

	if(delay_hud[client] < GameTime)	
	{
		delay_hud[client] = GameTime + 0.4;
		
		// Don't show HUD text if the round is won, we're switching maps, etc
		if (GameRules_GetRoundState() >= RoundState_TeamWin)
			return;
		
		char buffer[255];
		float HudY = 0.8;
		float HudX = -1.0;
		SetHudTextParams(HudX, HudY, 0.81, 255, 165, 0, 255);
		Format(buffer, sizeof(buffer), "(%i/%i)\n[%s]", ClientAtWhatScore[client] + 1, Cvar_GGR_WeaponsTillWin.IntValue, c_WeaponName[client]);
		
		bool ShowNextWeapon = true;
		if(ClientAtWhatScore[client] + 1 >= Cvar_GGR_WeaponsTillWin.IntValue)
			ShowNextWeapon = false;

		if (!CanClientGetAssistCredit(client))
		{
			StrCat(buffer, sizeof(buffer), "\nYou're on the final rank and cannot rank up through assists!");
		}
		else if (ClientAssistsThisLevel[client] > 0)
		{
			StrCat(buffer, sizeof(buffer), "\nYou'll rank up on the next assist!");
		}
		else
		{
			StrCat(buffer, sizeof(buffer), "\n");
		}
		
		if(ShowNextWeapon && WeaponListRound)
		{
			StrCat(buffer, sizeof(buffer), "\nNEXT:");
			WeaponInfo Weplist;
			WeaponListRound.GetArray(ClientAtWhatScore[client] + 1, Weplist);
			ItemInfo info;
			WeaponList.GetArray(Weplist.InternalWeaponID, info);
			
			Format(buffer, sizeof(buffer), "%s\n[%s]", buffer, info.WeaponName);
		}
		
		ShowSyncHudText(client, SyncHud_GunGame, "%s", buffer);
	}
}


public void OnWeaponSwitchPost(int client, int weapon)
{
	RequestFrame(OnWeaponSwitchFrame, GetClientUserId(client));
}

public void OnWeaponSwitchFrame(int userid)
{
	int client = GetClientOfUserId(userid);
	if(client)
	{
		ViewChange_Update(client, false);
		// We delay ViewChange_Switch by a frame so it doesn't mess with the regenerate process
	}
}


float f_TraceAttackWasTriggeredSameFrame[MAXENTITIES];

public Action Player_TraceAttack(int victim, int& attacker, int& inflictor, float& damage, int& damagetype, int& ammotype, int hitbox, int hitgroup)
{
//	PrintToChatAll("ow NPC_TraceAttack");
	if(attacker < 1 || attacker > MaxClients || victim == attacker)
		return Plugin_Continue;
		
	if(inflictor < 1 || inflictor > MaxClients)
		return Plugin_Continue;
		
	if(!IsValidEnemy(attacker, victim))
		return Plugin_Continue;
	i_HasBeenHeadShotted[victim] = false;
	
	int weapon = GetEntPropEnt(attacker, Prop_Send, "m_hActiveWeapon");
	if(!IsValidEntity(weapon))
		return Plugin_Continue;
	bool WasAlreadyPlayed = false;
	if(f_TraceAttackWasTriggeredSameFrame[victim] == GetGameTime())
	{
		WasAlreadyPlayed = true;
	}
	f_TraceAttackWasTriggeredSameFrame[victim] = GetGameTime();



	if(hitgroup == HITGROUP_HEAD)
	{
		i_HasBeenHeadShotted[victim] = true;
		//incase it has headshot multi
		damage *= Attributes_Get(weapon, Attrib_HeadshotBonus, 1.0);

		damage *= 1.5;
		
		int pitch = GetRandomInt(90, 110);
		int random_case = GetRandomInt(1, 2);
		float volume = 0.7;
	
		if(!WasAlreadyPlayed)
		{
			DisplayCritAboveNpc(victim, attacker, false);
		}
		switch(random_case)
		{
			case 1:
			{
				for(int client=1; client<=MaxClients; client++)
				{
					if(IsClientInGame(client) && client != attacker)
					{
						EmitSoundToClient(client, "zombiesurvival/headshot1.wav", victim, _, 80, _, volume, pitch);
					}
				}
				EmitSoundToClient(attacker, "zombiesurvival/headshot1.wav", _, _, 90, _, volume, pitch);
			}
			case 2:
			{
				for(int client=1; client<=MaxClients; client++)
				{
					if(IsClientInGame(client) && client != attacker)
					{
						EmitSoundToClient(client, "zombiesurvival/headshot2.wav", victim, _, 80, _, volume, pitch);
					}
				}
				EmitSoundToClient(attacker, "zombiesurvival/headshot2.wav", _, _, 90, _, volume, pitch);
			}
		}
	}
	return Plugin_Changed;
}

/*
	//to use EntityFuncTakeDamage, copypaste this on take damage, the wepaon will be your wepaon ez gg
	//make your own file like all other weapons.

*/
public Action Player_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	if(weapon != -1)
	{
		Function func = EntityFuncTakeDamage[weapon];
		if(func && func!=INVALID_FUNCTION)
		{
			Call_StartFunction(null, func);
			Call_PushCell(victim);
			Call_PushCellRef(attacker);
			Call_PushCellRef(inflictor);
			Call_PushFloatRef(damage);
			Call_PushCellRef(damagetype);
			Call_PushCellRef(weapon);
			Call_PushArray(damageForce, sizeof(damageForce));
			Call_PushArray(damagePosition, sizeof(damagePosition));
			Call_PushCell(damagecustom);
			Call_Finish();
		}
	}

	i_WeaponKilledWith[victim] = weapon;
	if(damagetype & DMG_FALL)
	{
		damage *= Attributes_Get(victim, Attrib_MultiplyFallDamage, 1.0);
	}
	if (damagecustom == TF_CUSTOM_KART)
	{
		damage *= 3.0;
	}
	
	return Plugin_Changed;
}

static Action OnPlayerJarated(UserMsg msg_id, BfRead bf, const int[] players, int playersNum, bool reliable, bool init)
{
	int attacker = bf.ReadByte();
	int victim = bf.ReadByte();

	int weapon = GetPlayerWeaponSlot(attacker, TFWeaponSlot_Secondary);
	if(weapon != -1)
	{
		Function func = EntityFuncJarate[weapon];
		if(func && func!=INVALID_FUNCTION)
		{
			Call_StartFunction(null, func);
			Call_PushCell(attacker);
			Call_PushCell(weapon);
			Call_PushCell(victim);
			Call_Finish();
		}
	}

	return Plugin_Continue;
}
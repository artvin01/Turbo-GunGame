#pragma semicolon 1
#pragma newdecls required

enum struct RawHooks
{
	int Ref;
	int Pre;
	int Post;
}



void DHook_Setup()
{
	GameData gamedata = LoadGameConfigFile("zombie_riot");
	
	if (!gamedata) 
	{
		SetFailState("Failed to load gamedata (zombie_riot).");
	} 
	
	DHook_CreateDetour(gamedata, "CTFPlayer::CanAirDash", DHook_CanAirDashPre);
	DHook_CreateDetour(gamedata, "CTFPlayer::CanAirDash", DHook_CanAirDashPre);
	DHook_CreateDetour(gamedata, "CTFPlayer::RegenThink", DHook_RegenThinkPre, DHook_RegenThinkPost);
	DHook_CreateDetour(gamedata, "CTFPlayer::ManageRegularWeapons()", DHook_ManageRegularWeaponsPre, DHook_ManageRegularWeaponsPost);
	DHook_CreateDetour(gamedata, "CTFPlayer::SpeakConceptIfAllowed()", SpeakConceptIfAllowed_Pre, SpeakConceptIfAllowed_Post);
	DHook_CreateDetour(gamedata, "CTFGameRules::CalcPlayerScore", Detour_CalcPlayerScore);

	HookItemIterateAttribute = DynamicHook.FromConf(gamedata, "CEconItemView::IterateAttributes");
	m_Item = FindSendPropInfo("CEconEntity", "m_Item");
	FindSendPropInfo("CEconEntity", "m_bOnlyIterateItemViewAttributes", _, _, m_bOnlyIterateItemViewAttributes);
}

stock DynamicHook DHook_CreateVirtual(GameData gamedata, const char[] name)
{
	DynamicHook hook = DynamicHook.FromConf(gamedata, name);
	if (!hook)
		LogError("Failed to create virtual: %s", name);
	
	return hook;
}
public MRESReturn DHook_ManageRegularWeaponsPre(int client, DHookParam param)
{
	if(!CurrentClass[client])
	{
		CurrentClass[client] = TFClass_Scout;
	}
	TF2_SetPlayerClass_ZR(client, CurrentClass[client]);
	return MRES_Ignored;
}
public MRESReturn DHook_ManageRegularWeaponsPost(int client, DHookParam param)
{
//	IsInsideManageRegularWeapons = false;
	return MRES_Ignored;
}
bool WasMedicPreRegen[MAXPLAYERS];

public MRESReturn DHook_RegenThinkPre(int client, DHookParam param)
{
	if(TF2_GetPlayerClass(client) == TFClass_Medic)
	{
		WasMedicPreRegen[client] = true;
		TF2_SetPlayerClass_ZR(client, TFClass_Scout, false, false);
	}
	else
	{
		WasMedicPreRegen[client] = false;
	}

	return MRES_Ignored;
}

public MRESReturn DHook_RegenThinkPost(int client, DHookParam param)
{
	if(WasMedicPreRegen[client])
		TF2_SetPlayerClass_ZR(client, TFClass_Medic, false, false);
		
	WasMedicPreRegen[client] = false;
	return MRES_Ignored;
}

public MRESReturn DHook_CanAirDashPre(int client, DHookReturn ret)
{
	ret.Value = false;
	return MRES_Supercede;
}




MRESReturn Detour_CalcPlayerScore(DHookReturn hReturn, DHookParam hParams)
{
	//make strange point gain not possible
	hReturn.Value = 0;
	return MRES_Supercede;
}

void DHook_EntityDestoryed()
{
	RequestFrame(DHook_EntityDestoryedFrame);
}

public void DHook_EntityDestoryedFrame()
{
	if(RawEntityHooks)
	{
		int length = RawEntityHooks.Length;
		if(length)
		{
			RawHooks raw;
			for(int i; i < length; i++)
			{
				RawEntityHooks.GetArray(i, raw);
				if(!IsValidEntity(raw.Ref))
				{
					if(raw.Pre != INVALID_HOOK_ID)
						DynamicHook.RemoveHook(raw.Pre);
					
					if(raw.Post != INVALID_HOOK_ID)
						DynamicHook.RemoveHook(raw.Post);
					
					RawEntityHooks.Erase(i--);
					length--;
				}
			}
		}
	}
}


stock Handle CheckedDHookCreateFromConf(Handle game_config, const char[] name) {
    Handle res = DHookCreateFromConf(game_config, name);

    if (res == INVALID_HANDLE) {
        SetFailState("Failed to create detour for %s", name);
    }

    return res;
}

public Action CH_ShouldCollide(int ent1, int ent2, bool &result)
{
	if(!(ent1 >= 0 && ent1 <= MAXENTITIES && ent2 >= 0 && ent2 <= MAXENTITIES))
		return Plugin_Continue;

	result = PassfilterGlobal(ent1, ent2, true);
	if(!result)
	{
		return Plugin_Handled;
	}
	return Plugin_Continue;

}
public Action CH_PassFilter(int ent1, int ent2, bool &result)
{
	if(!(ent1 >= 0 && ent1 <= MAXENTITIES && ent2 >= 0 && ent2 <= MAXENTITIES))
		return Plugin_Continue;

	result = PassfilterGlobal(ent1, ent2, true);
	if(!result)
	{
		return Plugin_Handled;
	}
	return Plugin_Continue;

}
stock void DHook_HookStripWeapon(int entity)
{
	if(m_Item > 0 && m_bOnlyIterateItemViewAttributes > 0)
	{
		if(!RawEntityHooks)
			RawEntityHooks = new ArrayList(sizeof(RawHooks));
		
		Address pCEconItemView = GetEntityAddress(entity) + view_as<Address>(m_Item);
		
		RawHooks raw;
		
		raw.Ref = EntIndexToEntRef(entity);
		raw.Pre = HookItemIterateAttribute.HookRaw(Hook_Pre, pCEconItemView, DHook_IterateAttributesPre);
		raw.Post = HookItemIterateAttribute.HookRaw(Hook_Post, pCEconItemView, DHook_IterateAttributesPost);
		
		RawEntityHooks.PushArray(raw);
	}
}

public MRESReturn DHook_IterateAttributesPre(Address pThis, DHookParam hParams)
{
	StoreToAddress(pThis + view_as<Address>(m_bOnlyIterateItemViewAttributes), true, NumberType_Int8);
	return MRES_Ignored;
}

public MRESReturn DHook_IterateAttributesPost(Address pThis, DHookParam hParams)
{
	StoreToAddress(pThis + view_as<Address>(m_bOnlyIterateItemViewAttributes), false, NumberType_Int8);
	return MRES_Ignored;
}



public MRESReturn SpeakConceptIfAllowed_Pre(int client, DHookReturn returnHook, DHookParam param)
{
	/*
	for(int client_2=1; client_2<=MaxClients; client_2++)
	{
		if(IsClientInGame(client_2))
		{
			if(!CurrentClass[client_2])
			{
				CurrentClass[client_2] = TFClass_Scout;
			}
			TF2_SetPlayerClass_ZR(client_2, CurrentClass[client_2], false, false);
		}
	}
	*/
	return MRES_Ignored;
}
public MRESReturn SpeakConceptIfAllowed_Post(int client, Handle hReturn, Handle hParams)
{
	/*
	for(int client_2=1; client_2<=MaxClients; client_2++)
	{
		if(IsClientInGame(client_2))
		{
			if(GetEntProp(client_2, Prop_Send, "m_iHealth") > 0)
			{
				if(!WeaponClass[client_2])
				{
					WeaponClass[client_2] = TFClass_Scout;
				}
				TF2_SetPlayerClass_ZR(client_2, WeaponClass[client_2], false, false);
			}
		}
	}
	*/
	return MRES_Ignored;
}



public bool PassfilterGlobal(int ent1, int ent2, bool result)
{
	for( int ent = 1; ent <= 2; ent++ ) 
	{
		static int entity1;
		static int entity2; 	
		if(ent == 1)
		{
			entity1 = ent1;
			entity2 = ent2;
		}
		else
		{
			entity1 = ent2;
			entity2 = ent1;			
		}
		if(b_IsAProjectile[entity1])
		{
			if(b_IsAProjectile[entity2])
			{
				return false;
			}
			if(!ValidTargetToHit[entity2])
			{
				if(entity2 > MaxClients)
					return false;
			}
			if(entity2 == GetEntPropEnt(entity1, Prop_Send, "m_hOwnerEntity"))
			{
				return false;
			}
		}
	}
	return result;	
}
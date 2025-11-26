#pragma semicolon 1
#pragma newdecls required

#define VIEW_CHANGES

static const char HandModels[][] =
{
	"models/weapons/c_models/c_engineer_gunslinger.mdl",
	"models/weapons/c_models/c_scout_arms.mdl",
	"models/weapons/c_models/c_sniper_arms.mdl",
	"models/zombie_riot/weapons/soldier_hands/c_soldier_arms.mdl", //needed custom model due to rocket in face.
	"models/weapons/c_models/c_demo_arms.mdl",
	"models/weapons/c_models/c_medic_arms.mdl",
	"models/weapons/c_models/c_heavy_arms.mdl",
	"models/weapons/c_models/c_pyro_arms.mdl",
	"models/weapons/c_models/c_spy_arms.mdl",
	"models/weapons/c_models/c_engineer_arms.mdl"
};

static int HandIndex[10];
static bool b_AntiSameFrameUpdate[MAXPLAYERS];

void ViewChange_MapStart()
{
	for(int i; i<sizeof(HandIndex); i++)
	{
		HandIndex[i] = PrecacheModel(HandModels[i], true);
	}
	Zero(b_AntiSameFrameUpdate);


	int entity = -1;
	while((entity=FindEntityByClassname(entity, "tf_wearable_vm")) != -1)
	{
		RemoveEntity(entity);
	}
}

void ViewChange_ClientDisconnect(int client)
{
	int entity = EntRefToEntIndex(WeaponRef_viewmodel[client]);
	if(entity != -1)
	{
		WeaponRef_viewmodel[client] = -1;
		RemoveEntity(entity);
	}
	
	entity = EntRefToEntIndex(i_Worldmodel_WeaponModel[client]);
	if(entity != -1)
	{
		i_Worldmodel_WeaponModel[client] = -1;
		TF2_RemoveWearable(client, entity);
	}

	ViewChange_DeleteHands(client);
}

void Viewchange_UpdateDelay(int client)
{
	RequestFrame(Viewchange_UpdateDelay_Internal, EntIndexToEntRef(client));
}

void Viewchange_UpdateDelay_Internal(int ref)
{
	int client = EntRefToEntIndex(ref);
	if(IsValidClient(client))
		return;

	ViewChange_Update(client);
}
void ViewChange_Update(int client, bool full = true)
{
	if(full)
		ViewChange_DeleteHands(client);
	

	//Some weapons or things call it in the same frame, lets prevent this!
	//If people somehow spam switch, or multiple things call it, lets wait a frame before updating, it allows for easy use iwthout breaking everything
	if(b_AntiSameFrameUpdate[client])
		return;
		
	RequestFrame(AntiSameFrameUpdateRemove0, client);

	b_AntiSameFrameUpdate[client] = true;
	char classname[36];
	int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	if(weapon != -1)
	{
		GetEntityClassname(weapon, classname, sizeof(classname));
	}
	
	ViewChange_Switch(client, weapon, classname);
}
public void AntiSameFrameUpdateRemove0(int client)
{
	b_AntiSameFrameUpdate[client] = false;
}

stock bool ViewChange_IsViewmodelRef(int ref)
{
	for(int client = 1; client <= MaxClients; client++)
	{
		if(WeaponRef_viewmodel[client] == ref)
			return true;
		
		if(i_Worldmodel_WeaponModel[client] == ref)
			return true;
		
		if(HandRef[client] == ref)
			return true;
	}

	return false;
}

void ViewChange_Switch(int client, int active, const char[] classname)
{
	int entity = EntRefToEntIndex(WeaponRef_viewmodel[client]);
	if(entity != -1)
	{
		WeaponRef_viewmodel[client] = -1;
		RemoveEntity(entity);
	}
	
	entity = EntRefToEntIndex(i_Worldmodel_WeaponModel[client]);
	if(entity != -1)
	{
		i_Worldmodel_WeaponModel[client] = -1;
		TF2_RemoveWearable(client, entity);
	}
	entity = GetEntPropEnt(client, Prop_Send, "m_hViewModel");
	if(entity != -1)
	{
		if(active != -1)
		{	
			SetEntProp(entity, Prop_Send, "m_nModelIndex", HandIndex[CurrentClass[client]]);
			
			int team = GetClientTeam(client);


			SetTeam(entity, team);
			SetEntProp(entity, Prop_Send, "m_nSkin", team-2);
			int model = GetEntProp(active, Prop_Send, "m_iWorldModelIndex");
			
			entity = CreateViewmodel(client, model, i_WeaponModelIndexOverride[active] > 0 ? i_WeaponModelIndexOverride[active] : model, active, true);
			if(entity != -1)	// Weapon viewmodel
			{
				WeaponRef_viewmodel[client] = EntIndexToEntRef(entity);
				if(i_WeaponVMTExtraSetting[active] != -1)
				{
					i_WeaponVMTExtraSetting[entity] = i_WeaponVMTExtraSetting[active];
					SetEntityRenderColor(entity, 255, 255, 255, i_WeaponVMTExtraSetting[active]);
				}
				if(i_WeaponBodygroup[active] != -1)
				{
					SetVariantInt(i_WeaponBodygroup[active]);
					AcceptEntityInput(entity, "SetBodyGroup");
				}
			}

			entity = CreateEntityByName("tf_wearable");
			if(entity != -1)	// Weapon worldmodel
			{
				if(i_WeaponModelIndexOverride[active] > 0)
					SetEntProp(entity, Prop_Send, "m_nModelIndex", i_WeaponModelIndexOverride[active]);
				else
					SetEntProp(entity, Prop_Send, "m_nModelIndex", GetEntProp(active, Prop_Send, "m_iWorldModelIndex"));
					
				if(i_WeaponVMTExtraSetting[active] != -1)
				{
					i_WeaponVMTExtraSetting[entity] = i_WeaponVMTExtraSetting[active];
					SetEntityRenderColor(entity, 255, 255, 255, i_WeaponVMTExtraSetting[active]);
				}
				if(i_WeaponBodygroup[active] != -1)
				{
					SetVariantInt(i_WeaponBodygroup[active]);
					AcceptEntityInput(entity, "SetBodyGroup");
				}

				ImportSkinAttribs(entity, active);

				SetEntProp(entity, Prop_Send, "m_fEffects", 129);

				SetTeam(entity, team);
				SetEntProp(entity, Prop_Send, "m_nSkin", team-2);
				SetEntProp(entity, Prop_Send, "m_usSolidFlags", 4);
				SetEntityCollisionGroup(entity, 11);
				SetEntProp(entity, Prop_Send, "m_bValidatedAttachedEntity", 1);
				
				DispatchSpawn(entity);
				SetVariantString("!activator");
				ActivateEntity(entity);

				i_Worldmodel_WeaponModel[client] = EntIndexToEntRef(entity);
				
				SDKCall_EquipWearable(client, entity);
				DataPack pack = new DataPack();
				pack.WriteCell(EntIndexToEntRef(active));
				pack.WriteCell(EntIndexToEntRef(entity));
				//needs to be delayed...
				RequestFrame(AdjustWeaponFrameDelay, pack);
			}
			
			HidePlayerWeaponModel(client, active);
			
			//ViewChange_DeleteHands(client);
			ViewChange_UpdateHands(client, CurrentClass[client]);

			int iMaxWeapons = GetMaxWeapons(client);
			for (int i = 0; i < iMaxWeapons; i++)
			{
				int weapon = GetEntPropEnt(client, Prop_Send, "m_hMyWeapons", i);
				if (weapon != INVALID_ENT_REFERENCE)
					SetEntProp(weapon, Prop_Send, "m_nCustomViewmodelModelIndex", GetEntProp(weapon, Prop_Send, "m_nModelIndex"));
			}
			return;
		}
	}

	ViewChange_DeleteHands(client);
}

void AdjustWeaponFrameDelay(DataPack pack)
{
	pack.Reset();
	int weapon = EntRefToEntIndex(pack.ReadCell());
	int wearable = EntRefToEntIndex(pack.ReadCell());
	if(IsValidEntity(weapon) && IsValidEntity(wearable))
	{
		float AttribDo = Attributes_Get(weapon, 4021, -1.0);
		if(AttribDo != -1.0)
		{
			SetEntProp(wearable, Prop_Send, "m_nSkin", RoundToNearest(AttribDo));
		}
		AttribDo = Attributes_Get(weapon, 542, -1.0);
		if(AttribDo != -1.0)
		{
			Attributes_Set(wearable, 542, AttribDo);
		}
	}
	delete pack;
}

void ViewChange_DeleteHands(int client)
{
	int entity = EntRefToEntIndex(HandRef[client]);
	HandRef[client] = INVALID_ENT_REFERENCE;

	if(entity != -1)
		RemoveEntity(entity);
}

int ViewChange_UpdateHands(int client, TFClassType class)
{
	int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	int entity = EntRefToEntIndex(HandRef[client]);
	if(entity != -1)
	{
		SetEntPropEnt(entity, Prop_Send, "m_hWeaponAssociatedWith", weapon);
	}
	else
	{
		int model = HandIndex[view_as<int>(class)];
		
		entity = CreateViewmodel(client, model, model, weapon);
		
		if(entity != -1)
			HandRef[client] = EntIndexToEntRef(entity);
	}
	return entity;
}

stock bool Viewchanges_NotAWearable(int client, int wearable)
{
	if(EntRefToEntIndex(HandRef[client]) == wearable)
		return true;
	if(EntRefToEntIndex(WeaponRef_viewmodel[client]) == wearable)
		return true;
	if(EntRefToEntIndex(i_Worldmodel_WeaponModel[client]) == wearable)
		return true;

	return false;
}

static int CreateViewmodel(int client, int modelAnims, int modelOverride, int weapon, bool copy = false)
{
	int wearable = CreateEntityByName("tf_wearable_vm");
	
	float vecOrigin[3], vecAngles[3];
	GetEntPropVector(client, Prop_Send, "m_vecOrigin", vecOrigin);
	GetEntPropVector(client, Prop_Send, "m_angRotation", vecAngles);
	TeleportEntity(wearable, vecOrigin, vecAngles, NULL_VECTOR);

	if(copy)
		ImportSkinAttribs(wearable, weapon);
	
	SetEntProp(wearable, Prop_Send, "m_bValidatedAttachedEntity", true);
	SetEntPropEnt(wearable, Prop_Send, "m_hOwnerEntity", client);
	SetEntProp(wearable, Prop_Send, "m_iTeamNum", GetClientTeam(client));
	SetEntProp(wearable, Prop_Send, "m_fEffects", EF_BONEMERGE|EF_BONEMERGE_FASTCULL);
	
	DispatchSpawn(wearable);
	
	SetEntProp(wearable, Prop_Send, "m_nModelIndex", modelAnims);	// After DispatchSpawn, otherwise CEconItemView overrides it
	/*
	char buffer[256];
	ModelIndexToString(modelAnims, buffer, sizeof(buffer));
	PrintToChatAll("Anims: '%s'", buffer);
	ModelIndexToString(modelOverride, buffer, sizeof(buffer));
	PrintToChatAll("Override: '%s'", buffer);
*/
	SetEntProp(wearable, Prop_Data, "m_nModelIndexOverrides", modelOverride);

	SetVariantString("!activator");
	AcceptEntityInput(wearable, "SetParent", GetEntPropEnt(client, Prop_Send, "m_hViewModel"));

	SetEntPropEnt(wearable, Prop_Send, "m_hWeaponAssociatedWith", weapon);
	
	return wearable;
}

static void ImportSkinAttribs(int wearable, int weapon)
{
	int index = GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex");
	SetEntProp(wearable, Prop_Send, "m_iItemDefinitionIndex", index);
	SetEntProp(wearable, Prop_Send, "m_bOnlyIterateItemViewAttributes", true);
	Attributes_Set(wearable, 834, Attributes_Get(weapon, 834, 0.0));
	Attributes_Set(wearable, 725, Attributes_Get(weapon, 725, 0.0));

	Attributes_Set(wearable, 866, GetURandomFloat());

	Attributes_Set(wearable, 867, float(index));//Attributes_Get(weapon, 867, 0.0));
	Attributes_Set(wearable, 2013, Attributes_Get(weapon, 2013, 0.0));
	Attributes_Set(wearable, 2014, Attributes_Get(weapon, 2014, 0.0));
	Attributes_Set(wearable, 2025, Attributes_Get(weapon, 2025, 0.0));
	Attributes_Set(wearable, 2027, Attributes_Get(weapon, 2027, 0.0));
	Attributes_Set(wearable, 2053, Attributes_Get(weapon, 2053, 0.0));
}

void HidePlayerWeaponModel(int client, int entity, bool OnlyHide = false)
{
	SetEntityRenderMode(entity, RENDER_NONE);
//	SetEntityRenderColor(entity, 0, 0, 0, 0);
//	SetEntProp(entity, Prop_Send, "m_bBeingRepurposedForTaunt", 1);
	SetEntPropFloat(entity, Prop_Send, "m_flModelScale", 0.001);
//	SetEntProp(entity, Prop_Send, "m_fEffects", GetEntProp(entity, Prop_Send, "m_fEffects") | EF_NODRAW);
	SetEntPropFloat(entity, Prop_Send, "m_fadeMinDist", 0.0);
	SetEntPropFloat(entity, Prop_Send, "m_fadeMaxDist", 0.00001);
	
	if(StoreWeapon[entity] >= 0)
	{
		ItemInfo info;
		WeaponList.GetArray(StoreWeapon[entity], info);
		Format(c_WeaponName[client],sizeof(c_WeaponName[]),"%s",info.WeaponName);	
	}
	if(OnlyHide)
		return;
	int EntityWeaponModel = EntRefToEntIndex(i_Worldmodel_WeaponModel[client]);
	if(IsValidEntity(EntityWeaponModel))
	{
		SetEntPropFloat(EntityWeaponModel, Prop_Send, "m_flModelScale", f_WeaponSizeOverride[entity]);
	}
	EntityWeaponModel = EntRefToEntIndex(WeaponRef_viewmodel[client]);
	if(IsValidEntity(EntityWeaponModel))
	{
		SetEntPropFloat(EntityWeaponModel, Prop_Send, "m_flModelScale", f_WeaponSizeOverrideViewmodel[entity]);
	}
}

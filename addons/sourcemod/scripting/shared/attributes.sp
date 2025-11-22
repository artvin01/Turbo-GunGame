#pragma semicolon 1
#pragma newdecls required

//4007 4008 4009 40010 Melee, Ranged, all damage taken while active | Apply Stats only while active (rpg)
enum
{
	Attrib_PapNumber = 122,
	Attrib_MaxEnemiesHitExplode = 4011,
	Attrib_ReducedGibHealing = 4012,
	Attrib_ExplosionFalloff = 4013,
	Attrib_ConsumeReserveAmmo = 4014,
	Attrib_NeverAttack = 4015, //If set to 1, sets the weapons next attack to FAR_FUTURE, as doing 821 ; 1 ; 128 ; 1 breaks animations.
	Attrib_BonusRaidDamage = 4016,
	Attrib_AttackspeedConvertIntoDmg = 4017,
	Attrib_ClaimCadesAlways = 4018,
	Attrib_MaxManaAdd = 4019,
	Attrib_ManaRegen = 4020, 
	Attrib_OverrideWeaponSkin = 4021, // Override Weapon Skin To This
	Attrib_TerrianRes = 4022,
	Attrib_ElementalDef = 4023,
	Attrib_SlowImmune = 4024,
	Attrib_ObjTerrianAbsorb = 4025,
	Attrib_SetArchetype = 4026,
	Attrib_SetSecondaryDelayInf = 4027, // Set secondary weapon delay to FAR_FUTURE
	Attrib_FormRes = 4028,
	Attrib_OverrideExplodeDmgRadiusFalloff = 4029,
	Attrib_CritChance = 4030,
	// 4031
	// 4032
	Attrib_ReviveTimeCut = 4033,
	Attrib_ExtendExtraCashGain = 4034,
	Attrib_ReduceMedifluidCost = 4035,
	Attrib_ReduceMetalCost = 4036,
	Attrib_BarracksHealth = 4037,
	Attrib_BarracksDamage = 4038,
	Attrib_BlessingBuff = 4039,
	Attrib_ArmorOnHit = 4040,
	Attrib_ArmorOnHitMax = 4041,
	Attrib_Melee_UseBuilderDamage = 4042,
	Attrib_HeadshotBonus = 4043,
	Attrib_ReviveSpeedBonus = 4044,
	Attrib_BuildingOnly_PreventUpgrade = 4045, 
	//used for anti abuse.
	//specifically so you cant repair buildings for low cost and re-upgrade them.

	Attrib_BuildingStatus_PreventAbuse = 4046, 
	//used for anti abuse.
	//specifally so you cant make ranged units lategame and sell all other units and just keep those alive forever.

	Attrib_Weapon_MaxDmgMulti = 4047, 
	Attrib_Weapon_MinDmgMulti = 4048, 
	//used currently for heavy particle rifle
	//but will probably be used for other weapons to define max/min dmg depending on whatever the weapon specific plugin does with it.
	Attrib_ElementalDefPerc = 4049,

	Attrib_BarracksSupplyRate = 4050,
	Attrib_FinalBuilder = 4051,
	Attrib_GlassBuilder = 4052,
	Attrib_WildingenBuilder = 4053,
	Attrib_TauntRangeValue = 4054,
	Attrib_DamageTakenFromRaid = 4055,
	Attrib_RegenHpOutOfBattle_MaxHealthScaling = 4056,
	Attrib_DerankOnly = 4057,
	Attrib_MultiplyFallDamage = 4058,
}

StringMap WeaponAttributes[MAXENTITIES + 1];

bool Attribute_ServerSide(int attribute)
{
	if(attribute > 3999)
		return true;
	/*
	switch(attribute)
	{
		
		//Various attributes that are not needed as actual attributes.
		
		case 526,733, 309, 777, 701, 805, 180, 830, 785, 405, 527, 319, 286,287 , 95 , 93,8, 734:
		{
			return true;
		}

		case 57, 190, 191, 218, 366, 651,33,731,719,544,410,786,3002,3000,149,208,638,17,71,868,122,225, 224:
		{
			return true;
		}
	}
	*/
	return false;
}

bool Attribute_IntAttribute(int attribute)
{
	switch(attribute)
	{
		case 314, 834, 866, 867, Attrib_BarracksSupplyRate, Attrib_FinalBuilder, Attrib_GlassBuilder, Attrib_WildingenBuilder:
			return true;
	}

	return false;
}

bool Attribute_DontSaveAsIntAttribute(int attribute)
{
	switch(attribute)
	{
		//this attrib is a float, but saves as an int, for stuff thats additional, not multi.
		case 314, 142:
			return true;
	}

	return false;
}

/*
	There are attributes that are used only for ZR that dont actually exist
	there are described here:
	4001: Extra melee range
	4002: Medigun overheal
	4007: Melee resisance while equipped in hand
	4008: Ranged resistance while equipped in hand
	4009: total damage reduced while in hand
	4010: RPG ONLY!!! Stats to use while in hand only such as STR or END or DEX
	4011: Explosive weapon limit on hit if its not on default, default is 10 (hits only 10 enemies.), you can reduce it to 2 for example, if your explosive weapon has tiny AOE
	733: Magic shot cost
	410: Magic damage % 

	most of these are via %, 1.0 means just 100% normal, 0.5 means half, 1.5 means 50% more
*/
void Attributes_EntityDestroyed(int entity)
{
	delete WeaponAttributes[entity];
}

stock bool Attributes_RemoveAll(int entity)
{
	delete WeaponAttributes[entity];
	return TF2Attrib_RemoveAll(entity);
}

int ReplaceAttribute_Internally(int attribute)
{
	switch(attribute)
	{
		//replace dmg attrib with another, this is due to the MVM hud on pressing inspect fucking crashing you at high dmges
		case 2:
			return 1000;
	}
	return attribute;
}
stock bool Attributes_Has(int entity, int attrib)
{
	attrib = ReplaceAttribute_Internally(attrib);
	if(!WeaponAttributes[entity])
		return false;
	
	char buffer[6];
	IntToString(attrib, buffer, sizeof(buffer));
	return WeaponAttributes[entity].ContainsKey(buffer);
}

float Attributes_Get(int entity, int attrib, float defaul = 1.0)
{
	attrib = ReplaceAttribute_Internally(attrib);
	if(WeaponAttributes[entity])
	{
		float value = defaul;

		char buffer[6];
		IntToString(attrib, buffer, sizeof(buffer));
		if(WeaponAttributes[entity].GetValue(buffer, value))
			return value;
	}
	
	return defaul;
}

bool Attributes_Set(int entity, int attrib, float value, bool DoOnlyTf2Side = false)
{
	attrib = ReplaceAttribute_Internally(attrib);
	if(!DoOnlyTf2Side)
	{
		if(!WeaponAttributes[entity])
			WeaponAttributes[entity] = new StringMap();
		
		char buffer[6];
		IntToString(attrib, buffer, sizeof(buffer));
		WeaponAttributes[entity].SetValue(buffer, value);

		if(Attribute_ServerSide(attrib))
			return false;
	}
	
	if(Attribute_IntAttribute(attrib) && !Attribute_DontSaveAsIntAttribute(attrib))
	{
		TF2Attrib_SetByDefIndex(entity, attrib, view_as<float>(RoundFloat(value)));
		return true;
	}
	
	
	TF2Attrib_SetByDefIndex(entity, attrib, value);
	return true;
}

stock void Attributes_SetAdd(int entity, int attrib, float amount)
{
	attrib = ReplaceAttribute_Internally(attrib);

	char buffer[6];
	IntToString(attrib, buffer, sizeof(buffer));

	float value = 0.0;

	if(WeaponAttributes[entity])
	{
		WeaponAttributes[entity].GetValue(buffer, value);
	}
	else
	{
		WeaponAttributes[entity] = new StringMap();
	}

	value += amount;

	WeaponAttributes[entity].SetValue(buffer, value);
	if(!Attribute_ServerSide(attrib))
		Attributes_Set(entity, attrib, value, true);
}

stock void Attributes_SetMulti(int entity, int attrib, float amount)
{
	attrib = ReplaceAttribute_Internally(attrib);
	char buffer[6];
	IntToString(attrib, buffer, sizeof(buffer));

	float value = 1.0;

	if(WeaponAttributes[entity])
	{
		WeaponAttributes[entity].GetValue(buffer, value);
	}
	else
	{
		WeaponAttributes[entity] = new StringMap();
	}

	value *= amount;

	WeaponAttributes[entity].SetValue(buffer, value);
	if(!Attribute_ServerSide(attrib))
		Attributes_Set(entity, attrib, value, true);

	if(Attribute_IsMovementSpeed(attrib))
	{
		int owner;
		if(entity <= MaxClients)
			owner = entity;
		else
			owner = GetEntPropEnt(owner, Prop_Send, "m_hOwnerEntity");
		if(owner > 0 && owner <= MaxClients)
		{
			SDKCall_SetSpeed(owner);
		}
	}
}

bool Attribute_IsMovementSpeed(int attrib)
{
	switch(attrib)
	{
		case 442, 107, 54:
		{
			return true;
		}
	}

	return false;
}

stock bool Attributes_GetString(int entity, int attrib, char[] value, int length, int &size = 0)
{
	if(!WeaponAttributes[entity])
		return false;

	attrib = ReplaceAttribute_Internally(attrib);
	char buffer[6];
	IntToString(attrib, buffer, sizeof(buffer));
	return WeaponAttributes[entity].GetString(buffer, value, length, size);
}

stock void Attributes_SetString(int entity, int attrib, const char[] value)
{
	if(!WeaponAttributes[entity])
		WeaponAttributes[entity] = new StringMap();
	
	attrib = ReplaceAttribute_Internally(attrib);
	
	char buffer[6];
	IntToString(attrib, buffer, sizeof(buffer));
	WeaponAttributes[entity].SetString(buffer, value);
}


//override default
stock float Attributes_GetOnPlayer(int client, int index, bool multi = true, bool noWeapons = false, float defaultValue = -1.0)
{
	bool AttribWasFound = false;
	float defaul = multi ? 1.0 : 0.0;

	float TempFind = Attributes_Get(client, index, -1.0);
	float result;
	if(TempFind != -1.0)
	{
		AttribWasFound = true;
		result = TempFind;
	}
	else
	{
		result = defaul;
	}
	
	int entity = MaxClients + 1;
	
	if(!noWeapons)
	{
		int active = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");

		int i;
		while(TF2_GetItem(client, entity, i))
		{
			if(index != 128 && active != entity)
			{
				if(Attributes_Get(entity, 128, 0.0))
					continue;
			}
			
			float value = Attributes_Get(entity, index, defaul);
			if(value != defaul)
			{
				AttribWasFound = true;
				if(multi)
				{
					result *= value;
				}
				else
				{
					result += value;
				}
			}
		}
	}
	if(!AttribWasFound)
	{
		if(defaultValue == -1.0)
		{
			return defaul;
		}
		else
		{
			return defaultValue;
		}
	}
	return result;
}

stock float Attributes_GetOnWeapon(int client, int entity, int index, bool multi = true, float defaultstat = -1.0)
{
	float defaul = multi ? 1.0 : 0.0;
	if(defaultstat != -1.0)
	{	
		defaul = defaultstat;
	}
	float result = Attributes_Get(client, index, defaul);
	
	if(entity > MaxClients)
	{
		float value = Attributes_Get(entity, index, defaul);
		if(value != defaul)
		{
			if(multi)
			{
				result *= value;
			}
			else
			{
				result += value;
			}
		}
	}
	
	return result;
}

/*
#define MULTIDMG_NONE 		 ( 1<<0 )
#define MULTIDMG_MAGIC_WAND  ( 1<<1 )
#define MULTIDMG_BLEED 		 ( 1<<2 )
#define MULTIDMG_BUILDER 	 ( 1<<3 )
*/
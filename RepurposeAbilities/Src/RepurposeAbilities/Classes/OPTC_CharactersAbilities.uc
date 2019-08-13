class OPTC_CharactersAbilities extends X2DownloadableContentInfo config(RepurposeAbilities);

struct native CharacterAbilitiesNames
{
	var Name TemplateName;
	var bool RemoveOriginal;
	var array<Name> AddAbilityName;
	var array<Name> RemoveAbilityName;
};

var config array<CharacterAbilitiesNames> Abilities;

static event OnPostTemplatesCreated()
{
	local X2CharacterTemplateManager CharacterMgr;
	local X2ItemTemplateManager ItemMgr;
	local array<X2DataTemplate> TemplateAllDifficulties;
	local X2DataTemplate Template;

	local X2CharacterTemplate CharacterTemplate;
	local X2WeaponTemplate WeaponTemplate;
	local X2ArmorTemplate ArmorTemplate;
	local X2EquipmentTemplate ItemTemplate;
	
	local CharacterAbilitiesNames CharacterConfig;
	local Name AbilityName;

	`LOG("Repurpose Abilities loaded");

	CharacterMgr = class'X2CharacterTemplateManager'.static.GetCharacterTemplateManager();
	ItemMgr = class'X2ItemTemplateManager'.static.GetItemTemplateManager();

	foreach default.Abilities(CharacterConfig)
	{
		// Character Abilities
		CharacterMgr.FindDataTemplateAllDifficulties(CharacterConfig.TemplateName, TemplateAllDifficulties);

		foreach TemplateAllDifficulties(Template)
		{
			CharacterTemplate = X2CharacterTemplate(Template);

			if (CharacterTemplate != none)
			{
				if(CharacterConfig.RemoveOriginal)
				{
					CharacterTemplate.Abilities.length = 0;
					`LOG("Repurpose Abilities : Removed previous abilities from" @ CharacterConfig.TemplateName);
				}

				foreach CharacterConfig.AddAbilityName(AbilityName)
				{
					CharacterTemplate.Abilities.AddItem(AbilityName);
					`LOG("Repurpose Abilities : Added" @ AbilityName @ "to CharacterTemplate" @ CharacterConfig.TemplateName);
				}

				foreach CharacterConfig.RemoveAbilityName(AbilityName)
				{
					CharacterTemplate.Abilities.RemoveItem(AbilityName);
					`LOG("Repurpose Abilities : Removed" @ AbilityName @ "from CharacterTemplate" @ CharacterConfig.TemplateName);
				}
			}
		}

		ItemMgr.FindDataTemplateAllDifficulties(CharacterConfig.TemplateName, TemplateAllDifficulties);

		foreach TemplateAllDifficulties(Template)
		{
			
			/* !! WeaponsTemplate and ArmorTemplate are EquipmentTemplate !!
			// Weapon Abilities
			WeaponTemplate = X2WeaponTemplate(Template);

			if (WeaponTemplate != none)
			{
				if(CharacterConfig.RemoveOriginal)
				{
					WeaponTemplate.Abilities.length = 0;
					`LOG("Repurpose Abilities : Removed previous abilities from" @ CharacterConfig.TemplateName);
				}

				foreach CharacterConfig.AddAbilityName(AbilityName)
				{
					WeaponTemplate.Abilities.AddItem(AbilityName);
					`LOG("Repurpose Abilities : Added" @ AbilityName @ "to WeaponTemplate" @ CharacterConfig.TemplateName);
				}

				foreach CharacterConfig.RemoveAbilityName(AbilityName)
				{
					WeaponTemplate.Abilities.RemoveItem(AbilityName);
					`LOG("Repurpose Abilities : Removed" @ AbilityName @ "from WeaponTemplate" @ CharacterConfig.TemplateName);
				}
			}

			// Armor Abilities
			ArmorTemplate = X2ArmorTemplate(Template);

			if (ArmorTemplate != none)
			{
				if(CharacterConfig.RemoveOriginal)
				{
					ArmorTemplate.Abilities.length = 0;
					`LOG("Repurpose Abilities : Removed previous abilities from" @ CharacterConfig.TemplateName);
				}

				foreach CharacterConfig.AddAbilityName(AbilityName)
				{
					ArmorTemplate.Abilities.AddItem(AbilityName);
					`LOG("Repurpose Abilities : Added" @ AbilityName @ "to ArmorTemplate" @ CharacterConfig.TemplateName);
				}

				foreach CharacterConfig.RemoveAbilityName(AbilityName)
				{
					ArmorTemplate.Abilities.RemoveItem(AbilityName);
					`LOG("Repurpose Abilities : Removed" @ AbilityName @ "from ArmorTemplate" @ CharacterConfig.TemplateName);
				}
			}
			*/
			// Equipment Abilities
			ItemTemplate = X2EquipmentTemplate(Template);

			if (ItemTemplate != none)
			{
				if(CharacterConfig.RemoveOriginal)
				{
					ItemTemplate.Abilities.length = 0;
					`LOG("Repurpose Abilities : Removed previous abilities from" @ CharacterConfig.TemplateName);
				}

				foreach CharacterConfig.AddAbilityName(AbilityName)
				{
					ItemTemplate.Abilities.AddItem(AbilityName);
					`LOG("Repurpose Abilities : Added" @ AbilityName @ "to EquipmentTemplate" @ CharacterConfig.TemplateName);
				}

				foreach CharacterConfig.RemoveAbilityName(AbilityName)
				{
					ItemTemplate.Abilities.RemoveItem(AbilityName);
					`LOG("Repurpose Abilities : Removed" @ AbilityName @ "from EquipmentTemplate" @ CharacterConfig.TemplateName);
				}
			}
		}

	}
}


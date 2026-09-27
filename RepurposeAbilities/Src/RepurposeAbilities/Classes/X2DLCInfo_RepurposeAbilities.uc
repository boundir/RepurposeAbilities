class X2DLCInfo_RepurposeAbilities extends X2DownloadableContentInfo;

struct AbilityAttachment
{
	var array<name> Characters;
	var array<name> Equipments;
	var array<name> Abilities;
};

struct AbilityLink
{
	var name AbilityName;
	var array<AbilityAttachment> AddTo;
	var array<AbilityAttachment> RemoveFrom;
};

var config(RepurposeAbilities) array<AbilityLink> RepurposeAbility;
var config(Engine) bool EnableTrace;
var config(Engine) bool EnableDebug;

delegate RepurposeAbilityDelegate(X2DataTemplate Template, name RepurposeAbilityName, bool ShouldLog);

static private function X2DLCInfo_RepurposeAbilities GetClassDefaultObject()
{
	return X2DLCInfo_RepurposeAbilities(class'XComEngine'.static.GetClassDefaultObjectByName(default.Class.Name));
}

private function CallRepurposeAbilityFn(X2DataTemplate Template, name AbilityName, bool ShouldLog, delegate<RepurposeAbilityDelegate> RepurposeAbilityFn)
{
	RepurposeAbilityFn(Template, AbilityName, ShouldLog);
}

static event OnPostTemplatesCreated()
{
	`Log(`StaticLocation, default.EnableTrace, 'RepurposeAbilitiesTrace');

	RepurposeAbilities();
}

static function RepurposeAbilities()
{
	local AbilityLink Ability;
	local X2AbilityTemplateManager AbilityTemplateManager;
	local X2AbilityTemplate AbilityTemplate;

	`Log(`StaticLocation, default.EnableTrace, 'RepurposeAbilitiesTrace');

	AbilityTemplateManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();

	foreach default.RepurposeAbility(Ability)
	{
		AbilityTemplate = AbilityTemplateManager.FindAbilityTemplate(Ability.AbilityName);

		if (AbilityTemplate == none)
		{
			`Log(Ability.AbilityName @ "does not exist. Skipping.", true, 'RepurposeAbilities');

			continue;
		}

		AddAbilities(Ability);
		RemoveAbilities(Ability);
	}
}

static function AddAbilities(AbilityLink Ability)
{
	local AbilityAttachment Attachment;

	`Log(`StaticLocation, default.EnableTrace, 'RepurposeAbilitiesTrace');

	foreach Ability.AddTo(Attachment)
	{
		RepurposeCharacterAbilities(Attachment, Ability.AbilityName, AddAbility);
		RepurposeItemAbilities(Attachment, Ability.AbilityName, AddAbility);
		RepurposeAbilityAdditionalAbilities(Attachment, Ability.AbilityName, AddAbility);
	}
}

static function RemoveAbilities(AbilityLink Ability)
{
	local AbilityAttachment Attachment;

	`Log(`StaticLocation, default.EnableTrace, 'RepurposeAbilitiesTrace');

	foreach Ability.RemoveFrom(Attachment)
	{
		RepurposeCharacterAbilities(Attachment, Ability.AbilityName, RemoveAbility);
		RepurposeItemAbilities(Attachment, Ability.AbilityName, RemoveAbility);
		RepurposeAbilityAdditionalAbilities(Attachment, Ability.AbilityName, RemoveAbility);
	}
}

static function RepurposeCharacterAbilities(AbilityAttachment Attachment, name RepurposeAbilityName, delegate<RepurposeAbilityDelegate> RepurposeAbilityFn)
{
	local X2DLCInfo_RepurposeAbilities ClassObject;
	local X2CharacterTemplateManager CharacterTemplateManager;
	local array<X2DataTemplate> TemplateAllDifficulties;
	local X2DataTemplate Template;
	local X2CharacterTemplate CharacterTemplate;
	local name CharacterName;
	local bool ShouldLog;
	local int Index;

	`Log(`StaticLocation, default.EnableTrace, 'RepurposeAbilitiesTrace');

	CharacterTemplateManager = class'X2CharacterTemplateManager'.static.GetCharacterTemplateManager();

	foreach Attachment.Characters(CharacterName)
	{
		CharacterTemplateManager.FindDataTemplateAllDifficulties(CharacterName, TemplateAllDifficulties);

		foreach TemplateAllDifficulties(Template, Index)
		{
			CharacterTemplate = X2CharacterTemplate(Template);

			if (CharacterTemplate == none)
			{
				continue;
			}

			ShouldLog = false;

			if (default.EnableDebug && Index == 0)
			{
				ShouldLog = true;
			}

			ClassObject = GetClassDefaultObject();
			ClassObject.CallRepurposeAbilityFn(CharacterTemplate, RepurposeAbilityName, ShouldLog, RepurposeAbilityFn);
		}
	}
}

static function RepurposeItemAbilities(AbilityAttachment Attachment, name RepurposeAbilityName, delegate<RepurposeAbilityDelegate> RepurposeAbilityFn)
{
	local X2DLCInfo_RepurposeAbilities ClassObject;
	local X2ItemTemplateManager ItemTemplateManager;
	local array<X2DataTemplate> TemplateAllDifficulties;
	local X2DataTemplate Template;
	local X2EquipmentTemplate EquipmentTemplate;
	local name ItemName;
	local bool ShouldLog;
	local int Index;

	`Log(`StaticLocation, default.EnableTrace, 'RepurposeAbilitiesTrace');

	ItemTemplateManager = class'X2ItemTemplateManager'.static.GetItemTemplateManager();

	foreach Attachment.Equipments(ItemName)
	{
		ItemTemplateManager.FindDataTemplateAllDifficulties(ItemName, TemplateAllDifficulties);
		ShouldLog = false;

		foreach TemplateAllDifficulties(Template, Index)
		{
			EquipmentTemplate = X2EquipmentTemplate(Template);

			if (EquipmentTemplate == none)
			{
				continue;
			}

			ShouldLog = false;

			if (default.EnableDebug && Index == 0)
			{
				ShouldLog = true;
			}

			ClassObject = GetClassDefaultObject();
			ClassObject.CallRepurposeAbilityFn(EquipmentTemplate, RepurposeAbilityName, ShouldLog, RepurposeAbilityFn);
		}
	}
}

static function RepurposeAbilityAdditionalAbilities(AbilityAttachment Attachment, name RepurposeAbilityName, delegate<RepurposeAbilityDelegate> RepurposeAbilityFn)
{
	local X2DLCInfo_RepurposeAbilities ClassObject;
	local X2AbilityTemplateManager AbilityTemplateManager;
	local X2AbilityTemplate AbilityTemplate;
	local name AbilityName;

	`Log(`StaticLocation, default.EnableTrace, 'RepurposeAbilitiesTrace');

	AbilityTemplateManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();

	foreach Attachment.Abilities(AbilityName)
	{
		AbilityTemplate = AbilityTemplateManager.FindAbilityTemplate(AbilityName);

		if (AbilityTemplate == none)
		{
			continue;
		}

		ClassObject = GetClassDefaultObject();
		ClassObject.CallRepurposeAbilityFn(AbilityTemplate, RepurposeAbilityName, default.EnableDebug, RepurposeAbilityFn);
	}
}

static function AddAbility(X2DataTemplate Template, name AbilityName, bool ShouldLog = false)
{
	local X2CharacterTemplate CharacterTemplate;
	local X2EquipmentTemplate EquipmentTemplate;
	local X2AbilityTemplate AbilityTemplate;

	`Log(`StaticLocation, default.EnableTrace, 'RepurposeAbilitiesTrace');

	CharacterTemplate = X2CharacterTemplate(Template);

	if (CharacterTemplate != none)
	{
		CharacterTemplate.Abilities.AddItem(AbilityName);
	}

	EquipmentTemplate = X2EquipmentTemplate(Template);

	if (EquipmentTemplate != none)
	{
		EquipmentTemplate.Abilities.AddItem(AbilityName);
	}

	AbilityTemplate = X2AbilityTemplate(Template);

	if (AbilityTemplate != none)
	{
		AbilityTemplate.AdditionalAbilities.AddItem(AbilityName);
	}

	`Log(AbilityName @ "added to" @ Template.DataName, ShouldLog, 'RepurposeAbilities');
}

static function RemoveAbility(X2DataTemplate Template, name AbilityName, bool ShouldLog = false)
{
	local X2CharacterTemplate CharacterTemplate;
	local X2EquipmentTemplate EquipmentTemplate;
	local X2AbilityTemplate AbilityTemplate;

	`Log(`StaticLocation, default.EnableTrace, 'RepurposeAbilitiesTrace');

	CharacterTemplate = X2CharacterTemplate(Template);

	if (CharacterTemplate != none)
	{
		CharacterTemplate.Abilities.RemoveItem(AbilityName);
	}

	EquipmentTemplate = X2EquipmentTemplate(Template);

	if (EquipmentTemplate != none)
	{
		EquipmentTemplate.Abilities.RemoveItem(AbilityName);
	}

	AbilityTemplate = X2AbilityTemplate(Template);

	if (AbilityTemplate != none)
	{
		AbilityTemplate.AdditionalAbilities.RemoveItem(AbilityName);
	}

	`Log(AbilityName @ "removed from" @ Template.DataName, ShouldLog, 'RepurposeAbilities');
}


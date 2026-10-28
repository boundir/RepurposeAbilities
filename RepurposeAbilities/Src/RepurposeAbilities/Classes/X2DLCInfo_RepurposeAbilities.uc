class X2DLCInfo_RepurposeAbilities extends X2DownloadableContentInfo
	dependson(OPTC_CharactersAbilities)
	config(RepurposeAbilities);

`define REP_Log(msg) `Log(`msg, default.EnableDebug, 'RepurposeAbilities')
`define REP_Warn(msg) `Log(`msg,, 'RepurposeAbilities')

enum ERepurposeOperation
{
	eRepurpose_Add,
	eRepurpose_Remove,
	eRepurpose_Clear
};

struct AbilityTargets
{
	var array<name> Characters;
	var array<name> CharacterGroups;
	var array<name> Equipments;
	var array<name> WeaponCategories;
	var array<name> ItemCategories;
	var array<name> ArmorClasses;
	var array<name> ArmorCategories;
	var array<name> Abilities;
};

struct AbilityLink
{
	var name AbilityName;
	var AbilityTargets AddTo;
	var AbilityTargets RemoveFrom;
};

var config array<AbilityTargets> ClearAbilities;
var config array<AbilityLink> RepurposeAbility;
var config bool EnableDebug;

static event OnPostTemplatesCreated()
{
	local array<AbilityTargets> Clears;
	local array<AbilityLink> Links;
	local AbilityTargets Targets;
	local AbilityLink Link;

	ConvertLegacyEntries(Clears, Links);

	foreach default.ClearAbilities(Targets)
	{
		Clears.AddItem(Targets);
	}

	foreach default.RepurposeAbility(Link)
	{
		Links.AddItem(Link);
	}

	foreach Clears(Targets)
	{
		ApplyToTargets(Targets, '', eRepurpose_Clear);
	}

	foreach Links(Link)
	{
		ApplyLink(Link);
	}
}

static function ConvertLegacyEntries(out array<AbilityTargets> Clears, out array<AbilityLink> Links)
{
	local X2CharacterTemplateManager CharacterManager;
	local TemplateAbilitiesNames Entry;
	local AbilityTargets Targets, EmptyTargets;
	local AbilityLink Link, EmptyLink;
	local name AbilityName;

	CharacterManager = class'X2CharacterTemplateManager'.static.GetCharacterTemplateManager();

	foreach class'OPTC_CharactersAbilities'.default.Abilities(Entry)
	{
		Targets = EmptyTargets;

		if (Entry.CharacterGroup != '')
		{
			Targets.CharacterGroups.AddItem(Entry.CharacterGroup);
		}

		if (Entry.TemplateName != '')
		{
			if (CharacterManager.FindCharacterTemplate(Entry.TemplateName) != none)
			{
				Targets.Characters.AddItem(Entry.TemplateName);
			}
			else
			{
				Targets.Equipments.AddItem(Entry.TemplateName);
			}
		}

		if (Targets.Characters.Length + Targets.CharacterGroups.Length + Targets.Equipments.Length == 0)
		{
			continue;
		}

		if (Entry.RemoveOriginal)
		{
			Clears.AddItem(Targets);
		}

		foreach Entry.AddAbilityName(AbilityName)
		{
			Link = EmptyLink;
			Link.AbilityName = AbilityName;
			Link.AddTo = Targets;
			Links.AddItem(Link);
		}

		foreach Entry.RemoveAbilityName(AbilityName)
		{
			Link = EmptyLink;
			Link.AbilityName = AbilityName;
			Link.RemoveFrom = Targets;
			Links.AddItem(Link);
		}
	}
}

static function ApplyLink(AbilityLink Link)
{
	local X2AbilityTemplateManager AbilityManager;

	if (Link.AbilityName == '')
	{
		return;
	}

	AbilityManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();

	if (AbilityManager.FindAbilityTemplate(Link.AbilityName) == none)
	{
		`REP_Warn("Ability" @ Link.AbilityName @ "does not exist. It can be removed but will not be added.");
	}
	else
	{
		ApplyToTargets(Link.AddTo, Link.AbilityName, eRepurpose_Add);
	}

	ApplyToTargets(Link.RemoveFrom, Link.AbilityName, eRepurpose_Remove);
}

static function ApplyToTargets(AbilityTargets Targets, name AbilityName, ERepurposeOperation Operation)
{
	local array<X2DataTemplate> Templates;
	local X2DataTemplate Template;

	Templates = ResolveTargets(Targets);

	foreach Templates(Template)
	{
		ApplyToTemplate(Template, AbilityName, Operation);
	}
}

static function array<X2DataTemplate> ResolveTargets(AbilityTargets Targets)
{
	local X2CharacterTemplateManager CharacterManager;
	local X2ItemTemplateManager ItemManager;
	local X2AbilityTemplateManager AbilityManager;
	local array<X2DataTemplate> Resolved, Variants;
	local X2DataTemplate Template;
	local X2CharacterTemplate CharacterTemplate;
	local X2AbilityTemplate AbilityTemplate;
	local array<name> AllNames, MatchedFilters;
	local name TargetName, TemplateName;

	CharacterManager = class'X2CharacterTemplateManager'.static.GetCharacterTemplateManager();
	ItemManager = class'X2ItemTemplateManager'.static.GetItemTemplateManager();
	AbilityManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();

	foreach Targets.Characters(TargetName)
	{
		Variants.Length = 0;
		CharacterManager.FindDataTemplateAllDifficulties(TargetName, Variants);
		AppendTemplates(Resolved, Variants, TargetName);
	}

	if (Targets.CharacterGroups.Length > 0)
	{
		AllNames.Length = 0;
		CharacterManager.GetTemplateNames(AllNames);

		foreach AllNames(TemplateName)
		{
			Variants.Length = 0;
			CharacterManager.FindDataTemplateAllDifficulties(TemplateName, Variants);

			foreach Variants(Template)
			{
				CharacterTemplate = X2CharacterTemplate(Template);

				if (CharacterTemplate != none && NoteMatch(CharacterTemplate.CharacterGroupName, Targets.CharacterGroups, MatchedFilters))
				{
					AddUnique(Resolved, CharacterTemplate);
				}
			}
		}

		WarnUnmatched(Targets.CharacterGroups, MatchedFilters, "character group");
	}

	foreach Targets.Equipments(TargetName)
	{
		Variants.Length = 0;
		ItemManager.FindDataTemplateAllDifficulties(TargetName, Variants);
		AppendTemplates(Resolved, Variants, TargetName);
	}

	if (Targets.WeaponCategories.Length + Targets.ItemCategories.Length + Targets.ArmorClasses.Length + Targets.ArmorCategories.Length > 0)
	{
		AllNames.Length = 0;
		MatchedFilters.Length = 0;
		ItemManager.GetTemplateNames(AllNames);

		foreach AllNames(TemplateName)
		{
			Variants.Length = 0;
			ItemManager.FindDataTemplateAllDifficulties(TemplateName, Variants);

			foreach Variants(Template)
			{
				if (MatchesItemFilters(Template, Targets, MatchedFilters))
				{
					AddUnique(Resolved, Template);
				}
			}
		}

		WarnUnmatched(Targets.WeaponCategories, MatchedFilters, "weapon category");
		WarnUnmatched(Targets.ItemCategories, MatchedFilters, "item category");
		WarnUnmatched(Targets.ArmorClasses, MatchedFilters, "armor class");
		WarnUnmatched(Targets.ArmorCategories, MatchedFilters, "armor category");
	}

	foreach Targets.Abilities(TargetName)
	{
		AbilityTemplate = AbilityManager.FindAbilityTemplate(TargetName);

		if (AbilityTemplate == none)
		{
			`REP_Warn("No ability named" @ TargetName @ "was found");
			continue;
		}

		AddUnique(Resolved, AbilityTemplate);
	}

	return Resolved;
}

static function bool MatchesItemFilters(X2DataTemplate Template, AbilityTargets Targets, out array<name> MatchedFilters)
{
	local X2EquipmentTemplate EquipmentTemplate;
	local X2WeaponTemplate WeaponTemplate;
	local X2ArmorTemplate ArmorTemplate;
	local bool IsMatch;

	EquipmentTemplate = X2EquipmentTemplate(Template);

	if (EquipmentTemplate == none)
	{
		return false;
	}

	IsMatch = NoteMatch(EquipmentTemplate.ItemCat, Targets.ItemCategories, MatchedFilters);

	WeaponTemplate = X2WeaponTemplate(Template);

	if (WeaponTemplate != none)
	{
		IsMatch = NoteMatch(WeaponTemplate.WeaponCat, Targets.WeaponCategories, MatchedFilters) || IsMatch;
	}

	ArmorTemplate = X2ArmorTemplate(Template);

	if (ArmorTemplate != none)
	{
		IsMatch = NoteMatch(ArmorTemplate.ArmorClass, Targets.ArmorClasses, MatchedFilters) || IsMatch;
		IsMatch = NoteMatch(ArmorTemplate.ArmorCat, Targets.ArmorCategories, MatchedFilters) || IsMatch;
	}

	return IsMatch;
}

static function bool NoteMatch(name Value, array<name> Wanted, out array<name> Matched)
{
	if (Value == '' || Wanted.Find(Value) == INDEX_NONE)
	{
		return false;
	}

	if (Matched.Find(Value) == INDEX_NONE)
	{
		Matched.AddItem(Value);
	}

	return true;
}

static function WarnUnmatched(array<name> Wanted, array<name> Matched, string Kind)
{
	local name Value;

	foreach Wanted(Value)
	{
		if (Matched.Find(Value) == INDEX_NONE)
		{
			`REP_Warn("No template matches the" @ Kind @ Value);
		}
	}
}

static function AppendTemplates(out array<X2DataTemplate> Resolved, array<X2DataTemplate> Variants, name TargetName)
{
	local X2DataTemplate Template;

	if (Variants.Length == 0)
	{
		`REP_Warn("No template named" @ TargetName @ "was found");
		return;
	}

	foreach Variants(Template)
	{
		AddUnique(Resolved, Template);
	}
}

static function AddUnique(out array<X2DataTemplate> Resolved, X2DataTemplate Template)
{
	if (Resolved.Find(Template) == INDEX_NONE)
	{
		Resolved.AddItem(Template);
	}
}

static function ApplyToTemplate(X2DataTemplate Template, name AbilityName, ERepurposeOperation Operation)
{
	local X2CharacterTemplate CharacterTemplate;
	local X2EquipmentTemplate EquipmentTemplate;
	local X2AbilityTemplate AbilityTemplate;

	CharacterTemplate = X2CharacterTemplate(Template);

	if (CharacterTemplate != none)
	{
		EditAbilityList(CharacterTemplate.Abilities, Template.DataName, AbilityName, Operation);
		return;
	}

	EquipmentTemplate = X2EquipmentTemplate(Template);

	if (EquipmentTemplate != none)
	{
		EditAbilityList(EquipmentTemplate.Abilities, Template.DataName, AbilityName, Operation);
		return;
	}

	AbilityTemplate = X2AbilityTemplate(Template);

	if (AbilityTemplate != none)
	{
		EditAbilityList(AbilityTemplate.AdditionalAbilities, Template.DataName, AbilityName, Operation);
		return;
	}

	`REP_Warn(Template.DataName @ "is a" @ Template.Class.Name @ "and carries no ability list");
}

static function EditAbilityList(out array<name> Abilities, name OwnerName, name AbilityName, ERepurposeOperation Operation)
{
	switch (Operation)
	{
		case eRepurpose_Add:
			if (Abilities.Find(AbilityName) != INDEX_NONE)
			{
				`REP_Log(AbilityName @ "is already on" @ OwnerName);
				return;
			}

			Abilities.AddItem(AbilityName);
			`REP_Log("Added" @ AbilityName @ "to" @ OwnerName);
			break;

		case eRepurpose_Remove:
			if (Abilities.Find(AbilityName) == INDEX_NONE)
			{
				`REP_Log(AbilityName @ "is not on" @ OwnerName);
				return;
			}

			Abilities.RemoveItem(AbilityName);
			`REP_Log("Removed" @ AbilityName @ "from" @ OwnerName);
			break;

		case eRepurpose_Clear:
			Abilities.Length = 0;
			`REP_Log("Cleared every ability from" @ OwnerName);
			break;
	}
}

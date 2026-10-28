class OPTC_CharactersAbilities extends Object config(RepurposeAbilities);

struct TemplateAbilitiesNames
{
	var name TemplateName;
	var name CharacterGroup;
	var bool RemoveOriginal;
	var array<name> AddAbilityName;
	var array<name> RemoveAbilityName;
};

var config array<TemplateAbilitiesNames> Abilities;

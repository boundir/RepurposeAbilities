[h1]Description[/h1]

Attach abilities to, or remove them from, characters, character groups, weapons, armors, items and other abilities. Everything is driven by one config file, so any mod (or any player) can ship a [u]XComRepurposeAbilities.ini[/u] and reshape who has what.

[h1]Config[/h1]

One entry per ability, under [b][RepurposeAbilities.X2DLCInfo_RepurposeAbilities][/b]:

[code]
+RepurposeAbility=(AbilityName=<ability>, AddTo=(<targets>), RemoveFrom=(<targets>))
[/code]

A target block takes up to eight lists; name only the ones you need:

[list]
[*][u]Characters[/u] - character template names (Archon, AdvTrooperM1, ...)
[*][u]CharacterGroups[/u] - character group names (TheLost, AdventTrooper, ...); every member of the group is affected
[*][u]Equipments[/u] - weapon, armor and utility item template names (ArchonStaff, LightAlienArmor, MindShield, ...)
[*][u]WeaponCategories[/u] - every weapon of a category (rifle, shotgun, pistol, sword, sniper_rifle, cannon, grenade_launcher, gremlin, psiamp, bullpup, vektor_rifle, wristblade, gauntlet, sidearm, claymore, heavy, sparkrifle, and any category a mod adds)
[*][u]ItemCategories[/u] - every item of a category (weapon, armor, utility, grenade, ammo, heal, defense, psidefense, ...)
[*][u]ArmorClasses[/u] - every armor of a class (basic, light, medium, heavy)
[*][u]ArmorCategories[/u] - every faction armor of a category (reaper, skirmisher, templar)
[*][u]Abilities[/u] - ability template names; the ability becomes an AdditionalAbility of each, so it is granted whenever they are
[/list]

[code]
+ClearAbilities=(<targets>)
[/code]

Empties the ability list of each target. Clears always run before adds and removes, whatever their order in the file.

Rules:
[list]
[*]An ability already present on a target is not added twice.
[*]Every difficulty variant of a template is modified.
[*]An ability that does not exist is still removed from targets, but never added.
[*]A target name that matches nothing is reported in the log under the [b]RepurposeAbilities[/b] tag. Set [u]EnableDebug=true[/u] to also log every change made.
[*]Long entries can span several lines by ending each line with two backslashes.
[/list]

[h1]Examples[/h1]

[code]
[RepurposeAbilities.X2DLCInfo_RepurposeAbilities]
; Remove Blazing Pinions from the Archon
+RepurposeAbility=(AbilityName=BlazingPinionsStage1, RemoveFrom=(Characters=(Archon)))

; Give Bladestorm to the Archon staff and to every stun lance
+RepurposeAbility=(AbilityName=Bladestorm, AddTo=(Equipments=(ArchonStaff, AdvStunLancerM1_StunLance, AdvStunLancerM2_StunLance, AdvStunLancerM3_StunLance)))

; Take Grapple away from the Light Alien Armor
+RepurposeAbility=(AbilityName=Grapple, RemoveFrom=(Equipments=(LightAlienArmor)))

; Turn the Mind Shield into a robot immunity item
+RepurposeAbility=(AbilityName=MindShield, RemoveFrom=(Equipments=(MindShield)))
+RepurposeAbility=(AbilityName=RobotImmunities, AddTo=(Equipments=(MindShield)))

; Remove the Lost headshot from every Lost
+RepurposeAbility=(AbilityName=LostHeadshotInit, RemoveFrom=(CharacterGroups=(TheLost)))

; Give every sword Bladestorm and every heavy armor Shieldwall
+RepurposeAbility=(AbilityName=Bladestorm, AddTo=(WeaponCategories=(sword)))
+RepurposeAbility=(AbilityName=Shieldwall, AddTo=(ArmorClasses=(heavy)))

; Strip the Andromedon, then give it only Bladestorm
+ClearAbilities=(Characters=(Andromedon))
+RepurposeAbility=(AbilityName=Bladestorm, AddTo=(Characters=(Andromedon)))
[/code]

[h1]Previous format[/h1]

Entries under [b][RepurposeAbilities.OPTC_CharactersAbilities][/b] from version 1 ([u]TemplateName[/u], [u]CharacterGroup[/u], [u]RemoveOriginal[/u], [u]AddAbilityName[/u], [u]RemoveAbilityName[/u]) are still read and converted to the new format, so existing configs keep working. Prefer the new format for anything new.

[h1]Compatibility[/h1]

Works with everything.

[h1]Note[/h1]

Some abilities need animations the unit does not have. Do not be surprised when a Trooper fails to perform Bladestorm ¯\(°_o)/¯

[h1]Troubleshooting[/h1]
https://www.reddit.com/r/xcom2mods/wiki/mod_troubleshooting
[url=steamcommunity.com/sharedfiles/filedetails/?id=683218526]Mods not working properly / at all[/url]
[url=steamcommunity.com/sharedfiles/filedetails/?id=625230005]Mod not working? Mods still have their effects after you disable them?[/url]

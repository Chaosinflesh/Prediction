--[[
    Holds all basic hard-coded data elements. These can be overwritten by the user, but it is recommended to create
    your own ruleset.

    Pred.Data
        Class
            Specialization
                HastedCooldowns         Spell IDs related to this spec affected by haste.
                RuleSet ['Default']
                    Rules               This set of rules. Evaluated 1st.
                    SpellEffects        
                        Instant         Effects that happen immediately upon cast. Evaluated 2nd.
                        Cast            Effects that happen on conclusion of cast. Evaluated 6th.
                    BuffEffects         Specific Effects that happen during cast / GCD. Evaluated 4th.
                    RegenEffects        Generic effects that happen during cast / GCD. Evaluated 5th.
                [ ... ]
            [ ... ]
        [ ... ]
    
    SpellEffects.Cast may include DelayedEffects, these are evaluated 3rd if they exist.
]]

local Pred = LibStub('AceAddon-3.0'):GetAddon('Prediction')

Pred.Data = {
    Version = DB_VERSION,
    ["Death Knight"] = {
        ["Blood"] = {
            HastedCooldowns = {
                50842,      -- Blood Boil
            },
            Default = {
                Rules = {
                    {"Auto Attack", "(true)"},
                },
                SpellEffects = {
                    ["Auto Attack"] = {
                        Instant = "",
                        Cast = "",
                    },
                },
                BuffEffects = {
                    ["Auto Attack"] = "",
                    ["Death and Decay"] = "if Player.talents['Rapid Decomposition'] then\n    Player.resources['RunicPower'] = math.min(Player.resources['RunicPower'] + math.min(Player.buffs['Death and Decay'].timeRemaining, GetPeriod()), Player.maxResources['RunicPower'])\n end",
                    ["Rune Tap"] = "local t = math.floor(math.min(Player.buffs['Rune Tap'].timeRemaining, GetPeriod()) + 0.5)\nif t >= 1 then\n    Pred.Engine:AddRunes(t)\nend",
                },
                RegenEffects = {
                    ["Auto Attack"] = "",
                },
            },
        },
        ["Frost"] = {
            HastedCooldowns = {
                194913,     -- Glacial Advance
            },
            Default = {
                Rules = {
                    {"Auto Attack", "(true)"},
                },
                SpellEffects = {
                    ["Auto Attack"] = {
                        Instant = "",
                        Cast = "",
                    },
                },
                BuffEffects = {
                    ["Auto Attack"] = "",
                    ["Hungering Rune Weapon"] = "local t = math.floor(math.min(Player.buffs['Hungering Rune Weapon'].timeRemaining, GetPeriod()) + 0.5)\nPlayer.resources['RunicPower'] = math.min(Player.resources['RunicPower'] + t, Player.maxResources['RunicPower'])\nif t >= 1 then\nAddRunes(t)\nend",
                },
                RegenEffects = {
                    ["Auto Attack"] = "",
                },
            },
        },
        ["Unholy"] = {
            HastedCooldowns = {
                207317,     -- Epidemic
            },
            Default = {
                Rules = {
                    {"Auto Attack", "(true)"},
                },
                SpellEffects = {
                    ["Auto Attack"] = {
                        Instant = "",
                        Cast = "",
                    },
                },
                BuffEffects = {
                    ["Auto Attack"] = "",
                },
                RegenEffects = {
                    ["Auto Attack"] = "",
                },
            },
        },
    },
    ["Demon Hunter"] = {
        ["Havoc"] = {
            HastedCooldowns = {
            },
            Default = {
                Rules = {
                    {"Auto Attack", "(true)"},
                },
                SpellEffects = {
                    ["Auto Attack"] = {
                        Instant = "",
                        Cast = "",
                    },
                },
                BuffEffects = {
                    ["Auto Attack"] = "",
                },
                RegenEffects = {
                    ["Auto Attack"] = "",
                },
            },
        },
        ["Vengeance"] = {
            HastedCooldowns = {
            },
            Default = {
                Rules = {
                    {"Auto Attack", "(true)"},
                },
                SpellEffects = {
                    ["Auto Attack"] = {
                        Instant = "",
                        Cast = "",
                    },
                },
                BuffEffects = {
                    ["Auto Attack"] = "",
                },
                RegenEffects = {
                    ["Auto Attack"] = "",
                },
            },
        },
    },
    ["Druid"] = {
        ["Balance"] = {
            HastedCooldowns = {
            },
            Default = {
                Rules = {
                    {"Starsurge", "(Player.resources['LunarPower'] >= 40 and not (Player.buffs['Solar Empowerment'] or Player.buffs['Lunar Empowerment']))"},
                    {"Solar Wrath", "(Player.buffs['Solar Empowerment'] and Player.buffs['Solar Empowerment'].count > 0)"},
                    {"Moonfire", "(not Target.debuffs['Moonfire']) or Target.debuffs['Moonfire'].timeRemaining < (1.5 / (1 + Player.haste))"},
                    {"Solar Wrath", "(true)"},
                },
                SpellEffects = {
                    ["Auto Attack"] = {
                        Instant = "",
                        Cast = "",
                    },
                    ["Moonfire"] = {
                        Instant = "Target.debuffs['Moonfire'] = { count = 1, timeRemaining = 22, caster = 'player' }\nPlayer.resources['LunarPower'] = math.min(Player.maxResources['LunarPower'], Player.resources['LunarPower'] + 3)\n",
                        Cast = "",
                    },
                    ["Solar Wrath"] = {
                        Instant = "",
                        Cast = "if (Player.buffs['Solar Empowerment']) then\n    Player.buffs['Solar Empowerment'].count = Player.buffs['Solar Empowerment'].count - 1\n    if (Player.buffs['Solar Empowerment'].count <= 0) then\n        Player.buffs['Solar Empowerment'] = nil\n    end\nend\nPlayer.resources['LunarPower'] = math.min(Player.maxResources['LunarPower'], Player.resources['LunarPower'] + 8)",
                    },
                    ["Starsurge"] = {
                        Instant = "",
                        Cast = "Player.buffs['Lunar Empowerment'] = { count = 1, timeRemaining = 40, caster = 'player' }\nPlayer.buffs['Solar Empowerment'] = { count = 1, timeRemaining = 40, caster = 'player' }\nPlayer.resources['LunarPower'] = Player.resources['LunarPower'] - 40",
                    },
                },
                BuffEffects = {
                    ["Auto Attack"] = "",
                },
                RegenEffects = {
                    ["Auto Attack"] = "",
                },
            },
        },
        ["Feral"] = {
            HastedCooldowns = {
                202028,     -- Brutal Slash
            },
            Default = {
                Rules = {
                    {"Auto Attack", "(true)"},
                },
                SpellEffects = {
                    ["Auto Attack"] = {
                        Instant = "",
                        Cast = "",
                    },
                },
                BuffEffects = {
                    ["Auto Attack"] = "",
                },
                RegenEffects = {
                    ["Auto Attack"] = "",
                },
            },
        },
        ["Guardian"] = {
            HastedCooldowns = {
                33917,     -- Mangle
                77758,     -- Thrash
                22842,     -- Frenzied Regeneration
            },
            Default = {
                Rules = {
                    {"Auto Attack", "(true)"},
                },
                SpellEffects = {
                    ["Auto Attack"] = {
                        Instant = "",
                        Cast = "",
                    },
                },
                BuffEffects = {
                    ["Auto Attack"] = "",
                },
                RegenEffects = {
                    ["Auto Attack"] = "",
                },
            },
        },
        ["Restoration"] = {
            HastedCooldowns = {
            },
            Default = {
                Rules = {
                    {"Auto Attack", "(true)"},
                },
                SpellEffects = {
                    ["Auto Attack"] = {
                        Instant = "",
                        Cast = "",
                    },
                },
                BuffEffects = {
                    ["Auto Attack"] = "",
                },
                RegenEffects = {
                    ["Auto Attack"] = "",
                },
            },
        },
    },
    ["Hunter"] = {
        ["Beast Mastery"] = {
            HastedCooldowns = {
                53209,     -- Chimaera Shot
                120679,    -- Dire Beast
                34026,     -- Kill Command
            },
            Default = {
                Rules = {
                    {"Auto Attack", "(true)"},
                },
                SpellEffects = {
                    ["Auto Attack"] = {
                        Instant = "",
                        Cast = "",
                    },
                },
                BuffEffects = {
                    ["Auto Attack"] = "",
                },
                RegenEffects = {
                    ["Auto Attack"] = "",
                },
            },
        },
        ["Marksmanship"] = {
            HastedCooldowns = {
            },
            Default = {
                Rules = {
                    {"Auto Attack", "(true)"},
                },
                SpellEffects = {
                    ["Auto Attack"] = {
                        Instant = "",
                        Cast = "",
                    },
                },
                BuffEffects = {
                    ["Auto Attack"] = "",
                },
                RegenEffects = {
                    ["Auto Attack"] = "",
                },
            },
        },
        ["Survival"] = {
            HastedCooldowns = {
                200163,    -- Throwing Axes
                212436,    -- Butchery
                202800,    -- Flanking Strike
                190928,    -- Mongoose Bite
            },
            Default = {
                Rules = {
                    {"Auto Attack", "(true)"},
                },
                SpellEffects = {
                    ["Auto Attack"] = {
                        Instant = "",
                        Cast = "",
                    },
                },
                BuffEffects = {
                    ["Auto Attack"] = "",
                },
                RegenEffects = {
                    ["Auto Attack"] = "",
                },
            },
        },
    },
    ["Mage"] = {
        ["Arcane"] = {
            HastedCooldowns = {
                44425,     -- Arcane Barrage
            },
            Default = {
                Rules = {
                    {"Arcane Missiles", "(Player.buffs['Arcane Missiles!'])"},
                    {"Arcane Blast", "(true)"},
                },
                SpellEffects = {
                    ["Auto Attack"] = {
                        Instant = "",
                        Cast = "",
                    },
           			["Arcane Blast"] = {
                        Instant = "",
                        Cast = "Player.resources['ArcaneCharges'] = math.min(Player.maxResources['ArcaneCharges'], Player.resources['ArcaneCharges'] + 1)\n",
                    },
                },
                BuffEffects = {
                    ["Auto Attack"] = "",
                },
                RegenEffects = {
                    ["Auto Attack"] = "",
                },
            },
        },
        ["Fire"] = {
            HastedCooldowns = {
                44457,     -- Living Bomb
                198929,    -- Cinderstorm
                108853,    -- Fireblast
            },
            Default = {
                Rules = {
                    {"Pyroblast", "(Player.buffs['Hot Streak!'])"},
                    {"Fire Blast", "(Player.buffs['Heating Up'])"},
                    {"Fireball", "(Player.resources['Mana'] >= 0.02 * Player.maxResources['Mana'])"},
                },
                SpellEffects = {
                    ["Auto Attack"] = {
                        Instant = "",
                        Cast = "",
                    },
                    ["Fireball"] = {
                        Instant = "",
                        Cast = "Player.resources['Mana'] = math.max(0, Player.resources['Mana'] - 0.02 * Player.maxResources['Mana'])",
                    },
                },
                BuffEffects = {
                    ["Auto Attack"] = "",
                },
                RegenEffects = {
                    ["Auto Attack"] = "",
                },
            },
        },
        ["Frost"] = {
            HastedCooldowns = {
                190356,    -- Blizzard
            },
            Default = {
                Rules = {
                    {"Auto Attack", "(true)"},
                },
                SpellEffects = {
                    ["Auto Attack"] = {
                        Instant = "",
                        Cast = "",
                    },
                },
                BuffEffects = {
                    ["Auto Attack"] = "",
                },
                RegenEffects = {
                    ["Auto Attack"] = "",
                },
            },
        },
    },
    ["Monk"] = {
        ["Brewmaster"] = {
            HastedCooldowns = {
                116847,    -- Rushing Jade Wind
                115308,    -- Ironskin Brew
                121253,    -- Keg Smash
                119582,    -- Purifying Brew
            },
            Default = {
                Rules = {
                    {"Auto Attack", "(true)"},
                },
                SpellEffects = {
                    ["Auto Attack"] = {
                        Instant = "",
                        Cast = "",
                    },
                },
                BuffEffects = {
                    ["Auto Attack"] = "",
                },
                RegenEffects = {
                    ["Auto Attack"] = "",
                },
            },
        },
        ["Mistweaver"] = {
            HastedCooldowns = {
                196725,    -- Refreshing Jade Wind
                100784,    -- Blackout Kick
                107428,    -- Rising Sun Kick
            },
            Default = {
                Rules = {
                    {"Auto Attack", "(true)"},
                },
                SpellEffects = {
                    ["Auto Attack"] = {
                        Instant = "",
                        Cast = "",
                    },
                },
                BuffEffects = {
                    ["Auto Attack"] = "",
                },
                RegenEffects = {
                    ["Auto Attack"] = "",
                },
            },
        },
        ["Windwalker"] = {
            HastedCooldowns = {
                152175,    -- Whirling Dragon Punch
                113656,    -- Fist of Fury
            },
            Default = {
                Rules = {
                    {"Auto Attack", "(true)"},
                },
                SpellEffects = {
                    ["Auto Attack"] = {
                        Instant = "",
                        Cast = "",
                    },
                },
                BuffEffects = {
                    ["Auto Attack"] = "",
                },
                RegenEffects = {
                    ["Auto Attack"] = "",
                },
            },
        },
    },
    ["Paladin"] = {
        ["Holy"] = {
            HastedCooldowns = {
                35395,     -- Crusader Strike
                20473,     -- Holy Shock
                85222,     -- Light of Dawn
                231644,    -- Judgment
            },
            Default = {
                Rules = {
                    {"Auto Attack", "(true)"},
                },
                SpellEffects = {
                    ["Auto Attack"] = {
                        Instant = "",
                        Cast = "",
                    },
                },
                BuffEffects = {
                    ["Auto Attack"] = "",
                },
                RegenEffects = {
                    ["Auto Attack"] = "",
                },
            },
        },
        ["Protection"] = {
            HastedCooldowns = {
                31935,     -- Avenger's Shield
                231665,
                26573,     -- Consecration
                53595,     -- Hammer of the Righteous
                20271,     -- Judgment
                231657,
                184092,    -- Light of the Protector
                53600,     -- Shield of the Righteous
            },
            Default = {
                Rules = {
                    {"Auto Attack", "(true)"},
                },
                SpellEffects = {
                    ["Auto Attack"] = {
                        Instant = "",
                        Cast = "",
                    },
                },
                BuffEffects = {
                    ["Auto Attack"] = "",
                },
                RegenEffects = {
                    ["Auto Attack"] = "",
                },
            },
        },
        ["Retribution"] = {
            HastedCooldowns = {
                213757,    -- Execution Sentence
                205228,    -- Consectration
                217020,    -- Zeal
                198034,    -- Holy Hammer
                184575,    -- Blade of Justice
                231663,    -- Judgment
            },
            Default = {
                Rules = {
                    {"Judgment", "(not Target.debuffs['Judgment'])"},
                    {"Consecration", "(true)"},
                    {"Blade of Justice", "(true)"},
                    {"Templar's Verdict", "(Player.resources['HolyPower'] >= 3)"},
                    {"Crusader Strike", "(true)"},
                    {"Auto Attack", "(true)"},
                },
                SpellEffects = {
                    ["Auto Attack"] = {
                        Instant = "",
                        Cast = "",
                    },
                    ["Crusader Strike"] = {
                        Instant = "Player.resources['HolyPower'] = math.min(Player.maxResources['HolyPower'], Player.resources['HolyPower'] + 1)\nPlayer.spells['Crusader Strike'].currentCharges = Player.spells['Crusader Strike'].currentCharges - 1",
                        Cast = "",
                    },
                    ["Templar's Verdict"] = {
                        Instant = "Player.resources['HolyPower'] = math.max(0, Player.resources['HolyPower'] - 3)",
                        Cast = "",
                    },
                    ["Blade of Justice"] = {
                        Instant = "Player.resources['HolyPower'] = math.min(Player.maxResources['HolyPower'], Player.resources['HolyPower'] + 2)",
                        Cast = "",
                    },
                },
                BuffEffects = {
                    ["Auto Attack"] = "",
                },
                RegenEffects = {
                    ["Auto Attack"] = "",
                },
            },
        },
    },
    ["Priest"] = {
        ["Discipline"] = {
            HastedCooldowns = {
                129250,    -- Power Word: Solace
                17,        -- Power Word: Shield
            },
            Default = {
                Rules = {
                    {"Auto Attack", "(true)"},
                },
                SpellEffects = {
                    ["Auto Attack"] = {
                        Instant = "",
                        Cast = "",
                    },
                },
                BuffEffects = {
                    ["Auto Attack"] = "",
                },
                RegenEffects = {
                    ["Auto Attack"] = "",
                },
            },
        },
        ["Holy"] = {
            HastedCooldowns = {
                204883,    -- Circle of Healing
                33076,     -- Prayer of Mending
            },
            Default = {
                Rules = {
                    {"Auto Attack", "(true)"},
                },
                SpellEffects = {
                    ["Auto Attack"] = {
                        Instant = "",
                        Cast = "",
                    },
                },
                BuffEffects = {
                    ["Auto Attack"] = "",
                },
                RegenEffects = {
                    ["Auto Attack"] = "",
                },
            },
        },
        ["Shadow"] = {
            HastedCooldowns = {
                8092,      -- Mind Blast
                228260,    -- Void Eruption
                205448,    -- Void Bolt
            },
            Default = {
                Rules = {
                    {"Void Eruption", "(not Player.buffs['Voidform']) and Player.resources['Insanity'] >= 100 and Target.debuffs['Shadow Word: Pain']"},
                    {"Mind Blast", "(true)"},
                    {"Void Bolt", "(Player.buffs['Voidform'] and Player.spells['Void Eruption'].remainingCooldown <= 0)"},
                    {"Shadow Word: Pain", "(not Target.debuffs['Shadow Word: Pain']) or Target.debuffs['Shadow Word: Pain'].timeRemaining < (1.5 / (1 + Player.haste))"},
                    {"Mind Flay", "(true)"},
                },
                SpellEffects = {
                    ["Auto Attack"] = {
                        Instant = "",
                        Cast = "",
                    },
                    ["Mind Blast"] = {
                        Instant = "",
                        Cast = "local ins = Player.talents['Fortress of the Mind'] and 18 or 15\nPlayer.resources['Insanity'] = math.min(Player.maxResources['Insanity'], Player.resources['Insanity'] + ins)\n",
                    },
                    ["Shadowform"] = {
                        Instant = "Player.buffs['Shadowform'] = { count = 0, timeRemaining = 999, caster = 'player' }\n",
                        Cast = "",
                    },
                    ["Void Eruption"] = {
                        Instant = "",
                        Cast = "Player.buffs['Voidform'] = {count = 1, timeRemaining = 999, caster = 'player' }\nPlayer.spells['Void Bolt'].remainingCooldown = 4.5 / (1 + Player.haste)",
                    },
                    ["Shadow Word: Pain"] = {
                        Instant = "Target.debuffs['Shadow Word: Pain'] = { count = 0, timeRemaining = 18, caster = 'player' }\nPlayer.resources['Insanity'] = math.min(Player.maxResources['Insanity'], Player.resources['Insanity'] + 4)\n",
                        Cast = "",
                    },
                    ["Mind Flay"] = {
                        Instant = "local ins = Player.talents['Fortress of the Mind'] and 14 or 12\nPlayer.resources['Insanity'] = math.min(Player.maxResources['Insanity'], Player.resources['Insanity'] + ins)\n",
                        Cast = "",
                    },
                    ["Void Bolt"] = {
                        Instant = "Player.resources['Insanity'] = math.min(Player.maxResources['Insanity'], Player.resources['Insanity'] + 16)\nPlayer.spells['Void Eruption'].remainingCooldown = 4.5 / (1 + Player.haste)\n",
                        Cast = "",
                    },
                },
                BuffEffects = {
                    ["Auto Attack"] = "",
                },
                RegenEffects = {
                    ["Auto Attack"] = "",
                },
            },
        },
    },
    ["Rogue"] = {
        ["Assassination"] = {
            HastedCooldowns = {
            },
            Default = {
                Rules = {
                    {"Auto Attack", "(true)"},
                },
                SpellEffects = {
                    ["Auto Attack"] = {
                        Instant = "",
                        Cast = "",
                    },
                },
                BuffEffects = {
                    ["Auto Attack"] = "",
                },
                RegenEffects = {
                    ["Auto Attack"] = "",
                },
            },
        },
        ["Outlaw"] = {
            HastedCooldowns = {
            },
            Default = {
                Rules = {
                    {"Auto Attack", "(true)"},
                },
                SpellEffects = {
                    ["Auto Attack"] = {
                        Instant = "",
                        Cast = "",
                    },
                },
                BuffEffects = {
                    ["Auto Attack"] = "",
                },
                RegenEffects = {
                    ["Auto Attack"] = "",
                },
            },
        },
        ["Subtlety"] = {
            HastedCooldowns = {
            },
            Default = {
                Rules = {
                    {"Auto Attack", "(true)"},
                },
                SpellEffects = {
                    ["Auto Attack"] = {
                        Instant = "",
                        Cast = "",
                    },
                },
                BuffEffects = {
                    ["Auto Attack"] = "",
                },
                RegenEffects = {
                    ["Auto Attack"] = "",
                },
            },
        },
    },
    ["Shaman"] = {
        ["Elemental"] = {
            HastedCooldowns = {
            },
            Default = {
                Rules = {
                    {"Totem Mastery", "(not Player.buffs['Totem Mastery'] or Player.buffs['Totem Mastery'].timeRemaining < 1.5)"},
                    {"Flame Shock", "(not Target.debuffs['Flame Shock'] or Target.debuffs['Flame Shock'].timeRemaining < 1.5)"},
                    {"Elemental Blast", "(true)"},
                    {"Earthquake", "(false)"},
                    {"Earth Shock", "(Player.resources['Maelstrom'] >= 111 and Player.buffs['Earthen Strength'])" },
                    {"Earth Shock", "(Player.artifact and ((not Player.artifact['Swelling Maelstrom']) and Player.resources['Maelstrom'] >= 92 and Player.buffs['Earthen Strength']))"},
                    {"Frost Shock", "((not Player.buffs['Ascendance']) and Player.buffs['Earthen Strength'] and Player.buffs['Icefury'] and Player.resources['Maelstrom'] >= 20)"},
                    {"Earth Shock", "(Player.resources['Maelstrom'] >= 117 or ((Player.artifact and not Player.artifact['Swelling Maelstrom']) and Player.resources['Maelstrom'] >= 92))"},
                    {"Stormkeeper", "(not Player.buffs['Ascendance'])"},
                    {"Icefury", "((not Player.buffs['Ascendance']) and (Player.artifact and Player.artifact['Swelling Maelstrom'] and Player.resources['Maelstrom'] <= 101))"},
                    {"Icefury", "((not Player.buffs['Ascendance']) and (not (Player.artifact and Player.artifact['Swelling Maelstrom'])) and Player.resources['Maelstrom'] <= 76)"},
                    {"Liquid Magma Totem", "(true)"},
                    {"Lightning Bolt", "(Player.buffs['Power of the Maelstrom'] and Player.buffs['Stormkeeper'])"},
                    {"Lava Burst", "(Target.debuffs['Flame Shock'] and Target.debuffs['Flame Shock'].timeRemaining > Player.spells['Lava Burst'].baseCastTime)"},
                    {"Frost Shock", "(Player.buffs['Icefury'] and Player.resources['Maelstrom'] >= 20)"},
                    {"Frost Shock", "(Player.buffs['Icefury'] and Player.buffs['Icefury'].timeRemaining < (1.5 / (1 + Player.haste) * Player.buffs['Icefury'].count))"},
                    {"Flame Shock", "(Player.resources['Maelstrom'] >= 20 and Player.buffs['Elemental Focus'] and Target.debuffs['Flame Shock'] and Target.debuffs['Flame Shock'].timeRemaining < 9)"},
                    {"Earthquake", "(false)"},
                    {"Frost Shock", "(Player.buffs['Icefury'])"},
                    {"Earth Shock", "(Player.resources['Maelstrom'] >= 111)"},
                    {"Earth Shock", "(Player.gear['Smoldering Heart'] and Player.gear[\"The Deceiver's Blood Pact\"] and Player.resources['Maelstrom'] > 70)"},
                    {"Earth Shock", "(Player.gear['Echoes of the Great Sundering'] and Player.gear[\"The Deceiver's Blood Pact\"] and Player.resources['Maelstrom'] > 85)"},
                    {"Totem Mastery", "(Player.buffs['Totem Mastery'] and Player.buffs['Totem Mastery'].timeRemaining < 10)"},
                    {"Lightning Bolt", "(true)"},
                },
                SpellEffects = {
                    ["Auto Attack"] = {
                        Instant = "",
                        Cast = "",
                    },
                    ["Liquid Magma Totem"] = {
                        Instant = "if Player.buffs['Elemental Focus'] then\n    Player.buffs['Elemental Focus'].count = Player.buffs['Elemental Focus'].count - 1\n    if Player.buffs['Elemental Focus'].count <= 0 then\n        Player.buffs['Elemental Focus'] = nil\n    end\nend",
                        Cast = "",
                    },
                    ["Lava Burst"] = {
                        Instant = "",
                        Cast = "Player.buffs['Earthen Strength'] = { count = 0, timeRemaining = 15, caster = 'player'}\nPlayer.resources['Maelstrom'] = math.min(Player.maxResources['Maelstrom'], Player.resources['Maelstrom'] + 12)\n\nif Player.buffs['Lava Surge'] then\n    Player.buffs['Lava Surge'] = nil\nend\n\nif Target.debuffs['Flame Shock'] and (Target.debuffs['Flame Shock'].timeRemaining < 2 / (1 + Player.haste)) then\n    Player.buffs['Elemental Focus'] = {count = 2, timeRemaining = 10, caster = 'player'}\nend\n",
                    },
                    ["Totem Mastery"] = {
                        Instant = "Player.buffs['Ember Totem'] = { count = 0, timeRemaining = 120, caster='player'}\nPlayer.buffs['Resonance Totem'] = { count = 0, timeRemaining = 120, caster='player' }\nPlayer.buffs['Storm Totem'] = { count = 0, timeRemaining = 120, caster='player' }\nPlayer.buffs['Tailwind Totem'] = { count = 0, timeRemaining = 120, caster='player' }\nPlayer.buffs['Totem Mastery'] = { count = 0, timeRemaining = 120, caster='player' }\nPlayer.haste = Player.haste + 0.02\n            ",
                        Cast = "",
                    },
                    ["Icefury"] = {
                        Instant = "",
                        Cast = "Player.resources['Maelstrom'] = math.min(Player.maxResources['Maelstrom'], Player.resources['Maelstrom'] + 24)\nPlayer.buffs['Icefury'] = { count = 4, timeRemaining = 15, caster='player'}\n\nif Player.buffs['Elemental Focus'] then\n    Player.buffs['Elemental Focus'].count = Player.buffs['Elemental Focus'].count - 1\n    if Player.buffs['Elemental Focus'].count <= 0 then\n        Player.buffs['Elemental Focus'] = nil\n    end\nend",
                    },
                    ["Frost Shock"] = {
                        Instant = "if Player.buffs['Icefury'] then\n    Player.buffs['Icefury'].count = Player.buffs['Icefury'].count - 1\n    if Player.buffs['Icefury'].count == 0 then\n        Player.buffs['Icefury'] = nil\n    end\nend\n\nlocal spent = math.min(20, Player.resources['Maelstrom'])\nif Player.talents['Aftershock'] then\n    spent = spent * 0.7\nend\nPlayer.resources['Maelstrom'] = Player.resources['Maelstrom'] - spent\n\nif Player.buffs['Elemental Focus'] then\n    Player.buffs['Elemental Focus'].count = Player.buffs['Elemental Focus'].count - 1\n    if Player.buffs['Elemental Focus'].count <= 0 then\n        Player.buffs['Elemental Focus'] = nil\n    end\nend",
                        Cast = "",
                    },
                    ["Lightning Bolt"] = {
                        Instant = "",
                        Cast = "Player.resources['Maelstrom'] = math.min(Player.maxResources['Maelstrom'], Player.resources['Maelstrom'] + 8)\nif Player.buffs['Stormkeeper'] then\n    Player.buffs['Stormkeeper'].count = Player.buffs['Stormkeeper'].count - 1\n    if Player.buffs['Stormkeeper'].count == 0 then\n        Player.buffs['Stormkeeper'] = nil\n    end\nend\n\nif Player.buffs['Static Overload'] then\n    Player.buffs['Static Overload'] = nil\n    Player.buffs['Elemental Focus'] = { count = 2, timeRemaining = 10, caster = 'player'}\nelse\n    if Player.buffs['Elemental Focus'] then\n        Player.buffs['Elemental Focus'].count = Player.buffs['Elemental Focus'].count - 1\n        if Player.buffs['Elemental Focus'].count <= 0 then\n            Player.buffs['Elemental Focus'] = nil\n        end\n    end\nend",
                    },
                    ["Flame Shock"] = {
                        Instant = "Target.debuffs['Flame Shock'] = { count = 0, timeRemaining = 15, caster = 'player', }\n\nlocal spent = math.min(20, Player.resources['Maelstrom'])\nif Player.talents['Aftershock'] then\n    spent = spent * 0.7\nend\nPlayer.resources['Maelstrom'] = Player.resources['Maelstrom'] - spent\n\nif Player.buffs['Elemental Focus'] then\n    Player.buffs['Elemental Focus'].count = Player.buffs['Elemental Focus'].count - 1\n    if Player.buffs['Elemental Focus'].count <= 0 then\n        Player.buffs['Elemental Focus'] = nil\n    end\nend",
                        Cast = "",
                    },
                    ["Stormkeeper"] = {
                        Instant = "",
                        Cast = "Player.buffs['Stormkeeper'] = { count = 3, timeRemaining = 15, caster='player' }\nPlayer.buffs['Static Overload'] = { count = 0, timeRemaining = 15, caster='player' }\n",
                    },
                    ["Earthquake"] = {
                        Instant = "if Player.buffs['Echoes of the Great Sundering'] then\n    Player.buffs['Echoes of the Great Sundering'] = nil\nelseif Player.talents['Aftershock'] then\n    Player.resources['Maelstrom'] = Player.resources['Maelstrom'] - 35\nelse\n    Player.resources['Maelstrom'] = Player.resources['Maelstrom'] - 50\nend\n\nif Player.buffs['Elemental Focus'] then\n    Player.buffs['Elemental Focus'].count = Player.buffs['Elemental Focus'].count - 1\n    if Player.buffs['Elemental Focus'].count <= 0 then\n        Player.buffs['Elemental Focus'] = nil\n    end\nend",
                        Cast = "",
                    },
                    ["Elemental Blast"] = {
                        Instant = "",
                        Cast = "if Player.buffs['Elemental Focus'] then\n    Player.buffs['Elemental Focus'].count = Player.buffs['Elemental Focus'].count - 1\n    if Player.buffs['Elemental Focus'].count <= 0 then\n        Player.buffs['Elemental Focus'] = nil\n    end\nend",
                    },
                    ["Chain Lightning"] = {
                        Instant = "",
                        Cast = "Player.resources['Maelstrom'] = math.min(Player.maxResources['Maelstrom'], Player.resources['Maelstrom'] + 18)\nif Player.buffs['Stormkeeper'] then\n    Player.buffs['Stormkeeper'].count = Player.buffs['Stormkeeper'].count - 1\n    if Player.buffs['Stormkeeper'].count == 0 then\n        Player.buffs['Stormkeeper'] = nil\n    end\nend\n\nif Player.buffs['Static Overload'] then\n    Player.buffs['Static Overload'] = nil\n    Player.buffs['Elemental Focus'] = { count = 2, timeRemaining = 10, caster = 'player'}\nelse\n    if Player.buffs['Elemental Focus'] then\n        Player.buffs['Elemental Focus'].count = Player.buffs['Elemental Focus'].count - 1\n        if Player.buffs['Elemental Focus'].count <= 0 then\n            Player.buffs['Elemental Focus'] = nil\n        end\n    end\nend",
                    },
                    ["Earth Shock"] = {
                        Instant = "Player.resources['Maelstrom'] = Player.talents['Aftershock'] and (Player.resources['Maelstrom'] * 0.3) or 0\n\nif Player.buffs['Elemental Focus'] then\n    Player.buffs['Elemental Focus'].count = Player.buffs['Elemental Focus'].count - 1\n    if Player.buffs['Elemental Focus'].count <= 0 then\n        Player.buffs['Elemental Focus'] = nil\n    end\nend",
                        Cast = "",
                    },
                },
                BuffEffects = {
                    ["Auto Attack"] = "",
                },
                RegenEffects = {
                    ["Auto Attack"] = "",
                },
            },
        },
        ["Enhancement"] = {
            HastedCooldowns = {
                187874,    -- Crash Lightning
                193796,    -- Flametongue
                193786,    -- Rockbiter
                17364,     -- Stormstrike
            },
            Default = {
                Rules = {
                    {"Crash Lightning", "(Player.buffs['Spirit Wolf'] and (not Player.buffs['Alpha Wolf'] or Player.buffs['Alpha Wolf'].timeRemaining < 1.5) and Player.resources['Maelstrom'] >= 20)"},
                    {"Feral Spirit", "(Player.buffs['Bloodlust'] or Player.buffs['Time Warp'] or Player.buffs['Heroism'])"},
                    {"Doom Winds", "(Player.buffs['Stormbringer'])"},
                    {"Rockbiter", "(Player.talents['Landslide'] and (not Player.buffs['Landslide'] or Player.buffs['Landslide'].timeRemaining < 1.5 / (1 + Player.haste)))"},
                    {"Earthen Spike", "(true)"},
                    {"Flametongue", "(Player.buffs['Flametongue'] and Player.buffs['Flametongue'].timeRemaining < 4.5)"},
                    {"Stormstrike", "(Player.resources['Maelstrom'] >= 40)"},
                    {"Rockbiter", "(Player.spells['Rockbiter'].charges == 2 and Player.resources['Maelstrom'] < 130)"},
                    {"Lava Lash", "(Player.resources['Maelstrom'] >= 30)"},
                    {"Rockbiter", "(true)"},
                    {"Flametongue", "(true)"},
                    {"Auto Attack", "(true)"},
                },
                SpellEffects = {
                    ["Auto Attack"] = {
                        Instant = "",
                        Cast = "",
                    },
                    ["Earthen Spike"] = {
                        Instant = "Player.resources['Maelstrom'] = Player.resources['Maelstrom'] - 20",
                        Cast = "",
                    },
                    ["Frostbrand"] = {
                        Instant = "",
                        Cast = "",
                    },
                    ["Crash Lightning"] = {
                        Instant = "if Player.buffs['Spirit Wolf'] then\n    Player.buffs['Alpha Wolf'] = {count = 0, timeRemaining = 4, caster='player'}\nend",
                        Cast = "",
                    },
                    ["Lava Lash"] = {
                        Instant = "Player.resources['Maelstrom'] = Player.resources['Maelstrom'] - 30",
                        Cast = "",
                    },
                    ["Lightning Bolt"] = {
                        Instant = "",
                        Cast = "",
                    },
                    ["Flametongue"] = {
                        Instant = "Player.buffs['Flametongue'] = {count = 0, timeRemaining = 15, caster = 'player'}",
                        Cast = "",
                    },
                    ["Feral Spirit"] = {
                        Instant = "Player.buffs['Spirit Wolf'] = {count = 0, timeRemaining=12, caster='player'}",
                        Cast = "",
                    },
                    ["Stormstrike"] = {
                        Instant = "Player.resources['Maelstrom'] = Player.resources['Maelstrom'] - 40",
                        Cast = "",
                    },
                    ["Rockbiter"] = {
                        Instant = "if Player.talents['Landslide'] then\n    Player.buffs['Landslide'] = { count = 0, timeRemaining = 16, caster = 'player'}\nend\nPlayer.resources['Maelstrom'] = math.min(Player.maxResources['Maelstrom'], Player.resources['Maelstrom'] + 30)",
                        Cast = "",
                    },
                    ["Healing Surge"] = {
                        Instant = "",
                        Cast = "",
                    },
                    ["Doom Winds"] = {
                        Instant = "Player.buffs['Doom Winds'] = { count = 0, timeRemaining = 6, caster = 'player'}",
                        Cast = "",
                    },
                },
                BuffEffects = {
                    ["Auto Attack"] = "",
                },
                RegenEffects = {
                    ["Auto Attack"] = "",
                },
            },
        },
        ["Restoration"] = {
            HastedCooldowns = {
            },
            Default = {
                Rules = {
                    {"Flame Shock", "((not Target.debuffs['Flame Shock']) or Target.debuffs['Flame Shock'].timeRemaining < Player.spells['Lava Burst'].baseCastTime / (1 + Player.haste))"},
                    {"Lava Burst", "(true)"},
                    {"Lightning Bolt", "(true)"},
                },
                SpellEffects = {
                    ["Auto Attack"] = {
                        Instant = "",
                        Cast = "",
                    },
                    ["Lava Burst"] = {
                        Instant = "",
                        Cast = "Player.resources['Mana'] = Player.resources['Mana'] - 0.12 * Player.maxResources['Mana']\n                if Player.buffs['Lava Surge'] then\n    Player.buffs['Lava Surge'] = nil\nend\n",
                    },
                    ["Flame Shock"] = {
                        Instant = "Target.debuffs['Flame Shock'] = { count = 0, timeRemaining = 21, caster='player' }\n                Player.resources['Mana'] = Player.resources['Mana'] - 0.03 * Player.maxResources['Mana']\n",
                        Cast = "",
                    },
                },
                BuffEffects = {
                    ["Auto Attack"] = "",
                },
                RegenEffects = {
                    ["Auto Attack"] = "",
                },
            },
        },
    },
    ["Warlock"] = {
        ["Affliction"] = {
            HastedCooldowns = {
            },
            Default = {
                Rules = {
                    {"Auto Attack", "(true)"},
                },
                SpellEffects = {
                    ["Auto Attack"] = {
                        Instant = "",
                        Cast = "",
                    },
                },
                BuffEffects = {
                    ["Auto Attack"] = "",
                },
                RegenEffects = {
                    ["Auto Attack"] = "",
                },
            },
        },
        ["Demonology"] = {
            HastedCooldowns = {
            },
            Default = {
                Rules = {
                    {"Auto Attack", "(true)"},
                },
                SpellEffects = {
                    ["Auto Attack"] = {
                        Instant = "",
                        Cast = "",
                    },
                },
                BuffEffects = {
                    ["Auto Attack"] = "",
                },
                RegenEffects = {
                    ["Auto Attack"] = "",
                },
            },
        },
        ["Destruction"] = {
            HastedCooldowns = {
                17877,     -- Shadowburn
                196447,    -- Channel Demonfire
                17962,     -- Conflagrate
            },
            Default = {
                Rules = {
                    {"Auto Attack", "(true)"},
                },
                SpellEffects = {
                    ["Auto Attack"] = {
                        Instant = "",
                        Cast = "",
                    },
                },
                BuffEffects = {
                    ["Auto Attack"] = "",
                },
                RegenEffects = {
                    ["Auto Attack"] = "",
                },
            },
        },
    },
    ["Warrior"] = {
        ["Arms"] = {
            HastedCooldowns = {
                207982,    -- Focused Rage
                845,       -- Cleave
                12294,     -- Mortal Strike
            },
            Default = {
                Rules = {
                    {"Auto Attack", "(true)"},
                },
                SpellEffects = {
                    ["Auto Attack"] = {
                        Instant = "",
                        Cast = "",
                    },
                },
                BuffEffects = {
                    ["Auto Attack"] = "",
                },
                RegenEffects = {
                    ["Auto Attack"] = "",
                },
            },
        },
        ["Fury"] = {
            HastedCooldowns = {
                23881,     -- Bloodthirst
            },
            Default = {
                Rules = {
                    {"Auto Attack", "(true)"},
                },
                SpellEffects = {
                    ["Auto Attack"] = {
                        Instant = "",
                        Cast = "",
                    },
                },
                BuffEffects = {
                    ["Auto Attack"] = "",
                },
                RegenEffects = {
                    ["Auto Attack"] = "",
                },
            },
        },
        ["Protection"] = {
            HastedCooldowns = {
                6572,      -- Revenge
                2565,      -- Shield Block
                23922,     -- Shield Slam
                6343,      -- Thunder Clap
            },
            Default = {
                Rules = {
                    {"Auto Attack", "(true)"},
                },
                SpellEffects = {
                    ["Auto Attack"] = {
                        Instant = "",
                        Cast = "",
                    },
                },
                BuffEffects = {
                    ["Auto Attack"] = "",
                },
                RegenEffects = {
                    ["Auto Attack"] = "",
                },
            },
        },
    },
    ["Empty RuleSet"] = {
        Rules = {
            {"Auto Attack", "(true)"},
        },
        SpellEffects = {
            ["Auto Attack"] = {
                Instant = "",
                Cast = "",
            },
        },
        BuffEffects = {
            ["Auto Attack"] = "",
        },
        RegenEffects = {
            ["Auto Attack"] = "",
        },
    },
} -- Pred.Data ---------------------------------------------------------------------------------------------------------


-- Help message for help frame
Pred.Data.Help = [[
The aim of Prediction is to take your character's current state (gear, buffs, debuffs, etc) and attempt to predict what abilities you should be using within the next few moments. It does this by keeping an internal database of 'Rules' - similar to SimC - and a list of 'Effects'.  These Rules and Effects make use of a simple API that I have exposed for the player to use, and this config frame is primarily where you would enter these.  Your config frame is restricted to your class and talent specialization, but it allows you to select/make different configs of your own choosing, based on your selected talents and/or named rulesets.  The basic API exposed is listed below.

        Player {
            name            The character's name
            class           The character's class
            spec            The character's current specialization
            talents         A list of the character's chosen talents
            gear            A list of the character's equipped gear
            enchants        NOT YET IMPLEMENTED
            artifact        NOT YET IMPLEMENTED
            tier            NOT YET IMPLEMENTED
            haste           The character's haste value, where 1 = 100%
            hp_percent      The character's life, as percent
            resources       A list of resources the character may have, with associated values
            runes           For Death Knights, recharge times for each rune
            buffs           A named list of buffs that the character currently has
            debuffs         A named list of debuffs that the character currently has
            spells          A named list of spells that the character has available
        }
        Target {
            name            The target's name
            hp_percent      The target's life, as percent
            resources       A list of resources the target may have, with associated values
            buffs           A named list of buffs that the target currently has
            debuffs         A named list of debuffs that the target currently has
        }
        Buff/Debuff {
            count           How many stacks the buff/debuff has
            timeRemaining   How long the buff/debuff has left till it is exhausted, in seconds
            caster          Who cast the ability
        }
        Spell {
            spellId             The id of the spell
            name                The name of the spell
            icon                Path to the icon file
            baseCastTime        Cast time without haste taken into account
            castTime            Current cast time
            baseCooldown        Cooldown without haste and abilities taken into account
            effects             List of effects that this spell has on successful cast
            maxCharges          How many charges this spell may have
            currentCharges      How many charges the spell currently has
            remainingCooldown   How long (in seconds) till reusable
        }
 
Utility functions are also available:
         
         Player.runes.available How many runes are available right now
         AddRunes(x)            Recharge x runes
         UseRunes(x)            Use x runes
         Procced(chance)        Returns true chance percent of the time
         OverrideGCD(time)      Tell the engine the spell uses a different GCD.
         SetInstant()           Tells the engine the spell used an instant version instead of a cast.
         SetDelayEffect(time, instructions)
                                Tells the engine there is an effect that is delayed, e.g. Elemental T21_2PC causes Earthen Strength when spell lands, not when cast.
 
The author primarily plays an Elemental Shaman, so the data for that is pretty fleshed out, though possibly not optimal, and you are recommended to use it as an example of what to do. For example, the effect of the spell 'Flame Shock' is given below:

        Target.debuffs['Flame Shock'] = { count = 0, timeRemaining = 15, caster = 'player', }
        local spent = math.min(20, Player.resources['Maelstrom'])
        if Player.talents['Aftershock'] then
            spent = spent * 0.7
        end
        Player.resources['Maelstrom'] = Player.resources['Maelstrom'] - spent

 
Rules have two fields for you to enter - the name of the ability, and a condition that must evaluate to either TRUE or FALSE, with TRUE indicating that ability should be used. You do not need to check if the ability is available or off cooldown - Prediction will do that for you, before testing any other conditions.  For a real example, one of the conditions for 'Totem Mastery' as an Elemental Shaman is
        
        (not Player.buffs['Totem Mastery'] or Player.buffs['Totem Mastery'].timeRemaining < 1.5)


Rules are evaluated in order of prescription - the first ability found that is both available and matches it's condition is the ability that will be recommended at that time.  The addon then simulates the use of that ability, via it's Effect if defined, and continues to make predictions in this way until a predetermined limit (at the time of writing, 4) is reached.
 
 
RECOMMENDATIONS:
When checking the property of an item, particularly gear or debuff, you should check that the gear/debuff first exists.  E.g:
 
        (Target.debuffs['Flame Shock'] and Target.debuffs['Flame Shock'].timeRemaining < 9)
 
 
RESTRICTIONS:
It is recommended not to attempt to take into account the possibility of procs.  If there is demand for it, the author might add in a few extra bits of character information to help with such calculations, but atm they are considered 'nice surprises'.  When a proc happens, it will be taken into account in the next frame.
 
 
KNOWN ISSUES:
* GCD is not always taken into account correctly - some abilities have differing base GCDs, and at the moment Prediction doesn't differentiate between them.
* Artifact Traits, Enchants, and Tier bonuses are currently WIP.

]] -- Pred.Data.Help ---------------------------------------------------------------------------------------------------
RC_SPELLID_EXPERT_RIDING = 34090;
RC_SPELLID_ARTISAN_RIDING = 34091;
RC_SPELLID_MASTER_RIDING = 90265;
RC_SPELLID_COLD_FLYING = 54197;
RC_SPELLID_FLIGHT_LICENSE = 90267;
RC_SPELLID_BLACK_QIRAJI_BATTLE_TANK = 26656;
RC_SPELLID_ULTRAMARINE_QIRAJI_BATTLE_TANK = 92155;
RC_SPELLID_DRAENOR_PATHFINDER = 191645;
RC_SPELLID_BROKEN_ISLES_PATHFINDER = 233368;
RC_SPELLID_BFA_PATHFINDER = 278833;
RC_SPELLID_DRAGON_ISLES_PATHFINDER = 19307;

RC_GUILD_PAGE_ALLIANCE = 92395;
RC_GUILD_PAGE_HORDE = 92396;
RC_GUILD_HERALD_ALLIANCE = 92397;
RC_GUILD_HERALD_HORDE = 92398;

RC_MOUNTTYPE_GROUND = 230;
RC_MOUNTTYPE_ADVFLYING = 402;
RC_MOUNTTYPE_FLYING = 248;
RC_MOUNTTYPE_FLYINGCLOUD = 247;
RC_MOUNTTYPE_AQUATIC = 254;
RC_MOUNTTYPE_VASHJIR = 232;
RC_MOUNTTYPE_QIRAJI = 241;
RC_MOUNTTYPE_LOWLEVEL = 284;
RC_MOUNTTYPE_TURTLE = 231;
RC_MOUNTTYPE_KUAFON = 398;
RC_MOUNTTYPE_AQUAFLY = 407;
RC_MOUNTTYPE_DRAKE = 424;
RC_MOUNTTYPE_OTTUK = 412;
RC_MOUNTTYPE_SLOWSNAIL = 408;

RC_MAPID_VASHJIR = 203;
RC_MAPID_DRAENOR = 572;
RC_MAPID_BROKEN_ISLES = 619;
RC_MAPID_ZANDALAR = 875;
RC_MAPID_KUL_TIRAS = 876;
RC_MAPID_NAZJATAR = 1355;

RC_QUESTID_BUDDING_DEEPCORAL = 56766;

BINDING_HEADER_RANDOMCOMPANION = "RandomCompanion Bindings";
BINDING_NAME_RANDOMCOMPANION_MOUNT = "Random mount";
BINDING_NAME_RANDOMCOMPANION_MOUNT_GROUND = "Random ground mount";
BINDING_NAME_RANDOMCOMPANION_MOUNT_FLYING = "Random flying mount";
BINDING_NAME_RANDOMCOMPANION_MOUNT_PASSENGER = "Random passenger mount";
BINDING_NAME_RANDOMCOMPANION_MOUNT_AQUATIC = "Random aquatic mount";
BINDING_NAME_RANDOMCOMPANION_MOUNT_ADVFLYING = "Random advanced flying mount";
BINDING_NAME_RANDOMCOMPANION_PET_SUMMON = "Random vanity pet";
BINDING_NAME_RANDOMCOMPANION_PET_DISMISS = "Dismiss vanity pet";

RC_BUSY_AURA = {
    ["Food"] = true,
    ["Drink"] = true,
    ["Food & Drink"] = true,
    ["Graccu's Mince Meat Fruitcake"] = true,
    ["Stealth"] = true,
    ["Prowl"] = true,
    ["Shadowmeld"] = true,
    ["Invisibility"] = true,
    ["Flight Form"] = true,
    ["Swift Flight Form"] = true,
    ["Camouflage"] = true,
    ["Trapped in Amber"] = true,
    ["Recieve the Blessing of the Old God"] = true,
    ["Wisp Form"] = true,
    ["Endure the Transformation"] = true,
    ["Feign Death"] = true,
}

RC_STEALTH_AURA = {
    ["Stealth"] = true,
    ["Prowl"] = true,
    ["Shadowmeld"] = true,
    ["Invisibility"] = true,
    ["Camouflage"] = true,
    ["Feign Death"] = true,
}

RC_MOUNT_IDS = {
    passenger = {
        [55531] = true; --Mechano-Hog
        [60424] = true; --Mekgineer's Chopper
        --[61425] = true; --Traveler's Tundra Mammoth
        --[61447] = true; --Traveler's Tundra Mammoth
        [61465] = true; --Grand Black War Mammoth
        [61467] = true; --Grand Black War Mammoth
        [61469] = true; --Grand Ice Mammoth
        [61470] = true; --Grand Ice Mammoth
        [75973] = true; --X-53 Touring Rocket
        [93326] = true; --Sandstone Drake
        [121820] = true; --Obsidian Nightwing
		[307256] = true; --Explorer's Jungle Hopper
		[307263] = true; --Explorer's Dunetrekker
		[400733] = true; --Rocket Shredder 9001
        --[122708] = true; --Grand Expedition Yak
        --[261395] = true; --The Hivemind
    };
    flyingOnGround = {
        -- Flying Steeds
        [48025] = true; --Headless Horseman's Mount
        [75614] = true; --Celestial Steed
        [72286] = true; --Invincible
        [107203] = true; --Tyrael's Charger
        [134573] = true; --Swift Windsteed
        [136505] = true; --Ghastly Charger
        [142073] = true; --Hearthsteed
        [171847] = true; --Cindermane Charger

        --[[ Rockets
        [46197] = true; --X-51 Nether-Rocket
        [46199] = true; --X-51 Nether-Rocket X-TREME
        [71342] = true; --Big Love Rocket
        [75973] = true; --X-53 Touring Rocket
        [126507] = true; --Depleted-Kyparium Rocket
        [126508] = true; --Geosynchronous World Spinner
        [247448] = true; --Darkmoon Dirigible
        ]]

        --[[ Flying Carpets
        [61451] = true; --Flying Carpet
        [75596] = true; --Frosty Flying Carpet
        [61309] = true; --Magnificent Flying Carpet
        [233364] = true; --Leywoven Flying Carpet
        ]]

        -- Stone Cats
        [121837] = true; --Jade Panther
        [121838] = true; --Ruby Panther
        [121836] = true; --Sapphire Panther
        [121839] = true; --Sunstone Panther
        [120043] = true; --Jeweled Onyx Panther
        [98727] = true; --Winged Guardian
        [121820] = true; --Obsidian Nightwing

        -- Dogs
        [124659] = true; --Imperial Quilen
        [259395] = true; --Shu-Zen, the Divine Sentinel

        --[[ Discs
        [130092] = true; --Red Flying Cloud
        [229376] = true; --Archmage's Prismatic Disc
        ]]

        --[[ Pandaren Phoenix
        [132117] = true; --Ashen Pandaren Phoenix
        [129552] = true; --Crimson Pandaren Phoenix
        [132118] = true; --Emerald Pandaren Phoenix
        [132119] = true; --Violet Pandaren Phoenix
        [139448] = true; --Clutch of Ji-Kun
        ]]

        -- Mechanical Steeds
        [163024] = true; --Warforged Nightmare
        [142910] = true; --Ironbound Wraithcharger

        --[[ Dread Ravens
        [155741] = true; --Dread Raven
        [183117] = true; --Corrupted Dreadwing
        ]]

        -- Cats
        [180545] = true; --Mystic Runesaber
        [230897] = true; --Arcanist's Manasaber
        [229385] = true; --Ban-Lu, Grandmaster's Companion
        [243512] = true; --Luminous Starseeker

        --Mecha-Suits
        [134359] = true; --Sky Golem
        [182912] = true; --Felsteel Annihilator
        [223814] = true; --Mechanized Lumber Extractor
        [239013] = true; --Lightforged Warframe
		[400733] = true; --Rocket Shredder 9001

        -- Ravagers
        [163025] = true; --Grinning Reaver

        --[[ Wolfhawks
        [229438] = true; --Huntmaster's Fierce Wolfhawk
        [229439] = true; --Huntmaster's Dire Wolfhawk
        [229386] = true; --Huntmaster's Loyal Wolfhawk
        ]]

        -- Aquilons
        [186483] = true; --Forsworn Aquilon
        [186480] = true; --Battle-Hardened Aquilon
        [186482] = true; --Elysian Aquilon
        [186485] = true; --Ascendant's Aquilon

        -- Chargers
        [231435] = true; --Highlord's Golden Charger
        [231587] = true; --Highlord's Vengeful Charger
        [231588] = true; --Highlord's Vigilant Charger
        [231589] = true; --Highlord's Valorous Charger

        -- Elementals
        [231442] = true; --Farseer's Raging Tempest

        -- Undead Steeds
        [232412] = true; --Netherlord's Chaotic Wrathsteed
        [238452] = true; --Netherlord's Brimstone Wrathsteed
        [238454] = true; --Netherlord's Accursed Wrathsteed

        -- Demonic
        [243651] = true; --Shackled Ur'zul

        -- BfA 8.0
        [243795] = true; --Leaping Veinseeker
        [275841] = true; --Expedition Bloodswarmer
    };
    aquaticslow = {
        [64731] = true; --Sea Turtle
    };
};

RC_NOFLY_INSTANCE_IDS = {
    [754] = true, -- Throne of the Four Winds
    [1107] = true, -- Dreadscar Rift (Warlock)
    [1191] = true, -- Ashran PVP Area
    [1265] = true, -- Tanaan Jungle Intro
    [1463] = true, -- Helheim Exterior Area
    [1469] = true, -- Heart of Azeroth (Shaman)
    [1479] = true, -- Skyhold (Warrior)
    [1500] = true, -- Broken Shore DH Scenario
    [1514] = true, -- Wandering Isle (Monk)
    [1519] = true, -- Fel Hammer (DH)
    [1604] = true, -- Niskara, priest legion campaign
    [1688] = true, -- The Deadmines (Pet Battle)
    [1760] = true, -- Ruins of Lordaeron BfA opening
    [1813] = true, -- Island Expedition Un'gol Ruins
    [1882] = true, -- Island Expedition Verdant Wilds
    [1883] = true, -- Island Expedition Whispering Reef
    [1892] = true, -- Island Expedition Rotting Mire
    [1893] = true, -- Island Expedition The Dread Chain
    [1897] = true, -- Island Expedition Molten Cay
    [1898] = true, -- Island Expedition Skittering Hollow
    [1944] = true, -- Thros, The Blighted Lands (The Pride of Kul'Tiras)
};

RC_DEFAULT_DISABLED_PET_SPECIESIDS = {
    -- Guild Page/Herald
    [280] = true,
    [281] = true,
    [282] = true,
    [283] = true
}
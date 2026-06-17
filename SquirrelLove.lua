--=====================================================================
--  SquirrelLove  v1.0.2
--  Builds and maintains a self-advancing macro that targets critters
--  and /love's them for the "To All the Squirrels..." achievement line,
--  plus a button to drop every TomTom waypoint for the critter hunt.
--
--  WoW secure-code rules forbid fully automated target+emote loops, so
--  the player still presses a key. This addon keeps the macro current:
--    * reads each achievement's criteria live (completed ones skipped)
--    * builds a "SquirrelLove" macro of /tar lines split into 255-char
--      pages; each press hugs nearby critters then flips to the next
--    * when everything is done the macro becomes a harmless no-op.
--=====================================================================

local MACRO_NAME = "SquirrelLove"
local MACRO_ICON = 3732476         -- inv_squirrelflying
local MAX_MACRO  = 255
local VERSION    = "1.0.10"

local PAW_ICON = "|TInterface\\Icons\\INV_Pet_BattlePetTraining:12:12|t"

-- Pest Control (kill pests; not part of the /love macro).
local PEST_CONTROL_ID = 2556

SquirrelLoveDB = SquirrelLoveDB or {}

--=====================================================================
--  DATA
--  Just the achievement IDs and a display title. Every critter name is
--  read live from each achievement's criteria, so completed critters
--  and achievements are skipped automatically.
--=====================================================================
local ACHIEVEMENTS = {
  { id = 1206,  title = "To All the Squirrels I've Loved Before",          region = "EK/Kal" },
  { id = 2557,  title = "To All the Squirrels Who Shared My Life",         region = "NR" },
  { id = 5548,  title = "To All the Squirrels Who Cared for Me",           region = "Cata" },
  { id = 6350,  title = "To All the Squirrels I Once Caressed",            region = "Panda" },
  { id = 14728, title = "To All the Squirrels Through Time and Space",     region = "Draenor" },
  { id = 14729, title = "To All the Squirrels I Love Despite Their Scars", region = "Legion" },
  { id = 14730, title = "To All the Squirrels I Set Sail to See",          region = "BfA" },
  { id = 14731, title = "To All the Squirrels I've Loved and Lost",        region = "SL" },
  { id = 16729, title = "To All the Squirrels Hidden Til Now",             region = "DI" },
  { id = 18361, title = "To All the Squirrels Burrowed Beneath",           region = "Zaralek" },
}

local REGION_NAMES = {
  ["EK/Kal"]  = "Eastern Kingdoms / Kalimdor",
  ["NR"]      = "Northrend",
  ["Cata"]    = "Cataclysm",
  ["Panda"]   = "Pandaria",
  ["Draenor"] = "Draenor",
  ["Legion"]  = "Legion",
  ["BfA"]     = "Battle for Azeroth",
  ["SL"]      = "Shadowlands",
  ["DI"]      = "Dragon Isles",
  ["Zaralek"] = "Zaralek Cavern",
}

-- A few achievement criteria use a generic name (e.g. "Crab") while the
-- critter you actually /target has a fuller name. NAME_FIXES maps the
-- criterion text (lowercase) to the correct /target text, per
-- achievement. Add entries here if any critter ever mistargets.
local NAME_FIXES = {
  [1206] = {
    ["crab"] = "Shore Cra",   -- criterion "Crab" -> Shore Crab
    ["frog"] = "Small Fro",   -- criterion "Frog" -> Small Frog
  },
}

-- Achievement criterion name -> battle-pet journal names (full names).
-- Per-achievement overrides first; then PET_ALIASES by criterion key.
local PET_ALIASES_ACH = {
  -- "frog" only: criterion is generic, so don't alias it globally where it
  -- could mis-hint other achievements. "crab" falls through to PET_ALIASES.
  [1206] = {
    ["frog"] = { "Small Frog" },
  },
}

local PET_ALIASES = {
  ["crab"]    = { "Shore Crab" },
  ["creeper"] = {
    "Murky Creeper", "Mire Creeper", "Grimy Creeper",
    "Nibbling Creeper", "Slimy Creeper",
  },
}

--=====================================================================
--  TOMTOM WAYPOINTS
--  Each string is the text that follows "/way ". Fed straight to
--  TomTom's /way command, so zone names, map IDs (#123) and either
--  comma- or space-separated coordinates all work.
--=====================================================================
local WAYPOINTS = {
  -- To All the Squirrels I've Loved Before (1206) — Wowhead comment TomTom block
  "Elwynn Forest 32.31 53.81 Fawn",
  "Elwynn Forest 47.75 59.41 Deer",
  "Elwynn Forest 86.68 72.17 Cow",
  "Elwynn Forest 84.79 71.63 Rabbit",
  "Elwynn Forest 43.83 54.14 Cat",
  "Elwynn Forest 42.54 66.21 Chicken",
  "Elwynn Forest 77.27 53.76 Small Frog",
  "Elwynn Forest 65 76 Sheep",
  "Wetlands 48.29 68.06 Ram",
  "Wetlands 49 58 Toad",
  "Northern Barrens 48 44 Gazelle",
  "Northern Barrens 56 40 Swine",
  "Northern Barrens 68 30 Prairie Dog",
  "Durotar 41 17 Hare",
  "Un'Goro Crater 50.98 77.43 Parrot",
  "Shattrath City 59.21 22.51 Ewe",
  "Terokkar Forest 49.6 63.6 Squirrel",
  "Terokkar Forest 33 51 Skunk",
  "Zangarmarsh 82 85 Small Frog",
  "Zangarmarsh 70 49 Shore Crab",
  "Westfall 50 45 Prairie Dog",
  -- To All the Squirrels Who Shared My Life (2557)
  "Borean Tundra 51 73 Borean Marmot",
  "Borean Tundra 62 68 Tundra Penguin",
  "Borean Tundra 78 28 Steam Frog",
  "Borean Tundra 74 31 Borean Frog",
  "Howling Fjord 19 56 Fjord Penguin",
  "Howling Fjord 68 65 Fjord Turkey",
  "Howling Fjord 36 79 Scalawag Frog",
  "Dragonblight 28 50 Arctic Hare",
  "Grizzly Hills 57 35 Mountain Skunk",
  "Grizzly Hills 43 48 Grizzly Squirrel",
  "Sholazar Basin 27 60 Sholazar Tickbird",
  "Icecrown 67 25 Glacier Penguin",
  "Swamp of Sorrows 11 35 Huge Toad",
  "Searing Gorge 42 37 Lava Crab",
  -- To All the Squirrels Who Cared for Me (5548)
  "Stonetalon Mountains 61 80 Mountain Skunk",
  "Mount Hyjal 60 23 Chipmunk",
  "Mount Hyjal 58 22 Vole",
  "Mount Hyjal 69 67 Viper",
  "Shimmering Expanse 67 41 Whelk",
  "Shimmering Expanse 49 57 Cucumber",
  "Uldum 47 48 Moth",
  "Uldum 60 30 Frog",
  "Tol Barad Peninsula 69 47 Cat",
  "Tol Barad Peninsula 57 36 Rat",
  "Tol Barad 40 26 Fox",
  "Twilight Highlands 47 70 Marmot",
  "Twilight Highlands 46 48 Rattlesnake",
  "Twilight Highlands 51 35 Turkey",
  -- To All the Squirrels I Once Caressed (6350)
  "The Jade Forest 51 55 Leopard Tree Frog",
  "The Jade Forest 36 58 Shrine Fly",
  "The Jade Forest 64 82 Coral Adder",
  "Vale of Eternal Blossoms 32 68 Dancing Water Skimmer",
  "Vale of Eternal Blossoms 69 38 Gilded Moth",
  "Vale of Eternal Blossoms 69 23 Golden Civet",
  "Valley of The Four Winds 34 62 Malayan Quillrat",
  "Valley of The Four Winds 32 53 Bandicoon",
  "Valley of The Four Winds 41 35 Marsh Fiddler",
  "Valley of The Four Winds 64 65 Sifan Otter",
  "Krasarang Wilds 81 19 Amethyst Spiderling",
  "Krasarang Wilds 75 7 Luyu Moth",
  "Dread Wastes 69 61 Clouded Hedgehog",
  "Dread Wastes 51 45 Resilient Roach",
  "Dread Wastes 54 82 Emperor Crab",
  "Townlong Steppes 62 67 Mongoose",
  "Townlong Steppes 76 82 Yakrat",
  -- To All the Squirrels Through Time and Space (14728)
  "Frostfire Ridge 66.69 76.35 Frostfur Rat",
  "Frostfire Ridge 66.69 76.35 Icespine Hatchling",
  "Gorgrond 42.40 38.99 Parched Lizard",
  "Gorgrond 53.95 68.79 Twilight Wasp",
  "Nagrand:Draenor 72.89 42.27 Leatherhide Runt",
  "Shadowmoon Valley:Draenor 44.97 48.71 Moon Snake",
  "Shadowmoon Valley:Draenor 39.96 17.03 Moonshell Crab",
  "Shadowmoon Valley:Draenor 48.30 83.25 Mossbite Skitterer",
  "Shadowmoon Valley:Draenor 39 36 Royal Moth",
  "Spires of Arak 38.23 29.72 Mud Jumper",
  "Spires of Arak 63.29 53.96 Thicket Skitterer",
  "Talador 46.71 85.55 Brilliant Bloodfeather",
  "Talador 57.05 74.31 Flat-Tooth Calf",
  "Talador 81.70 27.11 Shadow Sporebat",
  "Tanaan Jungle 48.48 51.22 Bloodbeak",
  -- To All the Squirrels I Love Despite Their Scars (14729)
  "Azsuna 31 35 Albatross Chick",
  "Azsuna 59 39 Coastal Sandpiper",
  "Azsuna 34 43 Felspider",
  "Azsuna 40 59 Tenebrous Snake",
  "Highmountain 57.0 55.6 Black-Footed Fox Kit",
  "Highmountain 54 42 Echo Batling (in cave)",
  "Highmountain 56 54 Long-Eared Owl",
  "Stormheim 62 51 Golden Eaglet",
  "Stormheim 55 46 Tiny Apparition",
  "Suramar 42 58 Glitterpool Frog",
  "Val'sharah 64 74 Auburn Ringtail",
  "Val'sharah 38 62 Blighthawk",
  "Val'sharah 55 73 Gleamhoof Fawn",
  -- To All the Squirrels I Set Sail to See (14730)
  "Stormsong Valley 45.87 62.73 Honey Bee",
  "Stormsong Valley 25.83 70.26 Olivewing",
  "Tiragarde Sound 77.72 47.90 Tiragarde Gull",
  "Tiragarde Sound 84.76 77.74 Fluttering Softwing",
  "Drustvar 59.81 21.85 Bramble Hare",
  "Drustvar 53.09 30.50 Drustbat",
  "Nazmir 30.30 66.91 Bloodfever Tarantula",
  "Nazmir 48.01 69.10 Nazmani Weevil",
  "Vol'dun 52.75 83.73 Vale Flutterby",
  "Zuldazar 67.11 41.89 Crested Gekkota",
  "Zuldazar 62.72 16.52 Jungle Gulper",
  "Dazar'alor:Zuldazar 43.53 36.77 Temple Beetle",
  -- To All the Squirrels I've Loved and Lost (14731)
  "Bastion 48.0 77.8 Soulwing Flitter",
  "Bastion 37.7 27.5 Darkened Wyrmling",
  "Bastion 54.9 13.5 Dreadfur Kit",
  "Maldraxxus 57.8 66.5 Bubbling Refuse",
  "Maldraxxus 49.0 60.1 Chittering Claw",
  "Maldraxxus 48.5 60.5 Writhing Rachis",
  "Ardenweald 35.2 57.5 Runewood Hoarder",
  "Ardenweald 51.9 61.2 Starmoth",
  "Ardenweald 40.8 28.1 Timber Kit",
  "Revendreth 39.0 49.3 Emaciated Bat (flying)",
  "Revendreth 70.9 76.5 Shardling",
  "Revendreth 56 58 Murky Creeper",
  -- To All the Squirrels Hidden Til Now (16729)
  "The Waking Shores 76.17 44.18 Kelp Nibbler",
  "The Waking Shores 65.15 28.38 Phoenix Hatchling",
  "The Waking Shores 58.31 72.05 Docile Kit",
  "Ohn'ahran Plains 22.14 63.78 Frilled Hatchling",
  "Ohn'ahran Plains 52.05 50.54 Thicket Glider",
  "Ohn'ahran Plains 51.72 51.79 Thunderspine Calf",
  "Azure Span 52.95 58.41 Timbertooth Kit",
  "Azure Span 49.92 57.61 Frost Spiderling",
  "Azure Span 28.89 41.94 Crimson Knocker",
  "Thaldraszus 56.09 68.71 Diminuitive Boghopper",
  "Thaldraszus 51.24 56.82 Reservoir Filly",
  "Thaldraszus 51.35 72.61 Rocdrop Scarab",
  -- To All the Squirrels Burrowed Beneath (18361)
  "Zaralek Cavern 58.45 74.22 Hissing Dustmoth",
  "Zaralek Cavern 37.96 71.07 Rock Martin",
  "Zaralek Cavern 52.04 75.21 Hatchling Dawdler",
  "Zaralek Cavern 36.40 54.17 Incense Cinder",
  "Zaralek Cavern 32.15 51.11 Phoenix Hatchling (up high)",
  "Zaralek Cavern 58.24 73.05 Pygmy Dawdler",
  "Zaralek Cavern 50.16 76.70 Skittering Pincher",
  "Zaralek Cavern 36.51 53.05 Magma Bubble",
  "Zaralek Cavern 50.03 64.69 Scuttering Beetle",
  "Zaralek Cavern 44.91 77.71 Aimless Snail",
}

-- Pest Control (2556): one or more TomTom pins per pest type.
-- Labels use a KILL: prefix so they stand out from /love waypoints.
local KILL_WAYPOINTS = {
  "Howling Fjord 56.8 54.0 KILL: Devouring Maggot",
  "Howling Fjord 34.0 78.0 KILL: Fjord Rat",
  "Howling Fjord 36.0 11.0 KILL: Roach",
  "Zul'Drak 45.0 63.0 KILL: Zul'Drak Rat",
  "Ghostlands 27.8 14.4 KILL: Larva",
  "Ghostlands 32.0 15.0 KILL: Maggot",
  "Ghostlands 28.0 12.0 KILL: Spider",
  "Badlands 49.6 52.8 KILL: Gold Beetle",
  "Winterspring 52.0 54.0 KILL: Crystal Spider",
  "Dalaran:Northrend 64.4 36.6 KILL: Underbelly Rat",
  "Hellfire Peninsula 17.0 48.0 KILL: Adder",
  "Hellfire Peninsula 18.0 47.0 KILL: Scorpion",
  "Swamp of Sorrows 48.0 45.0 KILL: Moccasin",
  "Searing Gorge 44.0 40.0 KILL: Fire Beetle",
  "Westfall 52.6 54.2 KILL: Mouse",
  "Westfall 39.6 49.8 KILL: Snake",
  "Terokkar Forest 49.0 54.0 KILL: Squirrel",
  "Grizzly Hills 78.0 30.0 KILL: Mouse",
  "Westfall 56.0 50.0 KILL: Rat",
  "Duskwood 17.2 57.4 KILL: Roach",
}

--=====================================================================
--  STATE
--=====================================================================
local pages         = {}
local pageIndex     = 1
local remaining     = 0
local pestRemaining = 0
local achStatus     = {}
local pestStatus    = {}
local pendingApply  = false
local rebuildQueued = false
local initialized   = false
local ui

--=====================================================================
--  HELPERS
--=====================================================================
local function Print(text)
  print("|cff66ccff[SquirrelLove]|r " .. tostring(text))
end

local function ShortTitle(title)
  return (title:gsub("^To All [Tt]he Squirrels%s*", ""))
end

local function RegionLong(tag)
  return (tag and REGION_NAMES[tag]) or tag or ""
end

local HEAD = "/cleartarget\n"
local TAIL = "/run SquirrelLove_Next()\n/stopmacro [noexists]\n/love"
local DONE_BODY =
  "/run print('|cff66ccff[SquirrelLove]|r all squirrel achievements complete!')"

--=====================================================================
--  ACHIEVEMENT / CRITTER READING
--  Every critter name is read live from the in-game achievement
--  criteria.  NAME_FIXES (above) corrects the few criteria whose
--  generic name (e.g. "Crab") differs from the critter you /target.
--=====================================================================
local function CritterTarget(achID, criteria)
  local fixes = NAME_FIXES[achID]
  return (fixes and fixes[criteria:lower()]) or criteria
end

--=====================================================================
--  BATTLE PET /love HINTS (Phase 1: detect owned, summonable pets)
--=====================================================================
local function PetCandidateNames(achID, critName)
  local key = critName:lower()
  local perAch = PET_ALIASES_ACH[achID]
  if perAch and perAch[key] then
    return perAch[key]
  end
  if PET_ALIASES[key] then
    return PET_ALIASES[key]
  end
  return { critName }
end

local function FindSummonablePet(candidates)
  if not (C_PetJournal and C_PetJournal.FindPetIDByName) then
    return nil
  end
  for _, name in ipairs(candidates) do
    local _, petGUID = C_PetJournal.FindPetIDByName(name)
    if petGUID and C_PetJournal.PetIsSummonable(petGUID) then
      return name, petGUID
    end
  end
  return nil
end

local function ComputePetHints()
  for _, ach in ipairs(ACHIEVEMENTS) do
    local st = achStatus[ach.id]
    if not st then
    elseif st.completed then
      st.petCount, st.petCritters = 0, nil
    else
      st.petCount = 0
      st.petCritters = {}
      local num = GetAchievementNumCriteria(ach.id) or 0
      for i = 1, num do
        local critName, _, critDone = GetAchievementCriteriaInfo(ach.id, i)
        if critName and critName ~= "" and not critDone then
          local petName = FindSummonablePet(PetCandidateNames(ach.id, critName))
          if petName then
            st.petCount = st.petCount + 1
            st.petCritters[#st.petCritters + 1] = {
              crit = critName,
              pet  = petName,
            }
          end
        end
      end
      if st.petCount == 0 then
        st.petCritters = nil
      end
    end
  end
end

local function ShowAchRowTooltip(achID)
  local name = select(2, GetAchievementInfo(achID))
  GameTooltip:SetText(name or ("Achievement " .. achID), 1, 1, 1)
  for _, ach in ipairs(ACHIEVEMENTS) do
    if ach.id == achID and ach.region then
      GameTooltip:AddLine(RegionLong(ach.region), 0.53, 0.67, 0.8)
      break
    end
  end
  GameTooltip:AddLine("Click to open it in the Achievement panel.", 0.6, 0.6, 0.6)
  local st = achStatus[achID]
  if st and st.petCritters then
    GameTooltip:AddLine(" ")
    GameTooltip:AddLine("Summonable battle pets:", 1, 0.82, 0)
    for _, p in ipairs(st.petCritters) do
      GameTooltip:AddLine(
        ("  %s  |cffffffff/summonpet %s|r"):format(p.crit, p.pet),
        0.75, 0.75, 0.75)
    end
    GameTooltip:AddLine("Then /love your summoned pet.", 0.6, 0.6, 0.6)
  end
end

--=====================================================================
--  COMPUTE WHAT IS STILL NEEDED
--=====================================================================
local function ComputeNeeded()
  local needed, seen = {}, {}
  remaining = 0

  for _, ach in ipairs(ACHIEVEMENTS) do
    local _, name, _, completed = GetAchievementInfo(ach.id)
    local num  = GetAchievementNumCriteria(ach.id) or 0
    local left = 0

    -- A completed achievement contributes nothing.
    for i = 1, num do
      local critName, _, critDone = GetAchievementCriteriaInfo(ach.id, i)
      if critName and critName ~= "" and not completed and not critDone then
        left = left + 1
        local target = CritterTarget(ach.id, critName)
        local key = target:lower()
        if not seen[key] then
          seen[key] = true
          needed[#needed + 1] = target
          remaining = remaining + 1
        end
      end
    end

    achStatus[ach.id] = {
      completed = completed and true or false,
      remaining = left,
      total     = num,
      name      = name,
    }
  end

  return needed
end

local function ComputePestStatus()
  local _, name, _, completed = GetAchievementInfo(PEST_CONTROL_ID)
  local num  = GetAchievementNumCriteria(PEST_CONTROL_ID) or 0
  local left = 0

  for i = 1, num do
    local _, _, critDone = GetAchievementCriteriaInfo(PEST_CONTROL_ID, i)
    if not completed and not critDone then
      left = left + 1
    end
  end

  pestRemaining = left
  pestStatus = {
    completed = completed and true or false,
    remaining = left,
    total     = num,
    name      = name or "Pest Control",
  }
end

--=====================================================================
--  BUILD MACRO PAGES (each <= 255 characters)
--=====================================================================
local function BuildPages(needed)
  local result = {}
  local budget = MAX_MACRO - #HEAD - #TAIL - 1
  local lines, len = {}, 0

  local function flush()
    if #lines > 0 then
      result[#result + 1] = HEAD .. table.concat(lines, "\n") .. "\n" .. TAIL
      lines, len = {}, 0
    end
  end

  for _, name in ipairs(needed) do
    local line = "/tar " .. name
    local add  = #line + (#lines > 0 and 1 or 0)
    if #lines > 0 and (len + add) > budget then
      flush()
      add = #line
    end
    lines[#lines + 1] = line
    len = len + add
  end
  flush()

  return result
end

--=====================================================================
--  MACRO MANAGEMENT
--=====================================================================
local function MacroIndex()
  local idx = GetMacroIndexByName(MACRO_NAME)
  return (idx and idx ~= 0) and idx or nil
end

local function EnsureMacro()
  if MacroIndex() then return end
  local ok, idx = pcall(CreateMacro, MACRO_NAME, MACRO_ICON,
    "/run print('SquirrelLove: type /sqlove')", false)
  if not ok or not idx then
    Print("|cffff5555Could not create the macro - your macro list may be full.|r")
  end
end

local function SetMacroBody(body)
  if InCombatLockdown() then
    pendingApply = true
    return
  end
  local idx = MacroIndex()
  if not idx then
    EnsureMacro()
    idx = MacroIndex()
  end
  if idx then
    pcall(EditMacro, idx, MACRO_NAME, MACRO_ICON, body)
  end
end

local function ApplyCurrentPage()
  if #pages == 0 then
    SetMacroBody(DONE_BODY)
  else
    if pageIndex > #pages then pageIndex = 1 end
    SetMacroBody(pages[pageIndex])
  end
end

--=====================================================================
--  REBUILD
--=====================================================================
local function Rebuild()
  if InCombatLockdown() then
    pendingApply = true
    return
  end
  local needed = ComputeNeeded()
  ComputePestStatus()
  ComputePetHints()
  pages = BuildPages(needed)
  if pageIndex > #pages then pageIndex = 1 end
  ApplyCurrentPage()
  if ui then ui.Update() end
end

local function QueueRebuild()
  if rebuildQueued then return end
  rebuildQueued = true
  C_Timer.After(1.0, function()
    rebuildQueued = false
    Rebuild()
  end)
end

--=====================================================================
--  PAGE ADVANCE  (called by the macro itself via /run)
--=====================================================================
function SquirrelLove_Next()
  if #pages <= 1 then return end
  pageIndex = pageIndex + 1
  if pageIndex > #pages then pageIndex = 1 end
  C_Timer.After(0, function()
    ApplyCurrentPage()
    if ui then ui.Update() end
  end)
end

--=====================================================================
--  TOMTOM WAYPOINTS
--=====================================================================
-- TomTom uses only the description (text after x y) as the waypoint title;
-- the zone is used for map placement but not shown. Rebuild each line so
-- the title includes the zone, and fix wiki-style "24.83" -> 24 83 coords.
local function ParseWaypointLine(wp)
  local s = wp:gsub(",", " "):gsub("%s+", " ")
  local tokens = {}
  for t in s:gmatch("%S+") do
    tokens[#tokens + 1] = t
  end
  if #tokens < 2 then return nil end

  -- Zone is every token before the first number (the X coord); Y follows.
  local xIdx
  for idx = 1, #tokens do
    if tonumber(tokens[idx]) then
      xIdx = idx
      break
    end
  end
  if not xIdx or xIdx < 2 then return nil end

  local x = tokens[xIdx]
  local y = tokens[xIdx + 1]
  if not tonumber(x) or not tonumber(y) then return nil end

  local zone = table.concat(tokens, " ", 1, xIdx - 1)
  local desc = table.concat(tokens, " ", xIdx + 2)
  if desc == "" then
    desc = zone
  end
  return zone, x, y, desc
end

local function FormatWaypointLine(zone, x, y, desc)
  if desc:sub(1, #zone) ~= zone then
    desc = zone .. ": " .. desc
  end
  return ("%s %s %s %s"):format(zone, x, y, desc)
end

-- Find the function registered for a slash command (e.g. "/way"),
-- whatever internal key the owning addon used.
local function GetSlashHandler(slash)
  slash = slash:lower()
  for key, func in pairs(SlashCmdList) do
    local i = 1
    while true do
      local cmd = _G["SLASH_" .. key .. i]
      if not cmd then break end
      if type(cmd) == "string" and cmd:lower() == slash then
        return func
      end
      i = i + 1
    end
  end
  return nil
end

local function AddWaypointList(list, kind)
  local hasTomTom = TomTom ~= nil
    or (C_AddOns and C_AddOns.IsAddOnLoaded and C_AddOns.IsAddOnLoaded("TomTom"))
  if not hasTomTom then
    Print("|cffff5555TomTom is not loaded.|r Install/enable the TomTom addon, then try again.")
    return
  end

  local handler = GetSlashHandler("/way")
  if not handler then
    Print("|cffff5555Could not reach TomTom's /way command.|r")
    return
  end

  local count = 0
  local skipped = 0
  for _, wp in ipairs(list) do
    local zone, x, y, desc = ParseWaypointLine(wp)
    if not zone then
      skipped = skipped + 1
      Print("|cffff5555skipped invalid waypoint (need zone X Y label):|r " .. wp)
    else
      pcall(handler, FormatWaypointLine(zone, x, y, desc))
      count = count + 1
    end
  end
  if skipped > 0 then
    Print(("skipped %d invalid waypoint(s)."):format(skipped))
  end
  Print(("added %d %s waypoints to TomTom. Use |cffffffff/way reset all|r to clear them."):format(
    count, kind))
end

local function AddWaypoints()
  AddWaypointList(WAYPOINTS, "critter /love")
end

local function AddKillWaypoints()
  AddWaypointList(KILL_WAYPOINTS, "KILL (Pest Control)")
end

--=====================================================================
--  PROGRESS WINDOW
--=====================================================================
local function BuildUI()
  local ROW_H    = 15
  local ROW_STEP = 16
  local ROW_W    = 312
  local LIST_TOP = -82

  local f = CreateFrame("Frame", "SquirrelLoveFrame", UIParent, "BackdropTemplate")
  f:SetSize(340, 428)
  f:SetPoint(
    SquirrelLoveDB.point or "CENTER", UIParent,
    SquirrelLoveDB.point or "CENTER",
    SquirrelLoveDB.x or 0, SquirrelLoveDB.y or 0)
  if f.SetBackdrop then
    f:SetBackdrop({
      bgFile   = "Interface\\DialogFrame\\UI-DialogBox-Background",
      edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
      tile = true, tileSize = 32, edgeSize = 24,
      insets = { left = 6, right = 6, top = 6, bottom = 6 },
    })
  end
  f:SetMovable(true)
  f:EnableMouse(true)
  f:SetClampedToScreen(true)
  f:RegisterForDrag("LeftButton")
  f:SetScript("OnDragStart", f.StartMoving)
  f:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    local p, _, _, x, y = self:GetPoint()
    SquirrelLoveDB.point, SquirrelLoveDB.x, SquirrelLoveDB.y = p, x, y
  end)

  local title = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
  title:SetPoint("TOP", 0, -14)
  title:SetText("SquirrelLove")

  local close = CreateFrame("Button", nil, f, "UIPanelCloseButton")
  close:SetPoint("TOPRIGHT", -4, -4)
  close:SetScript("OnClick", function() f:Hide() end)

  local summary = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  summary:SetPoint("TOP", title, "BOTTOM", 0, -8)

  local pageText = f:CreateFontString(nil, "OVERLAY", "GameFontDisable")
  pageText:SetPoint("TOP", summary, "BOTTOM", 0, -3)

  local rows = {}
  for i = 1, #ACHIEVEMENTS do
    local achID = ACHIEVEMENTS[i].id
    local row = CreateFrame("Button", nil, f)
    row:SetSize(ROW_W, ROW_H)
    row:SetPoint("TOPLEFT", f, "TOPLEFT", 14, LIST_TOP - (i - 1) * ROW_STEP)

    local hl = row:CreateTexture(nil, "HIGHLIGHT")
    hl:SetAllPoints()
    hl:SetColorTexture(1, 1, 1, 0.12)

    local paw = row:CreateTexture(nil, "OVERLAY")
    paw:SetSize(12, 12)
    paw:SetPoint("RIGHT", row, "RIGHT", 0, 0)
    paw:SetTexture("Interface\\Icons\\INV_Pet_BattlePetTraining")
    paw:Hide()

    local statusFS = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    statusFS:SetSize(50, ROW_H)
    statusFS:SetPoint("LEFT", row, "LEFT", 0, 0)
    statusFS:SetJustifyH("RIGHT")
    statusFS:SetWordWrap(false)

    local regionFS = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    regionFS:SetSize(52, ROW_H)
    regionFS:SetPoint("LEFT", statusFS, "RIGHT", 6, 0)
    regionFS:SetJustifyH("LEFT")
    regionFS:SetWordWrap(false)

    local titleFS = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    titleFS:SetPoint("LEFT", regionFS, "RIGHT", 6, 0)
    titleFS:SetPoint("RIGHT", paw, "LEFT", -4, 0)
    titleFS:SetJustifyH("LEFT")
    titleFS:SetWordWrap(false)

    row.status = statusFS
    row.region = regionFS
    row.title  = titleFS
    row.paw    = paw
    row.achID  = achID

    row:SetScript("OnClick", function(self)
      if OpenAchievementFrameToAchievement then
        OpenAchievementFrameToAchievement(self.achID)
      else
        if not AchievementFrame and AchievementFrame_LoadUI then
          AchievementFrame_LoadUI()
        end
        if not (AchievementFrame and AchievementFrame:IsShown()) then
          ToggleAchievementFrame()
        end
      end
    end)
    row:SetScript("OnEnter", function(self)
      GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
      ShowAchRowTooltip(self.achID)
      GameTooltip:Show()
    end)
    row:SetScript("OnLeave", function() GameTooltip:Hide() end)

    rows[i] = row
  end

  local pestRow = CreateFrame("Button", nil, f)
  pestRow:SetSize(ROW_W, ROW_H)
  pestRow:SetPoint("TOPLEFT", f, "TOPLEFT", 14, LIST_TOP - #ACHIEVEMENTS * ROW_STEP)
  local pestHL = pestRow:CreateTexture(nil, "HIGHLIGHT")
  pestHL:SetAllPoints()
  pestHL:SetColorTexture(1, 0.4, 0.4, 0.12)
  local pestStatusFS = pestRow:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  pestStatusFS:SetSize(50, ROW_H)
  pestStatusFS:SetPoint("LEFT", pestRow, "LEFT", 0, 0)
  pestStatusFS:SetJustifyH("RIGHT")
  pestStatusFS:SetWordWrap(false)
  local pestFS = pestRow:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  pestFS:SetPoint("LEFT", pestStatusFS, "RIGHT", 6, 0)
  pestFS:SetPoint("RIGHT", pestRow, "RIGHT", 0, 0)
  pestFS:SetJustifyH("LEFT")
  pestFS:SetWordWrap(false)
  pestRow.status = pestStatusFS
  pestRow.text   = pestFS
  pestRow.achID = PEST_CONTROL_ID
  pestRow:SetScript("OnClick", function(self)
    if OpenAchievementFrameToAchievement then
      OpenAchievementFrameToAchievement(self.achID)
    else
      if not AchievementFrame and AchievementFrame_LoadUI then
        AchievementFrame_LoadUI()
      end
      if not (AchievementFrame and AchievementFrame:IsShown()) then
        ToggleAchievementFrame()
      end
    end
  end)
  pestRow:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText("Pest Control", 1, 1, 1)
    GameTooltip:AddLine("Kill pests for this achievement. Use Add Kill Waypoints.", 0.6, 0.6, 0.6)
    GameTooltip:Show()
  end)
  pestRow:SetScript("OnLeave", function() GameTooltip:Hide() end)

  local petHint = f:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
  petHint:SetPoint("TOPLEFT", pestRow, "BOTTOMLEFT", 0, -6)
  petHint:SetPoint("TOPRIGHT", pestRow, "BOTTOMRIGHT", 0, -6)
  petHint:SetJustifyH("LEFT")
  petHint:SetText(PAW_ICON .. " On the right of a row: you own a summonable " ..
    "battle pet for a critter still needed. Hover that row for /summonpet " ..
    "names, then /love your pet.")

  local hint = f:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
  hint:SetPoint("TOPLEFT", petHint, "BOTTOMLEFT", 0, -8)
  hint:SetPoint("TOPRIGHT", petHint, "BOTTOMRIGHT", 0, -8)
  hint:SetJustifyH("LEFT")
  hint:SetText("Put the macro on an action bar and spam it while standing " ..
    "among critters. Each press hugs nearby critters, then flips to the " ..
    "next page.  Click an achievement to open it.")

  local function MakeButton(label)
    local b = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    b:SetSize(120, 22)
    b:SetText(label)
    return b
  end

  local way = MakeButton("Add Love Waypoints")
  way:SetPoint("BOTTOMLEFT", 16, 68)
  way:SetPoint("BOTTOMRIGHT", -16, 68)

  local killWay = MakeButton("Add Kill Waypoints")
  killWay:SetPoint("BOTTOMLEFT", 16, 44)
  killWay:SetPoint("BOTTOMRIGHT", -16, 44)

  local grab = MakeButton("Grab Macro")
  grab:SetPoint("BOTTOMLEFT", 16, 16)
  local rebuild = MakeButton("Rebuild")
  rebuild:SetPoint("BOTTOMRIGHT", -16, 16)

  way:SetScript("OnClick", AddWaypoints)
  killWay:SetScript("OnClick", AddKillWaypoints)
  grab:SetScript("OnClick", function()
    local idx = MacroIndex()
    if idx then
      PickupMacro(idx)
      Print("Macro is on your cursor - drop it onto an action bar.")
    else
      Print("Macro not found - click Rebuild first.")
    end
  end)
  rebuild:SetScript("OnClick", function()
    Rebuild()
    Print("Rebuilt.")
  end)

  local obj = { frame = f, pestRow = pestRow }
  function obj.Update()
    summary:SetText(("Critters: |cffffd100%d|r  |  Pests: |cffff8855%d|r"):format(
      remaining, pestRemaining))
    if #pages > 0 then
      pageText:SetText(("Macro page %d of %d"):format(pageIndex, #pages))
    else
      pageText:SetText("|cff55ff55All achievements complete!|r")
    end
    for i, ach in ipairs(ACHIEVEMENTS) do
      local st = achStatus[ach.id]
      local short = ShortTitle(ach.title)
      local reg = ach.region or ""
      if not st then
        rows[i].status:SetText("")
        rows[i].region:SetText("|cff888888" .. reg .. "|r")
        rows[i].title:SetText("|cff888888" .. short .. "|r")
      elseif st.completed then
        rows[i].status:SetText("|cff55ff55Done|r")
        rows[i].region:SetText("|cff888888" .. reg .. "|r")
        rows[i].title:SetText("|cff888888" .. short .. "|r")
      else
        rows[i].status:SetText(("|cffff8855%d left|r"):format(st.remaining))
        rows[i].region:SetText("|cff88aacc" .. reg .. "|r")
        rows[i].title:SetText(short)
      end
      if rows[i].paw then
        if st and st.petCount and st.petCount > 0 then
          rows[i].paw:Show()
        else
          rows[i].paw:Hide()
        end
      end
    end
    local pst = pestStatus
    if not pst or not pst.total then
      pestRow.status:SetText("")
      pestRow.text:SetText("|cff888888Pest Control|r")
    elseif pst.completed then
      pestRow.status:SetText("|cff55ff55Done|r")
      pestRow.text:SetText("|cff888888Pest Control|r")
    else
      pestRow.status:SetText(("|cffff5555%d left|r"):format(pst.remaining))
      pestRow.text:SetText("Pest Control")
    end
  end

  obj.Update()
  f:Hide()
  return obj
end

-- Lazily build the window; survives any error in BuildUI.
local function EnsureUI()
  if ui then return ui end
  local ok, res = pcall(BuildUI)
  if ok and res then
    ui = res
  else
    Print("|cffff5555window failed to build:|r " .. tostring(res))
  end
  return ui
end

--=====================================================================
--  MINIMAP BUTTON
--=====================================================================
local minimapBtn

local function MinimapRadius()
  -- Place the button center just outside the minimap rim, regardless
  -- of how the user has scaled or resized their minimap.
  local w = (Minimap and Minimap:GetWidth()) or 140
  return (w / 2) + 5
end

local function UpdateMinimapPos()
  if not minimapBtn then return end
  local angle = math.rad(SquirrelLoveDB.minimapAngle or 198)
  local r = MinimapRadius()
  minimapBtn:ClearAllPoints()
  minimapBtn:SetPoint("CENTER", Minimap, "CENTER",
    math.cos(angle) * r, math.sin(angle) * r)
end

local function UpdateMinimapShown()
  if not minimapBtn then return end
  if SquirrelLoveDB.minimapHide then
    minimapBtn:Hide()
  else
    minimapBtn:Show()
  end
end

local function ToggleWindow()
  local w = EnsureUI()
  if w then
    if w.frame:IsShown() then w.frame:Hide() else w.frame:Show() end
  end
end

local function BuildMinimapButton()
  if minimapBtn or not Minimap then return end
  local atan2 = math.atan2 or math.atan

  local b = CreateFrame("Button", "SquirrelLoveMinimapButton", Minimap)
  b:SetFrameStrata("MEDIUM")
  b:SetFrameLevel(8)
  b:SetSize(31, 31)
  b:RegisterForClicks("LeftButtonUp", "RightButtonUp")
  b:RegisterForDrag("LeftButton")

  local icon = b:CreateTexture(nil, "BACKGROUND")
  icon:SetSize(20, 20)
  icon:SetTexture(MACRO_ICON)
  icon:SetPoint("CENTER", 0, 1)

  local border = b:CreateTexture(nil, "OVERLAY")
  border:SetSize(53, 53)
  border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
  border:SetPoint("TOPLEFT")

  b:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

  local function dragUpdate()
    local mx, my = Minimap:GetCenter()
    if not mx then return end
    local scale  = Minimap:GetEffectiveScale()
    local cx, cy = GetCursorPosition()
    cx, cy = cx / scale, cy / scale
    SquirrelLoveDB.minimapAngle = math.deg(atan2(cy - my, cx - mx))
    UpdateMinimapPos()
  end
  b:SetScript("OnDragStart", function(self) self:SetScript("OnUpdate", dragUpdate) end)
  b:SetScript("OnDragStop",  function(self) self:SetScript("OnUpdate", nil) end)

  b:SetScript("OnClick", function(_, button)
    if button == "RightButton" then
      SquirrelLoveDB.minimapHide = true
      UpdateMinimapShown()
      Print("minimap button hidden. Type /sqlove minimap to show it again.")
    else
      ToggleWindow()
    end
  end)

  b:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_LEFT")
    GameTooltip:SetText("SquirrelLove", 1, 1, 1)
    GameTooltip:AddLine("Left-click: toggle the window.", 0.8, 0.8, 0.8)
    GameTooltip:AddLine("Right-click: hide this button.", 0.8, 0.8, 0.8)
    GameTooltip:AddLine("Paw icon on a row: summonable battle pet owned.", 0.6, 0.8, 1)
    GameTooltip:AddLine(remaining .. " critters, " .. pestRemaining .. " pests left.", 0.6, 0.6, 0.6)
    GameTooltip:Show()
  end)
  b:SetScript("OnLeave", function() GameTooltip:Hide() end)

  minimapBtn = b
  UpdateMinimapPos()
  UpdateMinimapShown()
end

--=====================================================================
--  INITIALIZE
--=====================================================================
local function Initialize()
  if initialized then return end
  initialized = true
  EnsureUI()
  BuildMinimapButton()
  EnsureMacro()
  C_Timer.After(2.0, function()
    Rebuild()
    Print(("ready - %d critters to go. Click the minimap button to open the window."):format(remaining))
  end)
end

--=====================================================================
--  SLASH COMMANDS
--=====================================================================
SLASH_SQUIRRELLOVE1 = "/sqlove"
SLASH_SQUIRRELLOVE2 = "/squirrellove"
SlashCmdList["SQUIRRELLOVE"] = function(arg)
  arg = (arg or ""):lower():gsub("%s+", "")

  if arg == "grab" then
    local idx = MacroIndex()
    if idx then
      PickupMacro(idx)
      Print("Macro is on your cursor - drop it onto an action bar.")
    else
      Print("Macro not found - type /sqlove rebuild first.")
    end

  elseif arg == "rebuild" then
    Rebuild()
    Print("Rebuilt. " .. remaining .. " critters remaining.")

  elseif arg == "way" or arg == "waypoints" then
    AddWaypoints()

  elseif arg == "killway" or arg == "kill" or arg == "pest" then
    AddKillWaypoints()

  elseif arg == "minimap" then
    SquirrelLoveDB.minimapHide = not SquirrelLoveDB.minimapHide
    UpdateMinimapShown()
    if SquirrelLoveDB.minimapHide then
      Print("minimap button hidden. Type /sqlove minimap to show it again.")
    else
      Print("minimap button shown.")
    end

  elseif arg == "status" then
    Print(("%d critters and %d pests remaining."):format(remaining, pestRemaining))

  elseif arg == "debug" then
    Print(("v%s | macro index: %s | pages: %d | remaining: %d | ui: %s"):format(
      VERSION, tostring(MacroIndex()), #pages, remaining, ui and "ok" or "nil"))

  elseif arg == "show" then
    local w = EnsureUI()
    if w then w.frame:Show() end

  elseif arg == "hide" then
    local w = EnsureUI()
    if w then w.frame:Hide() end

  else
    local w = EnsureUI()
    if w then
      if w.frame:IsShown() then
        w.frame:Hide()
        Print("window hidden. Commands: show, hide, grab, rebuild, way, killway, minimap, status, debug.")
      else
        w.frame:Show()
      end
    else
      Print("commands: show, hide, grab, rebuild, way, killway, minimap, status, debug.")
    end
  end
end

--=====================================================================
--  EVENTS
--=====================================================================
local ev = CreateFrame("Frame")
ev:RegisterEvent("PLAYER_LOGIN")
ev:RegisterEvent("PLAYER_ENTERING_WORLD")
ev:RegisterEvent("CRITERIA_UPDATE")
ev:RegisterEvent("ACHIEVEMENT_EARNED")
ev:RegisterEvent("PLAYER_REGEN_ENABLED")
ev:RegisterEvent("PET_JOURNAL_LIST_UPDATE")
ev:SetScript("OnEvent", function(_, event)
  if event == "PLAYER_LOGIN" then
    Initialize()
  elseif event == "PLAYER_REGEN_ENABLED" then
    if pendingApply then
      pendingApply = false
      Rebuild()
    end
  else
    QueueRebuild()
  end
end)

-- If the addon was loaded after PLAYER_LOGIN already fired, init now.
if IsLoggedIn() then
  Initialize()
end

-- Load-time confirmation: if you DON'T see this line after /reload,
-- the addon's code is not running (out-of-date gate or bad install).
Print("v" .. VERSION .. " loaded. Type /sqlove")

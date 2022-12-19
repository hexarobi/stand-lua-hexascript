-- HexaScript
-- a Lua script the Stand Mod Menu for GTA5
-- Save this file in `Stand/Lua Scripts`
-- by Hexarobi

local SCRIPT_VERSION = "0.13b6"
local AUTO_UPDATE_BRANCHES = {
    { "main", {}, "More stable, but updated less often.", "main", },
    { "dev", {}, "Cutting edge updates, but less stable.", "dev", },
}
local SELECTED_BRANCH_INDEX = 2
local selected_branch = AUTO_UPDATE_BRANCHES[SELECTED_BRANCH_INDEX][1]

---
--- Auto-Updater Lib Install
---

-- Auto Updater from https://github.com/hexarobi/stand-lua-auto-updater
local status, auto_updater = pcall(require, "auto-updater")
if not status then
    local auto_update_complete = nil util.toast("Installing auto-updater...", TOAST_ALL)
    async_http.init("raw.githubusercontent.com", "/hexarobi/stand-lua-auto-updater/main/auto-updater.lua",
            function(result, headers, status_code)
                local function parse_auto_update_result(result, headers, status_code)
                    local error_prefix = "Error downloading auto-updater: "
                    if status_code ~= 200 then util.toast(error_prefix..status_code, TOAST_ALL) return false end
                    if not result or result == "" then util.toast(error_prefix.."Found empty file.", TOAST_ALL) return false end
                    filesystem.mkdir(filesystem.scripts_dir() .. "lib")
                    local file = io.open(filesystem.scripts_dir() .. "lib\\auto-updater.lua", "wb")
                    if file == nil then util.toast(error_prefix.."Could not open file for writing.", TOAST_ALL) return false end
                    file:write(result) file:close() util.toast("Successfully installed auto-updater lib", TOAST_ALL) return true
                end
                auto_update_complete = parse_auto_update_result(result, headers, status_code)
            end, function() util.toast("Error downloading auto-updater lib. Update failed to download.", TOAST_ALL) end)
    async_http.dispatch() local i = 1 while (auto_update_complete == nil and i < 40) do util.yield(250) i = i + 1 end
    if auto_update_complete == nil then error("Error downloading auto-updater lib. HTTP Request timeout") end
    auto_updater = require("auto-updater")
end
if auto_updater == true then error("Invalid auto-updater lib. Please delete your Stand/Lua Scripts/lib/auto-updater.lua and try again") end

---
--- Auto-Update
---

local auto_update_config = {
    source_url="https://raw.githubusercontent.com/hexarobi/stand-lua-hexascript/main/HexaScript.lua",
    script_relpath=SCRIPT_RELPATH,
    switch_to_branch=selected_branch,
    verify_file_begins_with="--",
    dependencies={
        {
            name="constants",
            source_url="https://raw.githubusercontent.com/hexarobi/stand-lua-hexascript/main/lib/constants.lua",
            script_relpath="lib/hexascript/constants.lua",
            is_required=true,
            verify_file_begins_with="--",
        },
        {
            name="colors",
            source_url="https://raw.githubusercontent.com/hexarobi/stand-lua-hexascript/main/lib/colors.lua",
            script_relpath="lib/hexascript/colors.lua",
            switch_to_branch=selected_branch,
            is_required=true,
        },
        {
            name="natives-1651208000",
            source_url="https://raw.githubusercontent.com/hexarobi/stand-lua-hexascript/main/lib/natives-1651208000.lua",
            script_relpath="lib/natives-1651208000.lua",
            verify_file_begins_with="--",
            is_required=true,
        },
        --{
        --    name="inspect",
        --    source_url="https://raw.githubusercontent.com/hexarobi/stand-lua-constructor/main/lib/inspect.lua",
        --    script_relpath="lib/inspect.lua",
        --    verify_file_begins_with="local",
        --    is_required=true,
        --},
    }
}
auto_updater.run_auto_update(auto_update_config)
local libs = {}
for _, dependency in pairs(auto_update_config.dependencies) do
    if dependency.loaded_lib == nil then
        util.toast("Error loading lib "..dependency.name, TOAST_ALL)
    end
    libs[dependency.name] = dependency.loaded_lib
end

local constants = libs.constants
local colorsRGB = libs.colors
--local inspect = libs.inspect

---
--- Config
---

local control_characters = {"!", "?", ".", "#", "@", "$", "%", "&"}

local config = {
    afk_mode = false,
    afk_mode_in_casino = true,
    chat_control_character = "!",
    chat_control_character_index = 1,
    num_allowed_spawned_vehicles_per_player = 2,
    auto_spectate_far_away_players = true,
    lobby_mode_index = 1,
    tick_handler_delay = 60000,
    announce_delay = 60,
}

local lobby_modes = {
    { "Public", {}, "Join an existing public lobby. Will often rejoin the previous session after being dropped.", "gopub" },
    { "New", {}, "Create a new empty public session.", "gosolopub" },
    { "Join Friend", {}, "Join a friends session.", "go joinafriend" },
    { "Friends Only", {}, "Create a new closed friends only session.", "go closedfriend" },
}

local VEHICLE_MODEL_SHORTCUTS = {
    moc = "trailerlarge",
    terrorbyte = "terbyte",
    ramp = "dune4",
    spacedocker = "dune2",
    wedge = "phantom2",
    phantomwedge = "phantom2",
    op = "oppressor",
    op2 = "oppressor2",
    br8 = "openwheel1",
    dr2 = "openwheel2",
    pr4 = "formula",
    r88 = "formula2",
    b11 = "strikeforce",
    weedvan = "youga4",
    airportbus = "airbus",
    prisonbus = "pbus",
    partybus = "pbus2",
    dominatorgtx = "dominator3",
    futogtx = "futo2",
    gokart = "veto",
    duneloader = "dloader",
    hellfire = "gauntlet4",
    luxordeluxe = "luxor2",
    swiftdeluxe = "swift2",
    antiaircraft = "trailersmall2",
    superdiamond = "superd",
    zz8 = "ruiner4",
    ingus = "ignus",
    iguns = "ignus",
    clownvan = "speedo2",
    blazeraqua = "blazer5",
    firetruck = "firetruk",
    utilitytruck = "utillitruck",
    utilitytruck2 = "utillitruck2",
    utilitytruck3 = "utillitruck3",
    jesterrr = "jester4",
    buffalostx = "buffalo4",
    vigerozx = "vigero2",
    stirlinggt = "feltzer3",
    ["10f"] = "tenf",
    ["10fwide"] = "tenf2",
    ["10f2"] = "tenf2",
    tank = "rhino",
    bodhi = "bodhi2",
    egt = "omnisegt",
    etr1 = "sheava",
    donk = "faction3",
    mallard = "stunt",
    ["811"] = "pfister811",
    sparrow = "seasparrow2",
    ultralight = "microlight",
    s80rr = "s80",
    re7b = "le7b",
    x80 = "prototipo",
    rattruck = "ratloader2",
    liberator = "monster",
    -- Thanks EndGame for additional aliases!
    d10 = "coquette4",
    xxr = "entity2",
    bug = "weevil",
    rsx = "italirsx",
    stx = "buffalo4",
    gtx = "dominator3",
    asp = "dominator7",
    gtt = "dominator8",
    dod = "dukes2",
    tank2 = "khanjali",
    tm02 = "khanjali",
    tank3 = "minitank",
    reaver = "reever",
    cabrio = "cogcabrio",
    ["370z"] = "euros",
    drag = "hakuchou2",
    ramp2 = "dune5",
    mini = "issi2",
    tb = "terbyte",
    lf22 = "starling",
    fh1 = "hunter",
    gtb = "italigtb",
    gtb2 = "italigtb2",
    xo = "torero2",
    dv8 = "deveste",
    roosevelt = "btype",
    frankenstange = "btype2",
    stange = "btype2",
    valor = "btype3",
    vette = "coquette2",
    stirling = "feltzer3",
    bond = "jb700",
    bond2 = "jb7002",
    bennyspeyote = "peyote3",
    bennystornado = "tornado5",
    gogo = "blista3",
    bennyscomet = "comet3",
    bennysspecter = "specter2",
    bennysbanshee = "banshee2",
    bennysmanana = "manana2",
    bennysgtb = "italigtb2",
    bennysnero = "nero2",
    bennysdonk = "faction3",
    donk = "faction3",
    bennysminivan = "minivan2",
    bennyssabre = "sabregt2",
    bennysvirgo = "virgo2",
    bennysbuccaneer = "buccaneer2",
    bennyschino = "chino2",
    bennysfaction = "faction2",
    bennysvoodoo = "voodoo",
    bennysgauntlet = "gauntlet5",
    mt = "entity3",
    minirally = "issi8",
    minisport = "issi7",
    panther = "panthere",
    ["300r"] = "r300",
    m100 = "tulip2",
}
local VEHICLE_BLOCK_FRIENDLY_SPAWNS = {
    kosatka = 1,
    jet = 2,
    cargoplane = 3,
    tug = 4,
    --alkonost = 4,
    --titan = 5,
    --volatol = 6,
}
local passthrough_commands = {
    {
        command="sprunk",
        help="Spawns a sprunkified vehicle and some cans",
        outbound_command="sprunk",
        requires_player_name=true,
    },
    "sprunkify",
    "sprunkrain",
    "spawnfor",
    "ecola",
--    {
--        command="casinojoin",
--        outbound_command="casinojoin",
--        requires_player_name=true,
--    },
    {
        command="tele",
        outbound_command="tele",
        requires_player_name=true,
    },
    {
        command="casinotp",
        outbound_command="casinotp",
        requires_player_name=true,
    },
    {
        command="animal",
        help="Turns into a random animal",
        outbound_command="furry",
        requires_player_name=true,
    },
}

---
--- Constructor Spawnable Constructs Passthrough Commands
---

local CONSTRUCTS_DIR = filesystem.stand_dir() .. 'Constructs\\'
local SPAWNABLE_DIR = CONSTRUCTS_DIR.."/spawnable"

local function load_spawnable_names_from_dir(directory)
    local spawnable_names = {}
    for _, filepath in ipairs(filesystem.list_files(directory)) do
        if not filesystem.is_dir(filepath) then
            local _, filename, ext = string.match(filepath, "(.-)([^\\/]-%.?)[.]([^%.\\/]*)$")
            table.insert(spawnable_names, filename)
        end
    end
    return spawnable_names
end

local function load_all_spawnable_names_from_dir(directory)
    local spawnable_names = load_spawnable_names_from_dir(directory)
    for _, filepath in ipairs(filesystem.list_files(directory)) do
        if filesystem.is_dir(filepath) then
            for _, construct_plan_file in pairs(load_all_spawnable_names_from_dir(filepath)) do
                table.insert(spawnable_names, construct_plan_file)
            end
        end
    end
    return spawnable_names
end

local spawnable_names = load_all_spawnable_names_from_dir(SPAWNABLE_DIR)
for _, spawnable_name in pairs(spawnable_names) do
    table.insert(
        passthrough_commands,
        {
            command=spawnable_name,
            help="Spawn a "..spawnable_name,
            outbound_command=spawnable_name,
            requires_player_name=true,
        }
    )
end

---
--- Utils
---

local function help_message(pid, message)
    if pid ~= nil and message ~= nil then
        if (type(message) == "table") then
            for _, message_part in pairs(message) do
                chat.send_targeted_message(pid, pid, message_part, false)
            end
        else
            chat.send_targeted_message(pid, pid, message, false)
        end
    end
end

local function announce_message(message)
    chat.send_message(message, false, true, true)
end

---
--- Casino AFK Mode
---

local function is_player_within_dimensions(dimensions, pid)
    if pid == nil then pid = players.user_ped() end
    local target_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
    local player_pos = ENTITY.GET_ENTITY_COORDS(target_ped)
    return (
            player_pos.x > dimensions.min.x and player_pos.x < dimensions.max.x
                    and player_pos.y > dimensions.min.y and player_pos.y < dimensions.max.y
                    and player_pos.z > dimensions.min.z and player_pos.z < dimensions.max.z
    )
end

local function force_roulette_area()
    if not is_player_within_dimensions({
        min={
            x=1130,
            y=240,
            z=-55,
        },
        max={
            x=1150,
            y=270,
            z=-45,
        },
    }, players.user()) then
        ENTITY.SET_ENTITY_COORDS(players.user_ped(), 1138.828, 256.55817, -51.035732)
    end
end

local function is_player_in_casino(pid)
    return is_player_within_dimensions({
        min={
            x=1073.9967,
            y=189.58717,
            z=-53.838943,
        },
        max={
            x=1166.935,
            y=284.88977,
            z=-42.28554,
        },
    }, pid)
end


--local function is_player_in_casino(pid)
--    local player_pos = players.get_position(pid)
--    -- Casino pos 1100.000, 220.000, -50.000
--    if player_pos.x > 900 and player_pos.x < 1300
--        and player_pos.y > 0 and player_pos.y < 500
--        and player_pos.z > -100 and player_pos.z < 0 then
--        return true
--    end
--    return false
--end

local function is_user_allowed_to_spawn_vehicles(pid, vehicle_model_name)
    local target_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
    if target_ped == players.user_ped() then   -- The user can spawn anything anywhere
        return true
    end
    if VEHICLE_BLOCK_FRIENDLY_SPAWNS[vehicle_model_name] ~= nil then    -- Block large vehicles from friendly spawns
        return false
    end
    if is_player_in_casino(pid) then
        return false
    end
    return true
end

local function load_hash(hash)
    STREAMING.REQUEST_MODEL(hash)
    while not STREAMING.HAS_MODEL_LOADED(hash) do
        util.yield()
    end
end

local players_spawned_vehicles = {}

local function get_player_spawned_vehicles(pid)
    for _, player_spawned_vehicles in pairs(players_spawned_vehicles) do
        if player_spawned_vehicles.pid == pid then
            return player_spawned_vehicles
        end
    end
    local new_player_spawned_vehicles = {pid=pid, vehicles={}}
    table.insert(players_spawned_vehicles, new_player_spawned_vehicles)
    return new_player_spawned_vehicles
end

local function despawn_for_player(pid)
    local player_spawned_vehicles = get_player_spawned_vehicles(pid)
    if #player_spawned_vehicles.vehicles >= config.num_allowed_spawned_vehicles_per_player then
        entities.delete_by_handle(player_spawned_vehicles.vehicles[1].handle)
        table.remove(player_spawned_vehicles.vehicles, 1)
    end
end

local function spawn_for_player(pid, vehicle)
    local player_spawned_vehicles = get_player_spawned_vehicles(pid)
    table.insert(player_spawned_vehicles.vehicles, {handle=vehicle})
end

local function spawn_vehicle_for_player(model_name, pid, offset)
    local model = util.joaat(model_name)
    if STREAMING.IS_MODEL_VALID(model) and STREAMING.IS_MODEL_A_VEHICLE(model) then
        despawn_for_player(pid)
        load_hash(model)
        local target_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        if offset == nil then offset = {x=0, y=4.0, z=0.5} end
        local pos = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(target_ped, offset.x, offset.y, offset.z)
        local heading = ENTITY.GET_ENTITY_HEADING(target_ped)
        local vehicle = entities.create_vehicle(model, pos, heading)
        STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(model)
        spawn_for_player(pid, vehicle)
        return vehicle
    end
end

local function vehicle_set_mod_max_value(vehicle, vehicle_mod)
    local max = VEHICLE.GET_NUM_VEHICLE_MODS(vehicle, vehicle_mod) - 1
    if vehicle_mod == 34 then max = -1 end  -- Don't set shifters to avoid crash
    VEHICLE.SET_VEHICLE_MOD(vehicle, vehicle_mod, max)
end

local function set_vehicle_mod_random_value(vehicle, vehicle_mod)
    local max = VEHICLE.GET_NUM_VEHICLE_MODS(vehicle, vehicle_mod) - 1
    VEHICLE.SET_VEHICLE_MOD(vehicle, vehicle_mod, math.random(-1, max))
end

local function max_mods(vehicle)
    VEHICLE.SET_VEHICLE_MOD_KIT(vehicle, 0)
    VEHICLE.SET_VEHICLE_WINDOW_TINT(vehicle, math.random(-1, constants.VEHICLE_MAX_OPTIONS.WINDOW_TINTS))
    for mod_name, mod_number in pairs(constants.VEHICLE_MOD_TYPES) do
        vehicle_set_mod_max_value(vehicle, mod_number)
    end
    for x = 17, 22 do
        VEHICLE.TOGGLE_VEHICLE_MOD(vehicle, x, true)
    end
    VEHICLE.SET_VEHICLE_TYRES_CAN_BURST(vehicle, false)
end

local function min_mods(vehicle)
    VEHICLE.SET_VEHICLE_MOD_KIT(vehicle, 0)
    VEHICLE.SET_VEHICLE_WINDOW_TINT(vehicle, math.random(-1, constants.VEHICLE_MAX_OPTIONS.WINDOW_TINTS))
    for mod_name, mod_number in pairs(constants.VEHICLE_MOD_TYPES) do
        VEHICLE.SET_VEHICLE_MOD(vehicle, mod_number, -1)
    end
    for x = 17, 22 do
        VEHICLE.TOGGLE_VEHICLE_MOD(vehicle, x, false)
    end
end

local function get_player_vehicle_handles()
    local player_vehicle_handles = {}
    for _, pid in pairs(players.list()) do
        local player_ped = PLAYER.GET_PLAYER_PED(pid)
        local veh = PED.GET_VEHICLE_PED_IS_IN(player_ped, false)
        if not ENTITY.IS_ENTITY_A_VEHICLE(veh) then
            veh = PED.GET_VEHICLE_PED_IS_IN(player_ped, true)
        end
        if not ENTITY.IS_ENTITY_A_VEHICLE(veh) then
            veh = 0
        end
        if veh then
            player_vehicle_handles[pid] = veh
        end
    end
    return player_vehicle_handles
end

local function is_entity_occupied(entity, type, player_vehicle_handles)
    if type == "VEHICLE" then
        for _, vehicle_handle in pairs(player_vehicle_handles) do
            if entity == vehicle_handle then
                return true
            end
        end
    end
    return false
end

local function delete_entities_by_range(my_entities, range, type, pid)
    local player_vehicle_handles = get_player_vehicle_handles()
    local player_pos = ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid), 1)
    local count = 0
    for _, entity in ipairs(my_entities) do
        local entity_pos = ENTITY.GET_ENTITY_COORDS(entity, 1)
        local dist = SYSTEM.VDIST(player_pos.x, player_pos.y, player_pos.z, entity_pos.x, entity_pos.y, entity_pos.z)
        if dist <= range then
            if not is_entity_occupied(entity, type, player_vehicle_handles) then
                entities.delete_by_handle(entity)
                count = count + 1
            end
        end
    end
    return count
end

local function delete_nearby_invis_vehicles(pid)
    local player_vehicle_handles = get_player_vehicle_handles()
    local player_pos = ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid), 1)
    local range = 500
    local count = 0
    for _, entity in ipairs(entities.get_all_vehicles_as_handles()) do
        local entity_pos = ENTITY.GET_ENTITY_COORDS(entity, 1)
        local dist = SYSTEM.VDIST(player_pos.x, player_pos.y, player_pos.z, entity_pos.x, entity_pos.y, entity_pos.z)
        if dist <= range then
            if not is_entity_occupied(entity, "VEHICLE", player_vehicle_handles) then
                if not VEHICLE.IS_VEHICLE_VISIBLE(entity) then
                    util.toast("Deleting invis vehicle")
                    entities.delete_by_handle(entity)
                    count = count + 1
                end
            end
        end
    end
    return count
end

---
--- Commands
---

local function shuffle_mods(vehicle)
    VEHICLE.SET_VEHICLE_MOD_KIT(vehicle, 0)
    VEHICLE.SET_VEHICLE_WINDOW_TINT(vehicle, math.random(-1, constants.VEHICLE_MAX_OPTIONS.WINDOW_TINTS))
    for mod_name, mod_number in pairs(constants.VEHICLE_MOD_TYPES) do
        -- Don't shuffle performance mods, wheels, or livery
        if not (mod_number == constants.VEHICLE_MOD_TYPES.MOD_ARMOR
                or mod_number == constants.VEHICLE_MOD_TYPES.MOD_TRANSMISSION
                or mod_number == constants.VEHICLE_MOD_TYPES.MOD_ENGINE
                or mod_number == constants.VEHICLE_MOD_TYPES.MOD_BRAKES
                or mod_number == constants.VEHICLE_MOD_TYPES.MOD_FRONTWHEELS
                or mod_number == constants.VEHICLE_MOD_TYPES.MOD_BACKWHEELS
                or mod_number == constants.VEHICLE_MOD_TYPES.MOD_LIVERY
        ) then
            set_vehicle_mod_random_value(vehicle, mod_number)
        end
    end
    for x = 17, 22 do
        VEHICLE.TOGGLE_VEHICLE_MOD(vehicle, x, math.random() > 0.5)
    end
    VEHICLE._SET_VEHICLE_XENON_LIGHTS_COLOR(vehicle, math.random(-1, 12))
end

local function shuffle_livery(vehicle, pid, livery_number)
    local max_livery_number = VEHICLE.GET_NUM_VEHICLE_MODS(vehicle, constants.VEHICLE_MOD_TYPES.MOD_LIVERY) - 1
    if livery_number == nil then
        livery_number = math.random(-1, max_livery_number)
    end
    VEHICLE.SET_VEHICLE_MOD(vehicle, constants.VEHICLE_MOD_TYPES.MOD_LIVERY, tonumber(livery_number))
    help_message(pid, "Set vehicle livery to "..livery_number)
end

local function shuffle_horn(vehicle, pid, horn_number)
    local max_horn_number = VEHICLE.GET_NUM_VEHICLE_MODS(vehicle, constants.VEHICLE_MOD_TYPES.MOD_HORNS) - 1
    if horn_number == nil then
        horn_number = math.random(-1, max_horn_number)
    end
    VEHICLE.SET_VEHICLE_MOD(vehicle, constants.VEHICLE_MOD_TYPES.MOD_HORNS, tonumber(horn_number))
    help_message(pid, "Set vehicle horn to "..horn_number.." (of "..max_horn_number..")")
end

local function shuffle_wheels(vehicle, pid, commands)
    local wheel_type
    local wheel_kind
    if commands and commands[2] == "ghost" then
        commands[2] = "benny"
        commands[3] = "106"
        VEHICLE.SET_VEHICLE_EXTRA_COLOURS(vehicle, 0, 111)
    end
    if commands and commands[2] then
        wheel_type = constants.VEHICLE_WHEEL_TYPES[commands[2]:upper()]
        if not wheel_type then
            help_message(pid, "Unknown wheel type")
            return false
        end
    else
        wheel_type = math.random(-1, constants.VEHICLE_MAX_OPTIONS.WHEEL_TYPES)
    end
    local max_wheel_kinds = VEHICLE.GET_NUM_VEHICLE_MODS(vehicle, constants.VEHICLE_MOD_TYPES.MOD_FRONTWHEELS) - 1
    if commands and commands[3] then
        wheel_kind = commands[3]
    else
        wheel_kind = math.random(-1, max_wheel_kinds)
    end
    local name = wheel_type
    for wheel_type_name, wheel_type_number in pairs(constants.VEHICLE_WHEEL_TYPES) do
        if wheel_type_number == tonumber(wheel_type) then
            name = wheel_type_name
        end
    end
    VEHICLE.SET_VEHICLE_WHEEL_TYPE(vehicle, wheel_type)
    VEHICLE.SET_VEHICLE_MOD(vehicle, constants.VEHICLE_MOD_TYPES.MOD_FRONTWHEELS, wheel_kind)
    VEHICLE.SET_VEHICLE_MOD(vehicle, constants.VEHICLE_MOD_TYPES.MOD_BACKWHEELS, wheel_kind)
    help_message(pid, "Set wheels to "..name.." type "..wheel_kind.." (of "..max_wheel_kinds..")")
    --set_vehicle_mod_random_value(vehicle, constants.VEHICLE_MOD_TYPES.MOD_FRONTWHEELS)
    --set_vehicle_mod_random_value(vehicle, constants.VEHICLE_MOD_TYPES.MOD_BACKWHEELS)
end

local function get_paint_type(optional_paint_type)
    if optional_paint_type then
        return optional_paint_type
    else
        return constants.VEHICLE_PAINT_TYPES.NORMAL
    end
end

local function get_command_color(command)
    if string.starts(command, "#") then
        return colorsRGB.DEC(command:sub(2))
    elseif colorsRGB.StandardColor(command) then
        return colorsRGB.StandardColor(command)
    elseif colorsRGB.colors_rgb[command] ~= nil then
        return colorsRGB.colors_rgb[command]
    end
end

local function set_vehicle_paint(pid, vehicle, commands)
    local main_color
    local secondary_color
    local paint_type = constants.VEHICLE_PAINT_TYPES.NORMAL
    if commands and commands[2] then
        for i, command in ipairs(commands) do
            if not main_color then
                local command_color = get_command_color(command)
                if command_color then
                    main_color = command_color
                    if command_color.a then
                        paint_type = get_paint_type(command_color.a)
                    end
                end
            end
            if command == "and" and get_command_color(commands[i+1]) then
                secondary_color = get_command_color(commands[i+1])
            end
            if command == "compliment" then
                secondary_color = colorsRGB.COMPLIMENT(main_color)
            end
            local command_paint_type = constants.VEHICLE_PAINT_TYPES[command:upper()]
            if command_paint_type then
                paint_type = command_paint_type
            end
        end
    end
    if not main_color then
        main_color = colorsRGB.random_color()
    end
    if not secondary_color then
        secondary_color = main_color
    end
    if main_color.index ~= nil then
        help_message(pid, "Painting vehicle standard "..main_color.name)
        VEHICLE.SET_VEHICLE_MOD_COLOR_1(vehicle, paint_type, main_color.index, 0)
        VEHICLE.SET_VEHICLE_COLOURS(
                vehicle,
                main_color.index,
                main_color.index
        )
        VEHICLE.CLEAR_VEHICLE_CUSTOM_PRIMARY_COLOUR(vehicle)
        VEHICLE.CLEAR_VEHICLE_CUSTOM_SECONDARY_COLOUR(vehicle)
    elseif main_color.r ~= nil then
        help_message(pid, "Painting vehicle custom color")
        VEHICLE.SET_VEHICLE_CUSTOM_PRIMARY_COLOUR(vehicle, main_color.r, main_color.g, main_color.b)
        VEHICLE.SET_VEHICLE_MOD_COLOR_1(vehicle, paint_type, 0, 0)
    end
    if secondary_color.index ~= nil then
        VEHICLE.SET_VEHICLE_MOD_COLOR_2(vehicle, paint_type, main_color.index, 0)
        VEHICLE.CLEAR_VEHICLE_CUSTOM_SECONDARY_COLOUR(vehicle)
    elseif secondary_color.r ~= nil then
        VEHICLE.SET_VEHICLE_CUSTOM_SECONDARY_COLOUR(vehicle, secondary_color.r, secondary_color.g, secondary_color.b)
        VEHICLE.SET_VEHICLE_MOD_COLOR_2(vehicle, paint_type, 0, 0)
    end
    VEHICLE.SET_VEHICLE_MOD(vehicle, constants.VEHICLE_MOD_TYPES.MOD_LIVERY, -1)
end

local function set_vehicle_secondary_paint(pid, vehicle, commands)
    local main_color
    local secondary_color
    local paint_type = constants.VEHICLE_PAINT_TYPES.NORMAL
    if commands and commands[2] then
        for i, command in ipairs(commands) do
            if not main_color then
                local command_color = get_command_color(command)
                if command_color then
                    secondary_color = command_color
                    if command_color[4] then
                        paint_type = get_paint_type(command_color[4])
                    end
                end
            end
            local command_paint_type = constants.VEHICLE_PAINT_TYPES[command:upper()]
            if command_paint_type then
                paint_type = command_paint_type
            end
        end
    end
    if not secondary_color then
        secondary_color = colorsRGB.random_color()
    end
    VEHICLE.SET_VEHICLE_CUSTOM_SECONDARY_COLOUR(vehicle, secondary_color.r, secondary_color.g, secondary_color.b)
    VEHICLE.SET_VEHICLE_MOD_COLOR_2(vehicle, paint_type, 0, 0)
end

local function shuffle_paint(vehicle)
    -- Dont apply custom paint to emergency vehicles
    if VEHICLE.GET_VEHICLE_CLASS(vehicle) == constants.VEHICLE_CLASSES.EMERGENCY then
        return
    end
    local main_color = colorsRGB.random_color()
    if main_color.r then
        VEHICLE.SET_VEHICLE_CUSTOM_PRIMARY_COLOUR(vehicle, main_color.r, main_color.g, main_color.b)
        VEHICLE.SET_VEHICLE_CUSTOM_SECONDARY_COLOUR(vehicle, main_color.r, main_color.g, main_color.b)
    end
end

local function shuffle_vehicle(vehicle)
    shuffle_mods(vehicle)
    shuffle_paint(vehicle)
    shuffle_wheels(vehicle)
end

local function vehicle_mods_set_max_performance(vehicle)
    vehicle_set_mod_max_value(vehicle, constants.VEHICLE_MOD_TYPES.MOD_ENGINE)
    vehicle_set_mod_max_value(vehicle, constants.VEHICLE_MOD_TYPES.MOD_TRANSMISSION)
    vehicle_set_mod_max_value(vehicle, constants.VEHICLE_MOD_TYPES.MOD_BRAKES)
    vehicle_set_mod_max_value(vehicle, constants.VEHICLE_MOD_TYPES.MOD_ARMOR)
    VEHICLE.TOGGLE_VEHICLE_MOD(vehicle, constants.VEHICLE_MOD_TYPES.MOD_TURBO, true)
end

local function removeVowels(inStr)
    local outStr, letter = ""
    local vowels = "AEIUOaeiou"
    for pos = 1, #inStr do
        letter = inStr:sub(pos, pos)
        if vowels:find(letter) then
            -- This letter is a vowel
        else
            outStr = outStr .. letter
        end
    end
    return outStr
end

local function plateify_text(plate_text)
    if string.len(plate_text) > 8 then
        plate_text = removeVowels(plate_text)
    end
    plate_text = string.sub(plate_text, 1, 8)
    return plate_text
end

local function vehicle_set_plate(vehicle, plate_text)
    ENTITY.SET_ENTITY_AS_MISSION_ENTITY(vehicle, true, true)
    VEHICLE.SET_VEHICLE_NUMBER_PLATE_TEXT(vehicle, plate_text)
    ENTITY.SET_ENTITY_AS_MISSION_ENTITY(vehicle, true, true)
end

local function get_enum_value_name(enum, enum_value)
    for key, value in pairs(enum) do
        if enum_value == value then
            return key
        end
    end
end

local function vehicle_set_plate_type(pid, vehicle, plate_type_num)
    if type(plate_type_num) == "string" then
        plate_type_num = constants.VEHICLE_PLATE_TYPES[plate_type_num:upper()]
    end
    if plate_type_num == nil then
        plate_type_num = math.random(0, 5)
    end
    local plate_type_name = get_enum_value_name(constants.VEHICLE_PLATE_TYPES, plate_type_num)
    ENTITY.SET_ENTITY_AS_MISSION_ENTITY(vehicle, true, true)
    VEHICLE.SET_VEHICLE_NUMBER_PLATE_TEXT_INDEX(vehicle, plate_type_num)
    help_message(pid, "Plate type set to " .. plate_type_name)
    end

local function vehicle_set_nameplate(vehicle, player_name)
    vehicle_set_plate(vehicle, plateify_text(player_name))
end

local function apply_vehicle_model_name_shortcuts(vehicle_model_name)
    if VEHICLE_MODEL_SHORTCUTS[vehicle_model_name] then
        return VEHICLE_MODEL_SHORTCUTS[vehicle_model_name]
    end
    return vehicle_model_name
end

local function show_busyspinner(text)
    HUD.BEGIN_TEXT_COMMAND_BUSYSPINNER_ON("STRING")
    HUD.ADD_TEXT_COMPONENT_SUBSTRING_PLAYER_NAME(text)
    HUD.END_TEXT_COMMAND_BUSYSPINNER_ON(2)
end

-- From Jackz Vehicle Options script
-- Gets the player's vehicle, attempts to request control. Returns 0 if unable to get control
local function get_player_vehicle_in_control(pid, opts)
    local my_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(players.user()) -- Needed to turn off spectating while getting control
    local target_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)

    -- Calculate how far away from target
    local pos1 = ENTITY.GET_ENTITY_COORDS(target_ped)
    local pos2 = ENTITY.GET_ENTITY_COORDS(my_ped)
    local dist = SYSTEM.VDIST2(pos1.x, pos1.y, 0, pos2.x, pos2.y, 0)

    local was_spectating = NETWORK.NETWORK_IS_IN_SPECTATOR_MODE() -- Needed to toggle it back on if currently spectating
    -- If they out of range (value may need tweaking), auto spectate.
    local vehicle = PED.GET_VEHICLE_PED_IS_IN(target_ped, true)
    if opts and opts.near_only and vehicle == 0 then
        return 0
    end
    if vehicle == 0 and target_ped ~= my_ped and dist > 340000 and not was_spectating then
        if not config.auto_spectate_far_away_players then
            help_message(pid, "Sorry, you are too far away right now, please try again later")
            return
        end
        util.toast("Player is too far, auto-spectating for upto 3s.")
        show_busyspinner("Player is too far, auto-spectating for upto 3s.")
        NETWORK.NETWORK_SET_IN_SPECTATOR_MODE(true, target_ped)
        -- To prevent a hard 3s loop, we keep waiting upto 3s or until vehicle is acquired
        local loop = (opts and opts.loops ~= nil) and opts.loops or 30 -- 3000 / 100
        while vehicle == 0 and loop > 0 do
            util.yield(100)
            vehicle = PED.GET_VEHICLE_PED_IS_IN(target_ped, true)
            loop = loop - 1
        end
        HUD.BUSYSPINNER_OFF()
    end

    if vehicle > 0 then
        if NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(vehicle) then
            return vehicle
        end
        -- Loop until we get control
        local netid = NETWORK.NETWORK_GET_NETWORK_ID_FROM_ENTITY(vehicle)
        local has_control_ent = false
        local loops = 15
        NETWORK.SET_NETWORK_ID_CAN_MIGRATE(netid, true)

        -- Attempts 15 times, with 8ms per attempt
        while not has_control_ent do
            has_control_ent = NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(vehicle)
            loops = loops - 1
            -- wait for control
            util.yield(15)
            if loops <= 0 then
                break
            end
        end
    end
    if not was_spectating then
        NETWORK.NETWORK_SET_IN_SPECTATOR_MODE(false, target_ped)
    end
    return vehicle
end

function string.starts(String,Start)
    return string.sub(String,1,string.len(Start))==Start
end

local function strsplit(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t={}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
        table.insert(t, str)
    end
    return t
end

local function spawn_shuffled_vehicle_for_player(vehicle_model_name, pid)
    if vehicle_model_name then
        vehicle_model_name = apply_vehicle_model_name_shortcuts(vehicle_model_name)
        if is_user_allowed_to_spawn_vehicles(pid, vehicle_model_name) then
            local vehicle = spawn_vehicle_for_player(vehicle_model_name, pid)
            if vehicle then
                max_mods(vehicle)
                shuffle_wheels(vehicle)
                shuffle_paint(vehicle)
                shuffle_livery(vehicle)
                vehicle_set_nameplate(vehicle, players.get_name(pid))
                return false
            end
        end
    end
end

--local function gift_vehicle_to_player(pid)
--    local vehicle = get_player_vehicle_in_control(pid)
--    if vehicle then
--        NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(vehicle);
--        local network_hash = NETWORK.NETWORK_HASH_FROM_PLAYER_HANDLE(pid)
--        for i = 1, 1, 50 do
--            --DECORATOR.DECOR_SET_INT(vehicle, "Veh_Modded_By_Player", network_hash)
--            --DECORATOR.DECOR_SET_INT(vehicle, "Player_Vehicle", network_hash)
--            --DECORATOR.DECOR_SET_INT(vehicle, "Previous_Owner", network_hash)
--            --DECORATOR.DECOR_SET_INT(vehicle, "MPBitSet", 0)
--            DECORATOR.DECOR_SET_INT(vehicle, "Player_Vehicle", NETWORK.NETWORK_HASH_FROM_PLAYER_HANDLE(pid))
--            DECORATOR.DECOR_SET_INT(vehicle, "PYV_Owner", NETWORK.NETWORK_HASH_FROM_PLAYER_HANDLE(pid))
--            DECORATOR.DECOR_SET_INT(vehicle, "PYV_Vehicle", NETWORK.NETWORK_HASH_FROM_PLAYER_HANDLE(pid))
--            VEHICLE.SET_VEHICLE_IS_STOLEN(vehicle, false);
--        end
--    end
--end

--local function gift_vehicle_to_player2(pid)
--    local vehicle = get_player_vehicle_in_control(pid)
--    if vehicle then
--            local networkId = NETWORK.VEH_TO_NET(vehicle);
--            if (NETWORK.NETWORK_GET_ENTITY_IS_NETWORKED(vehicle)) then
--                NETWORK.SET_NETWORK_ID_EXISTS_ON_ALL_MACHINES(networkId, true);
--                VEHICLE.SET_VEHICLE_IS_STOLEN(vehicle, false);
--                help_message(pid, "Success! You may now park your car in your garage. Make sure to REPLACE another car to keep this one!")
--            end
--        DECORATOR.DECOR_SET_INT(vehicle, "Player_Vehicle", NETWORK.NETWORK_HASH_FROM_PLAYER_HANDLE(pid))
--        DECORATOR.DECOR_SET_INT(vehicle, "PYV_Owner", NETWORK.NETWORK_HASH_FROM_PLAYER_HANDLE(pid))
--        DECORATOR.DECOR_SET_INT(vehicle, "PYV_Vehicle", NETWORK.NETWORK_HASH_FROM_PLAYER_HANDLE(pid))
--        help_message(pid, "Success! You may now park your car in your garage. Make sure to REPLACE another car to keep this one!")
--    end
--end

local function get_on_off(command)
    return command ~= "off"
end

local function get_on_off_string(command)
    return (get_on_off(command) and "ON" or "OFF")
end

local function get_menu_action_help(chat_command_options)
    if chat_command_options.help == nil then
        return ""
    end
    if (type(chat_command_options.help) == "table") then
        return chat_command_options.help[1]
    end
    return chat_command_options.help
end

local chat_commands = {}

local function add_chat_command(chat_command_options)
    table.insert(chat_commands, chat_command_options)
end

-- Help Commands

add_chat_command{
    command="help",
    help={
        "Welcome! Please don't grief others. For help with a specific command say !help <COMMAND>",
        "Available command categories: SELF, VEHICLE, MONEY",
    },
    func=function(pid, commands, this_chat_command)
        if type(commands) == "table" then
            for _, chat_command in ipairs(chat_commands) do
                if commands[2] == chat_command.command then
                    help_message(pid, chat_command.help)
                    return
                end
            end
        end
        help_message(pid, this_chat_command.help)
    end,
}

add_chat_command{
    command="self",
    help={
        "SELF commands: !autoheal, !bail, !allguns, !ammo, !animal, !tpme, !vip, !unstick, !noclip, !cleanup",
    }
}

add_chat_command{
    command="vehicle",
    help={
        "VEHICLE commands: !spawn, !invincible, !gift, !paint, !mods, !wheels, !shuffle, !tune",
        "!headlights, !neonlights, !wheelcolor, !tires, !livery, !plate, !platetype, !horn, !repair",
    }
}

add_chat_command{
    command="money",
    help={
        "The best way to make money is from running missions and heists! It's more fun and satisfying",
        "For a money boost try CEO pay (30k per min) use !vip for Org invite, then !ceopay",
        "For even bigger boost watch for the casino to be rigged, more info: !help roulette",
        "You can sell !deathbike2 for 1mil but limit sales to 2 per day to avoid any bans, more info: !help gift"
    },
    func=function(pid, commands, chat_command)
        help_message(pid, chat_command.help)
    end
}

add_chat_command{
    command="roulette",
    help={
        "HOW TO PLAY RIGGED ROULETTE: Enter the casino (!casinotp) get chips from cashier then enter the TABLE GAMES section.",
        "Find the HIGH LIMIT purple tables and take a seat at roulette. If you need VIP access join an org (!vip) or buy a penthouse.",
        "The ball will always land on 1. Press TAB for max bet, then click red \"1\" space once and the \"1st 12\" space five times.",
        "If you did it right you will bet 55k and win 330k per spin.",
        "You will get cut off for an hour after winning 13 in a row ($4mil), avoid by placing a small losing bet every 10 spins ($3mil)",
    },
    func=function(pid, commands, chat_command)
        help_message(pid, chat_command.help)
    end
}

add_chat_command{
    command="gift",
    help={
       "First fill a garage with FREE cars from Legendary Motor. Use !gift, then drive into garage and REPLACE a free car. For step-by-step instructions use !help gift1"
    },
    func=function(pid, commands)
        local vehicle = get_player_vehicle_in_control(pid)
        if vehicle == 0 then
            help_message(pid, "You must be in a vehicle to use !gift")
        else
            --delete_nearby_invis_vehicles(pid)
            local command_string = "gift " .. players.get_name(pid)
            menu.trigger_commands(command_string)
            help_message(pid, "Success! You may now park your car in your garage. Make sure to REPLACE another car to keep this one!")
        end
    end
}

add_chat_command{
    command="gift1",
    help={
        "TO KEEP SPAWNED CARS: #1 Buy a regular standalone 10-car garage.",
        "#2 Open phone, Legendary Motorsport, purchase any FREE car (2-door, Annis Elegy RH8)",
        "#3 Repeat step #2 until your garage is entirely full of FREE cars and you cannot order any more",
        "Once your garage is completely full, continue to next steps with !help gift2"
    },
    func=function(pid, commands, chat_command)
        help_message(pid, chat_command.help)
    end
}

add_chat_command{
    command="gift2",
    help={
        "#4 Spawn the car you want to keep by saying !spawn carname (or just !carname) and get in drivers seat",
        "#5 Say !gift to enable your vehicle to be driven into a garage",
        "#6 Drive into garage, and when prompted, choose YES to replace one of the free car with your spawned car",
        "If done correctly the vehicle should now be yours. For more tips and troubleshooting try !help gift3"
    },
    func=function(pid, commands, chat_command)
        help_message(pid, chat_command.help)
    end
}

add_chat_command{
    command="gift3",
    help={
        "Make sure to purchase insurance at LS Customs for each spawned vehicle, or it might be lost when destroyed.",
        "If something doesnt work, try resetting personal vehicle by driving an owned car out and back into garage.",
        "If garage door is blocked by invisible cars, clear them with !ramp or !cleanup",
    },
    func=function(pid, commands, chat_command)
        help_message(pid, chat_command.help)
    end
}

--add_chat_command{
--    command="moregift",
--    help={
--        "TO KEEP SPAWNED CARS: #1 Buy a regular standalone 10-car garage.",
--        "#2 Open phone, Legendary Motorsport, purchase any FREE car (2-door, Annis Elegy RH8)",
--        "#3 Repeat step #2 until your garage is entirely full of FREE cars and you cannot order any more",
--        "#4 Spawn the car you want to keep by saying !spawn carname (or just !carname) and get in drivers seat",
--        "#5 Say !gift to enable your vehicle to be driven into a garage",
--        "#6 Drive into garage, and when prompted, choose YES to replace one of the free car with your spawned car",
--        "#7 Take vehicle to LS customs and make sure it has insurance",
--        "#8 If something doesnt work, try resetting personal vehicle by driving an owned car out and back into garage",
--        "#9 If garage door is blocked, its probably invisible cars left in the way, clear them with !ramp or !cleanup",
--    },
--}

--add_chat_command{
--    command="gift2",
--    help={
--        "TO KEEP SPAWNED CARS: #1 Buy a regular standalone 10-car garage.",
--        "#2 Open phone, Legendary Motorsport, purchase any FREE car (2-door, Annis Elegy RH8)",
--        "#3 Repeat step #2 until your garage is entirely full of FREE cars and you cannot order any more",
--        "#4 Spawn the car you want to keep by saying !spawn carname (or just !carname) and get in drivers seat",
--        "#5 Say !gift to enable your vehicle to be driven into a garage",
--        "#6 Drive into garage, and when prompted, choose YES to replace one of the free car with your spawned car",
--        "#7 Take vehicle to LS customs and make sure it has insurance"
--    },
--    func=function(pid, commands)
--        gift_vehicle_to_player(pid)
--        help_message(pid, "Success! You may now park your car in your garage. Make sure to REPLACE another car to keep this one!")
--    end
--}

add_chat_command{
    command="vip",
    help="Request an org invite, useful for ceopay or VIP at casino.",
    func=function(pid, commands)
        -- Thanks to Totaw Annihiwation for this script event!
        util.trigger_script_event(1 << pid, {
            -1129846248,
            players.user(),
            4,
            10000, -- wage?
            0,
            0,
            0,
            0,
            memory.read_int(memory.script_global(1920255 + 9)), -- f_8
            memory.read_int(memory.script_global(1920255 + 10)), -- f_9
        })
        help_message(pid, "Org invite sent. Please check your phone to accept invite.")
    end
}

add_chat_command{
    command="cleanup",
    help="Clear unoccupied vehicles from immediate vicinity. Useful for clearing invis vehicles when gifting.",
    func=function(pid, commands)
        local num_deleted = delete_entities_by_range(entities.get_all_vehicles_as_handles(), 100, "VEHICLE", pid)
        help_message(pid, "Deleted "..num_deleted.." nearby vehicles")
    end
}

-- Vehicle Commands

add_chat_command{
    command="spawn",
    help="Spawn a shuffled vehicle",
    func=function(pid, commands)
        local vehicle = get_player_vehicle_in_control(pid)
        if vehicle then
            spawn_shuffled_vehicle_for_player(commands[2], pid)
        end
    end
}

local vehicles_list = {}
local file = io.open(filesystem.scripts_dir().."/lib/hexascript/vehicles.txt")
if file then
    for line in file:lines() do
        table.insert(vehicles_list, line)
    end
end

add_chat_command{
    command="car",
    help="Spawn a random vehicle",
    func=function(pid, commands)
        local model_name = vehicles_list[math.random(#vehicles_list)]
        spawn_shuffled_vehicle_for_player(model_name, pid)
    end
}

local function request_control_once(entity)
    if not NETWORK.NETWORK_IS_IN_SESSION() then
        return true
    end
    local netId = NETWORK.NETWORK_GET_NETWORK_ID_FROM_ENTITY(entity)
    NETWORK.SET_NETWORK_ID_CAN_MIGRATE(netId, true)
    return NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(entity)
end

add_chat_command{
    command="fly",
    help="Fly a plane",
    func=function(pid, commands)
        local vehicle_model_name = "lazer"
        if commands[2] ~= nil then
            vehicle_model_name = commands[2]
        end
        vehicle_model_name = apply_vehicle_model_name_shortcuts(vehicle_model_name)
        if is_user_allowed_to_spawn_vehicles(pid, vehicle_model_name) then
            local vehicle = spawn_vehicle_for_player(vehicle_model_name, pid, {x=0, y=4, z=30})
            if vehicle then
                vehicle_mods_set_max_performance(vehicle)
                shuffle_vehicle(vehicle)
                request_control_once(vehicle)
                PED.SET_PED_INTO_VEHICLE(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid), vehicle, -1)
                VEHICLE.SET_VEHICLE_FORWARD_SPEED(vehicle, 100)
            end
        end
    end
}

add_chat_command{
    command="shuffle",
    help="Shuffle your vehicle paint, mods, and wheels",
    func=function(pid, commands)
        local vehicle = get_player_vehicle_in_control(pid)
        if vehicle then
            shuffle_paint(vehicle)
            shuffle_mods(vehicle)
            shuffle_wheels(vehicle)
        end
        help_message(pid, "Shuffled your vehicle paint, mods and wheels")
    end
}

add_chat_command{
    command="paint",
    help={
        "Sets your vehicle paint. Allows for color names and paint type options",
        "Paint types: NORMAL, METALLIC, PEARL, MATTE, METAL, CHROME",
        "Example: !paint blue, !paint red and black, !paint metallic green",
        "Hex RGB color codes are allowed. Example: !paint #ff0000"
    },
    func=function(pid, commands)
        local vehicle = get_player_vehicle_in_control(pid)
        if vehicle then
            set_vehicle_paint(pid, vehicle, commands)
        end
    end
}

--add_chat_command{
--    command="clearcustompaint",
--    help={
--        "Sets your vehicle paint. Allows for color names and paint type options",
--        "Paint types: NORMAL, METALLIC, PEARL, MATTE, METAL, CHROME",
--        "Example: !paint blue, !paint red and black, !paint metallic green",
--        "Hex RGB color codes are allowed. Example: !paint #ff0000"
--    },
--    func=function(pid, commands)
--        local vehicle = get_player_vehicle_in_control(pid)
--        if vehicle then
--            VEHICLE.CLEAR_VEHICLE_CUSTOM_PRIMARY_COLOUR(vehicle)
--            VEHICLE.CLEAR_VEHICLE_CUSTOM_SECONDARY_COLOUR(vehicle)
--            --VEHICLE.SET_VEHICLE_COLOURS(vehicle, 151, 151)
--            VEHICLE.SET_VEHICLE_MOD_COLOR_1(vehicle, 3, 151)
--            VEHICLE.SET_VEHICLE_MOD_COLOR_2(vehicle, 3, 151)
--            help_message(pid, "Custom paint cleared")
--        end
--    end
--}

add_chat_command{
    command="paint2",
    help={
        "Sets your vehicle secondary paint. Allows for color names and paint type options",
        "Paint types: NORMAL, METALLIC, PEARL, MATTE, METAL, CHROME",
        "Example: !paint2 blue, !paint2 metallic green",
        "Hex RGB color codes are allowed. Example: !paint2 #ff0000"
    },
    func=function(pid, commands)
        local vehicle = get_player_vehicle_in_control(pid)
        if vehicle then
            set_vehicle_secondary_paint(pid, vehicle, commands)
        end
    end
}

add_chat_command{
    command="mods",
    help="Set the vehicles mods",
    func=function(pid, commands)
        local vehicle = get_player_vehicle_in_control(pid)
        if vehicle then
            if commands[2] == "max" then
                max_mods(vehicle)
            elseif commands[2] == "stock" then
                min_mods(vehicle)
            else
                shuffle_mods(vehicle)
            end
        end
    end
}

add_chat_command{
    command="wheels",
    help="Set the vehicles wheels",
    func=function(pid, commands)
        local vehicle = get_player_vehicle_in_control(pid)
        if vehicle then
            shuffle_wheels(vehicle, pid, commands)
        end
    end
}

local function get_vehicle_color_from_command(command)
    for _, vehicle_color in pairs(constants.VEHICLE_COLORS) do
        if vehicle_color.index == tonumber(command) or vehicle_color.name:lower() == command then
            return vehicle_color
        end
    end
end

local function set_extra_color(vehicle, pearl_color, wheel_color)
    local current_pearl_color = memory.alloc(8)
    local current_wheel_color = memory.alloc(8)
    VEHICLE.GET_VEHICLE_EXTRA_COLOURS(vehicle, current_pearl_color, current_wheel_color)
    pearl_color = get_vehicle_color_from_command(pearl_color)
    wheel_color = get_vehicle_color_from_command(wheel_color)
    if pearl_color == nil then pearl_color = {index=current_pearl_color} end
    if wheel_color == nil then wheel_color = {index=current_wheel_color} end
    VEHICLE.SET_VEHICLE_EXTRA_COLOURS(vehicle, pearl_color.index, wheel_color.index)
    memory.free(current_pearl_color)
    memory.free(current_wheel_color)
end

add_chat_command{
    command="wheelcolor",
    help="Set the vehicles wheel color",
    func=function(pid, commands)
        local vehicle = get_player_vehicle_in_control(pid)
        if vehicle then
            local color = get_vehicle_color_from_command(commands[2])
            if color then
                set_extra_color(vehicle, nil, color)
                help_message(pid, "Set vehicle wheel color to "..color.name.." ("..color.index..")")
            else
                help_message(pid, "Invalid color")
            end
        end
    end
}

add_chat_command{
    command="pearl",
    func=function(pid, commands)
        local vehicle = get_player_vehicle_in_control(pid)
        if vehicle then
            local color = get_vehicle_color_from_command(commands[2])
            if color then
                set_extra_color(vehicle, color, nil)
                help_message(pid, "Set vehicle pearl color to "..color.name.." ("..color.index..")")
            else
                help_message(pid, "Invalid color")
            end
        end
    end
}

local headlight_color_name_map = {
    default = -1,
    white = 0,
    blue = 1,
    electricblue = 2,
    mintgreen = 3,
    green = 4,
    limegreen = 4,
    yellow = 5,
    gold = 6,
    orange = 7,
    red = 8,
    pink = 9,
    ponypink = 9,
    hotpink = 10,
    purple = 11,
    blacklight = 12
}

add_chat_command{
    command="headlights",
    help="Set the vehicle headlights color",
    func=function(pid, commands)
        local vehicle = get_player_vehicle_in_control(pid)
        if vehicle then
            local color_number = tonumber(commands[2])
            local color_name = commands[2]
            if headlight_color_name_map[color_name] ~= nil then color_number = headlight_color_name_map[color_name] end
            if color_number < -1 or color_number > 12 then
                help_message(pid, "Invalid color")
                return
            end
            VEHICLE.TOGGLE_VEHICLE_MOD(vehicle, constants.VEHICLE_MOD_TYPES.MOD_XENONLIGHTS, true)
            VEHICLE._SET_VEHICLE_XENON_LIGHTS_COLOR(vehicle, color_number)
            help_message(pid, "Set vehicle headlight color to "..color_number)
        end
    end
}

add_chat_command{
    command="neonlights",
    help="Set the vehicle neon lights color",
    func=function(pid, commands)
        local vehicle = get_player_vehicle_in_control(pid)
        if vehicle then
            local color = get_command_color(commands[2])
            if not color then
                help_message(pid, "Invalid color")
                return
            end
            VEHICLE._SET_VEHICLE_NEON_LIGHT_ENABLED(vehicle, 0, true)
            VEHICLE._SET_VEHICLE_NEON_LIGHT_ENABLED(vehicle, 1, true)
            VEHICLE._SET_VEHICLE_NEON_LIGHT_ENABLED(vehicle, 2, true)
            VEHICLE._SET_VEHICLE_NEON_LIGHT_ENABLED(vehicle, 3, true)
            VEHICLE._SET_VEHICLE_NEON_LIGHTS_COLOUR(vehicle, color[1], color[2], color[3])
            help_message(pid, "Set vehicle neon lights color to "..commands[2])
        end
    end
}


add_chat_command{
    command="tiresmoke",
    help="Set the vehicle tire smoke color",
    func=function(pid, commands)
        local vehicle = get_player_vehicle_in_control(pid)
        if vehicle then
            local color = get_command_color(commands[2])
            if not color then
                help_message(pid, "Invalid color")
                return
            end
            VEHICLE.TOGGLE_VEHICLE_MOD(vehicle, 22, true)
            VEHICLE.SET_VEHICLE_TYRE_SMOKE_COLOR(vehicle, color[1], color[2], color[3])
            help_message(pid, "Set vehicle tire smoke color to "..commands[2])
        end
    end
}

add_chat_command{
    command="livery",
    help="Set the vehicles livery",
    func=function(pid, commands)
        local vehicle = get_player_vehicle_in_control(pid)
        if vehicle then
            shuffle_livery(vehicle, pid, commands[2])
        end
    end
}

add_chat_command{
    command="horn",
    help="Set the vehicles horn type",
    func=function(pid, commands)
        local vehicle = get_player_vehicle_in_control(pid)
        if vehicle then
            shuffle_horn(vehicle, pid, commands[2])
        end
    end
}

add_chat_command{
    command="blinkers",
    help="Set the vehicles blinkers",
    func=function(pid, commands)
        local vehicle = get_player_vehicle_in_control(pid)
        if vehicle then
            local side = 0
            if commands[2] == "left" then side = 1 end
            local state = true
            if commands[3] == "off" then state = false end
            VEHICLE.SET_VEHICLE_INDICATOR_LIGHTS(vehicle, side, state)
        end
    end
}

add_chat_command{
    command="plate",
    help="Set the vehicles plate text",
    func=function(pid, commands)
        local vehicle = get_player_vehicle_in_control(pid)
        if vehicle then
            vehicle_set_plate(vehicle, commands[2])
        end
    end
}

add_chat_command{
    command="platetype",
    help="Set the vehicles plate type",
    func=function(pid, commands)
        local vehicle = get_player_vehicle_in_control(pid)
        if vehicle then
            local plate_type
            if commands[2] then
                plate_type = commands[2]
            end
            vehicle_set_plate_type(pid, vehicle, plate_type)
        end
    end
}

add_chat_command{
    command="repair",
    help="Repairs your current vehicle",
    func=function(pid, commands)
        local vehicle = get_player_vehicle_in_control(pid)
        if vehicle then
            VEHICLE.SET_VEHICLE_FIXED(vehicle)
            help_message(pid, "Vehicle repaired")
        end
    end
}

add_chat_command{
    command="clean",
    help="Removed any dirt from your current vehicle",
    func=function(pid, commands)
        local vehicle = get_player_vehicle_in_control(pid)
        if vehicle then
            VEHICLE.SET_VEHICLE_DIRT_LEVEL(vehicle, 0)
            help_message(pid, "Vehicle cleaned")
        end
    end
}

add_chat_command{
    command="strip",
    help="Removes any removable extra parts on the vehicle",
    func=function(pid, commands)
        local vehicle = get_player_vehicle_in_control(pid)
        if vehicle then
            for x=0,50,1 do
                if VEHICLE.DOES_EXTRA_EXIST(vehicle, x) then
                    VEHICLE.SET_VEHICLE_EXTRA(vehicle, x, true)
                end
            end
            help_message(pid, "Vehicle stripped")
        end
    end
}

add_chat_command{
    command="suspension",
    help="Sets suspension height on the vehicle",
    func=function(pid, commands)
        local vehicle = get_player_vehicle_in_control(pid)
        if vehicle then
            local suspension_level
            if commands[2] then
                suspension_level = commands[2]
            end
            VEHICLE.SET_VEHICLE_MOD(vehicle, constants.VEHICLE_MOD_TYPES.MOD_SUSPENSION, suspension_level)
            help_message(pid, "Vehicle suspension "..suspension_level)
        end
    end
}

local window_tint_map = {
    none = -1,
    black = 0,
    dark = 1,
    light = 2,
    stock = 3,
    limo = 4,
    green = 5,
}

add_chat_command{
    command="windowtint",
    help="Sets suspension height on the vehicle",
    func=function(pid, commands)
        local vehicle = get_player_vehicle_in_control(pid)
        if vehicle then
            local tint_level = tonumber(commands[2])
            local tint_name = commands[2]
            if window_tint_map[tint_name] ~= nil then tint_level = window_tint_map[tint_name] end
            if tint_level < -1 or tint_level > 6 then
                help_message(pid, "Invalid tint")
                return
            end
            VEHICLE.SET_VEHICLE_WINDOW_TINT(vehicle, tint_level)
            help_message(pid, "Window tint "..tint_level)
        end
    end
}

add_chat_command{
    command="tires",
    help="Sets tires on the vehicle",
    func=function(pid, commands)
        local vehicle = get_player_vehicle_in_control(pid)
        if vehicle then
            if commands[2] == "burst" then
                VEHICLE.SET_VEHICLE_TYRES_CAN_BURST(vehicle, true)
                for wheel = 0,7 do
                    VEHICLE.SET_VEHICLE_TYRE_BURST(vehicle, wheel, true, 1000.0)
                end
                help_message(pid, "Vehicle tires burst ")
                return
            end
            if commands[2] == "bulletproof" then
                VEHICLE.SET_VEHICLE_TYRES_CAN_BURST(vehicle, false)
                help_message(pid, "Vehicle tires bulletproof")
            end
            if commands[2] == "drift" then
                VEHICLE.SET_VEHICLE_REDUCE_GRIP(vehicle, true)
                VEHICLE._SET_VEHICLE_REDUCE_TRACTION(vehicle, 3)
                help_message(pid, "Vehicle tires drift")
            end
            if commands[2] == "stock" then
                VEHICLE.SET_VEHICLE_REDUCE_GRIP(vehicle, false)
                VEHICLE._SET_VEHICLE_REDUCE_TRACTION(vehicle, 1.0)
                help_message(pid, "Vehicle tires stock[")
            end
        end
    end
}

add_chat_command{
    command="driftmode",
    help="Sets vehicle drift mode",
    func=function(pid, commands)
        local vehicle = get_player_vehicle_in_control(pid)
        if vehicle then
            vehicle_mods_set_max_performance(vehicle)
            local drift_mode = get_on_off_string(commands[2])
            if drift_mode == "ON" then
                util.toast("bursting")
                VEHICLE.SET_VEHICLE_TYRES_CAN_BURST(vehicle, true)
                VEHICLE.SET_VEHICLE_TYRE_BURST(vehicle, 2, false, 1000.0)
                VEHICLE.SET_VEHICLE_TYRE_BURST(vehicle, 3, false, 1000.0)
            else
                util.toast("fixing")
                VEHICLE.SET_VEHICLE_TYRE_BURST(vehicle, 2, false, 0.0)
                VEHICLE.SET_VEHICLE_TYRE_BURST(vehicle, 3, false, 0.0)
                VEHICLE.SET_VEHICLE_TYRES_CAN_BURST(vehicle, false)
            end
            help_message(pid, "Drift mode "..drift_mode)
        end
    end
}

add_chat_command{
    command="torque",
    help="Sets vehicle torque",
    func=function(pid, commands)
        local vehicle = get_player_vehicle_in_control(pid)
        if vehicle then
            local torque_value = 1.0
            if commands[2] then
                torque_value = commands[2] / 100
            end
            if torque_value == nil then torque_value = 1.0 end
            VEHICLE.SET_VEHICLE_CHEAT_POWER_INCREASE(vehicle, torque_value)
            help_message(pid, "Vehicle torque "..math.floor(torque_value * 100).. '%')
        end
    end
}

add_chat_command{
    command="stance",
    help="Lowers suspension on the vehicle",
    func=function(pid, commands)
        local vehicle = get_player_vehicle_in_control(pid)
        if vehicle then
            local enabled_string = get_on_off_string(commands[2])
            VEHICLE._SET_REDUCE_DRIFT_VEHICLE_SUSPENSION(vehicle, get_on_off(commands[2]))
            -- VEHICLE._SET_CAMBERED_WHEELS_DISABLED(vehicle, 0)
            help_message(pid, "Vehicle stance "..enabled_string)
        end
    end
}

add_chat_command{
    command="tune",
    help="Apply maximum performance options",
    func=function(pid, commands)
        local vehicle = get_player_vehicle_in_control(pid)
        if vehicle then
            vehicle_mods_set_max_performance(vehicle)
        end
    end
}

add_chat_command{
    command="noclip",
    help="Sets vehicle no clip",
    func=function(pid, commands)
        local vehicle = get_player_vehicle_in_control(pid)
        if vehicle then
            local enabled_string = get_on_off_string(commands[2])
            local enabled = (enabled_string == "ON")
            ENTITY.SET_ENTITY_COMPLETELY_DISABLE_COLLISION(vehicle, enabled, true)
            ENTITY.SET_ENTITY_COLLISION(vehicle, not enabled, false)
            help_message(pid, "No clip "..enabled_string)
        end
    end
}

add_chat_command{
    command="invincible",
    help="Set vehicle to god mode and prevent all damage",
    func=function(pid, commands)
        local vehicle = get_player_vehicle_in_control(pid)
        if vehicle then
            local enabled_string = get_on_off_string((commands and commands[2]) or "on")
            local enabled = (enabled_string == "ON")
            ENTITY.SET_ENTITY_INVINCIBLE(vehicle, enabled)
            help_message(pid, "Vehicle invincibility " .. enabled_string)
        end
    end
}

-- Self Commands

add_chat_command{
    command="tpme",
    help="Teleport to a nearby apartment. Good for when stuck in loading screens",
    func=function(pid, commands)
        menu.trigger_commands("aptme " .. players.get_name(pid))
    end
}

add_chat_command{
    command="tp",
    help="Teleport to your waypoint.",
    func=function(pid, commands)
        -- Copied from ACJokerScript
        local x, y, z, b = players.get_waypoint(pid)
        if HUD.IS_WAYPOINT_ACTIVE() then
            local curway = HUD.GET_BLIP_INFO_ID_COORD(HUD.GET_FIRST_BLIP_INFO_ID(8))
            HUD.SET_WAYPOINT_OFF()
            HUD.SET_NEW_WAYPOINT(x, y)
            if pid == players.user() then
                menu.trigger_commands("tpwp")
            else
                menu.trigger_commands("WPTP".. players.get_name(pid))
            end
            util.yield(1500)
            HUD.SET_NEW_WAYPOINT(curway.x, curway.y)
        else
            HUD.SET_NEW_WAYPOINT(x, y)
            menu.trigger_commands("WPTP".. players.get_name(pid))
            HUD.SET_WAYPOINT_OFF()
        end
    end
}

add_chat_command{
    command="unstick",
    help="Try to get unstuck from infinite loading screen",
    func=function(pid, commands)
        menu.trigger_commands("givesh " .. players.get_name(pid))
        help_message(pid, "Attempting to unstick you, good luck")
    end
}

add_chat_command{
    command="allguns",
    help="Get all possible weapons",
    func=function(pid, commands)
        menu.trigger_commands("arm " .. players.get_name(pid))
    end
}

add_chat_command{
    command="autoheal",
    help="Automatically heal any damage as quickly as possible",
    func=function(pid, commands)
        local enabled_string = get_on_off_string((commands and commands[2]) or "on")
        menu.trigger_commands("autoheal " .. players.get_name(pid) .. " " .. enabled_string)
        help_message(pid, "Autoheal " .. enabled_string)
    end
}

add_chat_command{
    command="otr",
    help="Go off the radar to hide from other players",
    func=function(pid, commands)
        local enabled_string = get_on_off_string((commands and commands[2]) or "on")
        menu.trigger_commands("giveotr " .. players.get_name(pid) .. " " .. enabled_string)
        help_message(pid, "Off the radar: " .. enabled_string)
    end
}

add_chat_command{
    command="bail",
    help="Avoid all wanted levels",
    func=function(pid, commands)
        local enabled_string = get_on_off_string(commands[2])
        menu.trigger_commands("bail " .. players.get_name(pid) .. " " .. enabled_string)
        help_message(pid, "Bail " .. enabled_string)
    end
}

add_chat_command{
    command="ammo",
    help="Add ammo for current weapon",
    func=function(pid, commands)
        menu.trigger_commands("ammo" .. players.get_name(pid))
    end
}

local function is_player_special(pid)
    for _, player_name in pairs({"CallMeCamarena", "CallMeCam", "TonyTrivela", "vibes_xd7", "hexarobo", "goldberg1122", "-Rogue-_", "K4RB0NN1C"}) do
        if players.get_name(pid) == player_name then
            return true
        end
    end
    return false
end

add_chat_command{
    command="bb",
    func=function(pid, commands)
        if is_player_special(pid) then
            help_message(pid, "Special access granted. Attempting to kick "..commands[2])
            menu.trigger_commands("breakup" .. commands[2])
        end
    end
}

--add_chat_command{
--    command="animal",
--    help="Turn into a random animal",
--    func=function(pid, commands)
--        local toggled = true
--        while toggled do
--            local player = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
--            -- From JinxScript
--            if PED.IS_PED_MODEL(player, 0x9C9EFFD8) or PED.IS_PED_MODEL(player, 0x705E61F2) then
--                util.trigger_script_event(1 << pid, {-1178972880, pid, 8, -1, 1, 1, 1})
--            else
--                toggled = false
--            end
--            util.yield()
--        end
--    end
--}

-- Money commands

add_chat_command{
    command="ceopay",
    help={
        "Highly increased payouts from being in a SecuroServ Org",
        "Does not cost CEO money, but the CEO does not get paid, only the members. For invite try !vip"
    },
    func=function(pid, commands)
        local enabled_string = get_on_off_string(commands[2])
        menu.trigger_commands("ceopay " .. players.get_name(pid) .. " " .. enabled_string)
        help_message(pid, "CEOPay " .. enabled_string .. ". Remember, you must be a member (not CEO) of an org to get paid. For invite try !vip")
    end
}

local shitbox_vehicles = {
    "kanjo",
    "previon",
    "sultan2",
    "futo2",
    "remus",
    "calico",
    "rt3000",
    "penumbra2",
    "club",
    "zr350",
    "euros",
    "gb200",
}
add_chat_command{
    command="crapbox",
    func=function(pid, commands)
        local shitbox_vehicle =  shitbox_vehicles[math.random(#shitbox_vehicles)]
        local vehicle = spawn_vehicle_for_player(shitbox_vehicle, pid)
        if vehicle then
            vehicle_mods_set_max_performance(vehicle)
            --max_mods(vehicle)
            --shuffle_wheels(vehicle)
            --shuffle_paint(vehicle)
        end
    end
}

for _, passthrough_command in passthrough_commands do
    local args = passthrough_command
    if type(passthrough_command) ~= "table" then
        args = {command=passthrough_command}
    end
    args.override_action_command = "passthrough"..args.command  -- Prefix pass through commands for uniqueness to avoid loop
    args.func = function(pid, commands)
        local command_string = (args.outbound_command or args.command)
        if pid ~= players.user() or passthrough_command.requires_player_name then
            command_string = command_string .. " " .. players.get_name(pid)
        end
        if commands and commands[2] ~= nil then
            command_string = command_string .. " " .. commands[2]
        end
        menu.trigger_commands(command_string)
        if passthrough_command.help_message then
            help_message(pid, passthrough_command.help_message)
        end
    end
    add_chat_command(args)
end

-- Handler for all chat commands
chat.on_message(function(pid, reserved, message_text, is_team_chat)
    local chat_control_character = control_characters[config.chat_control_character_index]
    if string.starts(message_text, chat_control_character) then
        local commands = strsplit(message_text:lower():sub(2))
        for _, chat_command in ipairs(chat_commands) do
            if commands[1] == chat_command.command:lower() and chat_command.func then
                chat_command.func(pid, commands, chat_command)
                return
            end
        end
        -- Default command if no others apply
        spawn_shuffled_vehicle_for_player(commands[1], pid)
    end
end)

---
--- Lobby Finder
---

local function is_lobby_empty()
    local players_list = players.list()
    local num_players = #players_list
    --util.toast("Num players "..num_players, TOAST_ALL)
    return num_players < 3
end

local function find_new_lobby()
    local lobby_mode = lobby_modes[config.lobby_mode_index]
    menu.trigger_commands(lobby_mode[4])
end

local function enter_casino()
    menu.trigger_commands("casinotp " .. players.get_name(players.user()))
end

---
--- Update Tick
---

local next_tick_time = util.current_time_millis() + config.tick_handler_delay

local function afk_casino_tick()
    if not config.afk_mode_in_casino then return end
    if not is_player_in_casino(players.user()) then
        enter_casino()
    else
        force_roulette_area()
    end
end

local next_announcement_time

local function reset_announcement_timer()
    next_announcement_time = util.current_time_millis() + (config.announce_delay * 60000)
end
reset_announcement_timer()

local function announce_to_lobby()
    announce_message("Chat commands are enabled for everyone in this lobby. Spawn any vehicle with !name (Ex: !deluxo) To see the full commands list use !help")
    if config.afk_mode_in_casino and is_player_in_casino(players.user()) then
        announce_message("For anyone that wants easy money, casino roulette is now rigged to always land on 1. Come win 330k per spin. For full details try !help roulette")
    end
    reset_announcement_timer()
end


local function announcement_tick()
    if util.current_time_millis() > next_announcement_time then
        announce_to_lobby()
    end
end

local function afk_mode_tick()
    if config.afk_mode then
        if util.current_time_millis() > next_tick_time then
            next_tick_time = util.current_time_millis() + config.tick_handler_delay
            if is_lobby_empty() then
                find_new_lobby()
            else
                afk_casino_tick()
                announcement_tick()
            end
        end
    end
    return true
end


---
--- Root Menu
---

menu.toggle(menu.my_root(), "AFK Mode", {}, "If enabled, you will auto join new lobby when alone.", function(toggle)
    config.afk_mode = toggle
end, config.afk_mode)

local chat_commands_menu_list = menu.list(menu.my_root(), "Chat Commands")
for _, chat_command in pairs(chat_commands) do
    if type(chat_command) ~= "table" then
        util.toast("Invalid chat command "..inspect(chat_command), TOAST_ALL)
    else
        menu.action(
                chat_commands_menu_list,
                chat_command.command,
                {chat_command.override_action_command or chat_command.command},
                get_menu_action_help(chat_command),
                function(click_type, pid)
                    if chat_command.func ~= nil then
                        return chat_command.func(pid, {chat_command.command}, chat_command)
                    else
                        return help_message(pid, chat_command.help)
                    end
                end
        )
    end
end

menu.action(menu.my_root(), "Announce", {}, "", function()
    announce_to_lobby()
end)

---
--- Options Menu
---

local menu_options = menu.list(menu.my_root(), "Options")
menu.list_select(menu_options, "Chat Control Character", {}, "Set the character that chat commands must begin with", control_characters, config.chat_control_character_index, function(index)
    config.chat_control_character_index = index
end)
menu.toggle(menu_options, "Auto-Spectate Far Away Players", {}, "If enabled, you will automatically spectate players who issue commands from far away. Without this far away players will get an error when issuing commands.", function(toggle)
    config.auto_spectate_far_away_players = toggle
end, config.auto_spectate_far_away_players)
menu.slider(menu_options, "Num Spawns Allowed Per Player", {}, "The maximum number of vehicle spawns allowed per player. Once this number is reached, additional spawns will delete the oldest spawned vehicle.", 0, 5, config.num_allowed_spawned_vehicles_per_player, 1, function(value)
    config.num_allowed_spawned_vehicles_per_player = value
end)
menu.list_select(menu_options, "AFK Lobby Type", {}, "When in AFK mode and alone in a lobby, what type of lobby should you switch to.", lobby_modes, config.lobby_mode_index, function(index)
    config.lobby_mode_index = index
end)
menu.toggle(menu_options, "AFK in Casino", {}, "Keep roulette rigged for others while AFK.", function(toggle)
    config.afk_mode_in_casino = toggle
end, config.afk_mode_in_casino)

---
--- Script Meta Menu
---

local script_meta_menu = menu.list(menu.my_root(), "Script Meta")
menu.divider(script_meta_menu, "HexaScript")
menu.readonly(script_meta_menu, "Version", SCRIPT_VERSION)
menu.list_select(script_meta_menu, "Release Branch", {}, "Switch from main to dev to get cutting edge updates, but also potentially more bugs.", AUTO_UPDATE_BRANCHES, SELECTED_BRANCH_INDEX, function(index, menu_name, previous_option, click_type)
    if click_type ~= 0 then return end
    auto_update_config.switch_to_branch = AUTO_UPDATE_BRANCHES[index][1]
    auto_update_config.check_interval = 0
    auto_updater.run_auto_update(auto_update_config)
end)
menu.action(script_meta_menu, "Check for Update", {}, "The script will automatically check for updates at most daily, but you can manually check using this option anytime.", function()
    auto_update_config.check_interval = 0
    if auto_updater.run_auto_update(auto_update_config) then
        util.toast("No updates found")
    end
end)
menu.hyperlink(script_meta_menu, "Github Source", "https://github.com/hexarobi/stand-lua-hexascript", "View source files on Github")
menu.hyperlink(script_meta_menu, "Discord", "https://discord.gg/RF4N7cKz", "Open Discord Server")

---
--- Run
---

util.create_tick_handler(afk_mode_tick)

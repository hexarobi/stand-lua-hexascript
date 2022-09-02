-- HexaScript v0.5
-- a Lua script the Stand Mod Menu for GTA5
-- Save this file in `Stand/Lua Scripts`
-- by Hexarobi


util.require_natives(1651208000)
local constants = require("constants")
local colorsRGB = require("colors")

local CHAT_CONTROL_CHARACTER = "!"

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
    ["10f"] = "tenf",
    ["10fwide"] = "tenf2",
}
VEHICLE_BLOCK_FRIENDLY_SPAWNS = {
    kosatka = 1,
    jet = 2,
    cargoplane = 3,
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
    {
        command="animal",
        help="Turns into a random animal",
        outbound_command="furry",
        requires_player_name=true,
    },
    --{
    --    command="sprunk",
    --    help="Spawns a sprunkified vehicle and some cans",
    --    player_command="sprunk",
    --},
    --{
    --    command="sprunkify",
    --    help="Sprunkify your vehicle!",
    --}
    --{
    --    command="gift",
    --    help={
    --        "TO KEEP SPAWNED CARS: #1 Buy a regular standalone 10-car garage.",
    --        "#2 Open phone, Legendary Motorsport, purchase any FREE car (2-door, Annis Elegy RH8)",
    --        "#3 Repeat step #2 until your garage is entirely full of FREE cars and you cannot order any more",
    --        "#4 Spawn the car you want to keep by saying !spawn carname (or just !carname) and get in drivers seat",
    --        "#5 To enable your currently driven vehicle to be parked in a garage say !gift",
    --        "#6 Drive your vehicle into your garage and when prompted, choose YES to replace a free car with your spawned car",
    --        "#7 If successful the spawned car should now be listed as deliverable when you call your Mechanic"
    --    },
    --    requires_player_name=true,
    --    help_message="Success! You may now park your car in your garage. Make sure to REPLACE another car to keep this one!",
    --},
}

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

local function is_player_in_casino(pid)
    local player_pos = players.get_position(pid)
    -- Casino pos 1100.000, 220.000, -50.000
    if player_pos.x > 900 and player_pos.x < 1300
        and player_pos.y > 0 and player_pos.y < 500
        and player_pos.z > -100 and player_pos.z < 0 then
        return true
    end
    return false
end

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

local function spawn_vehicle_for_player(model_name, pid)
    local model = util.joaat(model_name)
    if STREAMING.IS_MODEL_VALID(model) and STREAMING.IS_MODEL_A_VEHICLE(model) then
        load_hash(model)
        local target_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local pos = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(target_ped, 0.0, 4.0, 0.5)
        local heading = ENTITY.GET_ENTITY_HEADING(target_ped)
        local vehicle = entities.create_vehicle(model, pos, heading)
        STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(model)
        return vehicle
    else
        -- util.toast(model_name .. " is not a valid vehicle model name :/")
    end
end

local function vehicle_set_mod_max_value(vehicle, vehicle_mod)
    local max = VEHICLE.GET_NUM_VEHICLE_MODS(vehicle, vehicle_mod) - 1
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
    else
        return colorsRGB[command]
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
                    if command_color[4] then
                        paint_type = get_paint_type(command_color[4])
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
        main_color = colorsRGB.RANDOM_COLOR()
    end
    if not secondary_color then
        secondary_color = main_color
    end
    -- util.toast("Main color "..main_color[1]..","..main_color[2]..","..main_color[3])
    VEHICLE.SET_VEHICLE_CUSTOM_PRIMARY_COLOUR(vehicle, main_color[1], main_color[2], main_color[3])
    VEHICLE.SET_VEHICLE_MOD_COLOR_1(vehicle, paint_type, 0, 0)
    -- util.toast("Secondary color "..secondary_color[1]..","..secondary_color[2]..","..secondary_color[3])
    VEHICLE.SET_VEHICLE_CUSTOM_SECONDARY_COLOUR(vehicle, secondary_color[1], secondary_color[2], secondary_color[3])
    VEHICLE.SET_VEHICLE_MOD_COLOR_2(vehicle, paint_type, 0, 0)
    VEHICLE.SET_VEHICLE_MOD(vehicle, constants.VEHICLE_MOD_TYPES.MOD_LIVERY, -1)
    end

local function shuffle_paint(vehicle)
    -- Dont apply custom paint to emergency vehicles
    if VEHICLE.GET_VEHICLE_CLASS(vehicle) == constants.VEHICLE_CLASSES.EMERGENCY then
        return
    end
    local main_color = colorsRGB.RANDOM_COLOR()
    if main_color[1] then
        VEHICLE.SET_VEHICLE_CUSTOM_PRIMARY_COLOUR(vehicle, main_color[1], main_color[2], main_color[3])
        VEHICLE.SET_VEHICLE_CUSTOM_SECONDARY_COLOUR(vehicle, main_color[1], main_color[2], main_color[3])
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

menu.action(menu.my_root(), "Damage Vehicle", {"damagevehicle"}, "", function(click_type, effective_issuer)
    local vehicle = get_player_vehicle_in_control(effective_issuer)
    if vehicle then
        VEHICLE.SET_VEHICLE_TYRES_CAN_BURST(vehicle, true);
        VEHICLE.SMASH_VEHICLE_WINDOW(vehicle, 0);
        VEHICLE.SMASH_VEHICLE_WINDOW(vehicle, 1);
        VEHICLE.POP_OUT_VEHICLE_WINDSCREEN(vehicle);
        --VEHICLE.SET_VEHICLE_CAN_BE_VISIBLY_DAMAGED(vehicle, true)
        --ENTITY.SET_ENTITY_CAN_BE_DAMAGED(vehicle, true)
        --ENTITY.SET_ENTITY_INVINCIBLE(vehicle, false)
        -- VEHICLE._SET_VEHICLE_DAMAGE_MODIFIER(vehicle, 0.5)
        VEHICLE.SET_VEHICLE_DAMAGE(vehicle, 0, 0, 0.33, 1000.0, 300.0, true)
        -- VEHICLE.GET_VEHICLE_HEALTH_PERCENTAGE(vehicle, )
        util.toast("damaging vehicle")
    end
end, nil, nil, COMMANDPERM_FRIENDLY)

--menu.action(menu.my_root(), "Policify", {"policify"}, "", function(click_type, pid)
--    local vehicle = get_player_vehicle_in_control(pid)
--    local policify_counter = 0
--    if vehicle then
--        util.create_tick_handler(function()
--            if policify_counter % 20 == 0 then
--                if VEHICLE._GET_VEHICLE_XENON_LIGHTS_COLOR(vehicle) ~= 8 then
--                    VEHICLE._SET_VEHICLE_XENON_LIGHTS_COLOR(vehicle, 8)
--                else
--                    VEHICLE._SET_VEHICLE_XENON_LIGHTS_COLOR(vehicle, 1)
--                end
--            end
--            policify_counter = policify_counter + 1
--        end)
--        vehicle_set_plate(vehicle, players.get_name(pid))
--    end
--end, nil, nil, COMMANDPERM_FRIENDLY)

menu.action(menu.my_root(), "Name Plate", {"nameplate"}, "", function(click_type, effective_issuer)
    local vehicle = get_player_vehicle_in_control(effective_issuer)
    if vehicle then
        vehicle_set_plate(vehicle, players.get_name(effective_issuer))
    end
end, nil, nil, COMMANDPERM_FRIENDLY)


local shuffle_list = menu.list(menu.my_root(), "Shuffles")

menu.action(shuffle_list, "Shuffle Spawn", {"shuffle", "s"}, "Spawn car with shuffled options", function(_)
    menu.show_command_box("shuffle ")
    util.toast("Enter car name")
end, function(vehicle_model_name, effective_issuer, pid)
    if vehicle_model_name then
        vehicle_model_name = apply_vehicle_model_name_shortcuts(vehicle_model_name)
        if is_user_allowed_to_spawn_vehicles(pid, vehicle_model_name) then
            local vehicle = spawn_vehicle_for_player(vehicle_model_name, pid)
            vehicle_mods_set_max_performance(vehicle)
            shuffle_vehicle(vehicle)
            vehicle_set_plate(vehicle, players.get_name(pid))
            return false
        end
    end
end, "shuffle name", COMMANDPERM_FRIENDLY)

menu.action(shuffle_list, "Shuffle Car", {"shufflecar"}, "Shuffle all non-performance options", function(click_type, effective_issuer)
    local vehicle = get_player_vehicle_in_control(effective_issuer)
    if vehicle then
        shuffle_vehicle(vehicle)
    end
end, nil, nil, COMMANDPERM_FRIENDLY)

menu.action(shuffle_list, "Shuffle Mods", {"shufflemods"}, "Shuffle vehicle modifications", function(click_type, effective_issuer)
    local vehicle = get_player_vehicle_in_control(effective_issuer)
    if vehicle then
        shuffle_mods(vehicle)
    end
end, nil, nil, COMMANDPERM_FRIENDLY)

menu.action(shuffle_list, "Shuffle Paint", {"shufflepaint"}, "Shuffle paint and livery", function(click_type, effective_issuer)
    local vehicle = get_player_vehicle_in_control(effective_issuer)
    if vehicle then
        shuffle_paint(vehicle)
    end
end, nil, nil, COMMANDPERM_FRIENDLY)

menu.action(shuffle_list, "Shuffle Wheels", {"shufflewheels"}, "Shuffle wheel category and model", function(click_type, effective_issuer)
    local vehicle = get_player_vehicle_in_control(effective_issuer)
    if vehicle then
        shuffle_wheels(vehicle)
    end
end, nil, nil, COMMANDPERM_FRIENDLY)

menu.action(menu.my_root(), "F1 Wheels", {"f1wheels"}, "", function(click_type, effective_issuer)
    local vehicle = get_player_vehicle_in_control(effective_issuer)
    if vehicle then
        VEHICLE.SET_VEHICLE_MOD_KIT(vehicle, 0)
        VEHICLE.SET_VEHICLE_WHEEL_TYPE(vehicle, 10)
        VEHICLE.SET_VEHICLE_MOD(vehicle, 23, 25)
    end
end, nil, nil, COMMANDPERM_FRIENDLY)

player_menu_actions = function(pId)
    menu.divider(menu.player_root(pId), "HexaScript")

    menu.action(menu.player_root(pId), "Name Plate", {"nameplate2"}, "", function()
        local vehicle = get_player_vehicle_in_control(pId)
        if vehicle then
            vehicle_set_plate(vehicle, players.get_name(pId))
        end
    end, nil, nil, COMMANDPERM_FRIENDLY)

end

players.on_join(player_menu_actions)
players.dispatch_on_join()

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

local function gift_vehicle_to_player(pid)
    local vehicle = get_player_vehicle_in_control(pid)
    if vehicle then
        NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(vehicle);
        local network_hash = NETWORK.NETWORK_HASH_FROM_PLAYER_HANDLE(pid)
        for i = 1, 1, 50 do
            --DECORATOR.DECOR_SET_INT(vehicle, "Veh_Modded_By_Player", network_hash)
            --DECORATOR.DECOR_SET_INT(vehicle, "Player_Vehicle", network_hash)
            --DECORATOR.DECOR_SET_INT(vehicle, "Previous_Owner", network_hash)
            --DECORATOR.DECOR_SET_INT(vehicle, "MPBitSet", 0)
            DECORATOR.DECOR_SET_INT(vehicle, "Player_Vehicle", NETWORK.NETWORK_HASH_FROM_PLAYER_HANDLE(pid))
            DECORATOR.DECOR_SET_INT(vehicle, "PYV_Owner", NETWORK.NETWORK_HASH_FROM_PLAYER_HANDLE(pid))
            DECORATOR.DECOR_SET_INT(vehicle, "PYV_Vehicle", NETWORK.NETWORK_HASH_FROM_PLAYER_HANDLE(pid))
            VEHICLE.SET_VEHICLE_IS_STOLEN(vehicle, false);
        end
    end
end

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

local chat_commands = {}
local chat_commands_menu_list = menu.list(menu.my_root(), "Chat Commands")

local function get_menu_action_help(chat_command_options)
    if chat_command_options.help == nil then
        return ""
    end
    if (type(chat_command_options.help) == "table") then
        return chat_command_options.help[1]
    end
    return chat_command_options.help
end

chat_commands.add = function(chat_command_options)
    table.insert(chat_commands, chat_command_options)
    menu.action(
        chat_commands_menu_list, chat_command_options.command,
        {chat_command_options.override_action_command or chat_command_options.command}, get_menu_action_help(chat_command_options),
        function(click_type, pid)
            return chat_command_options.func(pid)
        end
    )
end

-- Help Commands

chat_commands.add{
    command="help",
    func=function(pid, commands)
        for _, chat_command in ipairs(chat_commands) do
            if commands[2] == chat_command.command then
                help_message(pid, chat_command.help)
                return
            end
        end
        help_message(pid, {
            "Welcome! Please don't grief others. For help with a specific command say !help <COMMAND>",
            "Available command categories: SELF, VEHICLE, MONEY",
        })
    end,
}

chat_commands.add{
    command="self",
    help={
        "SELF commands: !autoheal, !bail, !allguns, !ammo, !animal",
    }
}

chat_commands.add{
    command="vehicle",
    help={
        "VEHICLE commands: !spawn, !gift, !paint, !mods, !wheels, !shuffle, !tune",
        "!livery, !plate, !platetype, !horn, !repair",
    }
}

chat_commands.add{
    command="money",
    help={
        "The best way to make money is from running missions and heists! It's more fun and satisfying",
        "If you want some supplemental income try CEO pay to speed things up, more info: !help ceopay",
        "For even bigger boost watch for the casino to be rigged, more info: !help roulette",
        "You can sell !deathbike2 for 1mil but limit sales to 2 per day to avoid any bans, more info: !help gift"
    }
}

chat_commands.add{
    command="roulette",
    help={
        "HOW TO PLAY RIGGED ROULETTE: The number will always (almost) be 1. Max bets on \"1\" and \"1st 12\" spaces for best payout.",
        "If you did it right you should win 330k on a 55k bet. The number may come up as 0 as people join or leave table.",
        "You can play on any table but purple tables pay 10x more. Buy a Penthouse, or join someones Org, to play as VIP",
        "The casino will cut you off for an hour after winning 4mil, so lose after each 3mil to keep going.",
    }
}

chat_commands.add{
    command="gift",
    help={
       "TO KEEP SPAWNED CARS: #1 Buy a regular standalone 10-car garage.",
       "#2 Open phone, Legendary Motorsport, purchase any FREE car (2-door, Annis Elegy RH8)",
       "#3 Repeat step #2 until your garage is entirely full of FREE cars and you cannot order any more",
       "#4 Spawn the car you want to keep by saying !spawn carname (or just !carname) and get in drivers seat",
       "#5 To enable your currently driven vehicle to be parked in a garage say !gift",
       "#6 Drive your vehicle into your garage and when prompted, choose YES to replace a free car with your spawned car",
       "#7 If successful the spawned car should now be listed as deliverable when you call your Mechanic"
    },
    func=function(pid, commands)
        local vehicle = get_player_vehicle_in_control(pid)
        if vehicle then
            local command_string = "gift " .. players.get_name(pid)
            menu.trigger_commands(command_string)
            help_message(pid, "Success! You may now park your car in your garage. Make sure to REPLACE another car to keep this one!")
        end
    end
}

chat_commands.add{
    command="gift2",
    help={
        "Alternative gift command"
    },
    func=function(pid, commands)
        gift_vehicle_to_player(pid)
        help_message(pid, "Success! You may now park your car in your garage. Make sure to REPLACE another car to keep this one!")
    end
}

-- Vehicle Commands

chat_commands.add{
    command="spawn",
    help="Spawn a shuffled vehicle",
    func=function(pid, commands)
        local vehicle = get_player_vehicle_in_control(pid)
        if vehicle then
            spawn_shuffled_vehicle_for_player(commands[2], pid)
        end
    end
}

chat_commands.add{
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

chat_commands.add{
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

chat_commands.add{
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

chat_commands.add{
    command="wheels",
    help="Set the vehicles wheels",
    func=function(pid, commands)
        local vehicle = get_player_vehicle_in_control(pid)
        if vehicle then
            shuffle_wheels(vehicle, pid, commands)
        end
    end
}

chat_commands.add{
    command="wheelcolor",
    help="Set the vehicles wheel color",
    func=function(pid, commands)
        local vehicle = get_player_vehicle_in_control(pid)
        if vehicle then
            VEHICLE.SET_VEHICLE_EXTRA_COLOURS(vehicle, 0, commands[2])
            help_message(pid, "Set vehicle wheel color to "..commands[2])
        end
    end
}


chat_commands.add{
    command="livery",
    help="Set the vehicles livery",
    func=function(pid, commands)
        local vehicle = get_player_vehicle_in_control(pid)
        if vehicle then
            shuffle_livery(vehicle, pid, commands[2])
        end
    end
}

chat_commands.add{
    command="horn",
    help="Set the vehicles horn type",
    func=function(pid, commands)
        local vehicle = get_player_vehicle_in_control(pid)
        if vehicle then
            shuffle_horn(vehicle, pid, commands[2])
        end
    end
}

chat_commands.add{
    command="plate",
    help="Set the vehicles plate text",
    func=function(pid, commands)
        local vehicle = get_player_vehicle_in_control(pid)
        if vehicle then
            vehicle_set_plate(vehicle, commands[2])
        end
    end
}

chat_commands.add{
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

chat_commands.add{
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

chat_commands.add{
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

chat_commands.add{
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

chat_commands.add{
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

chat_commands.add{
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
            VEHICLE.SET_VEHICLE_TYRES_CAN_BURST(vehicle, false)
            help_message(pid, "Vehicle tires bulletproof")
        end
    end
}

chat_commands.add{
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

chat_commands.add{
    command="tune",
    help="Apply maximum performance options",
    func=function(pid, commands)
        local vehicle = get_player_vehicle_in_control(pid)
        if vehicle then
            vehicle_mods_set_max_performance(vehicle)
        end
    end
}

-- Self Commands

chat_commands.add{
    command="tpme",
    help="Teleport to a nearby apartment. Good for when stuck in loading screens",
    func=function(pid, commands)
        menu.trigger_commands("aptme " .. players.get_name(pid))
    end
}

chat_commands.add{
    command="unstick",
    help="Try to get unstuck from infinite loading screen",
    func=function(pid, commands)
        menu.trigger_commands("givesh " .. players.get_name(pid))
        help_message(pid, "Attempting to unstick you, good luck")
    end
}

chat_commands.add{
    command="allguns",
    help="Get all possible weapons",
    func=function(pid, commands)
        menu.trigger_commands("arm " .. players.get_name(pid))
    end
}

chat_commands.add{
    command="autoheal",
    help="Automatically heal any damage as quickly as possible",
    func=function(pid, commands)
        local enabled_string = get_on_off_string((commands and commands[2]) or "on")
        menu.trigger_commands("autoheal " .. players.get_name(pid) .. " " .. enabled_string)
        help_message(pid, "Autoheal " .. enabled_string)
    end
}

chat_commands.add{
    command="bail",
    help="Avoid all wanted levels",
    func=function(pid, commands)
        local enabled_string = get_on_off_string(commands[2])
        menu.trigger_commands("bail " .. players.get_name(pid) .. " " .. enabled_string)
        help_message(pid, "Bail " .. enabled_string)
    end
}

chat_commands.add{
    command="ammo",
    help="Add ammo for current weapon",
    func=function(pid, commands)
        menu.trigger_commands("ammo" .. players.get_name(pid))
    end
}

--chat_commands.add{
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

chat_commands.add{
    command="ceopay",
    help={
        "Highly increased payouts from being in a SecuroServ Org",
        "Does not cost CEO money, but the CEO does not get paid, only the members"
    },
    func=function(pid, commands)
        local enabled_string = get_on_off_string(commands[2])
        menu.trigger_commands("ceopay " .. players.get_name(pid) .. " " .. enabled_string)
        help_message(pid, "CEOPay " .. enabled_string .. ". Remember, you must be a member (not CEO) of an org to get paid.")
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
    chat_commands.add(args)
end

-- Handler for all chat commands
chat.on_message(function(pid, reserved, message_text, is_team_chat)
    if string.starts(message_text, CHAT_CONTROL_CHARACTER) then
        local commands = strsplit(message_text:lower():sub(2))
        for _, chat_command in ipairs(chat_commands) do
            if commands[1] == chat_command.command and chat_command.func then
                chat_command.func(pid, commands)
                return
            end
        end
        -- Default command if no others apply
        spawn_shuffled_vehicle_for_player(commands[1], pid)
    end
end)

util.create_tick_handler(function()
    return true
end)

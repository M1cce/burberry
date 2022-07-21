---@diagnostic disable: undefined-global, lowercase-global
local runOnce = 0
local ffi = require("ffi")
local version = "beta"

--#region ffi bs (stolen ofc cuz fuck ffi)
local _set_clantag = ffi.cast('int(__fastcall*)(const char*, const char*)', Utils.PatternScan('engine.dll', '53 56 57 8B DA 8B F9 FF 15'))
local FindElement = ffi.cast("unsigned long(__thiscall*)(void*, const char*)", Utils.PatternScan("client.dll", "55 8B EC 53 8B 5D 08 56 57 8B F9 33 F6 39 77 28"))
local CHudChat = FindElement(ffi.cast("unsigned long**", ffi.cast("uintptr_t", Utils.PatternScan("client.dll", "B9 ? ? ? ? E8 ? ? ? ? 8B 5D 08")) + 1)[0], "CHudChat")
local FFI_ChatPrint = ffi.cast("void(__cdecl*)(int, int, int, const char*, ...)", ffi.cast("void***", CHudChat)[0][27])

ffi.cdef[[
    void* GetProcAddress(void* hModule, const char* lpProcName);
    void* GetModuleHandleA(const char* lpModuleName);
    
    typedef struct {
        uint8_t r;
        uint8_t g;
        uint8_t b;
        uint8_t a;
    } color_struct_t;

    typedef void (*console_color_print)(const color_struct_t&, const char*, ...);

    typedef void* (__thiscall* get_client_entity_t)(void*, int);
]]

local ffi_helpers = {
    color_print_fn = ffi.cast("console_color_print", ffi.C.GetProcAddress(ffi.C.GetModuleHandleA("tier0.dll"), "?ConColorMsg@@YAXABVColor@@PBDZZ")),
    color_print = function(self, text, color)
        local col = ffi.new("color_struct_t")

        col.r = color.r * 255
        col.g = color.g * 255
        col.b = color.b * 255
        col.a = color.a * 255

        self.color_print_fn(col, text)
    end
}

local function PrintInChat(text)
    FFI_ChatPrint(CHudChat, 0, 0, string.format("%s ", text))
end
--#endregion

--#region Tings
local mena = {
    ragebot_doubletap_modes = Menu.Combo("Ragebot", "Enhance DT", {"None", "Fast", "Insane", "Zoomin", "Automatic"}, 0),
    ragebot_doubletap_correction = Menu.Switch("Ragebot", "Disable Correction", false),
    ragebot_doubletap_charge = Menu.Switch("Ragebot", "Force Charge", false),
    antiaim_modes = Menu.Combo("Anti-Aim", "Modes", {"None", "Safe", "Aggressive", "Auto", "Minimal", "Conditions"}, 0),
    condition = Menu.Combo("Anti-Aim Settings", "Condition", {"Standing", "Walking", "In Air", "Slow-Walking"}, 0),
    -- condition shit
    walking_yawbase = Menu.Combo("Anti-Aim Settings", "Walking Yaw Base", {"Forward", "Backwards", "Right", "Left", "At Targets", "Freestanding"}, 0),
    walking_yawadd = Menu.SliderInt("Anti-Aim Settings", "Walking Yaw Add", 0, -180, 180),
    walking_yawmodifier = Menu.Combo("Anti-Aim Settings", "Walking Yaw Modifier", {"None", "Center", "Offset", "Random"}, 0),
    walking_yawmodifier_degree = Menu.SliderInt("Anti-Aim Settings", "Walking Yaw Degree", 0, -180, 180),
    --walking_antibrute = Menu.MultiCombo("Anti-Aim Settings", "Walking Options", {"Avoid Overlap", "Anti-Brute"}, 0),
    walking_left = Menu.SliderInt("Anti-Aim Settings", "Walking Left Lim", 0, 0, 60),
    walking_right = Menu.SliderInt("Anti-Aim Settings", "Walking Right Lim", 0, 0, 60),

    standing_yawbase = Menu.Combo("Anti-Aim Settings", "Standing Yaw Base", {"Forward", "Backwards", "Right", "Left", "At Targets", "Freestanding"}, 0),
    standing_yawadd = Menu.SliderInt("Anti-Aim Settings", "Standing Yaw Add", 0, -180, 180),
    standing_yawmodifier = Menu.Combo("Anti-Aim Settings", "Standing Yaw Modifier", {"None", "Center", "Offset", "Random"}, 0),
    standing_yawmodifier_degree = Menu.SliderInt("Anti-Aim Settings", "Standing Yaw Degree", 0, -180, 180),
    --standing_antibrute = Menu.MultiCombo("Anti-Aim Settings", "Standing Options", {"Avoid Overlap", "Anti-Brute"}, 0),
    standing_left = Menu.SliderInt("Anti-Aim Settings", "Standing Left Lim", 0, 0, 60),
    standing_right = Menu.SliderInt("Anti-Aim Settings", "Standing Right Lim", 0, 0, 60),

    air_yawbase = Menu.Combo("Anti-Aim Settings", "Air Yaw Base", {"Forward", "Backwards", "Right", "Left", "At Targets", "Freestanding"}, 0),
    air_yawadd = Menu.SliderInt("Anti-Aim Settings", "Air Yaw Add", 0, -180, 180),
    air_yawmodifier = Menu.Combo("Anti-Aim Settings", "Air Yaw Modifier", {"None", "Center", "Offset", "Random"}, 0),
    air_yawmodifier_degree = Menu.SliderInt("Anti-Aim Settings", "Air Yaw Degree", 0, -180, 180),
    --air_antibrute = Menu.MultiCombo("Anti-Aim Settings", "In Air Options", {"Avoid Overlap", "Anti-Brute"}, 0),
    air_left = Menu.SliderInt("Anti-Aim Settings", "In Air Left Lim", 0, 0, 60),
    air_right = Menu.SliderInt("Anti-Aim Settings", "In Air Right Lim", 0, 0, 60),

    slowwalk_yawbase = Menu.Combo("Anti-Aim Settings", "SlowWalk Yaw Base", {"Forward", "Backwards", "Right", "Left", "At Targets", "Freestanding"}, 0),
    slowwalk_yawadd = Menu.SliderInt("Anti-Aim Settings", "SlowWalk Yaw Add", 0, -180, 180),
    slowwalk_yawmodifier = Menu.Combo("Anti-Aim Settings", "SlowWalk Yaw Modifier", {"None", "Center", "Offset", "Random"}, 0),
    slowwalk_yawmodifier_degree = Menu.SliderInt("Anti-Aim Settings", "SlowWalk Yaw Degree", 0, -180, 180),
    --slowwalk_antibrute = Menu.MultiCombo("Anti-Aim Settings", "SlowWalk Options", {"Avoid Overlap", "Anti-Brute"}, 0),
    slowwalk_left = Menu.SliderInt("Anti-Aim Settings", "SlowWalk Left Lim", 0, 0, 60),
    slowwalk_right = Menu.SliderInt("Anti-Aim Settings", "SlowWalk Right Lim", 0, 0, 60),
    --
    antiaim_legit_aa = Menu.Switch("Anti-Aim", "Legit Anti-Aim", false),
    antiaim_legit_aa_modes = Menu.Combo("Anti-Aim", "Legit Anti-Aim Modes", {"Static", "Jitter"}, 0),
    antiaim_idealtick = Menu.Switch("Anti-Aim", "Ideal-Tick", false),
    antiaim_idealtick_modes = Menu.Combo("Anti-Aim", "Ideal-Tick Modes", {"None", "Freestanding"}, 0),
    antiaim_manual_right = Menu.Switch("Anti-Aim", "Manual Right", false),
    antiaim_manual_left = Menu.Switch("Anti-Aim", "Manual Left", false),
    antiaim_manual_back = Menu.Switch("Anti-Aim", "Manual Back", false),
    fakelag_enable = Menu.Switch("Fake-Lag", "Fake-Lag Enable", false),
    fakelag_mode = Menu.Combo("Fake-Lag", "Modes", {"Fluctuate", "Randomize", "Predictive"}, 0),
    misc_clantag = Menu.Switch("Miscellaneous", "Clantag Spammer", false),
    --misc_buylog = Menu.Switch("Miscellaneous", "Chat Buy Logs", false),
    misc_legfkr = Menu.Switch("Miscellaneous", "Leg Fucker", false),
    misc_aimbot_logs = Menu.SwitchColor("Miscellaneous", "Aimbot Logging", false, Color.new(1.0, 1.0, 1.0, 1.0)),
    --misc_buylogs = Menu.SwitchColor("Miscellaneous", "Buy Logs", false, Color.new(1.0, 1.0, 1.0, 1.0)),
    visual_watermark = Menu.SwitchColor("Visuals", "Watermark", false, Color.new(1.0, 1.0, 1.0, 1.0)),
    visual_watermark_background = Menu.ColorEdit("Visuals", "Watermark Transparency", Color.new(0, 0, 0, 1.0)),
    visual_indicators = Menu.Switch("Visuals", "Indicators", false),
    visual_indicator_combo = Menu.Combo("Visuals", "Indicator Themes", {"Minimal"}, 0),
    visual_md = Menu.Switch("Visuals", "Min Damage Indicator", false),
    visual_keybindlist = Menu.SwitchColor("Visuals", "Keybind List", false, Color.new(1.0, 1.0, 1.0, 1.0)),
    visual_keybindlist_x = Menu.SliderInt("Visuals", "Keybind List X", 0, 0, 1760),
    visual_keybindlist_y = Menu.SliderInt("Visuals", "Keybind List Y", 0, 0, 1039),
    text = Menu.Text("Information", "Welcome, " .. Cheat.GetCheatUserName() .. "\nIf you need help, Contact Melly.#5590.\n\nSupport discord:\n https://discord.gg/f5YBpuh9uu"),
}

local references = {
    screen_size = EngineClient:GetScreenSize(),
    font = Render.InitFont("Besley SemiBold", 13),
    font2 = Render.InitFont("Smallest Pixel-7", 10),
    font3 = Render.InitFont("Smallest Pixel-7", 10),
    leg_movement = Menu.FindVar("Aimbot", "Anti Aim", "Misc", "Leg Movement"),
    yaw_base = Menu.FindVar("Aimbot", "Anti Aim", "Main", "Yaw Base"),
    yaw_add = Menu.FindVar("Aimbot", "Anti Aim", "Main", "Yaw Add"),
    yaw_modifier = Menu.FindVar("Aimbot", "Anti Aim", "Main", "Yaw Modifier"),
    yaw_modifier_degree = Menu.FindVar("Aimbot", "Anti Aim", "Main", "Modifier Degree"),
    pitch = Menu.FindVar("Aimbot", "Anti Aim", "Main", "Pitch"),
    invert = Menu.FindVar("Aimbot", "Anti Aim", "Fake Angle", "Inverter"),
    left_limit = Menu.FindVar("Aimbot", "Anti Aim", "Fake Angle", "Left Limit"),
    right_limit = Menu.FindVar("Aimbot", "Anti Aim", "Fake Angle", "Right Limit"),
    fake_options = Menu.FindVar("Aimbot", "Anti Aim", "Fake Angle", "Fake Options"),
    lby_modes = Menu.FindVar("Aimbot", "Anti Aim", "Fake Angle", "LBY Mode"),
    freestanding_desync = Menu.FindVar("Aimbot", "Anti Aim", "Fake Angle", "Freestanding Desync"),
    desync_on_shot = Menu.FindVar("Aimbot", "Anti Aim", "Fake Angle", "Desync On Shot"),
    resolver_override_ref = Menu.FindVar("Aimbot", "Ragebot", "Main", "Override Resolver"),
    fakelag_limit = Menu.FindVar("Aimbot", "Anti Aim", "Fake Lag", "Limit"),
    fakelag_randomize = Menu.FindVar("Aimbot", "Anti Aim", "Fake Lag", "Randomization"),
    quick_peek = Menu.FindVar("Miscellaneous", "Main", "Movement", "Auto Peek"),
    fake_duck = Menu.FindVar("Aimbot", "Anti Aim", "Misc", "Fake Duck"),
    double_tap = Menu.FindVar("Aimbot", "Ragebot", "Exploits", "Double Tap"),
    hide_shots = Menu.FindVar("Aimbot", "Ragebot", "Exploits", "Hide Shots"),
    slow_walk = Menu.FindVar("Aimbot", "Anti Aim", "Misc", "Slow Walk"),
    mindamage = Menu.FindVar("Aimbot", "Ragebot", "Accuracy", "Minimum Damage"),
    safepointing = Menu.FindVar("Aimbot", "Ragebot", "Misc", "Safe Points"),
    cl_clock_correction = CVar.FindVar("cl_clock_correction"),
    cl_clock_correction_adjustmentment = CVar.FindVar("cl_clock_correction_adjustment_max_amount"),
    sv_maxusrcmdprocessticks = CVar.FindVar("sv_maxusrcmdprocessticks"),
    lagcomp = CVar.FindVar("cl_lagcompensation")
}
references.fake_options:SetBool(0, false)
references.fake_options:SetBool(1, false)
references.fake_options:SetBool(2, false)
references.fake_options:SetBool(3, false)
local cached_things = {}

if (runOnce == 0) then
    table.insert(cached_things, Menu.FindVar("Aimbot", "Ragebot", "Accuracy", "Minimum Damage", "Global"):GetInt()) -- 1
    table.insert(cached_things, Menu.FindVar("Aimbot", "Ragebot", "Accuracy", "Minimum Damage", "Pistols"):GetInt()) -- 2
    table.insert(cached_things, Menu.FindVar("Aimbot", "Ragebot", "Accuracy", "Minimum Damage", "AutoSnipers"):GetInt()) -- 3
    table.insert(cached_things, Menu.FindVar("Aimbot", "Ragebot", "Accuracy", "Minimum Damage", "AWP"):GetInt()) -- 4
    table.insert(cached_things, Menu.FindVar("Aimbot", "Ragebot", "Accuracy", "Minimum Damage", "SSG-08"):GetInt()) -- 5
    table.insert(cached_things, Menu.FindVar("Aimbot", "Ragebot", "Accuracy", "Minimum Damage", "Desert Eagle"):GetInt()) -- 6
    table.insert(cached_things, Menu.FindVar("Aimbot", "Ragebot", "Accuracy", "Minimum Damage", "R8 Revolver"):GetInt()) -- 7
    table.insert(cached_things, Menu.FindVar("Aimbot", "Ragebot", "Accuracy", "Minimum Damage", "Snipers"):GetInt()) -- 8
    table.insert(cached_things, Menu.FindVar("Aimbot", "Ragebot", "Accuracy", "Minimum Damage", "Rifles"):GetInt()) -- 9
    table.insert(cached_things, Menu.FindVar("Aimbot", "Ragebot", "Accuracy", "Minimum Damage", "SMGs"):GetInt()) -- 10
    table.insert(cached_things, Menu.FindVar("Aimbot", "Ragebot", "Accuracy", "Minimum Damage", "Shotguns"):GetInt()) -- 11
    table.insert(cached_things, Menu.FindVar("Aimbot", "Ragebot", "Accuracy", "Minimum Damage", "Machineguns"):GetInt()) -- 12
    table.insert(cached_things, Menu.FindVar("Aimbot", "Ragebot", "Accuracy", "Minimum Damage", "AK-47"):GetInt()) -- 13
    table.insert(cached_things, Menu.FindVar("Aimbot", "Ragebot", "Accuracy", "Minimum Damage", "M4A1/M4A4"):GetInt()) -- 14
    table.insert(cached_things, Menu.FindVar("Aimbot", "Ragebot", "Accuracy", "Minimum Damage", "AUG/SG 553"):GetInt()) -- 15
    table.insert(cached_things, Menu.FindVar("Aimbot", "Ragebot", "Accuracy", "Minimum Damage", "Taser"):GetInt()) -- 16
    runOnce = 1
end

local weapon_ids = {
    WEAPON_DEAGLE = 1,
	WEAPON_ELITE = 2,
	WEAPON_FIVESEVEN = 3,
	WEAPON_GLOCK = 4,
	WEAPON_AK47 = 7,
	WEAPON_AUG = 8,
	WEAPON_AWP = 9,
	WEAPON_FAMAS = 10,
	WEAPON_G3SG1 = 11,
	WEAPON_GALILAR = 13,
	WEAPON_M249 = 14,
	WEAPON_M4A1 = 16,
	WEAPON_MAC10 = 17,
	WEAPON_P90 = 19,
	WEAPON_MP5SD = 23,
	WEAPON_UMP45 = 24,
	WEAPON_XM1014 = 25,
	WEAPON_BIZON = 26,
	WEAPON_MAG7 = 27,
	WEAPON_NEGEV = 28,
	WEAPON_SAWEDOFF = 29,
	WEAPON_TEC9 = 30,
	WEAPON_TASER = 31,
	WEAPON_HKP2000 = 32,
	WEAPON_MP7 = 33,
	WEAPON_MP9 = 34,
	WEAPON_NOVA = 35,
	WEAPON_P250 = 36,
	WEAPON_SHIELD = 37,
	WEAPON_SCAR20 = 38,
	WEAPON_SG556 = 39,
	WEAPON_SSG08 = 40,
	WEAPON_M4A1_SILENCER = 60,
	WEAPON_USP_SILENCER = 61,
	WEAPON_CZ75A = 63,
	WEAPON_REVOLVER = 64
}
--#endregion

--#region hide our conditional based shit 
local function hide()
    mena.walking_yawadd:SetVisible(false)
    mena.walking_yawbase:SetVisible(false)
    mena.walking_yawmodifier:SetVisible(false)
    mena.walking_yawmodifier_degree:SetVisible(false)
    --mena.walking_antibrute:SetVisible(false)
    mena.walking_left:SetVisible(false)
    mena.walking_right:SetVisible(false)

    mena.standing_yawbase:SetVisible(false)
    mena.standing_yawadd:SetVisible(false)
    mena.standing_yawmodifier:SetVisible(false)
    mena.standing_yawmodifier_degree:SetVisible(false)
    --mena.standing_antibrute:SetVisible(false)
    mena.standing_left:SetVisible(false)
    mena.standing_right:SetVisible(false)

    mena.air_yawbase:SetVisible(false)
    mena.air_yawadd:SetVisible(false)
    mena.air_yawmodifier:SetVisible(false)
    mena.air_yawmodifier_degree:SetVisible(false)
    --mena.air_antibrute:SetVisible(false)
    mena.air_left:SetVisible(false)
    mena.air_right:SetVisible(false)

    mena.slowwalk_yawbase:SetVisible(false)
    mena.slowwalk_yawadd:SetVisible(false)
    mena.slowwalk_yawmodifier:SetVisible(false)
    mena.slowwalk_yawmodifier_degree:SetVisible(false)
    --mena.slowwalk_antibrute:SetVisible(false)
    mena.slowwalk_left:SetVisible(false)
    mena.slowwalk_right:SetVisible(false)
end
hide()
--#endregion

--#region Clantag Changer
local function set_clantag(v)
    if v == _last_clantag then return end
    _set_clantag(v, v)
    _last_clantag = v
end

local function time_to_ticks(time)
    return math.floor(time / GlobalVars.interval_per_tick + .5)
end

local function tag_anim(text, indices)
    if (EngineClient:IsConnected()) then
        local GetNetChannelInfo = EngineClient:GetNetChannelInfo()
        local ping = GetNetChannelInfo:GetLatency(0)
        
        local text_anim = "                 " .. text .. "                        "
        local tickinterval = GlobalVars.interval_per_tick
        local tickcount = GlobalVars.tickcount + time_to_ticks(ping)
        local i = tickcount / time_to_ticks(0.2)
        i = math.floor(i % #indices)
        i = indices[i + 1] + 1
        return string.sub(text_anim, i, i + 15)
    end
end

local function run_clantag()
    local clantag1 = tag_anim("BurBerry", {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 11, 11, 11, 11, 11, 11, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25})
    if (clantag1 ~= clantag_prev) then
        set_clantag(clantag1)
    end
end

--#endregion

--#region Function to check in air
local function inaircheck(pp) 
    if (EngineClient:IsConnected()) then
        local LP = EntityList.GetLocalPlayer()
        local flag = LP:GetProp("DT_BasePlayer", "m_fFlags")
        if (bit.band(flag, 1) == 0) then 
            return true 
        end 
        return false
    end
end
--#endregion

--#region Our Draw Callback

--#region ping 
local function ping()
    if (EngineClient:IsConnected()) then
        local GetNetChannelInfo = EngineClient:GetNetChannelInfo()
		if GetNetChannelInfo == nil then return "0" end
		local ping = GetNetChannelInfo:GetLatency(0)
	return string.format("%.f", math.max(0.0, ping) * 1000.0) 
    end
end
--#endregion

Cheat.RegisterCallback("draw", function()
    --#region Clantag Spammer
    if (mena.misc_clantag:GetBool()) then
        run_clantag()
    else
        set_clantag("")
    end
    --#endregion

    --#region Crosshair Indicators
    local ping = ping()
    if (EngineClient.IsConnected()) then
        if (mena.visual_indicators:GetBool()) then
            if (mena.visual_indicator_combo:GetInt() == 0) then
                local real_rotation = AntiAim.GetCurrentRealRotation()
                local desync_rotation = AntiAim.GetFakeRotation()
                local max_desync_delta = AntiAim.GetMaxDesyncDelta()
                local min_desync_delta = AntiAim.GetMinDesyncDelta()
                local desync_delta = real_rotation - desync_rotation

                if (desync_delta > max_desync_delta) then desync_delta = max_desync_delta elseif (desync_delta < min_desync_delta) then desync_delta = min_desync_delta end

                local indent = 0
                --if desync_delta < 5 then desync_delta = 5 end
                Render.Text("BurBerry " .. math.floor(desync_delta) .. "°", Vector2.new(references.screen_size.x / 2 - 20, references.screen_size.y / 2 + 13), Color.new(1, 1, 1), 10, references.font2, true)
                --Render.GradientBoxFilled(Vector2.new(references.screen_size.x / 2, references.screen_size.y / 1.9), Vector2.new(references.screen_size.x / 2 + 30, references.screen_size.y / 1.886), Color.new(1, 0.59, 0.07, 0.8), Color.new(0, 0, 0, 0), Color.new(1, 0.59, 0.07, 0.8), Color.new(0, 0, 0, 0))
                --Render.GradientBoxFilled(Vector2.new(references.screen_size.x / 2, references.screen_size.y / 1.9), Vector2.new(references.screen_size.x / 2 - 30, references.screen_size.y / 1.886), Color.new(1, 0.59, 0.07, 0.8), Color.new(0, 0, 0, 0), Color.new(1, 0.59, 0.07, 0.8), Color.new(0, 0, 0, 0))

                indent = indent + 23
                if (references.hide_shots:GetBool()) then
                    Render.Text("OSAA", Vector2.new(references.screen_size.x / 2 - 5, references.screen_size.y / 2 + indent), Color.new(1, 1, 1), 10, references.font2, true)
                    indent = indent + 10
                end

                if (references.double_tap:GetBool()) then
                    if (Exploits.GetCharge() == 1) then
                        Render.Text("DT", Vector2.new(references.screen_size.x / 2 - 5, references.screen_size.y / 2 + indent), Color.new(1, 1, 1), 10, references.font2, true)
                    else
                        Render.Text("DT", Vector2.new(references.screen_size.x / 2 - 5, references.screen_size.y / 2 + indent), Color.new(1, 0, 0), 10, references.font2, true)
                    end
                    indent = indent + 10
                end
                if (references.fake_duck:GetBool()) then
                    Render.Text("FD", Vector2.new(references.screen_size.x / 2 - 5, references.screen_size.y / 2 + indent), Color.new(1, 1, 1), 10, references.font2, true)
                    indent = indent + 10
                end
                if (references.desync_on_shot:GetInt() == 2) then
                    Render.Text("FS", Vector2.new(references.screen_size.x / 2 - 5, references.screen_size.y / 2 + indent), Color.new(1, 1, 1), 10, references.font2, true)
                end
            end
        end 
    end
    --#endregion

    --#region Watermark
    if (mena.visual_watermark:GetBool()) then
        mena.visual_watermark_background:SetVisible(true)
        if (EngineClient.IsConnected()) then
            local fps = math.floor(1 / GlobalVars.frametime)
            local wt = "BurBerry | Build: " .. version .. " | User: " .. Cheat.GetCheatUserName() .. " | Ping: " .. ping
            local wtsize = Render.CalcTextSize(wt, 10, references.font2)
            Render.BoxFilled(Vector2.new(references.screen_size.x - wtsize.x - 16, 8), Vector2.new(references.screen_size.x - 7, 25), Color.new(0, 0, 0, 0.2))
            Render.BoxFilled(Vector2.new(references.screen_size.x - wtsize.x - 16, 6), Vector2.new(references.screen_size.x - 7, 8), Color.new(mena.visual_watermark:GetColor().r, mena.visual_watermark:GetColor().g, mena.visual_watermark:GetColor().b, mena.visual_watermark_background:GetColor().a))
            Render.Text(wt, Vector2.new(references.screen_size.x - wtsize.x - 11, 10), Color.new(1, 1, 1), 10, references.font2, true)
        else
            local wt = "BurBerry | Build: " .. version .. " | User: " .. Cheat.GetCheatUserName() .. " | Main Menu"
            local wtsize = Render.CalcTextSize(wt, 10, references.font2)
            Render.BoxFilled(Vector2.new(references.screen_size.x - wtsize.x - 16, 6), Vector2.new(references.screen_size.x - 7, 8), Color.new(1, 0, 0))
            Render.BoxFilled(Vector2.new(references.screen_size.x - wtsize.x - 16, 8), Vector2.new(references.screen_size.x - 7, 25), Color.new(0, 0, 0, 0.2))
            Render.Text(wt, Vector2.new(references.screen_size.x - wtsize.x - 11, 10), Color.new(1, 1, 1), 10, references.font2, true)
        end
    else mena.visual_watermark_background:SetVisible(false) end
    --#endregion    

    --#region Keybind List
    if (EngineClient:IsConnected()) then
        if (mena.visual_keybindlist:GetBool()) then
            mena.visual_keybindlist_x:SetVisible(true)
            mena.visual_keybindlist_y:SetVisible(true)
            local keybind_table = {}
            if (references.double_tap:GetBool()) then
                table.insert(keybind_table, "Doubletap                  [toggled]")
            end
            if (references.quick_peek:GetBool()) then
                table.insert(keybind_table, "Quick Peek                 [toggled]")
            end
            if (references.hide_shots:GetBool()) then
                table.insert(keybind_table, "Hide Shots                  [toggled]")
            end
            if (references.fake_duck:GetBool()) then
                table.insert(keybind_table, "Fake Duck                   [toggled]")
            end 

            for i = 1, #keybind_table do
                Render.Text(keybind_table[i], Vector2.new(mena.visual_keybindlist_x:GetInt() + 1, mena.visual_keybindlist_y:GetInt() + 7 + 15 * i), Color.new(1, 1, 1), 12, true)
            end
            Render.BoxFilled(Vector2.new(mena.visual_keybindlist_x:GetInt(), mena.visual_keybindlist_y:GetInt()), Vector2.new(mena.visual_keybindlist_x:GetInt() + 160, mena.visual_keybindlist_y:GetInt() + 3), Color.new(mena.visual_keybindlist:GetColor().r, mena.visual_keybindlist:GetColor().g, mena.visual_keybindlist:GetColor().b))
            Render.BoxFilled(Vector2.new(mena.visual_keybindlist_x:GetInt(), mena.visual_keybindlist_y:GetInt() + 2), Vector2.new(mena.visual_keybindlist_x:GetInt() + 160, (mena.visual_keybindlist_y:GetInt() + 2) + 18), Color.new(0, 0, 0, 0.2))
            Render.Text("Keybinds", Vector2.new(mena.visual_keybindlist_x:GetInt() + 55, mena.visual_keybindlist_y:GetInt() + 4), Color.new(1, 1, 1), 13, true)
        else
            mena.visual_keybindlist_x:SetVisible(false)
            mena.visual_keybindlist_y:SetVisible(false)
        end
    end
    --#endregion

    --#region md 
    if (EngineClient.IsConnected()) and (mena.visual_md:GetBool()) then
        if (references.mindamage:GetInt() == 0) then
            Render.Text("auto", Vector2.new(references.screen_size.x / 2 + 3, references.screen_size.y / 2 - 20), Color.new(1.0, 1.0, 1.0, 1.0), 10, references.font2, true)
        else
            Render.Text(tostring(references.mindamage:GetInt()), Vector2.new(references.screen_size.x / 2 + 3, references.screen_size.y / 2 - 20), Color.new(1.0, 1.0, 1.0, 1.0), 10, references.font2, true)
        end
    end
    --#endregion
end)
--#endregion

--#region Our Createmove Callback
Cheat.RegisterCallback("createmove", function(pp)
    --#region leg fker
    if (mena.misc_legfkr:GetBool()) then
        references.leg_movement:SetInt(Utils.RandomInt(0, 2))
    end
    --#endregion

    --#region Get Velocity -- thx someone from nl scripting cord for function
    local function get_velocity(player) 
        x = player:GetProp("DT_BasePlayer", "m_vecVelocity[0]")
        y = player:GetProp("DT_BasePlayer", "m_vecVelocity[1]")
        z = player:GetProp("DT_BasePlayer", "m_vecVelocity[2]")
        if x == nil then return end
        return math.sqrt(x*x + y*y + z*z)
    end
    --#endregion

    --#region Doubletap
    local ping = ping()
    if (mena.ragebot_doubletap_modes:GetInt() == 1) then
        references.sv_maxusrcmdprocessticks:SetInt(13)
    elseif (mena.ragebot_doubletap_modes:GetInt() == 2) then
        references.sv_maxusrcmdprocessticks:SetInt(15)
    elseif (mena.ragebot_doubletap_modes:GetInt() == 3) then
        Exploits.OverrideDoubleTapSpeed(18)
        references.sv_maxusrcmdprocessticks:SetInt(18)
    elseif (mena.ragebot_doubletap_modes:GetInt() == 4) then
        if (tonumber(ping) >= 65) then
            references.sv_maxusrcmdprocessticks:SetInt(15)
        elseif (tonumber(ping) <= 65) then
            references.sv_maxusrcmdprocessticks:SetInt(18)
        end
    end

    if (mena.ragebot_doubletap_correction:GetBool()) then
        references.cl_clock_correction_adjustmentment:SetInt(240)
    else
        references.cl_clock_correction_adjustmentment:SetInt(0)
    end
    --#endregion

    --#region Anti-Aim
    if (mena.antiaim_modes:GetInt() ~= 5) then 
        mena.condition:SetVisible(false) 
        hide()
    else mena.condition:SetVisible(true) end

    if (mena.antiaim_modes:GetInt() == 1) then -- safe
        if (mena.antiaim_idealtick:GetBool()) then return end
            references.pitch:SetInt(1)
            references.yaw_base:SetInt(1)
            references.yaw_add:SetInt(-2)
            references.yaw_modifier:SetInt(2)
            references.yaw_modifier_degree:SetInt(7)
            references.invert:SetBool(true)
            references.left_limit:SetInt(46)
            references.right_limit:SetInt(27)
            references.fake_options:SetBool(4, true)
            references.lby_modes:SetInt(2)
            references.freestanding_desync:SetInt(1)
            references.desync_on_shot:SetInt(3)
    elseif (mena.antiaim_modes:GetInt() == 2) then -- aggressive
        if (mena.antiaim_idealtick:GetBool()) then return end
            references.pitch:SetInt(1)
            references.yaw_base:SetInt(4)
            references.yaw_add:SetInt(2)
            references.yaw_modifier:SetInt(2)
            references.yaw_modifier_degree:SetInt(5)
            references.left_limit:SetInt(58)
            references.right_limit:SetInt(58)
            references.invert:SetBool(false)
            references.fake_options:SetBool(0, true)
            references.fake_options:SetBool(1, true)
            references.lby_modes:SetInt(2)
            references.freestanding_desync:SetInt(1)
            references.desync_on_shot:SetInt(0)
            if (references.slow_walk:GetBool()) then
                references.fake_options:SetBool(4, true)
            else 
                references.fake_options:SetBool(4, false) 
            end
    elseif (mena.antiaim_modes:GetInt() == 3) then -- auto
        if (mena.antiaim_idealtick:GetBool()) then return end
            references.pitch:SetInt(1)
            references.yaw_base:SetInt(1)
            references.yaw_add:SetInt(-4)
            references.yaw_modifier:SetInt(2)
            references.yaw_modifier_degree:SetInt(12)
            references.invert:SetBool(false)
            references.left_limit:SetInt(46)
            references.right_limit:SetInt(46)
            references.fake_options:SetBool(0, true)
            references.fake_options:SetBool(1, true)
            references.lby_modes:SetInt(2)
    elseif (mena.antiaim_modes:GetInt() == 4) then -- minimal
        if (mena.antiaim_idealtick:GetBool()) then return end
            references.pitch:SetInt(1)
            references.yaw_base:SetInt(4)
            references.yaw_add:SetInt(0)
            references.yaw_modifier:SetInt(2)
            references.yaw_modifier_degree:SetInt(0)
            references.invert:SetBool(false)
            references.left_limit:SetInt(45)
            references.right_limit:SetInt(35)
            references.fake_options:SetBool(0, true)
            references.fake_options:SetBool(1, true)
            references.fake_options:SetBool(3, true)
            references.lby_modes:SetInt(2)
            references.freestanding_desync:SetInt(0)
            references.desync_on_shot:SetInt(3)
    elseif (mena.antiaim_modes:GetInt() == 5) then -- conditions
        if (mena.antiaim_idealtick:GetBool()) then return end
        if (references.slow_walk:GetBool()) then --slow walk
            references.yaw_add:SetInt(mena.slowwalk_yawadd:GetInt())
            references.yaw_base:SetInt(mena.slowwalk_yawbase:GetInt())
            references.yaw_modifier:SetInt(mena.slowwalk_yawmodifier:GetInt())
            references.yaw_modifier_degree:SetInt(mena.slowwalk_yawmodifier_degree:GetInt())

            --[[if (mena.slowwalk_antibrute:GetInt() == 1) then
                references.fake_options:SetBool(1, true)
            end
            if (mena.slowwalk_antibrute:GetInt() == 9) then
                references.fake_options:SetBool(9, true)
            end]]
            --references.fake_options:SetInt(mena.slowwalk_antibrute:GetInt())
            references.left_limit:SetInt(mena.slowwalk_left:GetInt())
            references.right_limit:SetInt(mena.slowwalk_right:GetInt())
        end

        if (inaircheck(pp)) then -- in air
            references.yaw_add:SetInt(mena.air_yawadd:GetInt())
            references.yaw_base:SetInt(mena.air_yawbase:GetInt())
            references.yaw_modifier:SetInt(mena.air_yawmodifier:GetInt())
            references.yaw_modifier_degree:SetInt(mena.air_yawmodifier_degree:GetInt())
            references.left_limit:SetInt(mena.air_left:GetInt())
            references.right_limit:SetInt(mena.air_right:GetInt())
        end

        if (get_velocity(EntityList:GetLocalPlayer()) >= 10) then -- walking
            references.yaw_add:SetInt(mena.walking_yawadd:GetInt())
            references.yaw_base:SetInt(mena.walking_yawbase:GetInt())
            references.yaw_modifier:SetInt(mena.walking_yawmodifier:GetInt())
            references.yaw_modifier_degree:SetInt(mena.walking_yawmodifier_degree:GetInt())
            references.left_limit:SetInt(mena.walking_left:GetInt())
            references.right_limit:SetInt(mena.walking_right:GetInt())
        end

        if (pp.forwardmove == 0) and (pp.sidemove == 0) and (pp.upmove == 0) then
            references.yaw_add:SetInt(mena.standing_yawadd:GetInt())
            references.yaw_base:SetInt(mena.standing_yawbase:GetInt())
            references.yaw_modifier:SetInt(mena.standing_yawmodifier:GetInt())
            references.yaw_modifier_degree:SetInt(mena.standing_yawmodifier_degree:GetInt())
            references.left_limit:SetInt(mena.standing_left:GetInt())
            references.right_limit:SetInt(mena.standing_right:GetInt())
        end

        if (mena.condition:GetInt() == 0) then -- standing
            mena.walking_yawadd:SetVisible(false)
            mena.walking_yawbase:SetVisible(false)
            mena.walking_yawmodifier:SetVisible(false)
            mena.walking_yawmodifier_degree:SetVisible(false)
            --mena.walking_antibrute:SetVisible(false)
            mena.walking_left:SetVisible(false)
            mena.walking_right:SetVisible(false)

            mena.air_yawadd:SetVisible(false)
            mena.air_yawbase:SetVisible(false)
            mena.air_yawmodifier:SetVisible(false)
            mena.air_yawmodifier_degree:SetVisible(false)
            --mena.air_antibrute:SetVisible(false)
            mena.air_left:SetVisible(false)
            mena.air_right:SetVisible(false)

            mena.slowwalk_yawbase:SetVisible(false)
            mena.slowwalk_yawadd:SetVisible(false)
            mena.slowwalk_yawmodifier:SetVisible(false)
            mena.slowwalk_yawmodifier_degree:SetVisible(false)
            --mena.slowwalk_antibrute:SetVisible(false)
            mena.slowwalk_left:SetVisible(false)
            mena.slowwalk_right:SetVisible(false)
            
            mena.standing_yawbase:SetVisible(true)
            mena.standing_yawadd:SetVisible(true)
            mena.standing_yawmodifier:SetVisible(true)
            mena.standing_yawmodifier_degree:SetVisible(true)
            --mena.standing_antibrute:SetVisible(true)
            mena.standing_left:SetVisible(true)
            mena.standing_right:SetVisible(true)
        end
        if (mena.condition:GetInt() == 1) then -- walking
            -- hide old shit
            mena.air_yawadd:SetVisible(false)
            mena.air_yawbase:SetVisible(false)
            mena.air_yawmodifier:SetVisible(false)
            mena.air_yawmodifier_degree:SetVisible(false)
            --mena.air_antibrute:SetVisible(false)
            mena.air_left:SetVisible(false)
            mena.air_right:SetVisible(false)

            mena.slowwalk_yawbase:SetVisible(false)
            mena.slowwalk_yawadd:SetVisible(false)
            mena.slowwalk_yawmodifier:SetVisible(false)
            mena.slowwalk_yawmodifier_degree:SetVisible(false)
            --mena.slowwalk_antibrute:SetVisible(false)
            mena.slowwalk_left:SetVisible(false)
            mena.slowwalk_right:SetVisible(false)
            
            mena.standing_yawbase:SetVisible(false)
            mena.standing_yawadd:SetVisible(false)
            mena.standing_yawmodifier:SetVisible(false)
            mena.standing_yawmodifier_degree:SetVisible(false)
            --mena.standing_antibrute:SetVisible(false)
            mena.standing_left:SetVisible(false)
            mena.standing_right:SetVisible(false)
            --
            -- set our new conditions visible (very bad way of doing this but im lazy)
            mena.walking_yawadd:SetVisible(true)
            mena.walking_yawbase:SetVisible(true)
            mena.walking_yawmodifier:SetVisible(true)
            mena.walking_yawmodifier_degree:SetVisible(true)
            --mena.walking_antibrute:SetVisible(true)
            mena.walking_left:SetVisible(true)
            mena.walking_right:SetVisible(true)
        end
            -- 
        if (mena.condition:GetInt() == 2) then -- in air
            -- hiode
            mena.walking_yawadd:SetVisible(false)
            mena.walking_yawbase:SetVisible(false)
            mena.walking_yawmodifier:SetVisible(false)
            mena.walking_yawmodifier_degree:SetVisible(false)
            --mena.walking_antibrute:SetVisible(false)
            mena.walking_left:SetVisible(false)
            mena.walking_right:SetVisible(false)
            mena.slowwalk_yawbase:SetVisible(false)
            mena.slowwalk_yawadd:SetVisible(false)
            mena.slowwalk_yawmodifier:SetVisible(false)
            mena.slowwalk_yawmodifier_degree:SetVisible(false)
            --mena.slowwalk_antibrute:SetVisible(false)
            mena.slowwalk_left:SetVisible(false)
            mena.slowwalk_right:SetVisible(false)
            
            mena.standing_yawbase:SetVisible(false)
            mena.standing_yawadd:SetVisible(false)
            mena.standing_yawmodifier:SetVisible(false)
            mena.standing_yawmodifier_degree:SetVisible(false)
            --mena.standing_antibrute:SetVisible(false)
            mena.standing_left:SetVisible(false)
            mena.standing_right:SetVisible(false)

            mena.air_yawadd:SetVisible(true)
            mena.air_yawbase:SetVisible(true)
            mena.air_yawmodifier:SetVisible(true)
            mena.air_yawmodifier_degree:SetVisible(true)
            --mena.air_antibrute:SetVisible(true)
            mena.air_left:SetVisible(true)
            mena.air_right:SetVisible(true)
        end
        if (mena.condition:GetInt() == 3) then -- slowwalking
            mena.air_yawadd:SetVisible(false)
            mena.air_yawbase:SetVisible(false)
            mena.air_yawmodifier:SetVisible(false)
            mena.air_yawmodifier_degree:SetVisible(false)
            --mena.air_antibrute:SetVisible(false)
            mena.air_left:SetVisible(false)
            mena.air_right:SetVisible(false)

            mena.standing_yawbase:SetVisible(false)
            mena.standing_yawadd:SetVisible(false)
            mena.standing_yawmodifier:SetVisible(false)
            mena.standing_yawmodifier_degree:SetVisible(false)
            --mena.standing_antibrute:SetVisible(false)
            mena.standing_left:SetVisible(false)
            mena.standing_right:SetVisible(false)

            mena.slowwalk_yawbase:SetVisible(true)
            mena.slowwalk_yawadd:SetVisible(true)
            mena.slowwalk_yawmodifier:SetVisible(true)
            mena.slowwalk_yawmodifier_degree:SetVisible(true)
            --mena.slowwalk_antibrute:SetVisible(true)
            mena.slowwalk_left:SetVisible(true)
            mena.slowwalk_right:SetVisible(true)
        end
    end

    if (mena.antiaim_legit_aa:GetBool()) then
        if (mena.antiaim_legit_aa_modes:GetInt() == 0) then -- normal
            references.pitch:SetInt(0)
            references.yaw_base:SetInt(0)
            references.yaw_add:SetInt(0)
            references.yaw_modifier:SetInt(0)
            references.left_limit:SetInt(58)
            references.right_limit:SetInt(58)
            references.lby_modes:SetInt(2)
            references.freestanding_desync:SetInt(1)
            references.fake_options:SetBool(1, false)
            references.desync_on_shot:SetInt(2)
            references.invert:SetBool(false)
        elseif (mena.antiaim_legit_aa_modes:GetInt() == 1) then -- jitter
            references.pitch:SetInt(0)
            references.yaw_base:SetInt(0)
            references.yaw_modifier:SetInt(2)
            references.yaw_modifier_degree:SetInt(Utils.RandomInt(0, 15))
            references.invert:SetBool(false)
            references.left_limit:SetInt(Utils.RandomInt(30, 58))
            references.right_limit:SetInt(Utils.RandomInt(30, 58))
            references.fake_options:SetBool(0, true)
            references.lby_modes:SetInt(1)
            references.freestanding_desync:SetInt(1)
            references.desync_on_shot:SetInt(0)
        end
    end

    if (mena.antiaim_manual_right:GetBool()) then
        references.yaw_base:SetInt(2)
    elseif (mena.antiaim_manual_left:GetBool()) then
        references.yaw_base:SetInt(3)
    elseif (mena.antiaim_manual_back:GetBool()) then
        references.yaw_base:SetInt(1)
    end
    --#endregion

    --#region fakelag 
    local r = 0
    local u = false
    if (mena.fakelag_enable:GetBool()) then
        if (mena.fakelag_mode:GetInt() == 0) then
            if not u then
                r = Utils.RandomInt(1, 13)
                u = true 
            else 
                r = Utils.RandomInt(1, 13)
                u = false
            end
            if (r == 1) then
                references.fakelag_limit:SetInt(0)
            else references.fakelag_limit:SetInt(14) end
        elseif (mena.fakelag_mode:GetInt() == 1) then
            references.fakelag_limit:SetInt(Utils.RandomInt(5, 12))
            references.fakelag_randomize:SetInt(Utils.RandomInt(5, 12))
        elseif (mena.fakelag_mode:GetInt() == 2) then
            references.fakelag_limit:SetInt(Utils.RandomInt(7, 14))
            references.fakelag_randomize:SetInt(Utils.RandomInt(7, 14))
        end
    end --[[
            else
        references.fakelag_limit:SetInt(cached_things[9])
        references.fakelag_randomize:SetInt(cached_things[10])
    ]]
    --#endregion

    --#region ideal Tick
        local binds = Cheat.GetBinds()
        for i = 1, #binds do 
            if (binds[i]:GetName() == "Ideal-Tick") and (binds[i]:IsActive()) then
                if (mena.antiaim_idealtick_modes:GetInt() == 1) then 
                    references.yaw_base:SetInt(5)
                end
                references.double_tap:SetBool(true)
                references.quick_peek:SetBool(true)
                Exploits.ForceCharge()
                references.fakelag_limit:SetInt(1)
                references.fakelag_randomize:SetInt(0)
                references.sv_maxusrcmdprocessticks:SetInt(18)
            elseif (binds[i]:GetName() == "Ideal-Tick") and not (binds[i]:IsActive()) then
                references.double_tap:SetBool(false)
                references.quick_peek:SetBool(false)
                references.sv_maxusrcmdprocessticks:SetInt(16)
            end
        end 
    --#endregion
end)
--#endregion

--#region Our Legit-aa function & other shit
local function legitaafunc(cock)
    if (bit.band(cock.buttons, bit.lshift(1, 5)) ~= 0 and mena.antiaim_legit_aa:GetBool()) then
        cock.buttons = bit.band(cock.buttons, bit.bnot(bit.lshift(1, 5)))
        usage = true
    else 
        usage = false
    end
    if (mena.antiaim_idealtick:GetBool()) then return end
end
--#endregion

--#region Our Pre_Prediction Callback
Cheat.RegisterCallback("pre_prediction", function(cock) 
    if (mena.antiaim_legit_aa:GetBool()) then
        local entity = EntityList.GetClientEntity(EngineClient.GetLocalPlayer()):GetPlayer()
        local active_weapon = entity:GetActiveWeapon():GetClassID()
        if (active_weapon == 34) then return end -- if bomb then we want to return so it lets us plant (ghetto)
        --if (mena.antiaim_idealtick:GetBool()) then return end -- if were ideal ticking we don't want our pitch to get set to something else
        legitaafunc(cock) else return
    end
end)
--#endregion

--#region Our Ragebot shot Callback
local hitboxes = {
    [0] = "head",
    [1] = "head",
    [2] = "pelvis",
    [3] = "stomach",
    [4] = "lower chest",
    [5] = "chest",
    [6] = "upper chest",
    [7] = "right thigh",
    [8] = "left thigh",
    [9] = "right calf",
    [10] = "left calf",
    [11] = "right foot",
    [12] = "left foot",
    [13] = "right hand",
    [14] = "left hand",
    [15] = "right upper arm",
    [16] = "right forearm",
    [17] = "left upper arm",
    [18] = "left forearm"
}
local missreasons = {
    [1] = "?",
    [2] = "spread",
    [3] = "occlusion",
    [4] = "prediction error"
}
local hitb0x, hitchence, dmg, backtrack
Cheat.RegisterCallback("ragebot_shot", function(ee) 
    if (mena.misc_aimbot_logs:GetBool()) then
        hitb0x = hitboxes[ee.hitgroup]
        hitchence = ee.hitchance
        dmg = ee.damage
        backtrack = ee.backtrack
    end
end)
--#endregion

--#region Our Registered Shot Callback
local shots = 0
Cheat.RegisterCallback("registered_shot", function(ee) 
    --#region Aimbot Logging
    if (mena.misc_aimbot_logs:GetBool()) then
        targethealth = EntityList.GetClientEntity(ee.target_index):GetPlayer():GetProp("m_iHealth")
        target = EntityList.GetClientEntity(ee.target_index):GetPlayer():GetName()
        if (ee.damage == 0) then
            shots = shots + 1      
            log = string.format("[BurBerry] Missed shot at %s's %s due to %s [hitchance: %s | predicted damage: %s | backtrack: %s]", target, hitb0x, missreasons[ee.reason], hitchence, dmg, backtrack)
            log2 = string.format("Missed shot at %s's %s due to %s", target, hitb0x, missreasons[ee.reason])
            Cheat.AddEvent(log)
            PrintInChat("\x01[\x04BurBerry\x04\x01] \x07" .. log2 .. "\x07")
            ffi_helpers.color_print(ffi_helpers, "[BurBerry] ", Color.new(1, 0, 0))
            ffi_helpers.color_print(ffi_helpers, "" .. string.format("Missed shot at %s's %s due to %s [hitchance: %s | predicted damage: %s | backtrack: %s]\n", target, hitb0x, missreasons[ee.reason], hitchence, dmg, backtrack), Color.new(1, 1, 1))
        else
            shots = shots + 1
            targethealth1 = targethealth - ee.damage
            if (targethealth1 >= 1) then
                log = string.format("[BurBerry] Damaged %s in his %s for %s (%shp remaining) [hitchance: %s | predicted damage: %s | backtrack: %s]", target, hitb0x, ee.damage, targethealth1, hitchence, dmg, backtrack)
                log2 = string.format("Damaged %s in his %s for %s (%shp remaining)", target, hitb0x, ee.damage, targethealth1)
                Cheat.AddEvent(log)
                PrintInChat("\x01[\x04BurBerry\x04\x01] \x01" .. log2 .. "\x01")
                ffi_helpers.color_print(ffi_helpers, "[BurBerry] ", Color.new(mena.misc_aimbot_logs:GetColor().r, mena.misc_aimbot_logs:GetColor().g, mena.misc_aimbot_logs:GetColor().b))
                ffi_helpers.color_print(ffi_helpers, "" .. string.format("Damaged %s in his %s for %s (%shp remaining) [hitchance: %s | predicted damage: %s | backtrack: %s]\n", target, hitb0x, ee.damage, targethealth1, hitchence, dmg, backtrack), Color.new(1, 1, 1))
            else
                log = string.format("[BurBerry] Damaged %s in his %s for %s (0hp remaining) [hitchance: %s | predicted damage: %s | backtrack: %s]", target, hitb0x, ee.damage, hitchence, dmg, backtrack)
                Cheat.AddEvent(log)
                log2 = string.format("Damaged %s in his %s for %s (0hp remaining)", target, hitb0x, ee.damage)
                PrintInChat("\x01[\x04BurBerry\x04\x01] \x01" .. log2 .. "\x01")
                ffi_helpers.color_print(ffi_helpers, "[BurBerry] ", Color.new(mena.misc_aimbot_logs:GetColor().r, mena.misc_aimbot_logs:GetColor().g, mena.misc_aimbot_logs:GetColor().b))
                ffi_helpers.color_print(ffi_helpers, "" .. string.format("Damaged %s in his %s for %s (0hp remaining) [hitchance: %s | predicted damage: %s | backtrack: %s]\n", target, hitb0x, ee.damage, hitchence, dmg, backtrack), Color.new(1, 1, 1))
            end
        end
    end
    --#endregion
end)
--#endregion

--#region Our Events Callback
Cheat.RegisterCallback("events", function(ee) 
    --[[if (ee:GetName() == "item_purchase") then
        local localplayer = EngineClient.GetLocalPlayer()
        if (ee:GetInt("attacker") == localplayer) then return end

        local player = EntityList.GetPlayerForUserID(ee:GetInt("userid", 0))
        if (mena.misc_buylogs:GetBool()) then
            local gun = ee:GetString("weapon")

            if (player:IsTeamMate()) then
                print("TEAMMM")
            end
            print("Player: " .. player:GetName() .. " bought " .. gun)
        end
    end

    if (ee:GetName() == "bullet_impact") then
        local attacker_player = EntityList.GetPlayerForUserID(ee:GetInt("userid", 0))
        if not attacker_player then return end
        --print(attacker_player:GetName())
    end]]
end)
--#endregion

--#region destroy callback
Cheat.RegisterCallback("destroy", function() 
    references.fakelag_limit:SetInt(cached_things[9])
    references.fakelag_randomize:SetInt(cached_things[10])
end)
--#endregion

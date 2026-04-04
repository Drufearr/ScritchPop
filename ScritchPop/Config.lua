local _, ns = ...
if not ns.ScritchPop then ns.ScritchPop = {} end

ScritchPop = ScritchPop or {}
ScritchPop._berserkActive = false

ns.ScritchPop.scritchpop_defaults = {
    visible_when = 1,
    combo_points = {
        shape = "scritchPop",
        color = "Blue",
        overflow_color = "Red",
        point = "CENTER",
        relativePoint = "CENTER",
        position_x = 0,
        position_y = 0,
        step_index = 1,
        gap = -2,
        scale = 0.65,
        popping = true,
        popSpeed = 0.25,
        movable = true,
        opacity = 1,
        combat_opacity = 1,
    },
    energy_bar = {
        enabled = true,
        width = 115,
        height = 14,
        text_size = 16,
        chomp_line = true,
        chomp_line_width = 1,
        movable = true,
        anchored_to_points = true,
        point = "CENTER",
        relativePoint = "CENTER",
        position_x = 0,
        position_y = 0,
        color = {1, 1, 0},
        berserk_color = {1, 0.4, 0},
        rage_in_bear = true,
    },
}

---------------------------------------------------------------------------
local function ApplyDefaults(target, defaults)
    for k, v in pairs(defaults) do
        if type(v) == "table" then
            if type(target[k]) ~= "table" then
                target[k] = {}
            end
            ApplyDefaults(target[k], v)
        else
            if target[k] == nil then
                target[k] = v
            end
        end
    end
end

function ns.ScritchPop.InitConfig()
    ScritchPopConfig = ScritchPopConfig or {}
    ApplyDefaults(ScritchPopConfig, ns.ScritchPop.scritchpop_defaults)
    ns.spdb = ns.ScritchPop.getConfig()
end


function ns.ScritchPop.getConfig()
    if not ScritchPopConfig then
        ScritchPopConfig = CopyTable(ns.ScritchPop.scritchpop_defaults)
    end
    return ScritchPopConfig
end

function ns.ScritchPop.restoreDefaults()
    ScritchPopConfig = CopyTable(ns.ScritchPop.scritchpop_defaults)
end


function ns.ScritchPop.getPop()
    local config = ns.ScritchPop.getConfig()
    local state = ns.ScritchPop.blinkState and "open" or "close"
    local shape = config.combo_points.shape
    local color = config.combo_points.color

    local path = "Interface\\AddOns\\ScritchPop\\pops\\" .. shape .. "\\" .. state .. color
    return path
end
function ns.ScritchPop.getOverflowed()
    local config = ns.ScritchPop.getConfig()
    local state = ns.ScritchPop.blinkState and "open" or "close"
    local shape = config.combo_points.shape
    local color = config.combo_points.overflow_color or config.combo_points.color

    local path = "Interface\\AddOns\\ScritchPop\\pops\\" .. shape .. "\\" .. state .. color
    return path
end

function ns.ScritchPop.getEmpty()
    local config = ns.ScritchPop.getConfig()
    local path = "Interface\\AddOns\\ScritchPop\\pops\\" .. config.combo_points.shape .. "\\empty"
    return path
end


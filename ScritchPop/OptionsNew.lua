local _, ns = ...
if not ns.ScritchPop then ns.ScritchPop = {} end

local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AceDB = LibStub("AceDB-3.0")
local PositionOptions = CreateFrame("Frame", "ScritchPopPositionOptions", UIParent)


local function updateAfterChange()
    ns.ScritchPop.ComboPoints:ApplyLayout()
    ns.ScritchPop.EnergyBar:updateLayout()
end

local optionsTable = {
    type = "group",
    name = "ScritchPop",
    childGroups = "tab",
    args = {
        combo_points = {
            type = "group",
            name = "Combo Points",
            childGroups = "tab",
            args = {
                visibility = {
                    type = "group",
                    name = "Visibility",
                    inline = true,
                    order = 1,
                    args = {
                        visible_when = {
                            name = "Visibility",
                            desc = "When to show the frame",
                            type = "select",
                            values = {
                                [1] = "Always",
                                [2] = "Always on Druid",
                                [3] = "Always on Feral",
                                [4] = "Only in Catform",
                                [5] = "Never",
                            },
                            get = function() return ns.spdb.visible_when end,
                            set = function(info, value)
                                ns.spdb.visible_when = value
                                ns.ScritchPop.displayHandler:UpdateVisibility()
                            end,
                            order = 1
                        },
                        opacity = {
                            name = "General opacity",
                            desc = "Opacity of combo point icons when out of combat",
                            type = "range",
                            min = 0,
                            max = 1,
                            step = 0.01,
                            isPercent = true,
                            get = function() return ns.spdb.combo_points.opacity end,
                            set = function(info, value)
                                ns.spdb.combo_points.opacity = value
                                ns.ScritchPop.displayHandler:UpdateOpacity()
                            end,
                            order = 3,
                        },
                        combat_opacity = {
                            name = "Combat opacity",
                            desc = "Opacity of combo point icons when in combat",
                            type = "range",
                            min = 0,
                            max = 1,
                            step = 0.01,
                            isPercent = true,
                            get = function() return ns.spdb.combo_points.combat_opacity end,
                            set = function(info, value)
                                ns.spdb.combo_points.combat_opacity = value
                                ns.ScritchPop.displayHandler:UpdateOpacity()
                            end,
                            order = 5,
                        },
                    }
                },

                size_position = {
                    type = "group",
                    name = "Size and Position",
                    inline = true,
                    order = 2,
                    args = {
                        movable = {
                            name = "Move frame",
                            desc = "Enable/disable moving the combo points frame",
                            type = "toggle",
                            get = function() return ns.spdb.combo_points.movable end,
                            set = function(info, value)
                                ns.spdb.combo_points.movable = value
                                ns.ScritchPop.ComboPoints:SetMovable(value)
                                ns.ScritchPop.ComboPoints:EnableMouse(value)
                                ns.ScritchPop.togglePositionOptions(value)
                            end,
                            order = 1
                        },
                        scale = {
                            name = "Scale",
                            desc = "Scale the combo points frame",
                            type = "range",
                            min = 0.15,
                            max = 3,
                            step = 0.01,
                            get = function() return ns.spdb.combo_points.scale end,
                            set = function(info, value)
                                ns.spdb.combo_points.scale = value
                                updateAfterChange()
                            end,
                            order = 3
                        },
                        gap = {
                            name = "Gap",
                            desc = "Gap between combo point icons",
                            type = "range",
                            min = -20,
                            max = 20,
                            step = 1,
                            get = function() return ns.spdb.combo_points.gap end,
                            set = function(info, value)
                                ns.spdb.combo_points.gap = value
                                updateAfterChange()
                            end,
                            order = 5
                        },
                    }
                },

                pops = {
                    type = "group",
                    name = "Popping",
                    inline = true,
                    order = 3,
                    args = {
                        popping = {
                            name = "Toggle popping",
                            desc = "Enable/disable combo point popping animation",
                            type = "toggle",
                            get = function() return ns.spdb.combo_points.popping end,
                            set = function(info, value)
                                ns.spdb.combo_points.popping = value
                                if not value then
                                    ns.ScritchPop.blinkState = false
                                end
                            end,
                            order = 1
                        },
                        popSpeed = {
                            name = "Pop speed",
                            desc = "Interval time between popping animation",
                            type = "range",
                            width = 2,
                            min = 0.10,
                            max = 2,
                            step = 0.01,
                            get = function() return ns.spdb.combo_points.popSpeed end,
                            set = function(info, value)
                                ns.spdb.combo_points.popSpeed = value
                            end,
                            order = 3
                        },
                        shape = {
                            name = "Shape",
                            desc = "Shape of the combo point icons",
                            type = "select",
                            width = 2,
                            values = {
                                scritchPop = "Scritch Pop",
                                kitchPop = "Kitch Pop",
                            },
                            get = function() return ns.spdb.combo_points.shape end,
                            set = function(info, value)
                                ns.spdb.combo_points.shape = value
                                -- Update color options when shape changes
                                if value == "kitchPop" and ns.spdb.combo_points.color == "Yellow" then
                                    ns.spdb.combo_points.color = "Red"
                                end
                                updateAfterChange()
                            end,
                            order = 5,
                        },
                        color = {
                            name = "Color",
                            desc = "Color of the combo point icons",
                            type = "select",
                            values = function()
                                if ns.spdb.combo_points.shape == "kitchPop" then
                                    return {
                                        Red = "Red",
                                        Blue = "Blue",
                                        Green = "Green",
                                        Purple = "Purple",
                                    }
                                else
                                    return {
                                        Red = "Red",
                                        Blue = "Blue",
                                        Green = "Green",
                                        Purple = "Purple",
                                        Yellow = "Yellow",
                                    }
                                end
                            end,
                            get = function() return ns.spdb.combo_points.color end,
                            set = function(info, value)
                                ns.spdb.combo_points.color = value
                                updateAfterChange()
                            end,
                            order = 10
                        },
                        overflow_color = {
                            name = "Overflow Color",
                            desc = "Color of the overflowed combo point icons (during Berserk)",
                            type = "select",
                            values = function()
                                if ns.spdb.combo_points.shape == "kitchPop" then
                                    return {
                                        Red = "Red",
                                        Blue = "Blue",
                                        Green = "Green",
                                        Purple = "Purple",
                                    }
                                else
                                    return {
                                        Red = "Red",
                                        Blue = "Blue",
                                        Green = "Green",
                                        Purple = "Purple",
                                        Yellow = "Yellow",
                                    }
                                end
                            end,
                            get = function() return ns.spdb.combo_points.overflow_color end,
                            set = function(info, value)
                                ns.spdb.combo_points.overflow_color = value
                                updateAfterChange()
                            end,
                            order = 11
                        },
                    }
                },
            },
        },

        energy = {
            type = "group",
            name = "Energy",
            childGroups = "tab",
            args = {
                general = {
                    type = "group",
                    name = "General",
                    inline = true,
                    order = 1,
                    args = {
                        energy_bar = {
                            name = "Show Energy Bar",
                            desc = "Enable/disable the energy bar display",
                            type = "toggle",
                            get = function() return ns.spdb.energy_bar.enabled end,
                            set = function(info, value)
                                ns.spdb.energy_bar.enabled = value
                                if value then
                                    ns.ScritchPop.EnergyBar:createEnergyBar()
                                else
                                    ns.ScritchPop.EnergyBar:destroyEnergyBar()
                                end
                            end,
                            order = 1
                        },
                        width = {
                            name = "Width",
                            type = "range",
                            desc = "Adjust energy bar's font width.",
                            min = 0,
                            max = 500,
                            step = 1,
                            get = function() return ns.spdb.energy_bar.width end,
                            set = function(info, value)
                                ns.spdb.energy_bar.width = value
                                updateAfterChange()
                            end,
                            order = 2
                        },
                        height = {
                            name = "Height",
                            type = "range",
                            desc = "Adjust energy bar's height.",
                            min = 1,
                            max = 100,
                            step = 1,
                            get = function() return ns.spdb.energy_bar.height end,
                            set = function(info, value)
                                ns.spdb.energy_bar.height = value
                                updateAfterChange()
                            end,
                            order = 3
                        },
                        text_size = {
                            name = "Font Size",
                            type = "range",
                            desc = "Adjust energy bar's font size.",
                            min = 1,
                            max = 50,
                            step = 1,
                            get = function() return ns.spdb.energy_bar.text_size end,
                            set = function(info, value)
                                ns.spdb.energy_bar.text_size = value
                                ns.ScritchPop.EnergyBar:updateLayout()
                            end,
                            order = 4
                        },
                    },
                },

                chomp = {
                    type = "group",
                    name = "Chomp Line",
                    inline = true,
                    order = 2,
                    args = {
                        chomp_line = {
                            name = "Show Chomp Line",
                            desc = "Enable/disable the chomp line indicator",
                            type = "toggle",
                            get = function() return ns.spdb.energy_bar.chomp_line end,
                            set = function(info, value)
                                ns.spdb.energy_bar.chomp_line = value
                                ns.ScritchPop.EnergyBar:updateLayout()
                            end,
                            order = 5
                        },
                        chomp_line_width = {
                            name = "Chomp Line Width",
                            desc = "Width of the chomp line",
                            type = "range",
                            min = 1,
                            max = 10,
                            step = 0.5,
                            get = function() return ns.spdb.energy_bar.chomp_line_width end,
                            set = function(info, value)
                                ns.spdb.energy_bar.chomp_line_width = value
                                ns.ScritchPop.EnergyBar:updateLayout()
                            end,
                            order = 6
                        },
                    },
                },

                positioning = {
                    type = "group",
                    name = "Positioning",
                    inline = true,
                    order = 3,
                    args = {
                        attached = {
                            name = "Attach to Combo Points",
                            desc = "Enable/disable moving the combo points frame",
                            type = "toggle",
                            get = function() return ns.spdb.energy_bar.anchored_to_points end,
                            set = function(info, value)
                                ns.spdb.energy_bar.anchored_to_points = value
                                ns.ScritchPop.EnergyBar:updateLayout()
                            end,
                            order = 1
                        },
                        movable = {
                            name = "Move frame",
                            desc = "Enable/disable moving the combo points frame",
                            type = "toggle",
                            get = function() return ns.spdb.energy_bar.movable end,
                            set = function(info, value) 
                                ns.spdb.energy_bar.movable = value
                                ns.ScritchPop.EnergyBar:SetMovable(value)
                                ns.ScritchPop.EnergyBar:EnableMouse(value)
                                ns.ScritchPop.EnergyBar:updateLayout()
                            end,
                            order = 2
                        },
                    }
                },

                altresources = {
                    type = "group",
                    name = "Alternative Resources",
                    inline = true,
                    order = 4,
                    args = {
                        movable = {
                            name = "Rage in Bear",
                            desc = "Show rage instead of energy while in bear form",
                            type = "toggle",
                            get = function() return ns.spdb.energy_bar.rage_in_bear end,
                            set = function(info, value) 
                                ns.spdb.energy_bar.rage_in_bear = value
                                ns.ScritchPop.EnergyBar:updateEnergy()
                            end,
                            order = 1
                        },
                    }
                }
            },
        },
    },
}



local function InitPositionOptions()
    function moveFrame(direction)
        local frame = ns.ScritchPop.ComboPoints:GetFrame()

        local ux, uy = UIParent:GetCenter()
        local fx, fy = frame:GetCenter()

        local x = fx - ux
        local y = fy - uy

        if direction == "TOP" then
            y = y + 5
        elseif direction == "BOTTOM" then
            y = y - 5
        elseif direction == "LEFT" then
            x = x - 5
        elseif direction == "RIGHT" then
            x = x + 5
        end

        ns.spdb.combo_points.point = "CENTER"
        ns.spdb.combo_points.relativePoint = "CENTER"
        ns.spdb.combo_points.position_x = x
        ns.spdb.combo_points.position_y = y

        frame:ClearAllPoints()
        frame:SetPoint(ns.spdb.combo_points.point, UIParent, ns.spdb.combo_points.relativePoint, ns.spdb.combo_points.position_x, ns.spdb.combo_points.position_y)
    end

    function createIncremental(anchorPoint, dir, text, step)
        local btn = CreateFrame("Button", nil, PositionOptions.Incremental, "UIPanelButtonTemplate")
        btn:SetSize(32, 32)
        btn:SetPoint(dir, PositionOptions.Incremental, anchorPoint)
        btn:SetText(text)
        btn:SetScript("OnClick", function() moveFrame(anchorPoint) end)
        return btn
    end

    function centerFrame(zeroX, zeroY)
        local frame = ns.ScritchPop.ComboPoints:GetFrame()
        local ux, uy = UIParent:GetCenter()
        local fx, fy = frame:GetCenter()

        ns.spdb.combo_points.point = "CENTER"
        ns.spdb.combo_points.relativePoint = "CENTER"

        if zeroX then
            ns.spdb.combo_points.position_x = 0
        else
            ns.spdb.combo_points.position_x = fx - ux
        end

        if zeroY then
            ns.spdb.combo_points.position_y = 0
        else
            ns.spdb.combo_points.position_y = fy - uy
        end

        frame:ClearAllPoints()
        frame:SetPoint(ns.spdb.combo_points.point, UIParent, ns.spdb.combo_points.relativePoint, ns.spdb.combo_points.position_x, ns.spdb.combo_points.position_y)
    end

    local anchor = ScritchPopComboPointsFrame
    PositionOptions.Incremental = CreateFrame("Frame", nil, anchor, "BackdropTemplate")
    PositionOptions.Incremental:SetAllPoints()
    PositionOptions.Incremental.TOP = createIncremental("TOP", "BOTTOM", "+")
    PositionOptions.Incremental.BOTTOM = createIncremental("BOTTOM", "TOP", "-")
    PositionOptions.Incremental.LEFT = createIncremental("LEFT", "RIGHT", "<")
    PositionOptions.Incremental.RIGHT = createIncremental("RIGHT", "LEFT", ">")

    PositionOptions.Center = CreateFrame("Button", nil, anchor, "UIPanelButtonTemplate")
    PositionOptions.Center:SetSize(160, 24)
    PositionOptions.Center:SetPoint("LEFT", anchor, "RIGHT", 32, -32)
    PositionOptions.Center:SetText("Center")
    PositionOptions.Center:SetScript("OnClick", function() centerFrame(true, true) end)

    PositionOptions.CenterVertical = CreateFrame("Button", nil, anchor, "UIPanelButtonTemplate")
    PositionOptions.CenterVertical:SetSize(160, 24)
    PositionOptions.CenterVertical:SetPoint("LEFT", anchor, "RIGHT", 32, 0)
    PositionOptions.CenterVertical:SetText("Center Vertically")
    PositionOptions.CenterVertical:SetScript("OnClick", function() centerFrame(false, true) end)

    PositionOptions.CenterHorizontal = CreateFrame("Button", nil, anchor, "UIPanelButtonTemplate")
    PositionOptions.CenterHorizontal:SetSize(160, 24)
    PositionOptions.CenterHorizontal:SetPoint("LEFT", anchor, "RIGHT", 32, 32)
    PositionOptions.CenterHorizontal:SetText("Center Horizontally")
    PositionOptions.CenterHorizontal:SetScript("OnClick", function() centerFrame(true, false) end)
    
    ns.ScritchPop.togglePositionOptions = function(val) 
        if val and ns.ScritchPop._optionsOpen then
            PositionOptions:Show()
            PositionOptions.Incremental:Show()
            PositionOptions.Incremental.TOP:Show()
            PositionOptions.Incremental.BOTTOM:Show()
            PositionOptions.Incremental.LEFT:Show()
            PositionOptions.Incremental.RIGHT:Show()
            PositionOptions.Center:Show()
            PositionOptions.CenterVertical:Show()
            PositionOptions.CenterHorizontal:Show()
        else
            PositionOptions:Hide()
            PositionOptions.Incremental:Hide()
            PositionOptions.Incremental.TOP:Hide()
            PositionOptions.Incremental.BOTTOM:Hide()
            PositionOptions.Incremental.LEFT:Hide()
            PositionOptions.Incremental.RIGHT:Hide()
            PositionOptions.Center:Hide()
            PositionOptions.CenterVertical:Hide()
            PositionOptions.CenterHorizontal:Hide()
        end
    end
    ns.ScritchPop.togglePositionOptions()
end

-- -----------------------------------------------------------------------------------------
-- -- display handler
-- -----------------------------------------------------------------------------------------
ns.ScritchPop.displayHandler = CreateFrame("Frame", nil)
function ns.ScritchPop.displayHandler:UpdateVisibility()
    if ns.spdb.visible_when == 1 then
        ns.ScritchPop.ComboPoints:Show()
        if ns.spdb.energy_bar.enabled then 
            ns.ScritchPop.EnergyBar:Show()
        end
        return
    end
    if ns.spdb.visible_when == 5 then
        ns.ScritchPop.ComboPoints:Hide()
        if ns.spdb.energy_bar.enabled then 
            ns.ScritchPop.EnergyBar:Hide()
        end
        return
    end
    
    local class = UnitClass("player")
    local spec = GetSpecialization()
    local form = GetShapeshiftFormID()
    if ns.spdb.visible_when == 2 and class == "Druid" then
        ns.ScritchPop.ComboPoints:Show()
        if ns.spdb.energy_bar.enabled then 
            ns.ScritchPop.EnergyBar:Show()
        end
        return
    end
    if ns.spdb.visible_when == 3 and class == "Druid" and spec == 2 then
        ns.ScritchPop.ComboPoints:Show()
        if ns.spdb.energy_bar.enabled then 
            ns.ScritchPop.EnergyBar:Show()
        end
        return
    end

    if form == 1 and ns.spdb.visible_when == 4 then
        ns.ScritchPop.ComboPoints:Show()
        if ns.spdb.energy_bar.enabled then 
            ns.ScritchPop.EnergyBar:Show()
        end
        return
    end
    
    ns.ScritchPop.ComboPoints:Hide()
    if ns.spdb.energy_bar.enabled then 
        ns.ScritchPop.EnergyBar:Hide()
    end
end
function ns.ScritchPop.displayHandler:UpdateOpacity()
    local combat = UnitAffectingCombat("player")
    ns.ScritchPop.ComboPoints:SetAlpha(combat and ns.spdb.combo_points.combat_opacity or ns.spdb.combo_points.opacity)
    if ns.spdb.energy_bar.enabled then 
        ns.ScritchPop.EnergyBar:SetAlpha(combat and ns.spdb.combo_points.combat_opacity or ns.spdb.combo_points.opacity)
    end
end
ns.ScritchPop.displayHandler:RegisterUnitEvent("UPDATE_SHAPESHIFT_FORM")
ns.ScritchPop.displayHandler:RegisterEvent("PLAYER_IN_COMBAT_CHANGED")
ns.ScritchPop.displayHandler:RegisterUnitEvent("PLAYER_SPECIALIZATION_CHANGED")
ns.ScritchPop.displayHandler:RegisterEvent("ACTIVE_PLAYER_SPECIALIZATION_CHANGED")
ns.ScritchPop.displayHandler:RegisterEvent("SPELL_UPDATE_USABLE")
ns.ScritchPop.displayHandler:RegisterEvent("SPELLS_CHANGED")
ns.ScritchPop.displayHandler:RegisterEvent("UNIT_MAXPOWER")
ns.ScritchPop.displayHandler:SetScript("OnEvent", function(_, event, ...)
    if (event == "PLAYER_IN_COMBAT_CHANGED") then
        ns.ScritchPop.displayHandler:UpdateOpacity()
    else
        if (event == "UNIT_MAXPOWER") then
            local unit, power_type = ...
            if unit == "player" and power_type == "COMBO_POINTS" then 
                updateAfterChange()
            end
        end

        ns.ScritchPop.displayHandler:UpdateVisibility()
        ns.ScritchPop.EnergyBar:updateChompLine()
    end
end)


ns.ScritchPop.RegisterOptions = function()
    AceConfig:RegisterOptionsTable("ScritchPopOptions", optionsTable)
    AceConfigDialog:SetDefaultSize("ScritchPopOptions", 775, 500)
    InitPositionOptions()

    ns.ScritchPop.OpenOptions = function() 
        AceConfigDialog:Open("ScritchPopOptions")

        C_Timer.After(0.1, function()
            ns.ScritchPop._optionsOpen = true
            ns.ScritchPop.togglePositionOptions(ns.spdb.combo_points.movable)

            local widget = AceConfigDialog.OpenFrames["ScritchPopOptions"]
            if widget and widget.frame then
                local originalOnHide = widget.frame:GetScript("OnHide")
                widget.frame:SetScript("OnHide", function(self, ...)
                    if originalOnHide then 
                        originalOnHide(self, ...) 
                    end
                    ns.ScritchPop._optionsOpen = false
                    ns.ScritchPop.togglePositionOptions(ns.spdb.combo_points.movable)
                end)
            end
        end)
    end
end


SLASH_SCRITCHPOP1 = "/scritchpop"
SLASH_SCRITCHPOP2 = "/scritch"
SLASH_SCRITCHPOP3 = "/spcp"

SlashCmdList["SCRITCHPOP"] = function(msg)
    local cmd, arg = msg:match("^(%S*)%s*(.-)$")

    if cmd == "default" or cmd == "reset" then
        restoreDefaults()
        ns.ScritchPop.ComboPoints:Cleanup()
        ns.ScritchPop.ComboPoints:Init()
        RegisterOptions()
    else 
        ns.ScritchPop.OpenOptions()
    end
end
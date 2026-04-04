local _, ns = ...
if not ns.ScritchPop then ns.ScritchPop = {} end

ns.ScritchPop.ComboPoints = CreateFrame("Frame", "ScritchPopComboPoints")

function ns.ScritchPop.ComboPoints:UpdateDisplay()
    if not self.initialized then return end

    local current = UnitPower("player", Enum.PowerType.ComboPoints)
    local max = UnitPowerMax("player", Enum.PowerType.ComboPoints) or 5
    local overflowing_info = C_UnitAuras.GetPlayerAuraBySpellID(405189)
    local overflowed = overflowing_info and overflowing_info.applications or 0
    max = max > 0 and max or 5

    for i = 1, max do
        if i <= overflowed then 
            self.PointsTextures[i]:SetTexture(ns.ScritchPop.getOverflowed())
        elseif i <= current then
            self.PointsTextures[i]:SetTexture(ns.ScritchPop.getPop())
        else
            self.PointsTextures[i]:SetTexture(ns.ScritchPop.getEmpty())
        end

    end

end

function ns.ScritchPop.ComboPoints:ApplyLayout()
    if not self.Frame then return end
    local max = UnitPowerMax("player", Enum.PowerType.ComboPoints) or 5
    max = max > 0 and max or 5
    self.PointSize = 64 * ns.spdb.combo_points.scale
    self.Frame:ClearAllPoints()
    self.Frame:SetPoint(ns.spdb.combo_points.point, UIParent, ns.spdb.combo_points.relativePoint, ns.spdb.combo_points.position_x, ns.spdb.combo_points.position_y)
    self.Frame:SetSize(max*self.PointSize + (max-2)*ns.spdb.combo_points.gap, self.PointSize)

    for i = 1, math.max(max, #self.PointsTextures) do
        if self.PointsTextures[i] then
            self.PointsTextures[i]:Hide()
            self.PointsTextures[i] = nil
        end
        if i <= max then
            self.PointsTextures[i] = self.Frame:CreateTexture(nil, "BACKGROUND")
            self.PointsTextures[i]:SetSize(self.PointSize, self.PointSize)
            self.PointsTextures[i]:SetTexture(ns.ScritchPop.getEmpty())
            self.PointsTextures[i]:ClearAllPoints()
            self.PointsTextures[i]:SetPoint("LEFT", self.Frame, "LEFT", (i-1)*(self.PointSize+ns.spdb.combo_points.gap), 0)
            self.PointsTextures[i]:Show()    
        end
    end
    self.initialized = true
    self:UpdateDisplay()
    ns.ScritchPop.displayHandler:UpdateVisibility()
    ns.ScritchPop.displayHandler:UpdateOpacity()
end


function ns.ScritchPop.ComboPoints:Cleanup()
    if self.Frame then
        self.Frame:UnregisterAllEvents()
        self.Frame:Hide()
        self.Frame:ClearAllPoints()
        self.Frame = nil
    end
    self.PointsTextures = {}
    self.initialized = false
end

function ns.ScritchPop.ComboPoints:Init()   
    ns.ScritchPop.blinkState = true

    self.PointsTextures = {}
    self.PointSize = 64 * ns.spdb.combo_points.scale
    self.Frame = CreateFrame("Frame", 'ScritchPopComboPointsFrame', UIParent, BackdropTemplateMixin and "BackdropTemplate")
    self.Frame:SetFrameLevel(200)
    self.Frame:Show()
    self:ApplyLayout()
    
    self.Frame:SetMovable(ns.spdb.combo_points.movable)
    self.Frame:EnableMouse(ns.spdb.combo_points.movable)
    self.Frame:RegisterForDrag("LeftButton")
    self.Frame:SetScript("OnDragStart", self.Frame.StartMoving)
    self.Frame:SetScript("OnDragStop", function(frame) 
        frame:StopMovingOrSizing() 
        local point, _, relativePoint, xOfs, yOfs = self.Frame:GetPoint() 
        ns.spdb.combo_points.point = point 
        ns.spdb.combo_points.relativePoint = relativePoint 
        ns.spdb.combo_points.position_x = xOfs 
        ns.spdb.combo_points.position_y = yOfs 

        if ns.ScritchPop.EnergyBar then
            point, _, relativePoint, xOfs, yOfs = ns.ScritchPop.EnergyBar:GetPoint() 
            ns.spdb.energy_bar.point = point 
            ns.spdb.energy_bar.relativePoint = relativePoint 
            ns.spdb.energy_bar.position_x = xOfs 
            ns.spdb.energy_bar.position_y = yOfs 
        end
    end)
    
    self.Frame:RegisterUnitEvent("UNIT_POWER_UPDATE", "player")
    self.Frame:RegisterUnitEvent("UNIT_AURA", "player")
    self.Frame:SetScript("OnEvent", function(_, event, unit, updateInfo)
        if unit and unit ~= "player" then return end
        self:UpdateDisplay()
    end)

    if (ns.spdb.energy_bar.enabled) then
        ns.ScritchPop.EnergyBar:createEnergyBar()
    end

    local blinkFrame = CreateFrame("Frame", nil, self.Frame)
    self.elapsed = 0
    blinkFrame:SetScript("OnUpdate", function(_, elapsed)
        self:UpdateDisplay()
        if (not ns.spdb.combo_points.popping) then return end
        self.elapsed = self.elapsed + elapsed
        if self.elapsed >= ns.spdb.combo_points.popSpeed then
            ns.ScritchPop.blinkState = not ns.ScritchPop.blinkState
            self:UpdateDisplay()
            self.elapsed = 0
        end
    end)
end

---------------------------------------------------------------------------

function ns.ScritchPop.ComboPoints:SetMovable(value)
    if self.Frame then self.Frame:SetMovable(value) end
end

function ns.ScritchPop.ComboPoints:EnableMouse(value)
    if self.Frame then self.Frame:EnableMouse(value) end
end

function ns.ScritchPop.ComboPoints:Show()
    if self.Frame then self.Frame:Show() end
end

function ns.ScritchPop.ComboPoints:Hide()
    if self.Frame then self.Frame:Hide() end
end

function ns.ScritchPop.ComboPoints:GetFrame()
    return self.Frame
end

function ns.ScritchPop.ComboPoints:SetAlpha(val)
    return self.Frame:SetAlpha(val)
end

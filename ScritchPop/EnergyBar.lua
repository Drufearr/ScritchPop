local _, ns = ...
if not ns.ScritchPop then ns.ScritchPop = {} end

ns.ScritchPop.EnergyBar = CreateFrame("Frame", "ScritchPopEnergyBar", UIParent)

function ns.ScritchPop.EnergyBar:createEnergyBar()
    if self.Border or self.TextFrame or self.TextValue or self.StatusBar then return end

    self.Border = self:CreateTexture(nil, "OVERLAY")
    self.Border:SetTexture("Interface\\BUTTONS\\WHITE8X8")
    self.Border:SetVertexColor(0, 0, 0, 0.5)
    self.Border:Show()

    self.TextFrame = CreateFrame("Frame", nil, self)
    self.TextFrame:Show()

    self.TextValue = self.TextFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    self.TextValue:SetJustifyH("CENTER")
    self.TextValue:SetFont("Fonts\\FRIZQT__.TTF", ns.spdb.energy_bar.text_size, "OUTLINE")
    self.TextValue:Show()

    self.StatusBar = CreateFrame("StatusBar", "ScritchPopEnergyBarStatusBar", self)
    self.StatusBar:SetStatusBarTexture("Interface\\TARGETINGFRAME\\UI-StatusBar")
    self.StatusBar:Show()

    self:SetMovable(ns.spdb.energy_bar.movable)
    self:EnableMouse(ns.spdb.energy_bar.movable)
    self:RegisterForDrag("LeftButton")
    self:SetScript("OnDragStart", self.StartMoving)
    self:SetScript("OnDragStop", function(frame) 
        frame:StopMovingOrSizing() 
        local point, _, relativePoint, xOfs, yOfs = self:GetPoint() 
        ns.spdb.energy_bar.point = point 
        ns.spdb.energy_bar.relativePoint = relativePoint 
        ns.spdb.energy_bar.position_x = xOfs 
        ns.spdb.energy_bar.position_y = yOfs 
    end)


    if ns.spdb.energy_bar.chomp_line then
        self.ChompLine = CreateFrame("Frame", 'ScritchPopComboPointsChompLine', self.StatusBar)
    end

    self:updateLayout()

    self:SetScript("OnUpdate", function(self, delta)
        self:updateEnergy()
    end)
end

function ns.ScritchPop.EnergyBar:destroyEnergyBar()
    if self.Border then
        self.Border:Hide()
        self.Border = nil
    end
    if self.TextFrame then
        self.TextFrame:Hide()
        self.TextFrame = nil
    end
    if self.TextValue then
        self.TextValue:Hide()
        self.TextValue = nil
    end
    if self.StatusBar then
        self.StatusBar:Hide()
        self.StatusBar = nil
    end
    self:destroyChompLine()
    self:SetScript("OnUpdate", nil);
end

function ns.ScritchPop.EnergyBar:destroyChompLine()
    if self.ChompLine and self.ChompLine.tex then
        self.ChompLine.tex:Hide()
        self.ChompLine.tex = nil
    end
    if self.ChompLine then
        self.ChompLine:Hide()
        self.ChompLine = nil
    end
end

function ns.ScritchPop.EnergyBar:updateLayout()
    self:SetSize(ns.spdb.energy_bar.width, ns.spdb.energy_bar.height)
    self:ClearAllPoints()
    if ns.spdb.energy_bar.anchored_to_points then
        self:SetPoint("BOTTOM", 'ScritchPopComboPointsFrame', "TOP", 0, 10)  
    else
        self:SetPoint(ns.spdb.energy_bar.point, UIParent, ns.spdb.energy_bar.relativePoint, ns.spdb.energy_bar.position_x, ns.spdb.energy_bar.position_y)
    end

    self.Border:SetPoint("TOPLEFT", -2, 2)
    self.Border:SetPoint("BOTTOMRIGHT", 2, -2)

    self.TextFrame:SetAllPoints()

    self.TextValue:SetPoint("CENTER", self.TextFrame, "CENTER", 0, 0)
    self.TextValue:SetFont("Fonts\\FRIZQT__.TTF", ns.spdb.energy_bar.text_size, "OUTLINE")

    self.StatusBar:SetAllPoints()
    self.StatusBar:SetStatusBarTexture("Interface\\TARGETINGFRAME\\UI-StatusBar")
    if ns.spdb.energy_bar.enabled then
        if ns.spdb.energy_bar.chomp_line then
            self:updateChompLine()
        else
            self:destroyChompLine()
        end
    end
end


function ns.ScritchPop.EnergyBar:updateChompLine()
    if not self.ChompLine then return end
    if not C_SpellBook.IsSpellKnown(1244258) then 
        self.ChompLine:Hide()
        return
    end
    local anchor = self.StatusBar
    local height = anchor:GetHeight()
    local width = anchor:GetWidth()
    self.ChompLine:ClearAllPoints()
    self.ChompLine:SetPoint("CENTER", anchor, "CENTER", -(width/5), 0)
    self.ChompLine:SetHeight(height) 
    self.ChompLine:SetWidth(ns.spdb.energy_bar.chomp_line_width)
    self.ChompLine:SetFrameLevel(anchor:GetFrameLevel() + 1)
    self.ChompLine:Show()

    if not self.ChompLine.tex then
        self.ChompLine.tex = self.ChompLine:CreateTexture(nil, "OVERLAY")
        self.ChompLine.tex:SetColorTexture(0, 0, 0, 1)
    end
    self.ChompLine.tex:SetAllPoints(self.ChompLine)
end

function ns.ScritchPop.EnergyBar:updateEnergy()
    if not self.StatusBar then return end

    local form = GetShapeshiftFormID()
    if ns.spdb.energy_bar.rage_in_bear and form == 5 then -- bear
        local rage = UnitPower("player", Enum.PowerType.Rage)
        local max_rage = UnitPowerMax("player", Enum.PowerType.Rage)

        self.StatusBar:SetStatusBarColor(1, 0, 0, 1)
        self.StatusBar:SetMinMaxValues(0, max_rage)
        self.StatusBar:SetValue(rage)
        self.TextValue:SetText(rage)
    else
        local energy = UnitPower("player", Enum.PowerType.Energy)
        local max_energy = UnitPowerMax("player", Enum.PowerType.Energy)

        local r, g, b = unpack(
            ScritchPop._berserkActive and ns.spdb.energy_bar.berserk_color
            or ns.spdb.energy_bar.color
        )
        self.StatusBar:SetStatusBarColor(r, g, b, 1)

        self.StatusBar:SetMinMaxValues(0, max_energy)
        self.StatusBar:SetValue(energy)
        self.TextValue:SetText(energy)
    end 
end
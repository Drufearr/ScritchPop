local addonName, ns = ...
if not ns.ScritchPop then ns.ScritchPop = {} end


local ScritchPopFrame = CreateFrame("Frame")
ScritchPopFrame:RegisterEvent("ADDON_LOADED")
ScritchPopFrame:RegisterEvent("PLAYER_LOGIN")
ScritchPopFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
ScritchPopFrame:SetScript("OnEvent", function(_, event, arg1)
    if (event == "ADDON_LOADED" or event == "PLAYER_ENTERING_WORLD" or event == "PLAYER_LOGIN") and arg1 == addonName then
        ns.ScritchPop.InitConfig()
        ns.ScritchPop.ComboPoints:Init()
        ns.ScritchPop.RegisterOptions()
    end
end)
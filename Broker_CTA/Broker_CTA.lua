function MyAddon_OnLoad()
    SlashCmdList["MyAddon"] = MyAddon_SlashCommand;
    SLASH_MYADDON1= "/myaddon";
    this:RegisterEvent("VARIABLES_LOADED")
end

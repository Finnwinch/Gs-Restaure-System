if not GS then GS = {} end
GS.ShowDetail = true
GS.Version = 3
GS.Debug = true
GS.Path = "GS/Restauration Emplacement"
GS.ValeurEntity = {
    ["edit_fog"] = 100,
    ["sent_ball"] = 1000
}
local function MyCommandAutoComplete(cmd, args)
    local options = {"true", "false"}
    local text = args[1] or ""

    if text ~= "" then
        local filtered = {}
        for _, option in ipairs(options) do
            if string.StartWith(option, text) then
                table.insert(filtered, option)
            end
        end
        options = filtered
    end

    return options
end

concommand.Add("mycommand", function(_, _, args)
    if args[1] == "true" then
        print("mycommand set to true")
    elseif args[1] == "false" then
        print("mycommand set to false")
    else
        print("Invalid option")
    end
end, MyCommandAutoComplete)
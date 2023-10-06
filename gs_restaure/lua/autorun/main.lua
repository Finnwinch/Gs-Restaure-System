if not GS then GS = {} end
if SERVER then
    include("gs_restaure/affichage_script_run.lua")
end
local PATH = "GS/Restauration Emplacement"
PATH = GS.Path || PATH
if not file.Exists(PATH,"data") then
	file.CreateDir(PATH)
end

gameevent.Listen("player_disconnect")
hook.Add("player_disconnect", "player_disconnect_example", function(data)
	local id = data.networkid
    hook.Add("PlayerDisconnected", "Playerleave", function(ply)
        if data.reason == ("Timed out!" || "Engine Error" || "Server Crash") || GS.Debug then
            local position = ply:GetPos()
            local angle = ply:GetAngles()
            local old_weapons = {}
            for _, weapon in pairs(ply:GetWeapons()) do
                table.insert(old_weapons,weapon:GetClass())
            end
            local emploie = ply:Team()
            local Mtable = { Identifiant = id,
            position.x, 
            position.y, 
            position.z,
            angle.p, 
            angle.y, 
            angle.r,
            Armes = {old_weapons},
            Valeur = ply.valeur,
            Job = emploie
            }
            for _, ent in pairs(ents.FindByClass("*")) do
                if ent:CPPIGetOwner() == ply then
                  ent:Remove()
                end
            end
			MsgC( Color( 153, 0, 255, 200), "[", Color(255,0,0), "GS", Color( 153, 0, 255, 200), "]", Color(0,0,255), " Resauration Enregistrement ", Color(0,255,0), ply:SteamID().."\n")
			id = string.sub(id,11,-1)
            file.Write(PATH.."/"..id.."Experiement_DisconnectMessage.json", util.TableToJSON(Mtable))
        end
    end)
end)

gameevent.Listen("player_connect")
hook.Add("player_connect", "AnnounceConnection", function(data)
	local id = data.networkid
	local id = string.sub(id,11,-1)
    if SERVER and file.Exists(PATH.."/"..id.."Experiement_DisconnectMessage.json", "DATA") then
        temp_info = util.JSONToTable(file.Read(PATH.."/"..id.."Experiement_DisconnectMessage.json", "DATA"))
		MsgC( Color( 153, 0, 255, 200), "[", Color(255,0,0), "GS", Color( 153, 0, 255, 200), "]", Color(0,0,255), " Resauration Trouvé ", Color(0,255,0), temp_info.Identifiant.."\n")
    end
end)

hook.Add("PlayerInitialSpawn", "SetPlayerPosition", function(ply)
    local id = string.sub(ply:SteamID(),11,-1)
    ply.valeur = 0
    hook.Add( "PlayerSpawnedSENT", "PrintSpawnedEnt", function( ply, ent )
        for k,v in pairs(GS.ValeurEntity) do
            if k == ent:GetClass() then
                ply.valeur = ply.valeur + v
            end
        end
        return ply.valeur
    end )
    if not file.Exists(PATH.."/"..id.."Experiement_DisconnectMessage.json","data") then
        MsgC( Color( 153, 0, 255, 200), "[", Color(255,0,0), "GS", Color( 153, 0, 255, 200), "]", Color(0,0,255), " Resauration Inconnu ", Color(0,255,0), ply:SteamID().."\n")
        return
    end
        info = util.JSONToTable(file.Read(PATH.."/"..id.."Experiement_DisconnectMessage.json", "DATA"))
		timer.Create("Waiter",1,1,function()
                MsgC( Color( 153, 0, 255, 200), "[", Color(255,0,0), "GS", Color( 153, 0, 255, 200), "]", Color(0,0,255), " Resauration Appliqué ", Color(0,255,0), ply:SteamID().."\n")
        	    ply:SetPos(Vector(info[1], info[2], info[3]))
        	    ply:SetEyeAngles(Angle(info[4], info[5], info[6]))
                ply:StripWeapons()
                if engine.ActiveGamemode() == "darkrp" then
                    ply:addMoney(info.Valeur)
                    ply:SetTeam(info.Job)
                    ply:setDarkRPVar("job",team.GetName(info.Job))
                    if istable(ply:getJobTable().model) then
                        ply:SetModel(ply:getJobTable().model[1])
                    else
                        ply:SetModel(ply:getJobTable().model)
                    end
                else
                    print(info.Valeur," valeur found to"..ply:SteamID())
                end
                for i = 1, #info.Armes[1], 1 do
                    ply:Give(info.Armes[1][i])
                end
                MsgC( Color( 153, 0, 255, 200), "[", Color(255,0,0), "GS", Color( 153, 0, 255, 200), "]", Color(0,0,255), " Resauration Supression ", Color(0,255,0), temp_info.Identifiant.."\n")
                file.Delete(PATH.."/"..id.."Experiement_DisconnectMessage.json")
		end)
end)

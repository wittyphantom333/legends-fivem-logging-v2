local channelsLoadFile = LoadResourceFile(GetCurrentResourceName(), "./config/channels.json")
local channelFile = json.decode(channelsLoadFile)
if channelFile == nil then
	local temp = LoadResourceFile(GetCurrentResourceName(), "./config/example.channels.json")
	local file = io.open(GetResourcePath(GetCurrentResourceName()) .. "/config/channels.json", "w")
	file:write(temp)
	file:close()
	channelsLoadFile = LoadResourceFile(GetCurrentResourceName(), "./config/channels.json")
	channelFile = json.decode(channelsLoadFile)
	print(
		"^2Success: ^0We created a channels file for you.\n^1Note: Please Reatsrt legendsDiscordLogs_V3 to continue.^0"
	)
end

local configLoadFile = LoadResourceFile(GetCurrentResourceName(), "./config/config.json")
local cfgFile = json.decode(configLoadFile)
if cfgFile == nil then
	local temp = LoadResourceFile(GetCurrentResourceName(), "./config/example.config.json")
	local file = io.open(GetResourcePath(GetCurrentResourceName()) .. "/config/config.json", "w")
	file:write(temp)
	file:close()
	configLoadFile = LoadResourceFile(GetCurrentResourceName(), "./config/config.json")
	cfgFile = json.decode(configLoadFile)
	print("^2Success: ^0We created a config file for you.\n^1Note: Please Reatsrt legendsDiscordLogs_V3 to continue.^0")
end

CreateThread(function()
	while true do
		Wait(0)
		if cfgFile.tokens ~= nil and channelFile.newInstall ~= nil then
			if cfgFile["tokens"]["1"].token == "" then
				print("^1Error: You need to set at least one bot token.^0")
			end
			if channelFile["newInstall"] then
				print("^2Please use the ^1!legendsDiscordLogs setup ^2command on discord to finish the installation.^0")
			end
			break
		end
	end
end)

RegisterCommand("legendsDiscordLogs", function(source, args, RawCommand)
	if source == 0 then
		if args[1]:lower() == "hide" then
			if not args[3] then
				return print("^1Error: Please use 'legendsDiscordLogs hide [channel] [object]'^0")
			end
			if channelFile[args[2]:lower()] then
				state = GetResourceKvpString("legendsDiscordLogs:" .. args[2]:lower() .. ":" .. args[3]:lower())
				if state == "false" or state == nil then
					_state = "true"
				else
					_state = "false"
				end
				SetResourceKvp("legendsDiscordLogs:" .. args[2]:lower() .. ":" .. args[3]:lower(), _state)
				print(
					"^5[legendsDiscordLogs]^1: Updated the hide status for "
						.. args[2]:lower()
						.. " ("
						.. args[3]:lower()
						.. ") to: "
						.. _state
						.. "^0"
				)
			else
				print(
					"^1Error: Channel "
						.. args[2]:lower()
						.. " does not exist. (Make sure to add it to your channels.json before using this command.)^0"
				)
			end
		end
	end
end)

exports("discord", function(msg, player_1, player_2, color, channel)
	args = {
		["EmbedMessage"] = msg,
		["color"] = color,
		["channel"] = channel,
	}
	if player_1 ~= 0 then
		args["player_id"] = player_1
	end
	if player_2 ~= 0 then
		args["player_2_id"] = player_2
	end
	CreateLog(args)
end)

exports("createLog", function(args)
	CreateLog(args)
end)

exports("GetPlayers", function(args)
	return GetPlayers()
end)

RegisterCommand("screenshot", function(source, args, RawCommand)
	if source == 0 then
		if args[1] == nil then
			return console.log("^1legendsDiscordLogs Error:^0 Please insert a target (1 argument expected got nil)")
		end
		TriggerEvent("legendsDiscordLogs:ScreenshotCommand", args[1], "Console")
	else
		if IsPlayerAceAllowed(source, cfgFile["screenshotPerms"]) then
			if args[1] == nil then
				return TriggerClientEvent("chat:addMessage", source, {
					color = { 255, 0, 0 },
					args = {
						"legendsDiscordLogs",
						"Please insert a target (use /screenshot id)",
					},
				})
			end
			TriggerEvent("legendsDiscordLogs:ScreenshotCommand", args[1], GetPlayerName(source))
		end
	end
end)

RegisterNetEvent("legendsDiscordLogs:ScreenshotCommand")
AddEventHandler("legendsDiscordLogs:ScreenshotCommand", function(tId, src)
	CreateLog({
		EmbedMessage = "**Screenshot of:** `" .. GetPlayerName(tId) .. "`\n**Requested by:** `" .. src .. "`",
		player_id = tId,
		channel = "screenshot",
		screenshot = true,
	})
end)

AddEventHandler("playerJoining", function(source, oldID)
	CreateLog({
		EmbedMessage = ("**%s** has joined the server."):format(GetPlayerName(source)),
		player_id = source,
		channel = "join",
	})
	TriggerClientEvent("legendsSystems:GetNotLogged", source, cfgFile["WeaponsNotLogged"])
	local ids = ExtractIdentifiers(source)
	local oldName = GetResourceKvpString("legendsDiscordLogs:nameChane:" .. ids.license)
	if oldName == nil then
		SetResourceKvp("legendsDiscordLogs:nameChane:" .. ids.license, GetPlayerName(source))
	else
		if oldName ~= GetPlayerName(source) then
			CreateLog({
				EmbedMessage = ("**Name Change Detected**\n`%s` :arrow_right: `%s`"):format(
					oldName,
					GetPlayerName(source)
				),
				player_id = source,
				channel = "nameChange",
			})
			SetResourceKvp("legendsDiscordLogs:nameChane:" .. ids.license, GetPlayerName(source))
			for k, v in pairs(GetPlayers()) do
				if IsPlayerAceAllowed(v, cfgFile["NameChangePerms"]) then
					TriggerClientEvent("chat:addMessage", i, {
						template = '<div style="background-color: rgba(90, 90, 90, 0.9); text-align: center; border-radius: 0.5vh; padding: 0.7vh; font-size: 1.7vh;"><b>Player ^1{0} ^0{1} ^1{2}</b></div>',
						args = { ("**Name Change Detected** `%s` -> `%s`"):format(GetPlayerName(source), oldName) },
					})
				end
			end
		end
	end
end)

CreateThread(function()
	local current = GetResourceMetadata(GetCurrentResourceName(), "version")
	PerformHttpRequest(
		"https://raw.githubusercontent.com/legendsSystems/legendsDiscordLogs/master/json/version.json",
		function(code, res, headers)
			if code == 200 then
				local rv = json.decode(res)
				SetConvarServerInfo("legendsDiscordLogs", "V" .. current)
				if rv.version ~= current then
					print(
						"^5[legendsDiscordLogs] ^1Error: ^0legendsDiscordLogs is outdated and you will no longer get support for this version."
					)
				end
			end
		end,
		"GET"
	)
	Wait(10 * 1000)
	SetResourceKvp("legendsDiscordLogs:LastVersion", current) -- This KVP is used for making the correct changes to config files when updating to the latest version.
end)

CreateThread(function()
	TriggerClientEvent("legendsSystems:GetNotLogged", -1, cfgFile["WeaponsNotLogged"]) -- Just sync the table in case of resource restart.
end)

AddEventHandler("playerDropped", function(reason)
	CreateLog({
		EmbedMessage = ("**%s** has left the server.\nReason: `%s`"):format(GetPlayerName(source), reason),
		player_id = source,
		channel = "leave",
	})
end)

AddEventHandler("chatMessage", function(source, name, msg)
	local _source = source
	if msg:sub(1, 1) ~= "/" then
		CreateLog({
			channel = "chat",
			EmbedMessage = ("**%s:** `%s`"):format(GetPlayerName(_source), msg),
			player_id = _source,
		})
	end
end)

AddEventHandler("explosionEvent", function(source, ev)
	local explosionTypes = {
		"GRENADE",
		"GRENADELAUNCHER",
		"STICKYBOMB",
		"MOLOTOV",
		"ROCKET",
		"TANKSHELL",
		"HI_OCTANE",
		"CAR",
		"PLANE",
		"PETROL_PUMP",
		"BIKE",
		"DIR_STEAM",
		"DIR_FLAME",
		"DIR_GAS_CANISTER",
		"BOAT",
		"SHIP_DESTROY",
		"TRUCK",
		"BULLET",
		"SMOKEGRENADELAUNCHER",
		"SMOKEGRENADE",
		"BZGAS",
		"FLARE",
		"GAS_CANISTER",
		"EXTINGUISHER",
		"PROGRAMMABLEAR",
		"TRAIN",
		"BARREL",
		"PROPANE",
		"BLIMP",
		"DIR_FLAME_EXPLODE",
		"TANKER",
		"PLANE_ROCKET",
		"VEHICLE_BULLET",
		"GAS_TANK",
		"BIRD_CRAP",
		"RAILGUN",
		"BLIMP2",
		"FIREWORK",
		"SNOWBALL",
		"PROXMINE",
		"VALKYRIE_CANNON",
		"AIR_DEFENCE",
		"PIPEBOMB",
		"VEHICLEMINE",
		"EXPLOSIVEAMMO",
		"APCSHELL",
		"BOMB_CLUSTER",
		"BOMB_GAS",
		"BOMB_INCENDIARY",
		"BOMB_STANDARD",
		"TORPEDO",
		"TORPEDO_UNDERWATER",
		"BOMBUSHKA_CANNON",
		"BOMB_CLUSTER_SECONDARY",
		"HUNTER_BARRAGE",
		"HUNTER_CANNON",
		"ROGUE_CANNON",
		"MINE_UNDERWATER",
		"ORBITAL_CANNON",
		"BOMB_STANDARD_WIDE",
		"EXPLOSIVEAMMO_SHOTGUN",
		"OPPRESSOR2_CANNON",
		"MORTAR_KINETIC",
		"VEHICLEMINE_KINETIC",
		"VEHICLEMINE_EMP",
		"VEHICLEMINE_SPIKE",
		"VEHICLEMINE_SLICK",
		"VEHICLEMINE_TAR",
		"SCRIPT_DRONE",
		"RAYGUN",
		"BURIEDMINE",
		"SCRIPT_MISSIL",
	}
	if ev.explosionType < -1 or ev.explosionType > 77 then
		ev.explosionType = "UNKNOWN"
	else
		ev.explosionType = explosionTypes[ev.explosionType + 1]
	end
	CreateLog({
		EmbedMessage = ("**%s** created an explotion: `%s`"):format(GetPlayerName(source), ev.explosionType),
		player_id = source,
		channel = "explosion",
	})
end)

AddEventHandler("onResourceStop", function(resourceName)
	CreateLog({ EmbedMessage = ("`%s` has been stopped."):format(resourceName), channel = "resource" })
end)

RegisterNetEvent("printDebug")
AddEventHandler("printDebug", function(txt)
	print("Debug" .. txt)
end)

AddEventHandler("onResourceStart", function(resourceName)
	Wait(100)
	CreateLog({ EmbedMessage = ("`%s` has been started."):format(resourceName), channel = "resource" })
end)

RegisterServerEvent("legendsSystems:playerDied")
AddEventHandler("legendsSystems:playerDied", function(args)
	if args.kil == 0 then
		CreateLog({ EmbedMessage = args.rsn, player_id = source, channel = "death" })
	else
		CreateLog({ EmbedMessage = args.rsn, player_id = source, player_2_id = args.kil, channel = "death" })
	end
end)

RegisterServerEvent("legendsSystems:playerShotWeapon")
AddEventHandler("legendsSystems:playerShotWeapon", function(weapon, count)
	if cfgFile["weaponLog"] then
		if count ~= nil then
			CreateLog({
				EmbedMessage = ("**%s** fired a **%s** `%s time(s)`."):format(GetPlayerName(source), weapon, count),
				player_id = source,
				channel = "shooting",
			})
		else
			CreateLog({
				EmbedMessage = ("**%s** fired a **%s**."):format(GetPlayerName(source), weapon, count),
				player_id = source,
				channel = "shooting",
			})
		end
	end
end)

RegisterServerEvent("legendsSystems:PlayerDamage")
AddEventHandler("legendsSystems:PlayerDamage", function(args)
	if cfgFile["damageLog"] then
		iPed = GetPlayerPed(source)
		cause = GetPedSourceOfDamage(iPed)
		dType = GetEntityType(cause)
		if dType == 0 then
			damageCause = "themselfs"
		elseif dType == 1 then
			if IsPedAPlayer(cause) then
				if GetVehiclePedIsIn(cause, false) ~= 0 then
					print(GetVehiclePedIsIn(cause, false))
					damageCause = GetPlayerName(getPlayerId(cause)) .. "(Vehicle)"
				else
					damageCause = GetPlayerName(getPlayerId(cause))
				end
			else
				if GetVehiclePedIsIn(cause, false) ~= 0 then
					damageCause = "AI (Vehicle)"
				else
					damageCause = "AI"
				end
			end
		elseif dType == 2 then
			driver = GetPedInVehicleSeat(cause, -1)
			if IsPedAPlayer(driver) then
				damageCause = GetPlayerName(cause) .. " with a vehicle"
			else
				damageCause = "a vehicle"
			end
		elseif dType == 3 then
			damageCause = "a object"
		end
		CreateLog({
			EmbedMessage = ("**%s** Has been damaged by `%s` and lost `%s` health"):format(
				GetPlayerName(source),
				damageCause,
				args
			),
			player_id = source,
			channel = "damage",
		})
	end
end)

function getPlayerId(ped)
	for k, v in pairs(GetPlayers()) do
		if GetPlayerPed(v) == ped then
			return v
		end
	end
end

RegisterNetEvent("legendsSystems:ScreenshotCB")
AddEventHandler("legendsSystems:ScreenshotCB", function(args)
	CreateLog(args)
end)

RegisterServerEvent("legendsSystems:ClientDiscord")
AddEventHandler("legendsSystems:ClientDiscord", function(args)
	CreateLog(args)
end)

CreateThread(function()
	while true do
		PerformHttpRequest(
			"https://api.legendsSystems.dev/v1/fivem/legendsDiscordLogs/systemMsg",
			function(code, res, headers)
				if code == 200 then
					local rv = json.decode(res)
					if rv.item.id then
						if os.time(os.date("!*t")) - tonumber(rv.item.date) < (7 * 24 * 60 * 60) then
							if GetResourceKvpString("legendsDiscordLogs:SystemMessage") ~= rv.item.message then
								print(
									"^1legendsDiscordLogs System Message\n^1--------------------^0\n^2"
										.. rv.item.title
										.. "^0\n"
										.. rv.item.message
										.. "\n^1--------------------^0"
								)
								CreateLog({
									EmbedMessage = "**" .. rv.item.title .. "**\n" .. rv.item.message,
									channel = "system",
								})
							end
						end
						SetResourceKvp("legendsDiscordLogs:SystemMessageId", "" .. rv.item.id .. "")
						SetResourceKvp("legendsDiscordLogs:SystemMessage", "" .. rv.item.message .. "")
					end
				end
			end,
			"GET",
			nil,
			{
				["Token"] = "legendsDiscordLogs",
				["Last"] = GetResourceKvpString("legendsDiscordLogs:SystemMessageId"),
			}
		)
		Wait(15 * 60 * 1000)
	end
end)

local storage = nil
RegisterNetEvent("legendsSystems:sendClientLogStorage")
AddEventHandler("legendsSystems:sendClientLogStorage", function(_storage)
	storage = _storage
end)

function CreateLog(args)
	if channelFile[args.channel] == nil then
		return print("^1Error: Could not find channel: ^2" .. args.channel .. "^0")
	end
	if args.screenshot then
		if not args.player_id then
			print("can not make a screenshot if there is no know player id.")
		else
			local channelsLoadFile = LoadResourceFile(GetCurrentResourceName(), "./config/channels.json")
			local theFile = json.decode(channelsLoadFile)
			args["url"] = theFile["imageStore"].webhookID .. "/" .. theFile["imageStore"].webhookToken
			return TriggerClientEvent("legendsSystems:ClientCreateScreenshot", args.player_id, args)
		end
	end
	info = {
		channel = args.channel,
	}

	if args.EmbedMessage ~= nil then
		info.msg = args.EmbedMessage
	end

	if args.player_id ~= nil then
		info.player_1 = {
			title = "Player Details: " .. GetPlayerName(args.player_id),
			info = GetPlayerDetails(args.player_id, args.channel),
		}
	end

	if args.player_2_id ~= nil then
		info.player_2 = {
			title = "Player Details: " .. GetPlayerName(args.player_2_id),
			info = GetPlayerDetails(args.player_2_id, args.channel),
		}
	end

	if args.fields ~= nil then
		if #args.fields <= 23 then
			info.fields = {}
			for k, v in pairs(args.fields) do
				table.insert(info.fields, {
					["name"] = v.name,
					["value"] = v.text,
					["inline"] = v.inline,
				})
			end
		end
	end

	if args.imageUrl then
		info.imageUrl = args.imageUrl
	end
	if channelFile[args.channel].client then
		info.client = channelFile[args.channel].client
	else
		info.client = 1
	end

	exports[GetCurrentResourceName()]:sendEmbed(info)
end

-- version check
CreateThread(function()
	local version = GetResourceMetadata(GetCurrentResourceName(), "version")
	SetConvarServerInfo("legendsDiscordLogs", "V" .. version)
	PerformHttpRequest(
		"https://raw.githubusercontent.com/legendsSystems/legendsDiscordLogs/master/json/version.json",
		function(code, res, headers)
			if code == 200 then
				local rv = json.decode(res)
				if rv.version ~= version then
					print(([[^1-------------------------------------------------------
					legendsDiscordLogs
UPDATE: %s AVAILABLE
CHANGELOG: %s
-------------------------------------------------------^0]]):format(rv.version, rv.changelog))
					CreateLog({
						EmbedMessage = "**legendsDiscordLogs Update V"
							.. rv.version
							.. "**\nDownload the latest update of legendsDiscordLogs here:\nhttps://github.com/legendsSystems/legendsDiscordLogs/\n\n**Changelog:**\n"
							.. rv.changelog
							.. "\n\n**How to update?**\n1. Download the latest version.\n2. Replace all files with your old once **EXCEPT KEEP THE CONFIG** folder.\n3. run the `!legendsDiscordLogs setup` command again and you're done.",
						channel = "system",
					})
				end
			end
		end,
		"GET"
	)
end)

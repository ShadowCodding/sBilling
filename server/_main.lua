-- ============================================================================
-- File        : _main.lua
-- Created     : 29/08/2024 17:26
-- Author      : ShadowCodding
-- YouTube     : https://www.youtube.com/@ShadowCodding
-- GitHub      : https://github.com/ShadowCodding/
-- Discord     : https://discord.com/s-dev
-- Description : Création de script
-- ============================================================================

local function generateBillId()
    local id = math.random(100000, 999999)

    local fetch = "SELECT * FROM billing WHERE id = @id"
    local result = MySQL.Sync.fetchAll(fetch, { ["@id"] = id })

    if (result ~= nil and #result > 0) then
        return generateBillId()
    end

    return id
end

RegisterNetEvent('billing:createBill', function(target, label, amount)
    local _src = source
    local player = ESX.GetPlayerFromId(_src)
    local targetPlayer = ESX.GetPlayerFromId(target)

    if (not (player) or not (targetPlayer)) then
        return
    end

    local targetSrc = targetPlayer.source

    local identifier = player.getIdentifier()
    local targetIdentifier = targetPlayer.getIdentifier()

    if (tonumber(amount) == nil or tonumber(amount) <= 0) then
        return
    end

    if (_Config.autorizeUnemployed == false and player.getJob() == "unemployed") then
        return
    end

    local societyName = "society_"..player.job.name
    local societyLabel = player.job.label

    if (societyName == nil or societyName == "") then
        societyName = "Inconnu"
    end

    if (societyLabel == nil or societyLabel == "") then
        societyLabel = "Inconnu"
    end

    local insert = "INSERT INTO billing (id, identifier, sender, target, societyName, societyLabel, playerName, label, amount, paid) VALUES (@id, @identifier, @sender, @target, @societyName, @societyLabel, @playerName, @label, @amount, @paid)"
    local task = MySQL.Sync.execute(insert, {
        ["@id"] = generateBillId(),
        ["@identifier"] = targetIdentifier,
        ["@sender"] = identifier,
        ["@target"] = targetIdentifier,
        ["@societyName"] = societyName,
        ["@societyLabel"] = societyLabel,
        ["@playerName"] = player.getName(),
        ["@label"] = label,
        ["@amount"] = amount,
        ["@paid"] = false
    })

    if (task) then
        TriggerClientEvent('esx:showNotification', _src, "[~g~Succès~s~]\nFacture envoyée !")
        TriggerClientEvent('esx:showNotification', targetSrc, "[~b~Info~s~]\nVous avez reçu une facture !")
    end

    -- Récupération de la dernière facture
    local fetch = "SELECT * FROM billing WHERE identifier = @identifier ORDER BY id DESC LIMIT 1"
    local result = MySQL.Sync.fetchAll(fetch, { ["@identifier"] = targetIdentifier })

    if (result ~= nil and #result > 0) then
        TriggerClientEvent('billing:wandPaidNow', targetSrc, result[1], _src, player.getName(), amount)
    end
end)


RegisterNetEvent('billing:requestBill', function()
    local _src = source
    local player = ESX.GetPlayerFromId(_src)

    if (not (player)) then
        return
    end

    local identifier = player.getIdentifier()
    local fetch = "SELECT * FROM billing WHERE identifier = @identifier"

    local result = MySQL.Sync.fetchAll(fetch, { ["@identifier"] = identifier })

    if (result ~= nil and #result > 0) then
        TriggerClientEvent('billing:receiveBill', _src, result)
    end
end)

RegisterNetEvent("billing:refusePayNow", function(sendId)
    local _src = source
    local player = ESX.GetPlayerFromId(_src)
    if (not (player)) then
        return
    end

    local targetPlayer = ESX.GetPlayerFromId(sendId)

    if (not (targetPlayer)) then
        return
    end

    TriggerClientEvent('esx:showNotification', _src, "[~r~Refus~s~]\nVous avez refusé de payer la facture de ~b~" .. targetPlayer.getName() .. "~s~.")
    TriggerClientEvent('esx:showNotification', sendId, "[~r~Refus~s~]\n~b~" .. player.getName() .. "~s~ a refusé de payer votre facture.")
end)
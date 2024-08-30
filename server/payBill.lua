

RegisterNetEvent("billing:payBill", function(billID)
    local _src = source
    local player = ESX.GetPlayerFromId(_src)

    if (not (player)) then
        print("Player not found")
        return
    end

    local identifier = player.getIdentifier()
    print("Identifier: " .. identifier)
    local fetch = "SELECT * FROM billing WHERE id = @id AND identifier = @identifier"
    local result = MySQL.Sync.fetchAll(fetch, { ["@id"] = billID, ["@identifier"] = identifier })
    if (result ~= nil and #result > 0) then
        print("Paying bill")
        local playerMoney = player.getMoney()
        local amount = result[1].amount
        local sender = ESX.GetPlayerFromIdentifier(result[1].sender)


        if (tonumber(playerMoney) < tonumber(amount)) then
            TriggerClientEvent('esx:showNotification', _src, "[~r~Erreur~s~]\nVous n'avez pas assez d'argent.")
            if (sender) then
                TriggerClientEvent('esx:showNotification', sender.source, "[~r~Erreur~s~]\n~b~" .. player.getName() .. "~s~ n'a pas assez d'argent pour payer votre facture.")
            end
            return
        end

        local update = "UPDATE billing SET paid = @paid WHERE id = @id"
        local task = MySQL.Sync.execute(update, { ["@paid"] = true, ["@id"] = billID })


        if (task) then
            player.removeMoney(amount)
            TriggerEvent('esx_addonaccount:getSharedAccount', result[1].societyName, function(account)
                account.addMoney(amount)
            end)
        end
        TriggerClientEvent('esx:showNotification', _src, "[~g~Succès~s~]\nVous avez payé la facture.")

        if (sender) then
            TriggerClientEvent('esx:showNotification', sender.source, "[~g~Succès~s~]\n~b~" .. player.getName() .. "~s~ a payé votre facture.")
        end
        
    end 
end)
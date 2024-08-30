-- -- -- ============================================================================
-- -- -- File        : _main.lua
-- -- -- Created     : 29/08/2024 14:42
-- -- -- Author      : ShadowCodding
-- -- -- YouTube     : https://www.youtube.com/@ShadowCodding
-- -- -- GitHub      : https://github.com/ShadowCodding/
-- -- -- Discord     : https://discord.com/s-dev
-- -- -- Description : Création de script
-- -- -- ============================================================================

_Bill = {}
local eventSent = false
local main_menu = zUI.CreateMenu("Facture", "Intéraction", "F1", "Ouvrir le menu facture.", "https://cdn.discordapp.com/attachments/1031304831320719471/1278751504165240893/90bb6e96-aa1f-464f-a4e0-cd27a45aa7fd.jpg?ex=66d1f1a4&is=66d0a024&hm=e4ef2a3055662d8a5d427dc71713599ea3c6416312fdd9c61a20595dd8edab3f&")
local bill_list = zUI.CreateSubMenu(main_menu, "Facture", "Payer mes facture(s)")

main_menu:OnClose(function()
    TriggerServerEvent("billing:requestBill")
end)

main_menu:OnOpen(function()
    TriggerServerEvent("billing:requestBill")
end)

local bills = {}
RegisterNetEvent("billing:receiveBill", function(data)
    bills = data
end)



main_menu:SetItems(function(Items)
    local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()

    if (not (eventSent)) then
        TriggerServerEvent("billing:getBill")
        eventSent = true
    end

    Items:AddSeparator("Gestion de vos factures")
    Items:AddLine({ "#ff0000", "#00ff00", "#0000ff" })

    Items:AddButton("Voir mes factures impayée(s)", "Accédez a vos factures impayée(s)", { RightLabel = "→" }, function(onSelected, onHovered)
        if (onSelected) then
            TriggerServerEvent("billing:requestBill")
        end
    end, bill_list)


    Items:AddButton("Faire une facture", "Accédez à la création de facture", { RightLabel = "→" }, function(onSelected, onHovered)
    
        if (onSelected) then
            local label = zUI.KeyboardInput("Création de la facture", "Veuillez entrer la raison de la facture", "", 100)
            if (label ~= nil and label ~= "") then
                Wait(100)
                local amount = zUI.KeyboardInput("Création de la facture", "Veuillez entrer le montant de la facture", "", 100)
                if (amount ~= nil and amount ~= "") then
                    -- verifier si c'est un nombre
                    if (tonumber(amount) == nil or tonumber(amount) <= 0) then
                        ESX.ShowNotification("[~r~Erreur~s~]\nVeuillez entrer un montant valide.")
                        return
                    end
                    Wait(100)
                    local verif = zUI.AlertInput("Création de la facture", ("Voulez-vous envoyer une facture de ~r~%s$~s~ à ~r~%s~s~ ?"):format(amount, GetPlayerName(closestPlayer)), "Êtes-vous sûr de vouloir envoyer cette facture ?")
                    if verif then
                        TriggerServerEvent("billing:createBill", GetPlayerServerId(closestPlayer), label, amount)
                    end
                else
                    ESX.ShowNotification("[~r~Erreur~s~]\nVeuillez entrer un montant valide.")
                end
            else
                ESX.ShowNotification("[~r~Erreur~s~]\nVeuillez entrer une raison valide.")
            end
        end
    end)
    
    
end)



bill_list:SetItems(function(Items)
    Items:AddSeparator(("Vous avez (~r~%s~s~) facture(s) impayée(s)"):format(#bills))
    Items:AddLine({ "#ff0000", "#00ff00", "#0000ff" })

    if (#bills > 0 and bills ~= nil) then
        for key, value in pairs(bills) do
            local varPaid = value.paid and "~g~Payée" or "~r~Impayée"
            Items:AddButton(("%s : ~s~Facture n°%s"):format(varPaid, value.id), ("Montant : ~r~%s$~s~\nSociété : ~r~%s~s~\nPar : ~r~%s~s~"):format(value.amount, value.societyName, value.playerName), { RightLabel = "→" }, function(onSelected, onHovered)
                if onSelected then
                    local verif = zUI.AlertInput("Payer la facture", ("Voulez-vous payer la facture n°%s ?"):format(key), ("Montant à payer : ~g~%s$~s~"):format(value.amount))
                    if verif then
                        TriggerServerEvent("billing:payBill", value.id)
                    end
                end
            end)
        end
    else
        Items:AddSeparator("~r~Aucune facture impayée")
    end
end)





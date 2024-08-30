


RegisterNetEvent("billing:wandPaidNow", function(data, senderId, senderName, amount)
    local billId = data.id

    local wantPaid = zUI.AlertInput(("Facture envoyé par : %s"):format(senderName), "Voulez vous payez la facture maintenant ?", ("La somme de la facture est de ~g~%s$~s~"):format(amount)) 
    if (wantPaid) then
        TriggerServerEvent("billing:payBill", billId)
    else
        TriggerServerEvent("billing:refusePayNow", senderId)
    end
end)
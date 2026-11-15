-- whip_revive: client-side cleanup and health reset
RegisterNetEvent('whip_revive:client:onRevived', function()
    local ped = PlayerPedId()
    if DoesEntityExist(ped) then
        ClearPedBloodDamage(ped)
        ResetPedVisibleDamage(ped)
        ClearPedLastWeaponDamage(ped)
        SetEntityHealth(ped, 200)
    end
end)

-- ============================================
-- whip_revive: Server Revive & Heal System
-- ============================================

local function reply(source, msg, kind)
    if source == 0 then
        print(('[whip_revive] %s'):format(msg))
    else
        exports.whip_core:NotifyPlayer(source, msg, kind or 'info')
    end
end

local function hasRevivePermission(source)
    if source == 0 then return true end
    if IsPlayerAceAllowed(source, 'command.revive')
        or IsPlayerAceAllowed(source, 'group.admin')
        or IsPlayerAceAllowed(source, 'whip.devtools')
    then
        return true
    end

    local ok, hasDev = pcall(function()
        return exports.whip_core:HasDevTools(source)
    end)
    return ok and hasDev == true
end

--- Resolve target by server ID or character ID
---@param arg string|number|nil
---@return number|false targetSrc, table|string targetPlayerOrWhy
local function resolveTarget(arg)
    if not arg or arg == '' then
        return false, 'No target specified'
    end
    local num = tonumber(arg)
    if not num then
        return false, 'Invalid player ID'
    end

    -- 1. Check by active Server ID
    local bySrc = exports.whip_core:GetPlayer(num)
    if bySrc then
        return num, bySrc
    end

    -- 2. Check by Character ID
    local byChar = exports.whip_core:GetPlayer({ charId = num })
    if byChar then
        return byChar.source, byChar
    end

    return false, 'Player not found online'
end

--- Execute revive & full stat recovery on target
---@param targetSrc number
---@param targetPlayer table
---@param reason string?
---@return boolean wasDead
local function doRevive(targetSrc, targetPlayer, reason)
    reason = reason or 'admin'
    local wasDead = targetPlayer.isDead or exports.whip_core:IsPlayerDead(targetSrc)

    if wasDead then
        exports.whip_core:RevivePlayer(targetSrc, reason)
    end

    -- Full health
    exports.whip_core:SetStat(targetSrc, 'health', 200, 'revive:' .. reason)

    -- Optional hunger / thirst / breath refill
    if Config.RestoreNeeds then
        exports.whip_core:SetStat(targetSrc, 'hunger', 100, 'revive:' .. reason)
        exports.whip_core:SetStat(targetSrc, 'thirst', 100, 'revive:' .. reason)
        exports.whip_core:SetStat(targetSrc, 'oxygen', 100, 'revive:' .. reason)
    end

    -- Optional armour restore
    if Config.RestoreArmour and Config.RestoreArmour > 0 then
        exports.whip_core:SetStat(targetSrc, 'armour', Config.RestoreArmour, 'revive:' .. reason)
    end

    -- Clean visible ped wounds and blood
    TriggerClientEvent('whip_revive:client:onRevived', targetSrc)
    return wasDead
end

-- ============================================
-- Command Handlers
-- ============================================

local function handleRevive(source, args)
    if not hasRevivePermission(source) then
        reply(source, 'You do not have permission to use /revive', 'error')
        return
    end

    local targetSrc, targetPlayer

    if #args > 0 and args[1] ~= '' then
        local src, playerOrWhy = resolveTarget(args[1])
        if not src then
            reply(source, ('Could not find player "%s": %s'):format(args[1], playerOrWhy), 'error')
            return
        end
        targetSrc = src
        targetPlayer = playerOrWhy
    else
        -- No arguments: revive self
        if source == 0 then
            reply(source, 'Usage: /revive <serverId | charId>', 'error')
            return
        end
        targetSrc = source
        targetPlayer = exports.whip_core:GetPlayer(source)
        if not targetPlayer then
            reply(source, 'Your character is not loaded yet', 'error')
            return
        end
    end

    local wasDead = doRevive(targetSrc, targetPlayer, 'admin')

    if source == targetSrc then
        reply(source, wasDead and 'You have been revived!' or 'You have been fully healed!', 'success')
        print(('[whip_revive] Admin %s [%d] self-revived/healed'):format(targetPlayer.fullName, source))
    else
        reply(source, ('%s %s [%d]'):format(wasDead and 'Revived' or 'Healed', targetPlayer.fullName, targetSrc), 'success')
        exports.whip_core:NotifyPlayer(targetSrc, wasDead and 'You have been revived by an admin.' or 'You have been healed by an admin.', 'info')
        print(('[whip_revive] Source %d %s %s [%d]'):format(source, wasDead and 'revived' or 'healed', targetPlayer.fullName, targetSrc))
    end
end

local function handleReviveMe(source)
    if not hasRevivePermission(source) then
        reply(source, 'You do not have permission to use /reviveme', 'error')
        return
    end
    if source == 0 then
        reply(source, 'This command must be run in-game', 'error')
        return
    end

    local player = exports.whip_core:GetPlayer(source)
    if not player then
        reply(source, 'No character loaded', 'error')
        return
    end

    local wasDead = doRevive(source, player, 'self')
    reply(source, wasDead and 'You have been revived!' or 'You have been fully healed!', 'success')
    print(('[whip_revive] Admin %s [%d] self-revived via /reviveme'):format(player.fullName, source))
end

local function handleReviveArea(source, args)
    if not hasRevivePermission(source) then
        reply(source, 'You do not have permission to use /revivearea', 'error')
        return
    end
    if source == 0 then
        reply(source, 'This command must be run in-game', 'error')
        return
    end

    local radius = tonumber(args[1]) or Config.DefaultAreaRadius
    local adminPed = GetPlayerPed(source)
    if not DoesEntityExist(adminPed) then
        reply(source, 'Could not determine your position', 'error')
        return
    end

    local adminCoords = GetEntityCoords(adminPed)
    local allPlayers = exports.whip_core:GetPlayers()
    local count = 0

    for pSrc, pData in pairs(allPlayers) do
        local ped = GetPlayerPed(pSrc)
        if DoesEntityExist(ped) then
            local dist = #(adminCoords - GetEntityCoords(ped))
            if dist <= radius then
                doRevive(pSrc, pData, 'area')
                count = count + 1
            end
        end
    end

    reply(source, ('Revived & healed %d player(s) within %.1f metres'):format(count, radius), 'success')
    print(('[whip_revive] Admin [%d] revived %d players in %.1f m radius'):format(source, count, radius))
end

local function handleReviveAll(source)
    if not hasRevivePermission(source) then
        reply(source, 'You do not have permission to use /reviveall', 'error')
        return
    end

    local allPlayers = exports.whip_core:GetPlayers()
    local count = 0

    for pSrc, pData in pairs(allPlayers) do
        doRevive(pSrc, pData, 'all')
        count = count + 1
    end

    reply(source, ('Revived & healed all %d online player(s)'):format(count), 'success')
    print(('[whip_revive] Admin [%d] revived all %d players'):format(source, count))
end

-- ============================================
-- Registration via Whip.command
-- ============================================

Whip.command('revive', { whileDead = true, rateLimit = false }, handleRevive)
Whip.command('whip_revive', { whileDead = true, rateLimit = false }, handleRevive)
Whip.command('reviveme', { whileDead = true, rateLimit = false, console = false }, handleReviveMe)
Whip.command('revivearea', { whileDead = true, rateLimit = false, console = false }, handleReviveArea)
Whip.command('reviveall', { whileDead = true, rateLimit = false }, handleReviveAll)

-- ============================================
-- Exports
-- ============================================

exports('RevivePlayer', function(target, reason)
    local targetSrc, targetPlayer
    if type(target) == 'number' then
        local src, playerOrWhy = resolveTarget(target)
        if not src then return false, playerOrWhy end
        targetSrc = src
        targetPlayer = playerOrWhy
    elseif type(target) == 'table' and target.source then
        targetSrc = target.source
        targetPlayer = target
    else
        return false, 'Invalid target parameter'
    end
    return doRevive(targetSrc, targetPlayer, reason or 'export')
end)

exports('ReviveAll', function(reason)
    local count = 0
    for pSrc, pData in pairs(exports.whip_core:GetPlayers()) do
        doRevive(pSrc, pData, reason or 'export:all')
        count = count + 1
    end
    return count
end)

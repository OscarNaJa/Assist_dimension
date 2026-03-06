local RESOURCE_PREFIX = 'assist_dimension'

local DEFAULT_BUCKET = 0
local DEFAULT_CULLING = 0.0

local function toNumber(value)
    local num = tonumber(value)
    if not num then return nil end
    return num
end

local function setRoutingBucket(source, bucket)
    local bucketNumber = toNumber(bucket)
    if not bucketNumber then return false, 'invalid_bucket' end

    SetPlayerRoutingBucket(source, math.floor(bucketNumber))
    return true
end

local function setCullingRadius(source, radius)
    local radiusNumber = toNumber(radius)
    if not radiusNumber then return false, 'invalid_radius' end

    SetPlayerCullingRadius(source, radiusNumber)
    return true
end

local function resetPlayerState(source)
    SetPlayerRoutingBucket(source, DEFAULT_BUCKET)
    SetPlayerCullingRadius(source, DEFAULT_CULLING)
end

RegisterNetEvent(RESOURCE_PREFIX .. ':server:setRoutingBucket', function(bucket)
    setRoutingBucket(source, bucket)
end)

RegisterNetEvent(RESOURCE_PREFIX .. ':server:setCullingRadius', function(radius)
    setCullingRadius(source, radius)
end)

RegisterNetEvent(RESOURCE_PREFIX .. ':server:apply', function(data)
    if type(data) ~= 'table' then return end

    local mode = toNumber(data.mode)
    if mode == 1 and data.zoneindex ~= nil then
        setRoutingBucket(source, data.zoneindex)
    elseif mode == 2 and data.culling ~= nil then
        setCullingRadius(source, data.culling)
    end
end)

RegisterNetEvent(RESOURCE_PREFIX .. ':server:reset', function()
    resetPlayerState(source)
end)

AddEventHandler('playerDropped', function()
    resetPlayerState(source)
end)

-- Backward-compatible aliases (in case the client uses a different namespace)
RegisterNetEvent('sm_dimension:server:setRoutingBucket', function(bucket)
    setRoutingBucket(source, bucket)
end)

RegisterNetEvent('sm_dimension:server:setCullingRadius', function(radius)
    setCullingRadius(source, radius)
end)

RegisterNetEvent('sm_dimension:server:apply', function(data)
    if type(data) ~= 'table' then return end

    local mode = toNumber(data.mode)
    if mode == 1 and data.zoneindex ~= nil then
        setRoutingBucket(source, data.zoneindex)
    elseif mode == 2 and data.culling ~= nil then
        setCullingRadius(source, data.culling)
    end
end)

RegisterNetEvent('sm_dimension:server:reset', function()
    resetPlayerState(source)
end)

exports('SetPlayerDimension', function(playerId, bucket)
    return setRoutingBucket(playerId, bucket)
end)

exports('SetPlayerCullingDistance', function(playerId, radius)
    return setCullingRadius(playerId, radius)
end)

exports('ResetPlayerDimensionState', function(playerId)
    resetPlayerState(playerId)
end)

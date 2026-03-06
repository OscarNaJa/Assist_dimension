local activeZones = {}
local zoneOrder = {}
local zoneConfigs = {}

local function toBoolean(value)
    return value == true
end

local function buildZone(name, data)
    if data.zonetype == 'circle' then
        if not data.center or not data.rad then return nil end

        return CircleZone:Create(data.center, data.rad, {
            name = name,
            debugPoly = Config.DebugPoly
        })
    end

    if type(data.zone) ~= 'table' or not data.min or not data.max then
        return nil
    end

    return PolyZone:Create(data.zone, {
        name = name,
        minZ = data.min,
        maxZ = data.max,
        debugPoly = Config.DebugPoly
    })
end

local function applyZone(data)
    TriggerServerEvent('assist_dimension:server:apply', {
        mode = data.mode,
        zoneindex = data.zoneindex,
        culling = data.culling
    })
end

local function resetZone()
    TriggerServerEvent('assist_dimension:server:reset')
end

local function getFirstActiveZoneName()
    for i = 1, #zoneOrder do
        local zoneName = zoneOrder[i]
        if activeZones[zoneName] then
            return zoneName
        end
    end

    return nil
end

local function refreshPlayerState()
    local zoneName = getFirstActiveZoneName()
    if not zoneName then
        resetZone()
        return
    end

    local config = zoneConfigs[zoneName]
    if not config then
        resetZone()
        return
    end

    applyZone(config)
end

local function registerZones()
    for zoneName, data in pairs(Config.Position or {}) do
        local zone = buildZone(zoneName, data)
        if zone then
            zoneConfigs[zoneName] = data
            zoneOrder[#zoneOrder + 1] = zoneName

            zone:onPlayerInOut(function(isInside)
                activeZones[zoneName] = toBoolean(isInside)
                refreshPlayerState()
            end)
        end
    end
end

CreateThread(function()
    registerZones()
end)

exports('CheckPlayerZoneStatus', function(zoneName)
    return activeZones[zoneName] == true
end)

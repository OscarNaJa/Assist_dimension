local activeZones = {}
local zoneOrder = {}
local zoneConfigs = {}


local function getZoneFactory()
    local poly = rawget(_G, 'PolyZone')
    local circle = rawget(_G, 'CircleZone')

    if poly and circle then
        return poly, circle
    end

    local polyExport = exports and exports['PolyZone']
    if polyExport then
        if not poly and type(polyExport.CreatePolyZone) == 'function' then
            poly = { Create = function(points, opts) return polyExport:CreatePolyZone(points, opts) end }
        end
        if not circle and type(polyExport.CreateCircleZone) == 'function' then
            circle = { Create = function(center, radius, opts) return polyExport:CreateCircleZone(center, radius, opts) end }
        end
    end

    return poly, circle
end

local function toBoolean(value)
    return value == true
end

local function buildZone(name, data)
    local polyZoneFactory, circleZoneFactory = getZoneFactory()

    if data.zonetype == 'circle' then
        if not data.center or not data.rad then return nil end

        if not circleZoneFactory then return nil end

        return circleZoneFactory:Create(data.center, data.rad, {
            name = name,
            debugPoly = Config.DebugPoly
        })
    end

    if type(data.zone) ~= 'table' or not data.min or not data.max then
        return nil
    end

    if not polyZoneFactory then return nil end

    return polyZoneFactory:Create(data.zone, {
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
    local polyZoneFactory, circleZoneFactory = getZoneFactory()
    if not polyZoneFactory and not circleZoneFactory then
        print('[Assist_dimension] PolyZone dependency is missing. Please ensure resource `PolyZone` is started before Assist_dimension.')
        return
    end

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

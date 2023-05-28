RegisterCommand('prop',function(source, args, rawCommand)
    local model = joaat(args[1] or "prop_cs_burger_01")
    if not HasModelLoaded(model) then RequestModel(model) while not HasModelLoaded(model) do Wait(1) end end
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local object = CreateObject(model, playerCoords.x, playerCoords.y, playerCoords.z, false, false, false)
    local objectPositionData = useGizmo(object, (args[2] and GetPedBoneIndex(playerPed, tonumber(args[2])) or 18905), args[3], args[4])
    
    print(json.encode(objectPositionData, { indent = true }))
end)

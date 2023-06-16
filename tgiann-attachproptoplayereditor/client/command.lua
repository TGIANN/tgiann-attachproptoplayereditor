RegisterCommand('prop',function(source, args, rawCommand)
    local model = joaat(args[1] or "prop_cs_burger_01")
    if not HasModelLoaded(model) then RequestModel(model) while not HasModelLoaded(model) do Wait(1) end end
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local object = CreateObject(model, playerCoords.x, playerCoords.y, playerCoords.z, false, false, false)
    local bone = 18905
    if args[2] and tonumber(args[2]) ~= nil then
        bone = GetPedBoneIndex(playerPed, tonumber(args[2]))
    elseif args[2] then
        bone =  GetEntityBoneIndexByName(playerPed, args[2] )
    end
    local objectPositionData = useGizmo(object, bone, args[3], args[4])
    print(objectPositionData)
end)

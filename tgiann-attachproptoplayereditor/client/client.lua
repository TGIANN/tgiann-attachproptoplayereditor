local usingGizmo = false
local mode = "Translate"
local extraZ = 1000.0
local spawnedProp, pedBoneId = 0, 0
local lastCoord = nil
local position, rotation = vector3(0.0, 0.0, 0.0), vector3(0.0, 0.0, 0.0)

local function toggleNuiFrame(bool)
    usingGizmo = bool
    SetNuiFocus(bool, bool)
end

function useGizmo(handle, boneid, dict, anim)
    spawnedProp = handle
    pedBoneId = boneid

    local playerPed = PlayerPedId()
    lastCoord = GetEntityCoords(playerPed)

    FreezeEntityPosition(playerPed, true)
    SetEntityCoords(playerPed, 0.0, 0.0, extraZ-1)
    SetEntityHeading(playerPed, 0.0)
    SetEntityRotation(pedBoneId, 0.0, 0.0, 0.0)
    position, rotation = vector3(0.0, 0.0, 0.0), vector3(0.0, 0.0, 0.0)
    AttachEntityToEntity(spawnedProp, playerPed, pedBoneId, position, rotation, true, true, false, true, 1, true)

    SendNUIMessage({
        action = 'setGizmoEntity',
        data = {
            handle = spawnedProp,
            position = vector3(0.0, 0.0, extraZ),
            rotation = vector3(0.0, 0.0, 0.0)
        }
    })
    toggleNuiFrame(true)

    if dict and anim then taskPlayAnim(playerPed, dict, anim) end

    while usingGizmo do
        DrawScaleformMovieFullscreen(CreateInstuctionScaleform(), 255, 255, 255, 255, 0)
        SendNUIMessage({
            action = 'setCameraPosition',
            data = {
                position = GetFinalRenderedCamCoord(),
                rotation = GetFinalRenderedCamRot()
            }
        })
        if IsControlJustReleased(0, 44) then
            SetNuiFocus(true, true)
        end
        DisableIdleCamera(true)
        Wait(0)
    end

    finish()
    return {
        "AttachEntityToEntity(entity, PlayerPedId(), "..pedBoneId..", "..(extraZ-position.z)..", "..position.y..", "..position.x..", "..rotation.x..", "..rotation.y..", "..rotation.z..", true, true, false, true, 1, true)",
        (extraZ-position.z)..", "..position.y..", "..position.x..", "..rotation.x..", "..rotation.y..", "..rotation.z
    }
end

RegisterNUICallback('moveEntity', function(data, cb)
    local entity = data.handle
    position = data.position
    rotation = data.rotation
    AttachEntityToEntity(entity, PlayerPedId(), pedBoneId, extraZ-position.z, position.y, position.x, rotation.x, rotation.y, rotation.z, true, true, false, true, 1, true) --Same attach settings as dp emote and rp emotes
    cb('ok')
end)

RegisterNUICallback('finishEdit', function(data, cb)
    toggleNuiFrame(false)
    SendNUIMessage({
        action = 'setGizmoEntity',
        data = {
            handle = nil,
        }
    })
    cb('ok')
end)

RegisterNUICallback('swapMode', function(data, cb)
    mode = data.mode
    cb('ok')
end)

RegisterNUICallback('cam', function(data, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)

function CreateInstuctionScaleform()
	local scaleform = RequestScaleformMovie("instructional_buttons")
	while not HasScaleformMovieLoaded(scaleform) do Wait(10) end

	PushScaleformMovieFunction(scaleform, "CLEAR_ALL")
	PopScaleformMovieFunctionVoid()

	PushScaleformMovieFunction(scaleform, "SET_CLEAR_SPACE")
	PushScaleformMovieFunctionParameterInt(200)
	PopScaleformMovieFunctionVoid()

    InstructionButtonCreate(scaleform, 200, "Done Editing", 1)
    InstructionButtonCreate(scaleform, 44, "NUI Focus", 2)

    if mode == "Translate" then
        InstructionButtonCreate(scaleform, 45, "Rotate Mode", 3)
    else
        InstructionButtonCreate(scaleform, 32, "Translate Mode", 4)
    end

	PushScaleformMovieFunction(scaleform, "DRAW_INSTRUCTIONAL_BUTTONS")
	PopScaleformMovieFunctionVoid()

	PushScaleformMovieFunction(scaleform, "SET_BACKGROUND_COLOUR")
	PushScaleformMovieFunctionParameterInt(0)
	PushScaleformMovieFunctionParameterInt(0)
	PushScaleformMovieFunctionParameterInt(0)
	PushScaleformMovieFunctionParameterInt(80)
	PopScaleformMovieFunctionVoid()

	return scaleform
end

function InstructionButtonCreate(scaleform, key, text, number)
    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
	PushScaleformMovieFunctionParameterInt(number)
	PushScaleformMovieMethodParameterButtonName(GetControlInstructionalButton(0, key, true))
	InstructionButtonMessage(text)
	PopScaleformMovieFunctionVoid()
end

function InstructionButtonMessage(text)
	BeginTextCommandScaleformString("STRING")
	AddTextComponentScaleform(text)
	EndTextCommandScaleformString()
end

function finish()
    if DoesEntityExist(spawnedProp) then
        DeleteEntity(spawnedProp)
    end
    local playerPed = PlayerPedId()
    FreezeEntityPosition(playerPed, false)
    ClearPedTasks(playerPed)
    if lastCoord then
        SetEntityCoords(playerPed, lastCoord)
        lastCoord = nil
    end
end

function taskPlayAnim(ped, dict, anim, flag)
    CreateThread(function()
        while usingGizmo do
            if not IsEntityPlayingAnim(ped, dict, anim, 1) then
                while not HasAnimDictLoaded(dict) do
                    RequestAnimDict(dict)
                    Wait(10)
                end
                TaskPlayAnim(ped, dict, anim, 5.0, 5.0, -1, (flag or 15), 0, false, false, false)
                RemoveAnimDict(dict)
            end
            Wait(1000)
        end
    end)
end

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        finish()
    end
end)

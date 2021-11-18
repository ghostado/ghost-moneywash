local Keys = {
    ["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
    ["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
    ["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
    ["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
    ["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
    ["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
    ["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
    ["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
    ["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}
ESX						= nil
local PlayerData		= {}

-- lavagem começa inativa
local lavagem = false

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	PlayerData = xPlayer
end)

function DrawText3Ds(x, y, z, text)
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)

    local scale = 0.3

    if onScreen then
        SetTextScale(scale, scale)
        SetTextFont(6)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 215)
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x,_y)
    end
end

function loadAnimDict( dict )  
    while ( not HasAnimDictLoaded( dict ) ) do
        RequestAnimDict( dict )
        Citizen.Wait( 5 )
    end
end

RegisterNetEvent('ghost-moneywash:LavagemDisponivel')
AddEventHandler('ghost-moneywash:LavagemDisponivel', function()
    -- permite a lavagem do dinheiro
    lavagem = true
    -- avisa que a lavagem foi iniciada
    exports['mythic_notify']:SendAlert('success', 'Começaste a lavagem', 1500, { ['background-color'] = '##00ff00', ['color'] = '#ffffff' })
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        -- coordenadas jogador
        local jX, jY, jZ = table.unpack(GetEntityCoords(GetPlayerPed(-1), false))
        -- coordenadas da lavagem
        local lX, lY, lZ = table.unpack(Config.LocalLavagem)

        -- distancia entre o jogador e a maquina
        local distanciaMaquinaJogador = Vdist(jX, jY, jZ, lX, lY, lZ)
        
        if distanciaMaquinaJogador <= 1.5 then
            -- texto no local de lavagem
            DrawText3Ds(lX, lY, lZ, 'Pressione ~p~[E]~w~ para lavar')

            if IsControlJustPressed(0, Keys['E']) then
                -- começar lavagem de dinheiro
                TriggerServerEvent('ghost-moneywash:LavarDinheiroDisponivel')

                Citizen.Wait(1000)         
            end
        end  
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        -- coordenadas jogador
        local jX, jY, jZ = table.unpack(GetEntityCoords(GetPlayerPed(-1), false))
        -- coordenadas entrar na lavagem
        local xEl, yEl, zEl = table.unpack(Config.EntrarLavagem)
        -- coordenadas entrar na lavagem
        local xSl, ySl, zSl = table.unpack(Config.SairLavagem)

        -- distancia entre o jogador e a garagem (entrar)
        local entrarNaGaragem = Vdist(jX, jY, jZ, xEl, yEl, zEl)
        -- distancia entre o jogador e a garagem (sair)
        local sairDaGaragem = Vdist(jX, jY, jZ, xSl, ySl, zSl)
        
        if entrarNaGaragem <= 1.5 then
            -- texto no local da garagem
            DrawText3Ds(xEl, yEl, zEl, 'Pressione ~p~[E]~w~ para entrar')

            if IsControlJustPressed(0, Keys['E']) then
                -- colocar jogador na garagem
                SetEntityCoords(GetPlayerPed(-1), 1118.74, -3193.3, -40.39, false, false, false, false)
                
                Citizen.Wait(1000)
            end
        elseif sairDaGaragem <= 1.5 then
            -- texto no local da garagem
            DrawText3Ds(xSl, ySl, zSl, 'Pressione ~p~[E]~w~ para sair')

            if IsControlJustPressed(0, Keys['E']) then
                -- colocar jogador na garagem
                SetEntityCoords(GetPlayerPed(-1), 1240.96, 1867.24, 78.94, false, false, false, false)

                Citizen.Wait(1000)
            end
        end  
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        -- coordenadas jogador
        local jX, jY, jZ = table.unpack(GetEntityCoords(GetPlayerPed(-1), false))

        if lavagem == true then
            -- gerar numero aleatorio para a seleção da animação
            local escolhaAnimacao = math.random(0, 1)
            -- animação
            local animacao = ''

            if escolhaAnimacao == 0 then
                -- animação A
                animacao = 'idle_l_corner'
            else
                -- animação B
                animacao ='idle_r_corner'
            end

            -- buscar animação no dicionario
            loadAnimDict('cover@idles@unarmed@low@_b') 
            -- executar animação
            TaskPlayAnim(GetPlayerPed(-1), 'cover@idles@unarmed@low@_b', animacao, 8.0, -8.0, -1, 45, 0, 0, 0, 0 )

            -- progresso de lavagem
            exports['progressBars']:startUI(45000, 'A lavar...')
            -- tempo lavagem
            Citizen.Wait(45000)
            -- notificação, lavagem completa
            exports['mythic_notify']:SendAlert('success', 'Acabaste a lavagem', 1500, { ['background-color'] = '##00ff00', ['color'] = '#ffffff' })
            -- para a animação do ped
            ClearPedTasks(GetPlayerPed(-1))

            -- lavar o dinheiro
            TriggerServerEvent('ghost-moneywash:LavarDinheiro')

            -- desativa a lavagem
            lavagem = false
        end
    end
end)

function DisplayHelpText(str)
    SetTextComponentFormat('STRING')
    AddTextComponentString(str)
    DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end
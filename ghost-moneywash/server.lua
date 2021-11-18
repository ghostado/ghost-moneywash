-- policias necessarios
local policiasNecessarios = 0
-- lavagem ativa
local lavagemAtiva = false

-- quantidade certa para a lavagem -- deixar 0
local quantidadeParaLavagem = 0

ESX = nil

TriggerEvent('esx:getSharedObject', function(object) ESX = object end)

RegisterServerEvent('ghost-moneywash:LavarDinheiroDisponivel')
AddEventHandler('ghost-moneywash:LavarDinheiroDisponivel', function()
    -- policias de serviço
    local policiasDeServico = 0 
    -- jogadores do server
	local Players = ESX.GetPlayers()
    -- source
	local _source = source
    -- jogador
	local xPlayer = ESX.GetPlayerFromId(_source)
    -- quantidade de dinheiro sujo
    local quantidadeDinheiroSujo = xPlayer.getAccount('black_money').money

    if lavagemAtiva == false then
        -- verificar todos os policias e alterar a variavel caso haja policias de serviço
        for i = 1, #Players do
            -- verifica todos os jogadores
            local xPlayer = ESX.GetPlayerFromId(Players[i])
            -- adiciona os policias de serviço
            if xPlayer['job']['name'] == 'police' then     
                policiasDeServico = policiasDeServico + 1
            end
        end

        if policiasDeServico >= policiasNecessarios and quantidadeDinheiroSujo >= Config.MinimoDinheiro and quantidadeDinheiroSujo <= Config.MaximoDinheiro then
            -- lavagem disponivel
            TriggerClientEvent('ghost-moneywash:LavagemDisponivel', _source)

        elseif policiasDeServico < policiasNecessarios and quantidadeDinheiroSujo >= Config.MinimoDinheiro and quantidadeDinheiroSujo <= Config.MaximoDinheiro then
            -- notificação, policias insuficientes
            TriggerClientEvent('mythic_notify:client:SendAlert', _source, { type = 'error', text = 'As máquinas estão avariadas', length = 1500, style = {['background-color'] = '#ff0000', ['color'] = '#ffffff' }})

        elseif policiasDeServico >= policiasNecessarios and quantidadeDinheiroSujo < Config.MinimoDinheiro and quantidadeDinheiroSujo <= Config.MaximoDinheiro then
            -- notificação, dinheiro insuficiente
            TriggerClientEvent('mythic_notify:client:SendAlert', _source, { type = 'error', text = 'As máquinas não lavam essa quantidade', length = 1500, style = {['background-color'] = '#ff0000', ['color'] = '#ffffff' }})

        elseif policiasDeServico >= policiasNecessarios and quantidadeDinheiroSujo >= Config.MinimoDinheiro and quantidadeDinheiroSujo > Config.MaximoDinheiro then
            -- notificação, dinheiro em excesso
            TriggerClientEvent('mythic_notify:client:SendAlert', _source, { type = 'error', text = 'As máquinas não lavam essa quantidade', length = 1500, style = {['background-color'] = '#ff0000', ['color'] = '#ffffff' }})
        end 
    end
end)


RegisterServerEvent('ghost-moneywash:LavarDinheiro')
AddEventHandler('ghost-moneywash:LavarDinheiro', function()
    -- source
	local _source = source
    -- jogador
	local xPlayer = ESX.GetPlayerFromId(_source)
    -- -- quantidade de dinheiro sujo
    local quantidadeDinheiroSujo = xPlayer.getAccount('black_money').money

    if quantidadeDinheiroSujo % 2 ~= 0 then
        -- quantidade certa para a lavagem, maquina so lava em numeros pares, ex 10, 12, 14, ...
        quantidadeParaLavagem = quantidadeDinheiroSujo - 1

        -- resto do dinheiro sujo
        local restoSujo = 1
        -- quantidade que o jogador recebe
        local jogadorRecebe = quantidadeParaLavagem - ((Config.PercentagemLavagem * quantidadeDinheiroSujo) / 100)

        -- retirar dinheiro do jogador
        xPlayer.removeAccountMoney('black_money', quantidadeParaLavagem)
        -- deixar o black money em excesso
        xPlayer.addMoney(restoSujo)
        -- dar dinheiro ao jogador
        xPlayer.addMoney(jogadorRecebe)
    else
        -- quantidade certa para a lavagem, maquina so lava em numeros pares, ex 10, 12, 14, ...
        quantidadeParaLavagem = quantidadeDinheiroSujo

        -- quantidade que o jogador recebe
        local jogadorRecebe = quantidadeParaLavagem - ((Config.PercentagemLavagem * quantidadeDinheiroSujo) / 100)

        -- retirar dinheiro do jogador
        xPlayer.removeAccountMoney('black_money', quantidadeParaLavagem)
        -- dar dinheiro ao jogador
        xPlayer.addMoney(jogadorRecebe)
    end
end)
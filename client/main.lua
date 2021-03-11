local CurrentActionData, CurrentAction, CurrentActionMsg, hasAlreadyEnteredMarker, lastZone = {}
ESX = nil

Citizen.CreateThread(function ()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
	while ESX.GetPlayerData().job == nil do
		Citizen.Wait(100)
	end
	ESX.PlayerData = ESX.GetPlayerData()
end)

Citizen.CreateThread(function()
	RegisterNetEvent('esx:playerLoaded')
	AddEventHandler('esx:playerLoaded', function (xPlayer)
		while ESX == nil do
			Citizen.Wait(0)
		end
		ESX.PlayerData = xPlayer
	end)
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function (job)
	ESX.PlayerData.job = job
end)

function OpenBankActionsMenu()
	local elements = {}
	if ESX.PlayerData.job.grade_name ~= 'conveyor' and ESX.PlayerData.job.grade_name ~= 'conveyor_boss' then
		table.insert(elements, {label = _U('savingsMenuItem'), value = 'savingsAccounts'})
		table.insert(elements, {label = _U('openSavingsMenuItem'), value = 'openLivretA' })
		table.insert(elements, {label = _U('separatorMenuItem'), value = ''})
		table.insert(elements, {label = _U('riskedSavingsMenuItem'), value = 'riskedLivret'})
		table.insert(elements, {label = _U('openRiskedSavingsMenuItem'), value = 'openRisk' })
		table.insert(elements, {label = _U('separatorMenuItem'), value = ''})
		table.insert(elements, {label = _U('loanMenuItem'), value = 'lentMoney' })
		table.insert(elements, {label = _U('activeLoanMenuItem'), value = 'activeMoney' })
		table.insert(elements, {label = _U('frozenLoanMenuItem'), value = 'frozenMoney' })
		table.insert(elements, {label = _U('doLoanMenuItem'), value = 'lendMoney' })
		table.insert(elements, {label = _U('separatorMenuItem'), value = ''})
		table.insert(elements, {label = _U('billingMenuItem'),   value = 'billing'})
	end
	if ESX.PlayerData.job.grade_name == 'boss' then
		table.insert(elements, {label = _U('separatorMenuItem'), value = ''})
		table.insert(elements, { label = _U('closedSavingsMenuItem'), value = 'Closedcustomers' })
		table.insert(elements, { label = _U('closedRiskedSavingsMenuItem'), value = 'ClosedRiskedLivret' })
		table.insert(elements, { label = _U('companyManagementMenuItem'), value = 'boss_actions' })
	end
	ESX.UI.Menu.CloseAll()
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'bank_actions', {
		title    = _U('bank'),
		align    = 'top-left',
		elements = elements
	}, function(data, menu)
		if data.current.value == 'savingsAccounts' then
			OpenSavingsAccountsMenu()
		elseif data.current.value == 'Closedcustomers' then
			OpenClosedSavingsAccountsMenu()
		elseif data.current.value == 'riskedLivret' then
			OpenRiskedLivretMenu()
		elseif data.current.value == 'ClosedRiskedLivret' then
			OpenClosedRiskedLivretMenu()
		elseif data.current.value == 'billing' then
			Billing()
		elseif data.current.value == 'lendMoney' then
			LendMoney()
		elseif data.current.value == 'openLivretA' then
			openSavingsAccount()
		elseif data.current.value == 'openRisk' then
			OpenRiskedLivretAccount()
		elseif data.current.value == 'lentMoney' then
			OpenLentMoneyMenu()
		elseif data.current.value == 'activeMoney' then
			OpenActiveMoneyMenu()
		elseif data.current.value == 'frozenMoney' then
			OpenFrozenMoneyMenu()
		elseif data.current.value == 'boss_actions' then
			TriggerEvent('esx_society:openBossMenu', 'banker', function (data, menu)
				menu.close()
			end,  {wash = false})
		end
	end, function(data, menu)
		menu.close()
		CurrentAction     = 'bank_actions_menu'
		CurrentActionMsg  = _U('press_input_context_to_open_menu')
		CurrentActionData = {}
	end)
end

--########################################
--############SAVINGS ACCOUNTS############
--########################################

function OpenSavingsAccountsMenu()
	ESX.TriggerServerCallback('esx_bankerjob:getSavingsAccounts', function(customers)
		local elements = {
			head = { _U('account_num'), _U('client'), _U('rate'), _U('account_total'), _U('banker'), _U('actions') },
			rows = {}
		}
		for i=1, #customers do
			table.insert(elements.rows, {
				data = customers[i],
				cols = {
					customers[i].identifier,
					customers[i].firstname .. " " .. customers[i].lastname,
					customers[i].taux .. "%",
					customers[i].tot .. "$",
					customers[i].giverfirstname .. " " .. customers[i].giverlastname,
					'{{' .. _U('deposit') .. '|deposit}} {{' .. _U('withdraw') .. '|withdraw}} {{' .. _U('change_rate') .. '|taux}} {{' .. _U('close') .. '|close}} '
				}
			})
		end
		ESX.UI.Menu.Open('list', GetCurrentResourceName(), 'customers', elements, function(data, menu)
			local customer = data.data
			if data.value == 'deposit' then
				menu.close()
				ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'billing', {
					title = _U('amount')
				}, function(data2, menu2)
					local montant = tonumber(data2.value)
					if montant == nil then
						ESX.ShowNotification(_U('invalid_amount'))
					else
						menu2.close()
						TriggerServerEvent('esx_bankerjob:depositMoneySavingsAccount', data.data.identifier, montant)
					end
				end, function(data2, menu2)
					menu2.close()
				end)
			elseif data.value == 'withdraw' then
				menu.close()
				ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'billing', {
					title = _U('amount')
				}, function(data2, menu2)
					local montant = tonumber(data2.value)
					if montant == nil then
						ESX.ShowNotification(_U('invalid_amount'))
					else
						menu2.close()
						TriggerServerEvent('esx_bankerjob:withdrawSavings', data.data.identifier, montant)
					end
				end, function(data2, menu2)
					menu2.close()
				end)
			elseif data.value == 'taux' then
				menu.close()
				ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'billing', {
					title = _U('new_rate')
				}, function(data2, menu2)
					local taux = tonumber(data2.value)
					if taux == nil then
						ESX.ShowNotification(_U('invalid_rate'))
					else
						menu2.close()
						TriggerServerEvent('esx_bankerjob:changeSavingsAccountRate', data.data.identifier, taux)
					end
				end, function(data2, menu2)
					menu2.close()
				end)
			elseif data.value == 'close' then
				menu.close()
				TriggerServerEvent('esx_bankerjob:closeSavingsAccount', data.data.identifier)
			end
		end, function(data, menu)
			menu.close()
		end)
	end)
end

function openSavingsAccount()
	ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'billing', {
		title = _U('amount')
	}, function(data, menu)
		local montant = tonumber(data.value)
		if montant == nil then
			ESX.ShowNotification(_U('invalid_amount'))
		else
			menu.close()
			ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'billing', {
				title = _U('rate')
			}, function(data2, menu2)
				local taux = tonumber(data2.value)
				if taux == nil then
					ESX.ShowNotification(_U('invalid_rate'))
				else
					menu.close()		
					menu.close()
					ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'billing', {
						title = _U('client_surname')
					}, function(data3, menu3)
						local nom = tostring(data3.value)
						if nom == "nil" then
							ESX.ShowNotification( _U('invalid_name'))
						else
							menu.close()
							ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'billing', {
								title = _U('client_name')
							}, function(data4, menu4)
								local prenom = tostring(data4.value)
								if prenom == "nil" then
									ESX.ShowNotification( _U('invalid_surname'))
								else
									menu.close()
									menu.close()
									TriggerServerEvent('esx_bankerjob:openSavingsAccount', montant, taux, nom, prenom)
								end					
								end, function(data4, menu4)
									menu.close()
							end)	
						end					
					end, function(data3, menu3)
						menu.close()
					end)	
				end					
			end, function(data2, menu2)
				menu.close()
			end)
		end
	end, function(data, menu)
		menu.close()
	end)
end

function OpenClosedSavingsAccountsMenu()
	ESX.TriggerServerCallback('esx_bankerjob:getClosedSavingsAccounts', function(customers)
		local elements = {
			head = { _U('account_num'), _U('client'), _U('rate'), _U('account_total'), _U('banker'), _U('actions') },
			rows = {}
		}
		for i=1, #customers do
			table.insert(elements.rows, {
				data = customers[i],
				cols = {
					customers[i].identifier,
					customers[i].firstname .. " " .. customers[i].lastname,
					customers[i].taux .. "%",
					customers[i].tot .. "$",
					customers[i].giverfirstname .. " " .. customers[i].giverlastname,
					'{{' .. _U('reopen') .. '|reopen}} '
				}
			})
		end
		ESX.UI.Menu.Open('list', GetCurrentResourceName(), 'customers', elements, function(data, menu)
			local customer = data.data
			if data.value == 'reopen' then
				menu.close()
				TriggerServerEvent('esx_bankerjob:reopenSavingsAccount', data.data.identifier)
			end	
		end, function(data, menu)
			menu.close()
		end)
	end)
end

--#########################################
--#########RISKED SAVINGS ACCOUNTS#########
--#########################################


function OpenRiskedLivretMenu()
	ESX.TriggerServerCallback('esx_bankerjob:getRiskedSavingsAccount', function(customers)
		local elements = {
			head = { _U('account_num'), _U('client'), _U('account_total'), _U('banker'), _U('actions') },
			rows = {}
		}
		for i=1, #customers do
			table.insert(elements.rows, {
				data = customers[i],
				cols = {
					customers[i].identifier,
					customers[i].firstname .. " " .. customers[i].lastname,
					customers[i].tot .. "$",
					customers[i].giverfirstname .. " " .. customers[i].giverlastname,
					'{{' ..  _U('deposit') .. '|deposit}} {{' ..  _U('withdraw') .. '|withdraw}} {{' ..  _U('close') .. '|close}} '
				}
			})
		end
		ESX.UI.Menu.Open('list', GetCurrentResourceName(), 'customers', elements, function(data, menu)
			local customer = data.data
			if data.value == 'deposit' then
				menu.close()
				ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'billing', {
					title = _U('amount')
				}, function(data2, menu2)
					local montant = tonumber(data2.value)
					if montant == nil then
						ESX.ShowNotification(_U('invalid_amount'))
					else
						menu2.close()
						TriggerServerEvent('esx_bankerjob:depositMoneyRiskedSavingsAccount', data.data.identifier, montant)
					end
				end, function(data2, menu2)
					menu2.close()
				end)
			elseif data.value == 'withdraw' then
				menu.close()
				ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'billing', {
					title = _U('amount')
				}, function(data2, menu2)
					local montant = tonumber(data2.value)
					if montant == nil then
						ESX.ShowNotification(_U('invalid_amount'))
					else
						menu2.close()
						TriggerServerEvent('esx_bankerjob:withdrawRiskedSavingsAccount',  data.data.identifier, montant)
					end
				end, function(data2, menu2)
					menu2.close()
				end)
			elseif data.value == 'close' then
				menu.close()
				TriggerServerEvent('esx_bankerjob:closeRiskedSavingsAccount', data.data.identifier)
			end
		end, function(data, menu)
			menu.close()
		end)
	end)
end

function OpenClosedRiskedLivretMenu()
	ESX.TriggerServerCallback('esx_bankerjob:getClosedRiskedSavingsAccounts', function(customers)
		local elements = {
			head = { _U('account_num'), _U('client'), _U('account_total'), _U('banker'), _U('actions') },
			rows = {}
		}
		for i=1, #customers do
			table.insert(elements.rows, {
				data = customers[i],
				cols = {
					customers[i].identifier,
					customers[i].firstname .. " " .. customers[i].lastname,
					customers[i].tot .. "$",
					customers[i].giverfirstname .. " " .. customers[i].giverlastname,
					'{{' .. _U('reopen') .. '|reopen}}'	
				}
			})
		end
		ESX.UI.Menu.Open('list', GetCurrentResourceName(), 'customers', elements, function(data, menu)
			local customer = data.data
			if data.value == 'reopen' then
				menu.close()
				TriggerServerEvent('esx_bankerjob:reopenClosedRiskedSavingsAccount', data.data.identifier)
			end
		end, function(data, menu)
			menu.close()
		end)
	end)
end

function OpenRiskedLivretAccount()
	ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'billing', {
		title = _U('amount')
	}, function(data, menu)
		local montant = tonumber(data.value)
		if montant == nil then
			ESX.ShowNotification(_U('invalid_amount'))
		else
			menu.close()
			ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'billing', {
				title =  _U('client_surname')
			}, function(data3, menu3)
				local nom = tostring(data3.value)
				if nom == "nil" then
					ESX.ShowNotification(_U('invalid_surname'))
				else
					menu.close()
					ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'billing', {
						title =  _U('client_name')
					}, function(data4, menu4)
						local prenom = tostring(data4.value)
						if prenom == "nil" then
							ESX.ShowNotification(_U('invalid_name'))
						else
							menu.close()
							TriggerServerEvent('esx_bankerjob:openRiskedSavingsAccount', montant, nom, prenom)
							end					
						end, function(data4, menu4)
							menu.close()
						end)	
					end					
				end, function(data3, menu3)
					menu.close()
				end)
			end
	end, function(data, menu)
		menu.close()
	end)
end

--#########################################
--##############LENDING MONEY##############
--#########################################

function OpenLentMoneyMenu()
	ESX.TriggerServerCallback('esx_bankerjob:getLoanAccounts', function(customers)
		local elements = {
			head = { _U('account_num'), _U('client'), _U('total_repay_amount'), _U('rate'), _U('next_time_repay_amount'), _U('remaining_deadline_count'), _U('deadline_count'), _U('already_repayed_amount'), _U('remaining_time'), _U('time_between_deadlines'), _U('banker'), _U('status'), _U('actions') },
			rows = {}
		}
		for i=1, #customers do
			table.insert(elements.rows, {
				data = customers[i],
				cols = {
					customers[i].identifier,
					customers[i].firstname .. " " .. customers[i].lastname,
					customers[i].amount .. "$",
					customers[i].taux .. "%",
					customers[i].montProchEcheance .. "$",
					customers[i].nbEcheances,
					customers[i].echeancesTot,
					customers[i].montDernEcheance .. "$",
					customers[i].timeleft .. " jour(s)",
					customers[i].timeEcheance .. " jour(s)",
					customers[i].giverfirstname .. " " .. customers[i].giverlastname,
					customers[i].status,
					'{{' .. _U('close') .. '|close}}'
				}
			})
		end
		ESX.UI.Menu.Open('list', GetCurrentResourceName(), 'customers', elements, function(data, menu)
			local customer = data.data
			if data.value == 'close' then
				menu.close()
				TriggerServerEvent('esx_bankerjob:closeLoan', data.data.identifier)
			end
		end, function(data, menu)
			menu.close()
		end)
	end)
end

function OpenActiveMoneyMenu()
	ESX.TriggerServerCallback('esx_bankerjob:getActiveLoanAccounts', function(customers)
		local elements = {
			head = { _U('account_num'), _U('client'), _U('total_repay_amount'), _U('rate'), _U('next_time_repay_amount'), _U('remaining_deadline_count'),  _U('deadline_count'), _U('already_repayed_amount'), _U('remaining_time'), _U('time_between_deadlines'), _U('banker'), _U('status'), _U('actions') },
			rows = {}
		}
		for i=1, #customers do
			table.insert(elements.rows, {
				data = customers[i],
				cols = {
					customers[i].identifier,
					customers[i].firstname .. " " .. customers[i].lastname,
					customers[i].amount .. "$",
					customers[i].taux .. "%",
					customers[i].montProchEcheance .. "$",
					customers[i].nbEcheances,
					customers[i].echeancesTot,
					customers[i].montDernEcheance .. "$",
					customers[i].timeleft .. " jour(s)",
					customers[i].timeEcheance .. " jour(s)",
					customers[i].giverfirstname .. " " .. customers[i].giverlastname,
					customers[i].status,
					'{{' .. _U('freeze') .. '|freeze}} {{' .. _U('advance_deadline') .. '|avEch}}'
				}
			})
		end
		ESX.UI.Menu.Open('list', GetCurrentResourceName(), 'customers', elements, function(data, menu)
			local customer = data.data
			if data.value == 'freeze' then
				menu.close()
				TriggerServerEvent('esx_bankerjob:freezeLoan', data.data.identifier)
			elseif data.value == 'avEch' then
				menu.close()
				TriggerServerEvent('esx_bankerjob:avEche', data.data.identifier)
			end
		end, function(data, menu)
			menu.close()
		end)
	end)
end

function OpenFrozenMoneyMenu()
	ESX.TriggerServerCallback('esx_bankerjob:getFrozenLoanAccounts', function(customers)
		local elements = {
			head = {_U('account_num'), _U('client'), _U('total_repay_amount'), _U('rate'), _U('next_time_repay_amount'), _U('remaining_deadline_count'),  _U('deadline_count'), _U('already_repayed_amount'), _U('remaining_time'), _U('time_between_deadlines'), _U('banker'), _U('status'), _U('actions') },
			rows = {}
		}
		for i=1, #customers do
			table.insert(elements.rows, {
				data = customers[i],
				cols = {
					customers[i].identifier,
					customers[i].firstname .. " " .. customers[i].lastname,
					customers[i].amount .. "$",
					customers[i].taux .. "%",
					customers[i].montProchEcheance .. "$",
					customers[i].nbEcheances,
					customers[i].echeancesTot,
					customers[i].montDernEcheance .. "$",
					customers[i].timeleft .. " jour(s)",
					customers[i].timeEcheance .. " jour(s)",
					customers[i].giverfirstname .. " " .. customers[i].giverlastname,
					customers[i].status,
					'{{' .. _U('reopen') .. '|reopen}} {{' .. _U('advance_deadline') .. '|avEch}}'
				}
			})
		end
		ESX.UI.Menu.Open('list', GetCurrentResourceName(), 'customers', elements, function(data, menu)
			local customer = data.data
			if data.value == 'reopen' then
				menu.close()
				TriggerServerEvent('esx_bankerjob:reopenLoan', data.data.identifier)
			elseif data.value == 'avEch' then
				menu.close()
				TriggerServerEvent('esx_bankerjob:avEche', data.data.identifier)
			end
		end, function(data, menu)
			menu.close()
		end)
	end)
end

function LendMoney()
	ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'billing', {
		title = _U('amount')
	}, function(data, menu)
		local montant = tonumber(data.value)
		if montant == nil then
			ESX.ShowNotification(_U('invalid_amount'))
		else
			menu.close()
			ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'billing', {
				title = _U('rate')
			}, function(data2, menu2)
				local taux = tonumber(data2.value)
				if taux == nil then
					ESX.ShowNotification(_U('invalid_rate'))
				else
					menu.close()
					ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'billing', {
						title = _U('deadline_number')
					}, function(data3, menu3)
						local nbEche = tonumber(data3.value)
						if nbEche == nil then
							ESX.ShowNotification(_U('invalid_number'))
						else
							menu.close()
							ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'billing', {
								title = _U('time_between_deadlines')
							}, function(data4, menu4)
								local jours = tonumber(data4.value)
								if jours == nil then
									ESX.ShowNotification(_U('invalid_number'))
								else
									menu.close()
									local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
									if closestPlayer == -1 or closestDistance > 5.0 then
										ESX.ShowNotification(_U('no_player'))
									else
										TriggerServerEvent('esx_bankerjob:makeLoan', GetPlayerServerId(closestPlayer), montant, taux, nbEche, jours)
									end
								end
							end, function(data4, menu4)
								menu.close()
							end)
						end
					end, function(data3, menu3)
						menu.close()
					end)
				end
			end, function(data2, menu2)
				menu.close()
			end)
		end
	end, function(data, menu)
		menu.close()
	end)
end

--#########################################
--##################UTILS##################
--#########################################


AddEventHandler('esx_bankerjob:hasEnteredMarker', function (zone)
	if zone == 'BankActions' and ESX.PlayerData.job and ESX.PlayerData.job.name == 'banker' then
		CurrentAction     = 'bank_actions_menu'
		CurrentActionMsg  = _U('press_input_context_to_open_menu')
		CurrentActionData = {}
	elseif zone == 'BankStocks' and ESX.PlayerData.job and ESX.PlayerData.job.name == 'banker' then
		CurrentAction     = 'bank_stocks_menu'
		CurrentActionMsg  = _U('press_input_context_to_open_menu')
		CurrentActionData = {}
	elseif zone == 'VehicleDeleter' then
		local playerPed = PlayerPedId()
		local vehicle   = GetVehiclePedIsIn(playerPed, false)
		if IsPedInAnyVehicle(playerPed, false) and GetPedInVehicleSeat(vehicle, -1) == playerPed then
			CurrentAction     = 'delete_vehicle'
			CurrentActionMsg  = _U('press_input_context_to_park_car')
			CurrentActionData = { vehicle = vehicle }
		end
	elseif zone == 'VehicleSpawner' then
		CurrentAction     = 'vehicle_spawner'
		CurrentActionMsg  = _U('press_input_context_to_spawn_car')
		CurrentActionData = {}
	end
end)

AddEventHandler('esx_bankerjob:hasExitedMarker', function (zone)
	CurrentAction = nil
	ESX.UI.Menu.CloseAll()
end)

-- Create Blips
Citizen.CreateThread(function()
	local blip = AddBlipForCoord(Config.Zones.BankActions.Coords)
	SetBlipSprite(blip, 108)
	SetBlipColour(blip, 30)
	SetBlipAsShortRange(blip, true)
	BeginTextCommandSetBlipName('STRING')
	AddTextComponentSubstringPlayerName(_U('bank'))
	EndTextCommandSetBlipName(blip)
end)

-- Draw marker & activate menu when player is inside marker
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		if ESX.PlayerData.job and ESX.PlayerData.job.name == 'banker' then
			local playerCoords = GetEntityCoords(PlayerPedId())
			local isInMarker, letSleep, currentZone = false, true
			for k,v in pairs(Config.Zones) do
				local distance = #(playerCoords - v.Coords)
				if v.Type ~= -1 and distance < Config.DrawDistance then
					letSleep = false
					DrawMarker(v.Type, v.Coords, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, v.Size.x, v.Size.y, v.Size.z, v.Color.r, v.Color.g, v.Color.b, 100, false, true, 2, false, nil, nil, false)
				end
				if distance < v.Size.x then
					isInMarker, currentZone, letSleep = true, k, false
				end
			end
			if isInMarker and not hasAlreadyEnteredMarker then
				hasAlreadyEnteredMarker, lastZone = true, currentZone
				TriggerEvent('esx_bankerjob:hasEnteredMarker', currentZone)
			end
			if not isInMarker and hasAlreadyEnteredMarker then
				hasAlreadyEnteredMarker = false
				TriggerEvent('esx_bankerjob:hasExitedMarker', lastZone)
			end
			if letSleep then
				Citizen.Wait(500)
			end
		else
			Citizen.Wait(500)
		end
	end
end)

-- Key Controls
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		if CurrentAction then
			ESX.ShowHelpNotification(CurrentActionMsg)
			if IsControlJustReleased(0, 38) and ESX.PlayerData.job and ESX.PlayerData.job.name == 'banker' then
				if CurrentAction == 'bank_actions_menu' then
					OpenBankActionsMenu()
				elseif CurrentAction == 'bank_stocks_menu' then
					OpenStocksMenu()
				elseif CurrentAction == 'vehicle_spawner' then
					OpenVehicleSpawnerMenu()
				elseif CurrentAction == 'delete_vehicle' then
				DeleteJobVehicle()
				end
			CurrentAction = nil
			end
		else
			Citizen.Wait(500)
		end
	end
end)

RegisterNetEvent('esx_phone:loaded')
AddEventHandler('esx_phone:loaded', function (phoneNumber, contacts)
	local specialContact = {
		name       = _U('phone_label'),
		number     = 'banker',
		base64Icon = 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAIAAAACACAMAAAD04JH5AAAABGdBTUEAALGPC/xhBQAAAwBQTFRFAAAAJUO2JUS4JkW7Jka+L0y5M0+7O1e9J0fBKEjEKEnHKUrJKUvMKk3PK07SK0/VLFHaLVLeLVPgLlTjOl7kO1/lQFu/RmDBTmbEU2vHXHLIR2jmSGnnVHPoVXToaX7NYX7pYn/qbIHPd4rReYzTbojre5PtfZTuhZbWh5jYiJ7vkqHblqnwl6rxoK3fpLXzsb/1u8Xovsr2ydHty9X419zy5Oj25ur88vT78vT88/X9////AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAATuU7PwAAAQB0Uk5T////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////AFP3ByUAAAAJcEhZcwAADsIAAA7CARUoSoAAAAAYdEVYdFNvZnR3YXJlAHBhaW50Lm5ldCA0LjEuNv1OCegAAAUoSURBVHhe5ZvrdtQ2FEZjoCmFltsQ2gYCA4VA06GUhktK3v+5ppK8bUu2jnTk26zV7l+JbH1nR7Y0QglH+zHstpsBb7hWSLHAjnpxttylp0zgKXWSXHCzjgKBxxRQcE4XBVqBc6LV0C+LTqDgh+/Y0TmNRoDAcjRPIi8w6qdvyI9CTiAy4csgRyQjQMoUHhMlkBSYNPodpMVJCdB/OqlBkAXO6D0LZEYQBeg5F+L6LAnQbz7OCO4jCNBrVojuERUoXvh1kB4SE1ioftwgIjDr6x9CBZ+hwGI/v4UaHgOBRetHDAYC3LgYlGnpC3DbcvSX5Z4Ady1Jb+McCnDPslALAoEFJ6AP1WoCAW5YHMo5fAEuL4//GngCM+1/NFDR4glwcRUoaegEuFTEp+vr6298XUS3P2kFRuy/X5rylvd8XwJVPQEu6Dn5Rn3Dc9r0PKVsK1D8BtrR7yh/DtRtBWjWckHhjr+5oobCCNCo5BlFQ95yVUldeJTAVyoOOOEGFXws1gIlb8AHqsX4yj0qXGUEaFLQTD2JgilZTwQnoN6G+VNP4iX35ukEaMgSTj0J9ZQsFRhOPYlP9MjRCKhewfjUk9BNyUaAb5OIU0/iGR1T2EMsncBfpJagmZK1QPb8NTf1JD7QX6YW4BuJE+LGkJuSGgHd1JP4hxQJK5A+f1esPGkeEBTHCvClADHjOb5HUpQVBE6rH4iKsYJAVVU3yIpwlhV4Tg58NnnwhCbLFW0WmuCjayMswv4o/Q5agvfQ5TmuaHHQZvhIi+MJjdUjsgbsj/LbccJqCDQElWgzvKPFcUpjVUmTYX/EFwn8legX8izeEPxGk+UzbYZLmix3SeuhEbC4PKJ8CppvERWyokB8MuxWFIhOhu2qAtVD4jrO1hWohuvyygLVHQJb1haobpLYsLpA/1U8gEC4Lh9CIFiXDyJQ/USs4TAC1W1yDybQrssrr4Q+dfD54QTqybDuh1GP+yZ4zY/jIWZd3h+9oUQamzi/gNmkZHfFYBMXEKiq/73Aq0ML2H+aqc7pbeJSAqohsIn/RYFfDy1QH9FcUCSFTVxMQDMENnF+ge8OLWBqOwHFYblNXE5AMQQ2cXaB77UC3hGJ/y/+L7QZvtBkuaTN4J/cRLCla4G0QXBU2Z1Q/EGL4x2NVXVKi6M+IZJwpRUC70lz0NcQVGoPg6pjWhwvaIziKiOQOKl6O+ms9PKYahFcZQTkISBoPOIgvK4rIyDORGImQL0BdeFGQBwCUiZAvT6/U7gRkN4CUsbjz1Af6rYC0hBMPq4X3kKqegKSATlj+ZOCfSjqC0i/vBvzC6uGq259CKGmoROQp+I9es2H2Qk1eAKywSP6zQYFLb5A4jeoN+g5D9Rz+ALyEGw2d+g7B6yBNYFAyuABvadjN2IdoUByf0r/yVALQoH0H/TdImEaVGroCaQewmbzIxlToE5LXyBt8JCU8TSfQS0DgbTB1BfhFUU6hgIZg9tEjcJbARsiAhmD+4SN4GcK+MQEMgajF+bh+BuiAhmDkQvz4P1zxAVyf1hzl8wSSO4jCOQObsoXZnIHSALZx0CuknD995EFcgYlC3Pw+ReSEMg9Bv1GibwoKYGZ5mNk9fFIC+TOjzTzkSSJjEDu76yyGyVSZLICmeeQno/xtSdAIZBZlqgVQVFeKZB+EMJ8pGcOpYCBchEiGyV3/qRCL5A4ROhtlORlL0KJgIWSfShtSM/6IaUCltjW2W2Uoh/4GcYI1Oy2rcj2XPe/rIfs9/8CuOBqaLBm2ZcAAAAASUVORK5CYII='
	}
	TriggerEvent('esx_phone:addSpecialContact', specialContact.name, specialContact.number, specialContact.base64Icon)
end)

function OpenVehicleSpawnerMenu()
	ESX.UI.Menu.CloseAll()
	local elements = {}
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'vehicle_spawner',
	{
		css         = 'banker',
		title		= _U('garage'),
		align		= 'top-left',
		elements	= Config.AuthorizedVehicles
	}, function(data, menu)
		if not ESX.Game.IsSpawnPointClear(Config.Zones.VehicleSpawnPoint.Coords, 5.0) then
			ESX.ShowNotification(_U('blocked_spawn_point'))
			return
		end
		if ESX.PlayerData.job.grade_name ~= 'boss' and data.current.auth == 'boss' then
			menu.close()
			ESX.ShowNotification(_U('not_boss'))
		else
			menu.close()
			ESX.Game.SpawnVehicle(data.current.model, Config.Zones.VehicleSpawnPoint.Coords, Config.Zones.VehicleSpawnPoint.Heading, function(vehicle)
				local playerPed = PlayerPedId()
				TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
				SetVehicleEnginePowerMultiplier(vehicle, 60)
				SetVehicleDirtLevel (vehicle, 0) 
				SetVehicleEngineTorqueMultiplier(vehicle, 1.5)
				SetVehicleColours(vehicle, 12 , 12)
				local plate = Config.CompanyPlate .. math.random(10, 99)
				SetVehicleNumberPlateText(vehicle, plate)
			end)
		end	
	end, function(data, menu)
		CurrentAction     = 'vehicle_spawner'
		CurrentActionData = {}
		menu.close()
	end)
end

function IsInAuthorizedVehicle()
	local playerPed = PlayerPedId()
	local vehModel  = GetEntityModel(GetVehiclePedIsIn(playerPed, false))
	for i=1, #Config.AuthorizedVehicles, 1 do
		if vehModel == GetHashKey(Config.AuthorizedVehicles[i].model) then
			return true
		end
	end
	return false
end

function DeleteJobVehicle()
	local playerPed = PlayerPedId()
	if IsInAuthorizedVehicle() then
		ESX.Game.DeleteVehicle(CurrentActionData.vehicle)
	else
		ESX.ShowNotification(_U('not_in_auth_car'))
	end
end

function Billing()
	ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'billing', {
		title = _U('amount')
	}, function(data, menu)
		local amount = tonumber(data.value)
		if amount == nil then
			ESX.ShowNotification(_U('invalid_amount'))
		else
			menu.close()
			local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
			if closestPlayer == -1 or closestDistance > 5.0 then
				ESX.ShowNotification(_U('no_player'))
			else
				TriggerServerEvent('esx_billing:sendBill', GetPlayerServerId(closestPlayer), 'society_banker', 'Banque', amount)
			end
		end
	end, function(data, menu)
		menu.close()
	end)
end



function OpenStocksMenu()
	local elements = {
		{label = _U('get_weapon'),     	value = 'get_weapon'},
		{label = _U('put_weapon'),     	value = 'put_weapon'},
		{label = _U('take_inventory'),  value = 'get_stock'},
		{label = _U('put_inventory'), 	value = 'put_stock'}
	}
	ESX.UI.Menu.CloseAll()
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'bank_stocks', {
		title    = _U('bank_stocks_title'),
		align    = 'top-left',
		elements = elements
	}, function(data, menu)
		if data.current.value == 'get_weapon' then
			OpenGetWeaponMenu()
		elseif data.current.value == 'put_weapon' then
			OpenPutWeaponMenu()
		elseif data.current.value == 'buy_weapons' then
			OpenBuyWeaponsMenu()
		elseif data.current.value == 'put_stock' then
			OpenPutStocksMenu()
		elseif data.current.value == 'get_stock' then
			OpenGetStocksMenu()
		end
	end, function(data, menu)
		menu.close()
		CurrentAction     = 'bank_stocks_menu'
		CurrentActionMsg  = _U('press_input_context_to_open_menu')
		CurrentActionData = {}
	end)
end

function OpenGetWeaponMenu()
	ESX.TriggerServerCallback('esx_bankerjob:getWeapons', function(weapons)
		local elements = {}
		for i=1, #weapons, 1 do
			if weapons[i].count > 0 then
				table.insert(elements, {
					label = 'x' .. weapons[i].count .. ' ' .. ESX.GetWeaponLabel(weapons[i].name),
					value = weapons[i].name
				})
			end
		end
		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'armory_get_weapon', {
			css      = 'banker',
			title    = _U('take_weapon_action'),
			align    = 'top-left',
			elements = elements
		}, function(data, menu)
			menu.close()
			ESX.TriggerServerCallback('esx_bankerjob:removeWeapon', function()
				OpenGetWeaponMenu()
			end, data.current.value)
		end, function(data, menu)
			menu.close()
		end)
	end)
end

function OpenPutWeaponMenu()
	local elements   = {}
	local playerPed  = PlayerPedId()
	local weaponList = ESX.GetWeaponList()
	for i=1, #weaponList, 1 do
		local weaponHash = GetHashKey(weaponList[i].name)
		if HasPedGotWeapon(playerPed, weaponHash, false) and weaponList[i].name ~= 'WEAPON_UNARMED' then
			table.insert(elements, {
				label = weaponList[i].label,
				value = weaponList[i].name
			})
		end
	end
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'armory_put_weapon', {
		css      = 'banker',
		title    = _U('put_weapon_action'),
		align    = 'top-left',
		elements = elements
	}, function(data, menu)
		menu.close()
		ESX.TriggerServerCallback('esx_bankerjob:addWeapon', function()
			OpenPutWeaponMenu()
		end, data.current.value, true)
	end, function(data, menu)
		menu.close()
	end)
end

function OpenGetStocksMenu()
	ESX.TriggerServerCallback('esx_bankerjob:getStockItems', function(items)
		local elements = {}
		for i=1, #items, 1 do
			table.insert(elements, {
				label = 'x' .. items[i].count .. ' ' .. items[i].label,
				value = items[i].name
			})
		end
		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'stocks_menu', {
			title    = _U('bank_stocks_title'),
			align    = 'top-left',
			elements = elements
		}, function(data, menu)
			local itemName = data.current.value
			ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'stocks_menu_get_item_count', {
				title = _U('quantity')
			}, function(data2, menu2)
				local count = tonumber(data2.value)
				if count == nil then
					ESX.ShowNotification(_U('quantity_invalid'))
				else
					menu2.close()
					menu.close()
					TriggerServerEvent('esx_bankerjob:getStockItem', itemName, count)
					Citizen.Wait(300)
					OpenGetStocksMenu()
				end
			end, function(data2, menu2)
				menu2.close()
			end)
		end, function(data, menu)
			menu.close()
		end)
	end)
end

function OpenPutStocksMenu()
	ESX.TriggerServerCallback('esx_bankerjob:getPlayerInventory', function(inventory)
		local elements = {}
		for i=1, #inventory.items, 1 do
			local item = inventory.items[i]
			if item.count > 0 then
				table.insert(elements, {
					label = item.label .. ' x' .. item.count,
					type = 'item_standard',
					value = item.name
				})
			end
		end
		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'stocks_menu', {
			css      = 'banker',
			title    = _U('inventory'),
			align    = 'top-left',
			elements = elements
		}, function(data, menu)
			local itemName = data.current.value
			ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'stocks_menu_put_item_count', {
				css      = 'banker',
				title = _U('quantity')
			}, function(data2, menu2)
				local count = tonumber(data2.value)
				if count == nil then
					ESX.ShowNotification(_U('quantity_invalid'))
				else
					menu2.close()
					menu.close()
					TriggerServerEvent('esx_bankerjob:putStockItems', itemName, count)
					Citizen.Wait(300)
					OpenPutStocksMenu()
				end
			end, function(data2, menu2)
				menu2.close()
			end)
		end, function(data, menu)
			menu.close()
		end)
	end)
end











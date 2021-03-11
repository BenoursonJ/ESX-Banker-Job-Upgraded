ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
TriggerEvent('esx_phone:registerNumber', 'banker', _('phone_receive'), false, false)
TriggerEvent('esx_society:registerSociety', 'banker', _U('phone_label'), 'society_banker', 'society_banker', 'society_banker', {type = 'public'})

--########################################
--############SAVINGS ACCOUNTS############
--########################################

ESX.RegisterServerCallback('esx_bankerjob:getSavingsAccounts', function (source, cb)
	local customers = {}
	MySQL.Async.fetchAll('SELECT bank_savings.id, bank_savings.firstname, bank_savings.lastname, bank_savings.tot, bank_savings.rate, bank_savings.advisorFirstname, bank_savings.advisorLastname FROM bank_savings WHERE bank_savings.status = "Ouvert" ORDER BY id ASC',
	{}, function(result)
		local customers = {}
		for i=1, #result, 1 do
			table.insert(customers, {
				identifier = result[i].id,
				firstname = result[i].firstname,
				lastname = result[i].lastname,
				tot = result[i].tot,
				taux = result[i].rate,
				giverfirstname = result[i].advisorFirstname,
				giverlastname = result[i].advisorLastname
			})
		end
		cb(customers)
	end)
end)

ESX.RegisterServerCallback('esx_bankerjob:getClosedSavingsAccounts', function (source, cb)
	local customers = {}
	MySQL.Async.fetchAll('SELECT bank_savings.id, bank_savings.firstname, bank_savings.lastname, bank_savings.tot, bank_savings.rate, bank_savings.advisorFirstname, bank_savings.advisorLastname FROM bank_savings WHERE bank_savings.status = "Clos" ORDER BY id ASC',
	{}, function(result)
		local customers = {}
		for i=1, #result, 1 do
			table.insert(customers, {
				identifier = result[i].id,
				firstname = result[i].firstname,
				lastname = result[i].lastname,
				tot = result[i].tot,
				taux = result[i].rate,
				giverfirstname = result[i].advisorFirstname,
				giverlastname = result[i].advisorLastname
			})
		end
		cb(customers)
	end)
end)

RegisterServerEvent('esx_bankerjob:openSavingsAccount')
AddEventHandler('esx_bankerjob:openSavingsAccount', function (montant, taux, nom, prenom)
	local xPlayer = ESX.GetPlayerFromId(source)
	if xPlayer.getMoney() >= montant then
		xPlayer.removeMoney(montant)
		MySQL.Async.execute('INSERT INTO bank_savings(bank_savings.firstname, bank_savings.lastname, bank_savings.tot, bank_savings.rate, bank_savings.advisorFirstname, bank_savings.advisorLastname, bank_savings.status) VALUES(@prenom, @nom, @mont, @taux, (SELECT users.firstname FROM `users` WHERE users.identifier = @playGiver), (SELECT users.lastname FROM `users` WHERE users.identifier = @playGiver), "Ouvert");', 
		{
			['@mont']   = montant,
			['@taux'] = taux,
			['@nom']   = nom,
			['@prenom'] = prenom,
			['@playGiver']   = xPlayer.identifier
		},
		function ()
		end)
		TriggerClientEvent('esx:showNotification', xPlayer.source, "Livret A Ouvert pour " .. prenom .. " " .. nom .. ", montant déposé : " .. montant .. " $")
	else
		TriggerClientEvent('esx:showNotification', xPlayer.source, _U('not_enough_money'))
	end	
end)

RegisterServerEvent('esx_bankerjob:depositMoneySavingsAccount')
AddEventHandler('esx_bankerjob:depositMoneySavingsAccount', function (livretID, montant)
	local xPlayer = ESX.GetPlayerFromId(source)
	MySQL.Async.fetchScalar('SELECT COUNT(*) FROM bank_savings WHERE bank_savings.id = @livretID and bank_savings.status = "Ouvert"', 
	{
		['@livretID']   = livretID
	}, function(compte)
		if compte > 0 then
			if xPlayer.getMoney() >= montant then
				xPlayer.removeMoney(montant)
				MySQL.Async.fetchScalar('SELECT bank_savings.tot FROM bank_savings WHERE bank_savings.id = @livretID', 
				{
					['@livretID']   = livretID
				}, function(result)
					montajout = math.floor(result + montant)
					MySQL.Async.execute('UPDATE bank_savings set bank_savings.tot = @mont WHERE bank_savings.id = @livretID', 
					{
						['@mont']   = montajout,
						['@livretID'] = livretID
					},
					function ()
					end)
					TriggerClientEvent('esx:showNotification', xPlayer.source, "La somme de " .. montant .. "$ a été ajoutée au livret A, montant total : " .. montajout .. " $")
				end)
			else
				TriggerClientEvent('esx:showNotification', xPlayer.source, _U('not_enough_money'))
			end
		else
			TriggerClientEvent('esx:showNotification', xPlayer.source, _U('no_entry'))
		end
	end)
end)

RegisterServerEvent('esx_bankerjob:changeSavingsAccountRate')
AddEventHandler('esx_bankerjob:changeSavingsAccountRate', function (livretID, taux)
	local xPlayer = ESX.GetPlayerFromId(source)
	MySQL.Async.fetchScalar('SELECT COUNT(*) FROM bank_savings WHERE bank_savings.id = @livretID and bank_savings.status = "Ouvert"', 
		{
			['@livretID']   = livretID
		}, function(compte)
			if compte > 0 then
				MySQL.Async.execute('UPDATE bank_savings set bank_savings.rate = @taux WHERE bank_savings.id = @livretID', 
					{
						['@livretID'] = livretID,
						['@taux'] = taux
					},
				function ()
				end)
				TriggerClientEvent('esx:showNotification', xPlayer.source, "Le taux du Livret A a été modifié à : " .. taux .. " %")
			else
				TriggerClientEvent('esx:showNotification', xPlayer.source, _U('no_entry'))
			end
	end)
end)

RegisterServerEvent('esx_bankerjob:withdrawSavings')
AddEventHandler('esx_bankerjob:withdrawSavings', function (livretID, montant)
	local xPlayer = ESX.GetPlayerFromId(source)
	MySQL.Async.fetchScalar('SELECT COUNT(*) FROM bank_savings WHERE bank_savings.id = @livretID and bank_savings.status = "Ouvert"', 
		{
			['@livretID']   = livretID
		}, function(compte)
			if compte > 0 then
				MySQL.Async.fetchScalar('SELECT bank_savings.tot FROM bank_savings WHERE bank_savings.id = @livretID ', 
				{
					['@livretID']   = livretID

			}, function(result)
					if result >= montant then
						montretire = math.floor(result - montant)
						MySQL.Async.execute('UPDATE bank_savings set bank_savings.tot = @mont WHERE bank_savings.id = @livretID', 
						{
							['@mont']   = montretire,
							['@livretID'] = livretID
						},
						function ()
						end)
						xPlayer.addMoney(montant)
						TriggerClientEvent('esx:showNotification', xPlayer.source, "La somme de " .. montant .. "$ a été retirée du livret A, montant total restant : " .. montretire .. " $")
					else
						TriggerClientEvent('esx:showNotification', xPlayer.source, _U('not_enough_money_account'))
					end
				end)
			else
				TriggerClientEvent('esx:showNotification', xPlayer.source, _U('no_entry'))
			end
	end)
end)

RegisterServerEvent('esx_bankerjob:closeSavingsAccount')
AddEventHandler('esx_bankerjob:closeSavingsAccount', function (livretID)
	local xPlayer = ESX.GetPlayerFromId(source)
	MySQL.Async.fetchScalar('SELECT COUNT(*) FROM bank_savings WHERE bank_savings.id = @livretID and bank_savings.status = "Ouvert"', 
		{
			['@livretID']   = livretID
		}, function(compte)
			if compte > 0 then
				MySQL.Async.fetchScalar('SELECT bank_savings.tot FROM bank_savings WHERE bank_savings.id = @livretID', 
				{
					['@livretID']   = livretID
				}, function(result)
					MySQL.Async.execute('UPDATE bank_savings set bank_savings.status = "Clos", bank_savings.tot = "0" WHERE bank_savings.id = @livretID', 
					{
						['@livretID'] = livretID
					},
					function ()
					end)
					xPlayer.addMoney(result)
					TriggerClientEvent('esx:showNotification', xPlayer.source, "La somme de " .. result .. "$ a été retirée du livret A, dossier CLOS")
				end)
			else
				TriggerClientEvent('esx:showNotification', xPlayer.source, _U('no_entry'))
			end
	end)
end)


RegisterServerEvent('esx_bankerjob:reopenSavingsAccount')
AddEventHandler('esx_bankerjob:reopenSavingsAccount', function (numDoss)
	local xPlayer = ESX.GetPlayerFromId(source)
	local statut = "Ouvert"
	MySQL.Async.execute('UPDATE bank_savings SET bank_savings.status = @stat WHERE bank_savings.id = @mont', 
	{
		['@mont']   = numDoss,
		['@stat']   = statut
	},
	function ()
	end)
	TriggerClientEvent('esx:showNotification', xPlayer.source, "Le compte épargne " .. numDoss .. " est à nouveau ouvert !")
end)



--#########################################
--#########RISKED SAVINGS ACCOUNTS#########
--#########################################

ESX.RegisterServerCallback('esx_bankerjob:getRiskedSavingsAccount', function (source, cb)
	local customers = {}
	MySQL.Async.fetchAll('SELECT bank_riskedsavings.id, bank_riskedsavings.firstname, bank_riskedsavings.lastname, bank_riskedsavings.tot, bank_riskedsavings.advisorFirstname, bank_riskedsavings.advisorLastname FROM bank_riskedsavings WHERE status = "Ouvert" ORDER BY id ASC',
	{}, function(result)
		local customers = {}
		for i=1, #result, 1 do
			table.insert(customers, {
				identifier = result[i].id,
				firstname = result[i].firstname,
				lastname = result[i].lastname,
				tot = result[i].tot,
				giverfirstname = result[i].advisorFirstname,
				giverlastname = result[i].advisorLastname
			})
		end
		cb(customers)
	end)
end)

ESX.RegisterServerCallback('esx_bankerjob:getClosedRiskedSavingsAccounts', function (source, cb)
	local customers = {}
	MySQL.Async.fetchAll('SELECT bank_riskedsavings.id, bank_riskedsavings.firstname, bank_riskedsavings.lastname, bank_riskedsavings.tot, bank_riskedsavings.advisorFirstname, bank_riskedsavings.advisorLastname FROM bank_riskedsavings WHERE status = "Clos" ORDER BY id ASC',
	{}, function(result)
		local customers = {}
		for i=1, #result, 1 do
			table.insert(customers, {
				identifier = result[i].id,
				firstname = result[i].firstname,
				lastname = result[i].lastname,
				tot = result[i].tot,
				giverfirstname = result[i].advisorFirstname,
				giverlastname = result[i].advisorLastname
			})
		end
		cb(customers)
	end)
end)

RegisterServerEvent('esx_bankerjob:openRiskedSavingsAccount')
AddEventHandler('esx_bankerjob:openRiskedSavingsAccount', function (montant, nom, prenom)
	local xPlayer = ESX.GetPlayerFromId(source)
	if xPlayer.getMoney() >= montant then
		xPlayer.removeMoney(montant)
		MySQL.Async.execute('INSERT INTO bank_riskedsavings(bank_riskedsavings.firstname, bank_riskedsavings.lastname, bank_riskedsavings.tot, bank_riskedsavings.advisorFirstname, bank_riskedsavings.advisorLastname, bank_riskedsavings.status) VALUES(@prenom, @nom, @mont, (SELECT users.firstname FROM `users` WHERE users.identifier = @playGiver), (SELECT users.lastname FROM `users` WHERE users.identifier = @playGiver), "Ouvert");', 
		{
			['@mont']   = montant,
			['@nom']   = nom,
			['@prenom'] = prenom,
			['@playGiver']   = xPlayer.identifier
		},
		function ()
		end)
		TriggerClientEvent('esx:showNotification', xPlayer.source, "Livret A Ouvert pour " .. nom .. " " .. prenom .. ", montant déposé : " .. montant .. " $")
	else
		TriggerClientEvent('esx:showNotification', xPlayer.source, _U('not_enough_money'))
	end	
end)

RegisterServerEvent('esx_bankerjob:depositMoneyRiskedSavingsAccount')
AddEventHandler('esx_bankerjob:depositMoneyRiskedSavingsAccount', function (livretID, montant)
	local xPlayer = ESX.GetPlayerFromId(source)
	MySQL.Async.fetchScalar('SELECT COUNT(*) FROM bank_riskedsavings WHERE bank_riskedsavings.id = @livretID and bank_riskedsavings.status = "Ouvert"', 
	{
		['@livretID']   = livretID
	}, function(compte)
		if compte > 0 then
			if xPlayer.getMoney() >= montant then
				xPlayer.removeMoney(montant)
				MySQL.Async.fetchScalar('SELECT bank_riskedsavings.tot FROM bank_riskedsavings WHERE bank_riskedsavings.id = @livretID', 
				{
					['@livretID']   = livretID
				}, function(result)
					montajout = math.floor(result + montant)
					MySQL.Async.execute('UPDATE bank_riskedsavings set bank_riskedsavings.tot = @mont WHERE bank_riskedsavings.id = @livretID', 
					{
						['@mont']   = montajout,
						['@livretID'] = livretID
					},
					function ()
					end)
					TriggerClientEvent('esx:showNotification', xPlayer.source, "La somme de " .. montant .. "$ a été ajoutée au livret à risques, montant total : " .. montajout .. " $")
				end)
			else
				TriggerClientEvent('esx:showNotification', xPlayer.source, _U('not_enough_money'))
			end
		else
			TriggerClientEvent('esx:showNotification', xPlayer.source, _U('no_entry'))
		end
	end)
end)

RegisterServerEvent('esx_bankerjob:withdrawRiskedSavingsAccount')
AddEventHandler('esx_bankerjob:withdrawRiskedSavingsAccount', function (livretID, montant)
	local xPlayer = ESX.GetPlayerFromId(source)
	MySQL.Async.fetchScalar('SELECT COUNT(*) FROM bank_riskedsavings WHERE bank_riskedsavings.id = @livretID and bank_riskedsavings.status = "Ouvert"', 
		{
			['@livretID']   = livretID
		}, function(compte)
			if compte > 0 then
				MySQL.Async.fetchScalar('SELECT bank_riskedsavings.tot FROM bank_riskedsavings WHERE bank_riskedsavings.id = @livretID ', 
				{
					['@livretID']   = livretID
				}, function(result)
					if result >= montant then
						montretire = math.floor(result - montant)
						MySQL.Async.execute('UPDATE bank_riskedsavings set bank_riskedsavings.tot = @mont WHERE bank_riskedsavings.id = @livretID', 
						{
							['@mont']   = montretire,
							['@livretID'] = livretID
						},
						function ()
						end)
						xPlayer.addMoney(montant)
						TriggerClientEvent('esx:showNotification', xPlayer.source, "La somme de " .. montant .. "$ a été retirée du livret à risques, montant total restant : " .. montretire .. " $")
					else
						TriggerClientEvent('esx:showNotification', xPlayer.source, _U('not_enough_money_account'))
					end
				end)
			else
				TriggerClientEvent('esx:showNotification', xPlayer.source, _U('no_entry'))
			end
	end)
end)

RegisterServerEvent('esx_bankerjob:closeRiskedSavingsAccount')
AddEventHandler('esx_bankerjob:closeRiskedSavingsAccount', function (livretID)
	local xPlayer = ESX.GetPlayerFromId(source)
	MySQL.Async.fetchScalar('SELECT COUNT(*) FROM bank_riskedsavings WHERE id = @livretID and bank_riskedsavings.status = "Ouvert"', 
		{
			['@livretID']   = livretID
		}, function(compte)
			if compte > 0 then
				MySQL.Async.fetchScalar('SELECT bank_riskedsavings.tot FROM bank_riskedsavings WHERE bank_riskedsavings.id = @livretID', 
				{
					['@livretID']   = livretID
				}, function(result)
					MySQL.Async.execute('UPDATE bank_riskedsavings set bank_riskedsavings.status = "Clos", bank_riskedsavings.tot = "0" WHERE bank_riskedsavings.id = @livretID', 
					{
						['@livretID'] = livretID
					},
					function ()
					end)
					xPlayer.addMoney(result)
					TriggerClientEvent('esx:showNotification', xPlayer.source, "La somme de " .. result .. "$ a été retirée du livret à risques, dossier CLOS")
				end)
			else
				TriggerClientEvent('esx:showNotification', xPlayer.source, _U('no_entry'))
			end
	end)
end)

RegisterServerEvent('esx_bankerjob:reopenClosedRiskedSavingsAccount')
AddEventHandler('esx_bankerjob:reopenClosedRiskedSavingsAccount', function (numDoss)
	local xPlayer = ESX.GetPlayerFromId(source)
	local statut = "Ouvert"
	MySQL.Async.execute('UPDATE bank_riskedsavings SET bank_riskedsavings.status = @stat WHERE bank_riskedsavings.id = @livretID', 
	{
		['@livretID']   = numDoss,
		['@stat']   = statut
	},
	function ()
	end)
	TriggerClientEvent('esx:showNotification', xPlayer.source, "Le compte épargne " .. numDoss .. " est à nouveau ouvert !")
end)


--#########################################
--##############LENDING MONEY##############
--#########################################

ESX.RegisterServerCallback('esx_bankerjob:getLoanAccounts', function (source, cb)
	local customers = {}
	MySQL.Async.fetchAll('SELECT bank_lent_money.id, bank_lent_money.firstname, bank_lent_money.lastname, bank_lent_money.amount, bank_lent_money.rate, bank_lent_money.remainDeadlines, bank_lent_money.deadlines, bank_lent_money.amountNextDeadline, bank_lent_money.alreadyPaid, bank_lent_money.timeLeft, bank_lent_money.timeBeforeDeadline, bank_lent_money.advisorFirstname, bank_lent_money.advisorLastname, bank_lent_money.status FROM bank_lent_money ORDER BY id ASC',
	{}, function(result)
		local customers = {}
		for i=1, #result, 1 do
			table.insert(customers, {
				identifier = result[i].id,
				firstname = result[i].firstname,
				lastname = result[i].lastname,
				amount = result[i].amount,
				taux = result[i].rate,
				nbEcheances = result[i].remainDeadlines,
				echeancesTot = result[i].deadlines,
				montProchEcheance = result[i].amountNextDeadline,
				montDernEcheance = result[i].alreadyPaid,
				timeleft = result[i].timeLeft,
				timeEcheance = result[i].timeBeforeDeadline,
				giverfirstname = result[i].advisorFirstname,
				giverlastname = result[i].advisorLastname,
				status = result[i].status
			})
		end
		cb(customers)
	end)
end)

ESX.RegisterServerCallback('esx_bankerjob:getActiveLoanAccounts', function (source, cb)
	local customers = {}
	MySQL.Async.fetchAll('SELECT bank_lent_money.id, bank_lent_money.firstname, bank_lent_money.lastname, bank_lent_money.amount, bank_lent_money.rate, bank_lent_money.remainDeadlines, bank_lent_money.deadlines, bank_lent_money.amountNextDeadline, bank_lent_money.alreadyPaid, bank_lent_money.timeLeft, bank_lent_money.timeBeforeDeadline, bank_lent_money.advisorFirstname, bank_lent_money.advisorLastname, bank_lent_money.status FROM bank_lent_money WHERE bank_lent_money.status = "Ouvert" ORDER BY id ASC',
	{}, function(result)
		local customers = {}
		for i=1, #result, 1 do
			table.insert(customers, {
				identifier = result[i].id,
				firstname = result[i].firstname,
				lastname = result[i].lastname,
				amount = result[i].amount,
				taux = result[i].rate,
				nbEcheances = result[i].remainDeadlines,
				echeancesTot = result[i].deadlines,
				montProchEcheance = result[i].amountNextDeadline,
				montDernEcheance = result[i].alreadyPaid,
				timeleft = result[i].timeLeft,
				timeEcheance = result[i].timeBeforeDeadline,
				giverfirstname = result[i].advisorFirstname,
				giverlastname = result[i].advisorLastname,
				status = result[i].status
			})
		end
		cb(customers)
	end)
end)

ESX.RegisterServerCallback('esx_bankerjob:getFrozenLoanAccounts', function (source, cb)
	local customers = {}
	MySQL.Async.fetchAll('SELECT bank_lent_money.id, bank_lent_money.firstname, bank_lent_money.lastname, bank_lent_money.amount, bank_lent_money.rate, bank_lent_money.remainDeadlines, bank_lent_money.deadlines, bank_lent_money.amountNextDeadline, bank_lent_money.alreadyPaid, bank_lent_money.timeLeft, bank_lent_money.timeBeforeDeadline, bank_lent_money.advisorFirstname, bank_lent_money.advisorLastname, bank_lent_money.status FROM bank_lent_money WHERE bank_lent_money.status != "Ouvert" AND bank_lent_money.status != "Clos" ORDER BY id ASC',
	{}, function(result)
		local customers = {}
		for i=1, #result, 1 do
			table.insert(customers, {
				identifier = result[i].id,
				firstname = result[i].firstname,
				lastname = result[i].lastname,
				amount = result[i].amount,
				taux = result[i].rate,
				nbEcheances = result[i].remainDeadlines,
				echeancesTot = result[i].deadlines,
				montProchEcheance = result[i].amountNextDeadline,
				montDernEcheance = result[i].alreadyPaid,
				timeleft = result[i].timeLeft,
				timeEcheance = result[i].timeBeforeDeadline,
				giverfirstname = result[i].advisorFirstname,
				giverlastname = result[i].advisorLastname,
				status = result[i].status
			})
		end
		cb(customers)
	end)
end)

RegisterServerEvent('esx_bankerjob:closeLoan')
AddEventHandler('esx_bankerjob:closeLoan', function (numDoss)
	local xPlayer = ESX.GetPlayerFromId(source)
	local statut = "Clos"
	MySQL.Async.execute('CREATE TABLE new_table LIKE bank_lent_money; INSERT INTO new_table SELECT * FROM bank_lent_money WHERE bank_lent_money.id = @id; UPDATE bank_lent_money SET bank_lent_money.remainDeadlines = "0", bank_lent_money.amountNextDeadline = "0", bank_lent_money.alreadyPaid = (SELECT new_table.amount FROM new_table WHERE new_table.id = @id), bank_lent_money.timeLeft = "0", bank_lent_money.status = @stat WHERE bank_lent_money.id = @id; DROP TABLE new_table;', 
		{
			['@id'] = numDoss,
			['@stat']   = statut
		},
		function ()
	end)
	TriggerClientEvent('esx:showNotification', xPlayer.source, _U('entry_now_closed'))
end)


RegisterServerEvent('esx_bankerjob:reopenLoan')
AddEventHandler('esx_bankerjob:reopenLoan', function (numDoss)
	local xPlayer = ESX.GetPlayerFromId(source)
	local statut = "Ouvert"
	MySQL.Async.execute('UPDATE bank_lent_money SET bank_lent_money.status = @stat WHERE bank_lent_money.id = @mont', 
	{
		['@mont']   = numDoss,
		['@stat']   = statut
	},
	function ()
	end)
	TriggerClientEvent('esx:showNotification', xPlayer.source, _U('entry_now_reopened'))
end)

RegisterServerEvent('esx_bankerjob:avEche')
AddEventHandler('esx_bankerjob:avEche', function (numDoss)
	local xPlayer = ESX.GetPlayerFromId(source)
	MySQL.Async.execute('CREATE TABLE new_table LIKE bank_lent_money; INSERT INTO new_table SELECT * FROM bank_lent_money WHERE bank_lent_money.id = @id; UPDATE bank_lent_money SET bank_lent_money.remainDeadlines = ((SELECT new_table.remainDeadlines FROM new_table WHERE new_table.id = @id) - 1), bank_lent_money.timeLeft = (SELECT new_table.timeBeforeDeadline FROM new_table WHERE new_table.id = @id), bank_lent_money.alreadyPaid = (SELECT SUM(new_table.alreadyPaid + new_table.amountNextDeadline) FROM new_table WHERE new_table.id = @id), bank_lent_money.status = "Ouvert" WHERE bank_lent_money.id = @id; DROP TABLE new_table;', 
	{
		['@id']   = numDoss
	},
	function ()
	end)
	TriggerClientEvent('esx:showNotification', xPlayer.source, _U('deadline_advanced'))
end)

RegisterServerEvent('esx_bankerjob:freezeLoan')
AddEventHandler('esx_bankerjob:freezeLoan', function (numDoss)
	local xPlayer = ESX.GetPlayerFromId(source)
	local statut = "Gel"
	MySQL.Async.execute('UPDATE bank_lent_money SET bank_lent_money.status = @stat WHERE bank_lent_money.id = @mont', 
	{
		['@mont']   = numDoss,
		['@stat']   = statut
	},
	function ()
	end)
	TriggerClientEvent('esx:showNotification', xPlayer.source, _U('entry_now_frozen'))
end)

RegisterServerEvent('esx_bankerjob:closeLoan')
AddEventHandler('esx_bankerjob:closeLoan', function (numDoss)
	local xPlayer = ESX.GetPlayerFromId(source)
	local statut = "Clos"
	MySQL.Async.execute('UPDATE bank_lent_money SET bank_lent_money.remainDeadlines = "0", bank_lent_money.amountNextDeadline = "0", bank_lent_money.timeLeft = "0", bank_lent_money.status = @stat WHERE bank_lent_money.id = @mont', 
	{
		['@mont']   = numDoss,
		['@stat']   = statut
	},
	function ()
	end)
	TriggerClientEvent('esx:showNotification', xPlayer.source, _U('entry_now_closed'))
end)

--EFFECTUER PRET ®Benourson#9496
RegisterServerEvent('esx_bankerjob:makeLoan')
AddEventHandler('esx_bankerjob:makeLoan', function (playerId, montant, taux, nbEche, jours)
	local xPlayer = ESX.GetPlayerFromId(source)
	local xTarget = ESX.GetPlayerFromId(playerId)
	local montant2 = montant
	local montant = montant + math.floor((montant * taux) / 100) 
	local taux = taux
	local nbEche = nbEche
	local jours = jours
	local premEche = math.floor(montant/nbEche)
	TriggerEvent('esx_addonaccount:getSharedAccount', 'society_banker', function(account)
		if account.money >= montant then
			account.removeMoney(montant)
			xTarget.addMoney(montant)
			MySQL.Async.execute('INSERT INTO bank_lent_money(bank_lent_money.firstname, bank_lent_money.lastname, bank_lent_money.amount, bank_lent_money.rate, bank_lent_money.remainDeadlines, bank_lent_money.deadlines, bank_lent_money.amountNextDeadline, bank_lent_money.alreadyPaid, bank_lent_money.timeLeft, bank_lent_money.timeBeforeDeadline, bank_lent_money.clientID, bank_lent_money.advisorFirstname, bank_lent_money.advisorLastname, bank_lent_money.status) VALUES((SELECT users.firstname FROM `users` WHERE users.identifier = @playGiven), (SELECT users.lastname FROM `users` WHERE users.identifier = @playGiven), @mont, @taux, @nbEche, @nbEche, @premEche, "0", @jours, @jours, @playGiven, (SELECT users.firstname FROM `users` WHERE users.identifier = @playGiver), (SELECT users.lastname FROM `users` WHERE users.identifier = @playGiver), "Ouvert");', 
			{
				['@mont']   = montant,
				['@taux'] = taux,
				['@nbEche'] = nbEche,
				['@jours'] = jours,
				['@premEche'] = premEche,
				['@playGiven']   = xTarget.identifier,
				['@playGiver']   = xPlayer.identifier
			},
			function ()
			end)
			TriggerClientEvent('esx:showNotification', xPlayer.source, "Prêt d'une somme de " .. montant2 .. "$ alloué à " .. xTarget.name)
		else
			TriggerClientEvent('esx:showNotification', xPlayer.source, _U('not_enough_money_bank'))
		end	
	end)
end)

--#########################################
--##################CRON###################
--#########################################


function CalculateLivretASavings(d, h, m)
	if d == Config.SavingsDay then
		local asyncTasks = {}
		print(os.date ("%c") .. _U('savings_start'))
		MySQL.Async.fetchAll('SELECT bank_savings.id, bank_savings.tot, bank_savings.rate FROM bank_savings WHERE bank_savings.status = "Ouvert" ORDER BY bank_savings.id ASC',
		{}, function(result)
			for i=1, #result, 1 do
				if  result[i].rate ~= 0 and result[i].tot ~= 0 and (result[i].tot <= 1000000 or result[i].tot >= 1500000) then
					local montant = result[i].tot + math.floor(math.floor(result[i].tot * result[i].rate) / 100)
					if Config.SavingsAccountRemove then
						TriggerEvent('esx_addonaccount:getSharedAccount', 'society_banker', function(account)
							account.removeMoney(montant)
						end)
					end
					MySQL.Sync.execute('UPDATE bank_savings SET bank_savings.tot = @montant WHERE bank_savings.id = @identifiant', 
					{
						['@montant']   = montant,
						['@identifiant']   = result[i].id
					})
				end
			end
		end)
		print(os.date ("%c") .. _U('savings_end'))
	end
end
TriggerEvent('cron:runAt', Config.CRONSavingsTime[1], Config.CRONSavingsTime[2], CalculateLivretASavings)

function CalculateRiskSavings(d, h, m)
	if d == Config.SavingsDay then
		local asyncTasks = {}
		print(os.date ("%c") .. _U('risk_savings_start'))
		local taux = Config.RiskedRates
		MySQL.Async.fetchAll('SELECT bank_riskedsavings.id, bank_riskedsavings.tot FROM bank_riskedsavings WHERE bank_riskedsavings.status = "Ouvert" ORDER BY bank_riskedsavings.id ASC',
		{}, function(result)
			for i=1, #result, 1 do
				if  result[i].tot ~= 0 then
					local ac = (math.random(1,5))
					local calc = taux[ac]
					local montant = math.floor(result[i].tot * calc)
					if Config.SavingsAccountRemove then
						TriggerEvent('esx_addonaccount:getSharedAccount', 'society_banker', function(account)
							account.removeMoney(montant)
						end)
					end
					MySQL.Sync.execute('UPDATE bank_riskedsavings SET bank_riskedsavings.tot = @montant WHERE bank_riskedsavings.id = @identifiant', 
					{
						['@montant']   = montant,
						['@identifiant']   = result[i].id
					})
				end
			end
		end)
		print(os.date ("%c") .. _U('risk_savings_end'))
	end
end
TriggerEvent('cron:runAt', Config.CRONRiskedSavingsTime[1], Config.CRONRiskedSavingsTime[2], CalculateRiskSavings)

function RemoveDeadlineDay(d, h, m)
	print(os.date ("%c") .. _U('remove_deadline_start'))
	MySQL.Async.fetchAll('SELECT bank_lent_money.id, bank_lent_money.timeLeft FROM bank_lent_money WHERE bank_lent_money.status = "Ouvert" and bank_lent_money.timeLeft > "0" and bank_lent_money.remainDeadlines > "0" ORDER BY bank_lent_money.id ASC',
	{}, function(result)
		for i=1, #result, 1 do
			MySQL.Sync.execute('UPDATE bank_lent_money SET bank_lent_money.timeLeft = @tempsrestant WHERE bank_lent_money.id = @identifiant', 
			{
				['@tempsrestant']   = result[i].timeLeft - 1,
				['@identifiant']   = result[i].id
			})
		end
	end)
	print(os.date ("%c") .. _U('remove_deadline_end'))
end
TriggerEvent('cron:runAt', Config.CRONLoanDeadlineTime[1], Config.CRONLoanDeadlineTime[2], RemoveDeadlineDay)


---CHECK EXPIRATION PRET ®Benourson#9496
function CheckPretExpire(d, h, m)
	print(os.date ("%c") .. _U('checking_expired_deadline_loans_start'))
	MySQL.Async.fetchAll('SELECT bank_lent_money.id, bank_lent_money.clientID, bank_lent_money.amount, bank_lent_money.amountNextDeadline, bank_lent_money.alreadyPaid, bank_lent_money.remainDeadlines, bank_lent_money.timeBeforeDeadline, bank_lent_money.deadlines FROM bank_lent_money WHERE bank_lent_money.status = "Ouvert" AND bank_lent_money.timeLeft = "0" AND bank_lent_money.remainDeadlines > "0"',
	{}, function(result) 
		for i=1, #result, 1 do
			MySQL.Async.fetchAll('SELECT users.bank FROM users WHERE users.identifier = @clientID', 
			{['@clientID'] = result[i].clientID}, function(bankmoney) 
				local playerbank = bankmoney[1].bank 
				if result[i].remainDeadlines > 1 then
					--User can pay
					if playerbank > result[i].amountNextDeadline then
						MySQL.Async.execute('UPDATE bank_lent_money SET bank_lent_money.remainDeadlines = @remainingDeadlines, bank_lent_money.alreadyPaid = @alreadyPaid, bank_lent_money.timeLeft = @timeLeft WHERE bank_lent_money.id = @identifiant', 
						{
							['@identifiant']   			= result[i].id,
							['@remainingDeadlines']   	= result[i].remainDeadlines - 1,
							['@alreadyPaid']   			= result[i].alreadyPaid + result[i].amountNextDeadline,
							['@timeLeft']   			= result[i].timeBeforeDeadline	
						})
						MySQL.Async.execute('UPDATE users SET users.bank = @amount WHERE users.identifier = @clientID', 
						{
							['@amount']   				= playerbank - result[i].amountNextDeadline,
							['@clientID']   				= result[i].clientID	
						})
						TriggerEvent('esx_addonaccount:getSharedAccount', 'society_banker', function(account)
								account.addMoney(result[i].amountNextDeadline)
						end)
					-- User cannot pay	
					else
						MySQL.Async.execute('UPDATE bank_lent_money SET bank_lent_money.status = @status WHERE bank_lent_money.id = @identifiant', 
						{
							['@identifiant']   			= result[i].id,
							['@status']					= _U('unpayed_freeze') .. os.date ("%c")
						})
					end
				else
					--User can pay
					if playerbank > result[i].amountNextDeadline then
						MySQL.Async.execute('UPDATE bank_lent_money SET bank_lent_money.remainDeadlines = 0, bank_lent_money.alreadyPaid = @alreadyPaid, bank_lent_money.timeLeft = 0, bank_lent_money.status = "Clos" WHERE bank_lent_money.id = @identifiant', 
						{
							['@identifiant']   			= result[i].id,
							['@alreadyPaid']   			= result[i].alreadyPaid + result[i].amountNextDeadline
						})
						MySQL.Async.execute('UPDATE users SET users.bank = @amount WHERE users.identifier = @clientID', 
						{
							['@amount']   				= playerbank - result[i].amountNextDeadline,
							['@clientID']   				= result[i].clientID	
						})
						TriggerEvent('esx_addonaccount:getSharedAccount', 'society_banker', function(account)
							account.addMoney(result[i].amountNextDeadline)
						end)
					-- User cannot pay	
					else
						MySQL.Async.execute('UPDATE bank_lent_money SET bank_lent_money.status = @status WHERE bank_lent_money.id = @identifiant', 
						{
							['@identifiant']   			= result[i].id,
							['@status']					= _U('unpayed_freeze') .. os.date ("%c")
						})
					end
				end
			end)
		end
	end)
	print(os.date ("%c") .. _U('checking_expired_deadline_loans_end'))
end
TriggerEvent('cron:runAt', Config.CRONLoanTime[1], Config.CRONLoanTime[2], CheckPretExpire)




--#########################################
--#################ITEMS###################
--#########################################

ESX.RegisterServerCallback('esx_bankerjob:getWeapons', function(source, cb)
	TriggerEvent('esx_datastore:getSharedDataStore', 'society_banker', function(store)
		local weapons = store.get('weapons')
		if weapons == nil then
			weapons = {}
		end
		cb(weapons)
	end)
end)

ESX.RegisterServerCallback('esx_bankerjob:addWeapon', function(source, cb, weaponName, removeWeapon)
	local xPlayer = ESX.GetPlayerFromId(source)
	if removeWeapon then
		xPlayer.removeWeapon(weaponName)
	end
	TriggerEvent('esx_datastore:getSharedDataStore', 'society_banker', function(store)
		local weapons = store.get('weapons')
		if weapons == nil then
			weapons = {}
		end
		local foundWeapon = false
		for i=1, #weapons, 1 do
			if weapons[i].name == weaponName then
				weapons[i].count = weapons[i].count + 1
				foundWeapon = true
				break
			end
		end
		if not foundWeapon then
			table.insert(weapons, {
				name  = weaponName,
				count = 1
			})
		end
		store.set('weapons', weapons)
		cb()
	end)
end)

ESX.RegisterServerCallback('esx_bankerjob:removeWeapon', function(source, cb, weaponName)
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.addWeapon(weaponName, 200)
	TriggerEvent('esx_datastore:getSharedDataStore', 'society_banker', function(store)
		local weapons = store.get('weapons')
		if weapons == nil then
			weapons = {}
		end
		local foundWeapon = false
		for i=1, #weapons, 1 do
			if weapons[i].name == weaponName then
				weapons[i].count = (weapons[i].count > 0 and weapons[i].count - 1 or 0)
				foundWeapon = true
				break
			end
		end
		if not foundWeapon then
			table.insert(weapons, {
				name  = weaponName,
				count = 0
			})
		end
		store.set('weapons', weapons)
		cb()
	end)
end)

RegisterServerEvent('esx_bankerjob:getStockItem')
AddEventHandler('esx_bankerjob:getStockItem', function(itemName, count)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local sourceItem = xPlayer.getInventoryItem(itemName)
	TriggerEvent('esx_addoninventory:getSharedInventory', 'society_banker', function(inventory)
		local inventoryItem = inventory.getItem(itemName)
		-- is there enough in the society?
		if count > 0 and inventoryItem.count >= count then
			-- can the player carry the said amount of x item?
			if sourceItem.limit ~= -1 and (sourceItem.count + count) > sourceItem.limit then
				TriggerClientEvent('esx:showNotification', _source, _U('quantity_invalid'))
			else
				inventory.removeItem(itemName, count)
				xPlayer.addInventoryItem(itemName, count)
				TriggerClientEvent('esx:showNotification', _source, _U('have_withdrawn', count, inventoryItem.label))
			end
		else
			TriggerClientEvent('esx:showNotification', _source, _U('quantity_invalid'))
		end
	end)
end)

ESX.RegisterServerCallback('esx_bankerjob:getStockItems', function(source, cb)
	TriggerEvent('esx_addoninventory:getSharedInventory', 'society_banker', function(inventory)
		cb(inventory.items)
	end)
end)

RegisterServerEvent('esx_bankerjob:putStockItems')
AddEventHandler('esx_bankerjob:putStockItems', function(itemName, count)
	local xPlayer = ESX.GetPlayerFromId(source)
	local sourceItem = xPlayer.getInventoryItem(itemName)
	TriggerEvent('esx_addoninventory:getSharedInventory', 'society_banker', function(inventory)
		local inventoryItem = inventory.getItem(itemName)
		-- does the player have enough of the item?
		if sourceItem.count >= count and count > 0 then
			xPlayer.removeInventoryItem(itemName, count)
			inventory.addItem(itemName, count)
			TriggerClientEvent('esx:showNotification', xPlayer.source, _U('have_deposited', count, inventoryItem.label))
		else
			TriggerClientEvent('esx:showNotification', xPlayer.source, _U('quantity_invalid'))
		end
	end)
end)

ESX.RegisterServerCallback('esx_bankerjob:getPlayerInventory', function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)
	local items   = xPlayer.inventory
	cb( { items = items } )
end)
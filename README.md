# ESX Banker Job Upgraded [esx_bankerjob]

New Banker Job with functionnalities such as loans, savings with custom rates, risked savings, inventory and so on...

![ESX Banker Job Upgraded](https://repository-images.githubusercontent.com/346621827/078ab680-825e-11eb-8284-e0ad3d766ef1)

***

## [FEATURES]


* **Make loans and manage them** from the office inside the Pacific Standard Bank
  * **Powerful loan attribution system** : Define the amount given, the rate, the amount of deadlines, the time between deadlines
  * **Automatic loan management system** : every morning at defined time in config.lua two cron tasks run :
    * 1. Countdown of the time remaining before a player must repay part of his loan
    * 2. Automatic payment of a deadline if the user has enough money on his bank account otherwise the account is frozen
  * **View all | the active | the frozen loans and manage them**

* **Open savings accounts** with a custom rate defined in percentages (1 - 100)
  * **View** the active and closed accounts and manage them
  * **Automatic savings system** : once a week on the day defined in config.lua a cron task runs calculating the interests
  * **Choose** if the money is generated or removed from the company bank account
 
* **Open risked savings accounts** 
  * **View** the active and closed accounts and manage them
  * **Automatic savings system** : once a week on the day defined in config.lua a cron task runs calculating the interests
    * **Custom rates** : a custom rate that can be defined in the config.lua file is randomly chosen and applied to a risked savings account... living the life on the edge?
  * **Choose** if the money is generated or removed from the company bank account


***

## [REQUIREMENTS]


* es_extended (v1 OR v2)
  * es_extended v1 : https://github.com/esx-framework/es_extended/tree/v1-final
  * es_extended v2 : https://github.com/esx-framework/es_extended
* esx_society      : https://github.com/esx-framework/esx_society
* async            : https://github.com/esx-framework/async
* mysql-async      : https://github.com/brouznouf/fivem-mysql-async
* cron             : https://github.com/esx-framework/cron

***

## [INSTALLATION]

1. CD in your resources/[folderWhereYouWantTheScriptToBe]
 
2. Clone the repository
``` git
git clone https://github.com/BenoursonJ/ESX-Banker-Job-Upgraded esx_bankerjob
```
3. Import esx_bankerjob.sql in your database

4. Configure the config.lua file (do not forget to modify the authorized vehicles)
 
5. Modify the multiple "TriggerClientEvent('esx:showNotification" in server.lua to translate them to your liking.

6. Add this in your server.cfg after cron, async, mysql-async and esx_society:

``` lua
ensure esx_bankerjob
```

***

## [CONFIG.LUA EXPLAINED]
* **Config.DrawDistance** | Maximum distance from which the markers can be seen.
* **Config.Locale**       | Text language (currently supported: fr and en).
* **Config.CompanyPlate** | Prefix that will be displayed on the number plate of company cars.
* **Config.RiskedRates**	| Rates that can be defined in the array for the risked savings accounts. Value is multiplied with the total money on the account.
* **Config.SavingsAccountRemove** | True or False. If true, money removed from the company bank account, false, money is generated.
* **Config.SavingsDay**	  | Day on which to do the interests on the savings and risked savings accounts.
* **Config.CRONSavingsTime** | Time {HH, mm} at which the Savings task is to be executed.
* **Config.CRONRiskedSavingsTime** | Time {HH, mm} at which the Risked Savings task is to be executed.
* **Config.CRONLoanDeadlineTime** | Time {HH, mm} at which the Deadline Countdown task is to be executed.
* **Config.CRONLoanTime** | Time {HH, mm} at which the deadline payment task is to be executed.

* **Config.Zones** | Array listing the zones that will be drawn:
  * **ZoneName** | Marker name
    * **Coords** | Marker position
    * **Size** | Marker size
    * **Color** | Marker colour
    * **Type** | Marker Type (-1 = hidden | 1 = displayed)
    * **Heading** | Angle used as the direction when spawning cars

* **Config.AuthorizedVehicles** | List of vehicles that can be spawned
  * **model** | Vehicle model name (not the hash)
  * **label** | Display named that is used in the garage menu
  * **auth**  | Authorization level (banker = employee, boss = ceo)


***

## [TUTORIALS]

In need of info and troubleshooting tips ?
Head to the Wiki => [HERE](https://github.com/BenoursonJ/esx_bankerjob/wiki)

***

# Legal
### License
esx_bankerjob - Fivem script for es_extended. Greatly improved banker job.

Copyright (C) 2021 Benourson#9496

This program Is free software: you can redistribute it And/Or modify it under the terms Of the GNU General Public License As published by the Free Software Foundation, either version 3 Of the License, Or (at your option) any later version.

This program Is distributed In the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty Of MERCHANTABILITY Or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License For more details.

You should have received a copy Of the GNU General Public License along with this program. If Not, see http://www.gnu.org/licenses/.

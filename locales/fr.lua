Locales['fr'] = {
  --######################
  --####MENU ITEMS########
  --######################
  ['savingsMenuItem']                                 = '💳 Livrets A',
  ['openSavingsMenuItem']                             = "👛 Ouvrir un Livret A",
  ['riskedSavingsMenuItem']                           = "📋 Livrets à Risques",
  ['openRiskedSavingsMenuItem']                       = "💸 Ouvrir un Livret à Risques",
  ['loanMenuItem']                                    = "📁 Dossiers de Prêts",
  ['activeLoanMenuItem']                              = "📁 Dossiers de Prêts Actifs",
  ['frozenLoanMenuItem']                              = "📁 Dossiers de Prêts Gelés",
  ['doLoanMenuItem']                                  = "💰 Effectuer un prêt",
  ['billingMenuItem']                                 = "📝 Facturation",
  ['closedSavingsMenuItem']                           = "⛔️ Livrets A Clos",
  ['closedRiskedSavingsMenuItem']                     = "⛔️ Livrets à Risques Clos",
  ['companyManagementMenuItem']                       = "💎 Gestion d'Entreprise",
  ['separatorMenuItem']                               = "- - - - -",


  --######################
  --####MENU NAME#########
  --######################
  ['bank']                                            = '💎 Banque 💎',


  --##############################
  --#########TABLE ITEMS##########
  --##############################
  ['account_num']                                     = 'N° Compte',
  ['client']                                          = 'Client',
  ['rate']                                            = 'Taux',
  ['account_total']                                   = 'Solde Compte',
  ['banker']                                          = 'Conseiller',
  ['actions']                                         = 'Actions',
  ['total_repay_amount']                              = 'Montant à Rembourser',
  ['next_time_repay_amount']                          = 'Montant Prochaine Echéance',
  ['remaining_deadline_count']                        = 'Echéances Restantes',
  ['deadline_count']                                  = 'Echéances Originelles',
  ['already_repayed_amount']                          = 'Montant déjà remboursé',
  ['remaining_time']                                  = 'Temps restant',
  ['time_between_deadlines']                          = 'Jours entre echéances',
  ['status']                                          = 'Statut',



  --######################
  --####TABLE Actions#####
  --######################
  ['press_input_context_to_open_menu']                = 'Appuyez sur [E] pour ouvrir le menu',
  ['deposit']                                         = 'Dépôt',
  ['withdraw']                                        = 'Retrait',
  ['change_rate']                                     = 'Modification Taux',
  ['close']                                           = 'Fermeture',
  ['reopen']                                          = 'Ré-Ouverture',
  ['freeze']                                          = 'Geler',
  ['advance_deadline']                                = 'Avancer Echéance',

  --######################
  --#####MENU Actions#####
  --######################
  ['amount']                                          = 'Montant',
  ['invalid_amount']                                  = '❌ Montant Invalide (1 - 10 000 000)',
  ['invalid_rate']                                    = '❌ Taux Invalide (1 - 250)',
  ['invalid_number']                                  = '❌ Nombre Invalide (1 - 20)',  
  ['client_name']                                     = 'Prénom Client',
  ['client_surname']                                  = 'Nom Client',
  ['invalid_name']                                    = '❌ Prénom Invalide',
  ['invalid_surname']                                 = '❌ Nom de Famille Invalide',
  ['banker_name']                                     = 'Prénom Conseiller',
  ['banker_surname']                                  = 'Nom Conseiller',
  ['deadline_number']                                 = "Nombre d'échéances",
  ['no_player']                                       = '❌ Personne à proximité',

  --######################
  --#########CARS#########
  --######################
  ['press_input_context_to_park_car']                 = 'Appuyez sur [E] pour garer le véhicule',
  ['press_input_context_to_spawn_car']                = '[E] Véhicule de Fonction - Banquier',
  ['garage']                                          = 'Garage - Banque',
  ['blocked_spawn_point']                             = '❌ La place de parking est encombrée',
  ['not_boss']                                        = "❌ Vous n'êtes pas PDG.",
  ['not_in_auth_car']                                 = "❌ Vous n'êtes pas en véhicule de fonction.",

  --######################
  --########PHONE#########
  --######################
  ['phone_receive']                                   = 'Citoyen',
  ['phone_label']                                     = 'Banque',

  --######################
  --#Server Notifications#
  --######################
  ['not_enough_money']                                = "❌ Vous n'avez pas assez d'argent sur vous !",
  ['not_enough_money_bank']                           = "❌ Il n'y a pas assez de fonds dans le coffre de la banque !",
  ['not_enough_money_account']                        = "❌ Vous n'avez pas assez d'argent sur vous !",
  ['no_entry']                                        = "❌ Le dossier n'existe pas ou est clos !",
  ['entry_now_closed']                                = "✔️ Dossier mis à jour, il est désormais clos !",
  ['entry_now_frozen']                                = "✔️ Dossier mis à jour, il est désormais gelé !",
  ['entry_now_reopened']                              = "✔️ Dossier mis à jour, il est désormais rouvert !",
  ['deadline_advanced']                               = "✔️ L'échéance a été avancée d'une fois !",

  --######################
  --########CRON##########
  --######################
  ['savings_start']                                    = ' CRON DEBUT : Calcul des intérêts',
  ['savings_end']                                      = ' CRON TERMINE : Calcul des intérêts',
  ['risk_savings_start']                               = ' CRON DEBUT: Calcul des intérêts risqués',
  ['risk_savings_end']                                 = ' CRON TERMINE: Calcul des intérêts risqués',
  ['remove_deadline_start']                            = " CRON DEBUT: Décompte d'un jour entre échéances pour chaque dossier de prêt ouvert",
  ['remove_deadline_end']                              = " CRON TERMINE: Décompte d'un jour entre échéances pour chaque dossier de prêt ouvert",
  ['checking_expired_deadline_loans_start']            = ' CRON DEBUT: Paiement des échéances pour les dossiers arrivés à date',
  ['checking_expired_deadline_loans_end']              = ' CRON TERMINE: Paiement des échéances pour les dossiers arrivés à date',
  ['unpayed_freeze']                                   = "Gel - Impayé le ",

  --######################
  --#######STOCKS#########
  --######################
  ['bank_stocks_title']                                  = "🧳 Armoire - Banque 🧳",
  ['get_weapon']                                         = '🔫 Récupérer une arme',
  ['put_weapon']                                         = '🔫 Déposer une arme',
  ['take_inventory']                                     = '📄 Récupérer un objet',
  ['put_inventory']                                      = '📄 Déposer un objet',
  ['take_weapon_action']                                 = "✔️ Armurerie - Prendre une Arme",
  ['put_weapon_action']                                  = "❌ Armurerie - Déposer une Arme",
  ['quantity']                                           = "🔢 Quantité",
  ['quantity_invalid']                                   = "❌ Quantité invalide !",
  ['have_deposited']                                     = "✔️ Vous avez déposé des objets !",
  ['have_withdrawn']                                     = "✔️ Vous avez récupéré des objets !",
  ['inventory']                                          = "🎒 Sac à dos",
}


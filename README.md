
https://forum.gta-chronicles.com/index.php?forums/dev-features/

# GAMEMODE :

## **SYSTÈME D'INTRODUCTION AU SERVEUR :**

Revoir l'introduction lors de l'arrivée d'un nouveau joueur + tutoriel.

## **SYSTÈME ÉCONOMIQUE DU SERVEUR :**

## **SYSTÈME DE PANNEAUX PUBLICITAIRES :**

## **SYSTÈME DE PAYDAY :**

## **SYSTÈME D'ATM :**

Les atms doivent disposer d'une quantité limitée d'argent. // Qui peut être chargé de les remplir ?

## **SYSTÈME DE BANQUE :**

## **SYSTÈME D'INVENTAIRE :**

## **SYSTÈME D'ITEMS :**

## **SYSTÈME DE TÉLÉPHONE :**

## **SYSTÈME DE CABINES TÉLÉPHONIQUES :**

## **SYSTÈME DE PERMIS DE CONDUIRE (AUTO, AVION) :**

## **SYSTÈME DE MAISON :**

Chaque joueur peut disposer de 2 maisons.

## **SYSTÈME D'ENTREPRISES :**

Toutes les entreprises peuvent recruter, licencier, changer de rang, changer le nom des rangs (Nombre de rangs : 10), disposer d'une caisse job, fixer le salaire par payday (déduit de la caisse job), affecter des véhicules à l'entreprise, changer le skin en fonction du rang.

Liste des entreprises : 24/7 (1), armurerie, station-essence (3), concessionnaire, banque, taxi, location de voitures/motos, location de bateaux, location d'avions, mécanicien, camionneur, éboueur, presse.

- ### SYSTÈME DE VENTE :

Toutes les entreprises ayant un système de vente (24/7, armurerie, etc.) peuvent :
Soit acheter un "actor" afin que l'entreprise tourne 24h/24 (définir un mode de financement)
Soit recruter un joueur afin de jouer le rp vendeur (définir des avantages par rapport à l'actor)

- ### 3. STATION-ESSENCE :
L'essence doit être transporté par un camionneur jusqu'à la station essence.
L'essence est acheté à prix fixe par l'entreprise.
L'entreprise peut fixer un prix de vente.

## SYSTÈME D'ARMES :

### DÉGATS DES ARMES :

## SYSTÈME DE DROGUES :

## SYSTÈME DE VÉHICULES :
Dès lors d'un véhicule est en très mauvais état, il est impossible de la démarrer et il est nécessaire de faire appel à un mécanicien. (Permettre à un admin de réparer le véhicule)

Un joueur peut disposer de 3 véhicules au maximum (voiture/moto/bateau/avion)

2 concessionnaires maximum dans la ville (= sous forme de business) : le concessionnaire achète les véhicules à un tarif fixé dans le script ; il peut les revendre au prix qu'il le souhaite.

## SYSTÈME DE JOBS :
Fermier

-- GÉNÉRAL : Créer un système de caisses pour les jobs ayant un leader.

-- TAXI : Permettre au gouvernement de /vendrelicencetaxi. L'argent rentre dans la caisse de la faction. Le montant de la licence doit pouvoir être dynamique (gestion par le leader)

## SYSTÈME DE VÊTEMENTS :

## SYSTÈME DE TÉLÉPHONE :

## SYSTÈME DE FACTIONS LÉGALES :

**Éléments généraux :** Toutes les factions légales peuvent recruter, licencier, changer de rang, changer le nom des rangs (Nombre de rangs : 10), disposer d'une caisse job, fixer le salaire par payday (déduit de la caisse faction légale), affecter des véhicules à l'entreprise, changer le skin en fonction du rang. Toutes les amendes iront dans la caisse de la mairie.

**Liste des factions : LSCH, LSPD, LSFD, LSSD, FBI, DOJ**

### Los Santos City Hall (Mairie) :

### Los Santos Police Department :

**Éléments généraux :** Créer deux factions distinctes (cf CMLV) avec deux postes différents.

#### LISTE DES COMMANDES : 

|  Commande |  Retour | Commentaires |
| ------------ | ------------ | ------------ |
| /jmembres  | Affiche le Prénom, le nom, le nom du rang et le message lié à /occupation.  | |
|  /skin | Permet de mettre son skin principal si l'on est en /duty.  | |
| /amendej  [ID/PartieDuNom/NumeroInconnu] [prix] [motif] |  Permet de mettre une amende à un joueur. Il est possible pour le joueur de ne pas payer immédiatement. | Log LSPD | 
| /retirerpermis [ID/PartieDuNom/NumeroInconnu] [type de permis]  [motif]  | Permet de retirer le permis d'un joueur.  | Log LSPD
| /r  | Radio LSPD interne.  | Log LSPD |
| /d   |  Radio inter-services (toutes les factions légales) | Log LSPD |
|  /menotter [ID/PartieDuNom/NumeroInconnu] | Permet de menotter un joueur.  | |
|  /herse | Déposer une herse au sol et lui attribue un ID. La herse crève les pneus des véhicules.  | |
|  /retirerherse [ID] | Supprimer la herse en fonction de son ID.  | |
|  /retirerherses | Supprime toutes les herses.  | |
| /listeherses  |  Liste toutes les herses avec leurs IDs. | |
|  /jgov [message] | Affiche un message à tous les joueurs sur le serveur.  | Log LSPD |
|  /megaphone [message] | Affiche un message dans un périmètre élargi.  | |
|  /equipement | Affiche une liste d'armes et de gilets (léger/lourd) qu'il est possible de prendre.   | Les armes sont en quantité limitée. Elles doivent être livrées par les camionneurs. LOG LSPD à chaque retrait d'arme.|
| /barrage [id du barrage]  |  Déposer un barrage et lui attribue un ID. | |
|  /retirerbarrage [ID] | Supprimer le barrage en fonction de son ID.  | |
|  /retirerbarrages |  Supprimer tous les barrages. | |
| /listebarrages  |  Liste tous les barrages avec leurs IDs. | |
|  /mettresabot [motif] |  Déposer un sabot sur le véhicule à côté du joueur. | Log LSPD |
| /retirersabot |  Retirer le sabot sur le véhicule à côté du joueur. | Log LSPD |
| /amendev [ID du véhicule] [prix] [motif]  |  Permet de mettre une amende à un véhicule. Il est possible pour le joueur de ne pas payer immédiatement. | Log LSPD|
|  /juger [ID/PartieDuNom/NumeroInconnu] [peine (minutes)] [amende] [liste infractions] | Permet de mettre un joueur en prison.  | Log LSPD |
|  /dp [ID/PartieDuNom/NumeroInconnu] | Permet de mettre un joueur en détention provisoire.  |  Log LSPD |
| /bracelet [ID/PartieDuNom/NumeroInconnu] [motif]  |  Permet de mettre un bracelet électronique à un joueur. |  Log LSPD |
| /listebracelets :  | Permet d'afficher les joueurs connectés (Prénom, Nom, ID du joueur) qui ont un bracelet électronique ainsi que le motif.  | |
|  /localiserbracelet [ID du joueur] | Permet de localiser un joueur qui a un bracelet électronique en fonction de son ID.  | Ne fonctionne que pour les joueurs qui ont un bracelet électronique. |
|  /forcerporte | Force la porte d'entrée du commerce/de la maison.  | |
|  /baliseurg | Lance une balise d'urgence.  | Un message est envoyé à la radio interne. La localisation du joueur est affiché en temps réel.|
|  /stopbaliseurg | Désactive la balise d'urgence.  | |

 /jfreq, /vehiculedesc, /traceur, /detruire, /meec (/miseecoute), /bdd, /dashcam, /dashcamoff, /listevehlspd, /camera, /cameraoff, /taser, /beanbag, /affaires, /enquete, /classerenquete, /checkbalistique,, /listegav, /wanted, /checkwanted, /retirerwanted, /prendregilet, /chargeur, /noflash, /micro

### Los Santos Fire Department : 

### Los Santos Sheriff Department :

### Federal Bureau of Investigation :

### Department of Justice :

## SYSTÈME DE FACTIONS ILLÉGALES :

## SYSTÈME DE MORT :

## SYSTÈME DE SPORT :

## SYSTÈME DE POUBELLES :

## SYSTÈME DE BRAQUAGES :

## SYSTÈME DE GARAGES :

## TEXTDRAWS :

### COMPTEUR VÉHICULE :

## SYSTÈME DE PACKS OOC :

+ Pack véhicules : Permet d'acheter 2 véhicules supplémentaires (voiture/moto/bateau/avion).
+ Pack maison : Permet d'acheter 1 maison supplémentaire.

# MAPPINGS : 

Liste des lieux :

# UCP :

Avoir un MDC pour les forces de l'ordre.


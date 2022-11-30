
https://forum.gta-chronicles.com/index.php?forums/dev-features/

# GAMEMODE :

**Éléments généraux** :
2 personnages maximum par compte.

## **SYSTÈME D'INTRODUCTION AU SERVEUR :**

Reproduire l'introduction du jeu solo :
1. Spawn dans un avion
2. Caméra extérieure de l'avion qui se pose à LS
3. Spawn à l'aéroport (intérieur)
4. Emmener le joueur vers la sortie de l'aéroport
5. Visite des principaux lieux de la Ville avec un bot taxi (obligatoire)

## **SYSTÈME DE COMMANDES (AUTRES QUE CELLES DÉCRITES PLUS BAS) :**

| Commande  | Description  | Commentaire  |
| ------------ | ------------ | ------------ |
| /aide  | /propriete aide ; /voiture aide ; /entreprise aide ; /factionl aide ; /factioni aide ; /banque aide ; /job aide ; /telephone aide ; /garage aide  |   |
| /propriete aide  |   |   |
|  /voiture aide |   |   |
|  /entreprise aide |   |   |
| /factionl aide  |   |   |
| /factioni aide  |   |   |
| /banque aide  |   |   |
| /job aide  |   |   |
|  /telephone aide |   |   |
| /garage aide  |   |   |
|   |   |   |
|   |   |   |


## **SYSTÈME DE PANNEAUX PUBLICITAIRES :**

https://nsa40.casimages.com/img/2019/03/21/190321070033239051.png

Les panneaux publicitaires sont gérés par les journalistes de la Ville. Ils doivent être en nombre limité (entre 4 ou 6). Chaque publicité a une durée de 48 heures.

Chaque panneau publicitaire est identifié par son ID.

Chaque publicité est retransmise chaque heure sur un channel Discord.

## **SYSTÈME DE PAYDAY :**

## **SYSTÈME D'ATM :**

**Éléments généraux :**
Les ATMs doivent être suffisamment nombreux en Ville et doivent être placés à des endroits stratégiques. Ils disposent d'une quantité limitée d'argent et sont réapprovisionnés par l'entreprise "banque". Dès lors qu'un ATM dispose d'une somme inférieure à 5,000$, une notification est envoyée au leader (LOG LEADER BANQUE) - par le biais de l'UCP ?

| Commande  |Description   | Commentaires  |
| ------------ | ------------ | ------------ |
| /atm consulter  |  Consulter le solde bancaire. |   |
|  /atm retirer |  Retirer de l'argent.  | Maximum : xxxx$  |
| /atm deposer  | Déposer de l'argent.  | Maximum : xxxx$  |
|   |   |   |

## **SYSTÈME DE BANQUE :**

**Éléments généraux** :

La caisse de la banque est alimentée par les dépôts de fonds des joueurs. Avec cet argent, la banque peut réaliser des prêts avec intérêts auprès de joueurs.

Pour limiter la banque route, elle doit disposer d'une réserve de 70%.

Par exemple :
Les fonds sont de 100,000$.
La banque ne peut que prêter 30,000$.
En prêtant 30,000$ à 5% d'intérêts sur 1 mois, la banque réalisera un profit de 6,000$ (1500$ d'intérêts par semaine).

## **SYSTÈME D'INVENTAIRE :**

## **SYSTÈME D'ITEMS :**

## **SYSTÈME DE TÉLÉPHONE :**

## **SYSTÈME DE CABINES TÉLÉPHONIQUES :**

## **SYSTÈME DE PERMIS DE CONDUIRE (AUTO, AVION) :**

## **SYSTÈME DE PROPRIÉTÉS :**

**Éléments généraux :** 
Chaque joueur peut disposer de 2 propriétés.

| Commande  | Description  |  Commentaires |
| ------------ | ------------ | ------------ |
| /propriete liste  |  Liste l'ensemble des propriétés + leur ID. |   |
| /propriete acheter  | Acheter une maison.  |   |
| /propriete mettrelocation [ID de la propriété] [prix] |  Mettre en location sa propriété en fonction de son ID avec un montant fixé. |  Cette commande peut aussi être utilisée pour changer le prix de la location. |
| /propriete louer  | Louer une propriété.  |   |
|  /propriete vendre [ID de la propriété] [prix] | Mettre sa propriété en vente en fonction de son ID avec un montant fixé.  |   |
| /propriete expulser [ID de la propriété] |  Expulser un locataire de sa propriété. |  Le joueur peut être connecté ou pas. |
| /propriete habiter [ID de la propriété] | Changer de spawn.  | Il n'est possible d'habiter dans la propriété que si elle n'est pas louée.  |
|  /propriete consulter [ID de la propriété] | Consulter l'inventaire de la propriété.  | N'est possible que pour les propriétés non louées. |
|  /propriete arme deposer | Déposer une arme dans l'inventaire maison.  |  N'est possible que lorsque le joueur est dans la propriété et qu'elle n'est pas louée. |
|  /propriete arme retirer |  Retirer une arme de l'inventaire maison. | N'est possible que lorsque le joueur est dans la propriété et qu'elle n'est pas louée  |
|  /propriete drogue deposer [type de drogue] [quantité] | Déposer de la drogue dans l'inventaire maison.  |  N'est possible que lorsque le joueur est dans la propriété et qu'elle n'est pas louée. |
|  /propriete drogue deposer [type de drogue] [quantité] | Déposer de la drogue dans l'inventaire maison.  |  N'est possible que lorsque le joueur est dans la propriété et qu'elle n'est pas louée. |
|  /propriete mobilier |   |   |
|  /propriete sonner | Sonner depuis l'extérieur.  |   |
|  /propriete arme deposer |   |   |

/pdo, /visiter");
/furniture, /expulserinvite, /quitterhouse, /deposernourriture, /manger, /verifporte");
HOUSE: {FFFFFF}/housecontrebande");

## SYSTÈME D'ARMES :

### DÉGATS DES ARMES :

## SYSTÈME DE DROGUES :

## SYSTÈME DE VÉHICULES :
Dès lors d'un véhicule est en très mauvais état, il est impossible de la démarrer et il est nécessaire de faire appel à un mécanicien. (Permettre à un admin de réparer le véhicule)

Un joueur peut disposer de 3 véhicules au maximum (voiture/moto/bateau/avion)

2 concessionnaires maximum dans la ville (= sous forme de business) : le concessionnaire achète les véhicules à un tarif fixé dans le script ; il peut les revendre au prix qu'il le souhaite.

## **SYSTÈME D'ENTREPRISES :**

**Éléments généraux :**
Les entreprises fonctionnent sur le modèle traditionnel des factions légales.

**Liste des commandes :**

|  Commande |  Retour | Commentaires |
| ------------ | ------------ | ------------ |
| /entreprise recruter [ID/PartieDuNom/NumeroInconnu] | Inviter un joueur dans l'entreprise.  | Accessible au R10/R9/R8. / Log LEADERS_ENTREPRISES |
|  /entreprise virer [ID/PartieDuNom/NumeroInconnu] | Exclure un joueur de l'entreprise.  |   Accessible au R10/R9/R8. / Log LEADERS_ENTREPRISES |
| /entreprise changerrang [ID/PartieDuNom/NumeroInconnu]  |  Changer le rang d'un joueur. |  10 rangs. / Accessible au R10/R9/R8. / Log LEADERS_ENTREPRISES |
| /entreprise changernomrang [ID] | Changer le nom d'un rang de l'entreprise.  | ID 1 = Rang 1 et ID 10 = Rang 10 / Accessible au R10/R9/R8. / Log LEADERS_ENTREPRISES  |
|  /entreprise voircaisse |  Voir le montant disponible dans la caisse entreprise. | Accessible au R10/R9/R8.  |
| /entreprise retirercaisse [Montant] | Retirer un montant de la caisse entreprise.  | Accessible au R10/R9/R8. / Log LEADERS_ENTREPRISES  |
| /entreprise deposercaisse [Montant] | Déposer un montant dans la caisse entreprise.  | Accessible au R10/R9/R8. / Log LEADERS_ENTREPRISES  |
|  /entreprise salaire [ID du rang] [Montant] | Fixer le salaire par payday pour les joueurs en service. | Accessible au R10/R9/R8. / Déduire les salaires de la caisse faction / Log LEADERS_ENTREPRISES  |
|  /entreprise vehicule | Affecter le véhicule dans lequel se trouve le joueur à l'entreprise.  | Accessible au R10/R9/R8. / Log LEADERS_ENTREPRISES  |
| /entreprise retraitvehicule  | Désaffecter le véhicule de l'entreprise dans lequel se trouve le joueur et le mettre propriétaire.  | Accessible au R10/R9/R8. / Log LEADERS_ENTREPRISES  |
| /entreprise changerskin [ID du rang] [ID du skin] | Changer le skin en fonction du rang lorsque les joueurs sont en service.  | Accessible au R10/R9/R8. / Log LEADERS_ENTREPRISES  |

**Liste des entreprises :** 24/7, armurerie, station-essence, concessionnaire, banque, taxi, location de voitures/motos, location de bateaux, location d'avions, mécanicien, camionneur, éboueur, presse.

- ### SYSTÈME DE VENTE :

Toutes les entreprises ayant un système de vente (24/7, armurerie, etc.) peuvent :
Soit acheter un "actor" afin que l'entreprise tourne 24h/24 (définir un mode de financement)
Soit recruter un joueur afin de jouer le rp vendeur (définir des avantages par rapport à l'actor)

- ### 3. STATION-ESSENCE :
L'essence doit être transporté par un camionneur jusqu'à la station essence.
L'essence est acheté à prix fixe par l'entreprise.
L'entreprise peut fixer un prix de vente.

## SYSTÈME DE JOBS :

**Éléments généraux :** 
Il existe deux types de jobs.

1. Jobs autonomes : Les jobs autonomes permettent de trouver rapidement un travail et de le réaliser en toute autonomie.
2. Jobs non autonomes : Les jobs non autonomes sont les jobs qui nécessitent d'être en interaction avec d'autres joueurs.

**Liste des jobs :** 

1. Jobs autonomes : Fermier, 
2. Jobs non autonomes : 24/7, armurerie, station-essence, concessionnaire, banque, taxi, location de voitures/motos, location de bateaux, location d'avions, mécanicien, camionneur, éboueur, presse.

## SYSTÈME DE VÊTEMENTS :

## SYSTÈME DE TÉLÉPHONE :

## SYSTÈME DE FACTIONS LÉGALES :

**Éléments généraux :** 

|  Commande |  Retour | Commentaires |
| ------------ | ------------ | ------------ |
| /factionl recruter [ID/PartieDuNom/NumeroInconnu] | Inviter un joueur dans la faction.  | Accessible au R10/R9/R8. / Log LEADERS_LÉGAUX |
|  /factionl virer [ID/PartieDuNom/NumeroInconnu] | Exclure un joueur de la faction.  |   Accessible au R10/R9/R8. / Log LEADERS_LÉGAUX |
| /factionl changerrang [ID/PartieDuNom/NumeroInconnu]  |  Changer le rang d'un joueur. |  10 rangs. / Accessible au R10/R9/R8. / Log LEADERS_LÉGAUX |
| /factionl changernomrang [ID] | Changer le nom d'un rang de la faction.  | ID 1 = Rang 1 et ID 10 = Rang 10 / Accessible au R10/R9/R8. / Log LEADERS_LÉGAUX  |
|  /factionl voircaisse |  Voir le montant disponible dans la caisse faction. | Accessible au R10/R9/R8.  |
| /factionl retirercaisse [Montant] | Retirer un montant de la caisse faction.  | Accessible au R10/R9/R8. / Log LEADERS_LÉGAUX  |
| /factionl deposercaisse [Montant] | Déposer un montant dans la caisse faction.  | Accessible au R10/R9/R8. / Log LEADERS_LÉGAUX  |
|  /factionl salaire [ID du rang] [Montant] | Fixer le salaire par payday pour les joueurs en service.  | Accessible au R10/R9/R8. / Déduire les salaires de la caisse faction / Log LEADERS_LÉGAUX  |
|  /factionl vehicule | Affecter le véhicule dans lequel se trouve le joueur à la faction.  | Accessible au R10/R9/R8. / Log LEADERS_LÉGAUX  |
| /factionl retraitvehicule  | Désaffecter le véhicule de la faction dans lequel se trouve le joueur et le mettre propriétaire.  | Accessible au R10/R9/R8. / Log LEADERS_LÉGAUX  |
| /factionl changerskin [ID du rang] [ID du skin] | Changer le skin en fonction du rang lorsque les joueurs sont en service.  | Accessible au R10/R9/R8. / Log LEADERS_LÉGAUX  |

**Liste des factions :** LSCH, LSPD, LSFD, LSSD, FBI, DOJ

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
|  /forcerporte | Force la porte d'entrée du commerce/de la maison.  | Log LSPD  |
|  /baliseurg | Lance une balise d'urgence.  | Un message est envoyé à la radio interne. La localisation du joueur est affiché en temps réel. / Log LSPD |
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

**Éléments généraux :**
Il existe deux types de poubelles : les poubelles publiques et les poubelles privées.

- Poubelles publiques : Les poubelles publiques sont installées dans l'ensemble de la Ville. Le ramassage d'une poubelle publique (uniquement si elle est remplie à plus de xxxxx %) coûte xxxx $ à la caisse mairie.
- Poubelles privées : Chaque maison et commerce dispose d'une poubelle. Le ramassage d'une poubelle privée (uniquement si elle est remplie à plus de xxxxx %) coûte xxxx $ au propriétaire (retiré sur son compte en banque).

## SYSTÈME DE BRAQUAGES :

## SYSTÈME DE GARAGES :

## TEXTDRAWS :

### COMPTEUR VÉHICULE :

## SYSTÈME DE PACKS OOC :

+ Pack véhicules : Permet d'acheter 2 véhicules supplémentaires (voiture/moto/bateau/avion).
+ Pack maison : Permet d'acheter 1 maison supplémentaire.
+ Pack skin : Permet d'acheter 1 skin personnalisé.
+ Pack personnage : Permet de disposer d'un personnage complémentaire sur le compte.

## SYSTÈME D'ADMINISTRATION :

**Éléments généraux** : L'équipe doit pouvoir être autonome un maximum.
4 niveaux : Modérateur (1), Administrateur 1 (2), Administrateur 2 (3), Lead administrateur (4)

|  Commande | Description  | Commentaires  | Niveau min |   |
| ------------ | ------------ | ------------ | ------------ | ------------ |
| /supprimerpanneaupub  [ID du panneau]  | Permet de supprimer une publicité sur un panneau publicitaire.  |   |  | |
|   |   |   |   |   |
|   |   |   |   |   |
|   |   |   |   |   |
|   |   |   |   |   |
|   |   |   |   |   |
|   |   |   |   |   |
|   |   |   |   |   |
|   |   |   |   |   |


# MAPPINGS : 

Liste des lieux :

# ÉCONOMIE GLOBALE :

## ENTREPRISES :

**ÉQUILIBRE GLOBAL DU NOMBRE D'ENTREPRISES**

**Éléments généraux :**

|  Type | Nombre  |  Lieux |  Commentaires |
| ------------ | ------------ | ------------ | ------------ |
| 24/7  | 4  |   |   |
|  Armurerie | 2  |   |   |
| Station-essence  | 2  |   |   |
| Concessionnaire  | 2  |   |   |
| Banque  |  2 |   |   |
| Taxi  |  2 |   |   |
| Location de voitures/motos  |  2 |   |   |
|  Location de bateaux | 2  |   |   |
| Location d'avions  | 2  |   |   |
|  Mécanicien |  2 |   |   |
|  Camionneur |  2 |   |   |
|  Éboueur | 2  |   |   |
| Presse  | 2  |   |   |
|   |   |   |   |

# UCP :

Avoir un MDC pour les forces de l'ordre.


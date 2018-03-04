############################################################################################
The following script has been realized in an Universitary context
It allows users to get files under versioning, create new commit, load previous commit
and get informations about the commits through log messages
The script has been done for Dash interpretor
For further information on the script, see the README file

@Authors : FEDERSPIEL Remi & DELAVOUX Thibault
@UE : Systeme et programmation Systeme
L2 informatique - Université de franche-comté
############################################################################################

Bilan :

	Toutes les fonctions demandées ont été implémentées 
		- Add pour ajouter un fichier au système de version créant ainsi un dossier caché et insérant deux copies du fichier original
		- Commit pour ajouter un patch contenant les différences dans le fichier avec la version précédente
		- Rm pour supprimer du système de version tous les fichiers et patchs rattachés à un fichié donné
		- Revert pour annuler des changements et revenir à la dernière version commitée du fichier
		- Diff pour afficher les différences entre le fichier acctuel et le dernier commit réalisé
		- Checkout pour revenir à une version différente (plus ancienne ou plus récente)
		- Log pour afficher les dates des commits et les éventuels commentaires

Une alternative d'appel pour les commandes commit et checkout à également été implémenté (ci / co)


Lancement et appels :

	Les fonctions ont été testées dans différentes conditions pour assurer de couvrir au maximum les éventualités.
	Aucune faille n'a été détectée dans l'appel des commandes jusqu'à maintenant


Codes de retour en cas d'erreur :

1 : file not found
2 : file not under versioning yet
3 : invalid arguments number
4 : invalid argument form
	

Améliorations possibles :

	


Bilan du travail en binôme : 
	
	Les tâches à réaliser ont été clairement définies à l'avance et chaque membre du binôme à pu travailler en autonomie sur les fonctions dont il avait la charge.
	Rémi a implémenté les fonction add, rm, diff, revert ainsi que la boucle du main.
	Thibault à implémenté les fonctions checkout, commit, log, et à assurer la mise en commun des travaux.

	Nous avons ensuite travaillé de concert pour la gestion des éventuels bugs et disfonctionnements du script.

	Le travail à été réalisé majoritairement à distance par le biais d'un gestionnaire de version en ligne pour assurer un suivi et l'évolution cohérente d'un seul fichier. 



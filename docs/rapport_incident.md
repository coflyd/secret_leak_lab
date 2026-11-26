# Rapport d'incident : clé d'API exposée dans l'historique git

## 1. Résumé

En auditant mes dépôts GitHub, j'ai découvert qu'une clé d'API d'un service d'intelligence artificielle était restée lisible dans l'historique git d'un projet d'équipe universitaire auquel j'ai contribué. La clé avait été retirée du code, mais elle restait accessible dans les anciens commits, publiquement, pendant environ huit mois. Toute personne qui la trouvait pouvait consommer le service aux frais de son propriétaire. J'ai signalé la fuite au propriétaire de la clé, qui l'a révoquée, puis j'ai construit le laboratoire de ce dépôt pour comprendre comment détecter, corriger et prévenir ce type d'incident.

## 2. Découverte

Mon cours de tests d'intrusion web et remédiation, ainsi qu'un laboratoire PortSwigger consacré à la divulgation d'informations par l'historique de gestion de versions, m'ont fait comprendre une chose : tout ce qui est publié dans un dépôt public est exposé, y compris les anciennes versions des fichiers et les commentaires du code. J'ai donc décidé d'auditer mes propres dépôts, avec l'assistance d'un outil d'intelligence artificielle.

Le code actuel du projet paraissait propre : aucun fichier ne contenait de clé. Un simple coup d'œil au dépôt ne suffisait donc pas. La fuite se trouvait dans l'historique des commits, que l'on peut parcourir avec `git log`.

La détection a été reproduite sur un clone du dépôt avec deux méthodes :

1. **Une recherche dans tout l'historique** avec `git log --all -G`, qui a montré la clé dans trois commits : celui où elle a été ajoutée, celui où elle a été déplacée, et celui où elle a été retirée.
2. **Une analyse automatique avec gitleaks**, qui a relevé neuf résultats. Huit étaient des clés Firebase, publiques par conception : leur sécurité repose sur les règles d'accès de Firebase, et non sur leur confidentialité. Le neuvième était la clé exposée.

Cette comparaison a révélé une limite importante de gitleaks. La clé apparaissait dans deux fichiers, mais l'outil n'en a signalé qu'un seul. Dans le second, elle était écrite sous la forme d'un en‑tête `Authorization: Bearer`, et gitleaks ne possède pas de règle propre à ce fournisseur. C'est un faux négatif : sans la recherche manuelle, la moitié de l'exposition m'aurait échappé.

## 3. Chronologie

| Date et heure (UTC) | Événement |
|---|---|
| 17 mars 2026, 06 h 43 | Ajout de la clé en dur dans une fonction serveur |
| 17 mars 2026, 06 h 45 | Suppression de la fonction serveur et déplacement de la clé dans le code exécuté par le navigateur |
| 17 mars 2026, 08 h 23 | Retrait de la clé du code |
| 13 novembre 2026 | Découverte de la fuite lors de l'audit de mes dépôts |
| 16 novembre 2026, 21 h 33 | Signalement au propriétaire de la clé |
| Avant le 17 novembre 2026 | Révocation de la clé, à une date exacte inconnue |
| 17 novembre 2026, 13 h 49 | Confirmation de la révocation par le propriétaire |

La clé n'est restée dans le code qu'environ une heure et quarante minutes. En revanche, elle est restée lisible dans l'historique public du dépôt pendant environ huit mois, jusqu'à sa révocation.

## 4. Analyse du risque

On pourrait penser que la clé, restée peu de temps dans le code, n'a pas eu le temps d'être découverte. Ce raisonnement est faux : dès qu'un commit est publié, son contenu est définitivement exposé. Des robots parcourent GitHub en permanence pour récolter ce type de clé, et ils lisent aussi l'historique.

Cette clé donnait accès à un service d'intelligence artificielle payant. Avec elle, un attaquant pouvait envoyer des requêtes au nom du propriétaire, consommer ses crédits et lui faire supporter le coût. Elle ne donnait en revanche aucun accès à l'application elle‑même, à ses comptes utilisateurs ou à ses données.

Je ne sais pas si la clé a été utilisée par un tiers. Seul l'historique de consommation du compte du propriétaire permettrait de le vérifier, et je n'y ai pas accès. La révocation rend toutefois toute utilisation future impossible.

## 5. Cause

Le projet a été développé par des étudiants en apprentissage, sous la contrainte d'un budget nul. La clé devait au départ être utilisée par une fonction serveur, mais ce service nécessitait une offre payante. La fonction a donc été supprimée, et la clé a été placée directement dans le code exécuté par le navigateur. C'est la cause racine : **une contrainte de coût a conduit à placer un secret côté client**. Dans cette position, la clé était lisible non seulement dans le dépôt, mais aussi par tout visiteur du site déployé.

La clé a ensuite été retirée du code, mais cette correction était incomplète. Supprimer une ligne crée un nouveau commit sans effacer les précédents : la clé restait donc accessible dans l'historique.

## 6. Remédiation

Les actions ont été menées dans cet ordre :

1. J'ai prévenu le propriétaire de la clé, en ne citant que son début pour ne pas l'exposer une nouvelle fois.
2. Il a révoqué la clé.
3. Il m'a donné son accord pour que l'incident serve de cas d'étude anonymisé.

La révocation passe avant tout le reste, car c'est la seule mesure qui neutralise vraiment la clé. Tant qu'elle fonctionne, toute personne qui l'a copiée peut s'en servir, même si l'historique est nettoyé ensuite.

Une fois la clé révoquée, j'ai choisi de ne pas réécrire l'historique du dépôt. La clé n'a plus aucune valeur, et une réécriture aurait obligé chaque membre de l'équipe à récupérer un nouvel historique, sans aucun bénéfice pour la sécurité.

## 7. Prévention

Aucune mesure ne suffit seule. Il faut les superposer, selon le principe de la défense en profondeur :

1. **Ne jamais placer un secret dans le code exécuté par le navigateur.** Un appel à une API payante doit passer par un serveur, qui lit la clé dans une variable d'environnement.
2. **Installer un hook pre-commit** qui bloque tout commit contenant un secret. Je l'ai mis en place sur tous mes dépôts : le secret est arrêté avant même d'entrer dans l'historique.
3. **Activer la protection des envois de GitHub**, qui bloque côté serveur un envoi contenant un secret, y compris pour les membres de l'équipe qui n'ont pas installé de hook.
4. **Compléter les outils automatiques par une recherche manuelle**, puisque gitleaks a manqué une partie de l'exposition.

## 8. Leçons retenues

Sur le plan technique, j'ai appris qu'un dépôt git ne s'audite pas seulement dans son état actuel, mais dans tout son historique. J'ai aussi appris qu'un outil de détection peut laisser passer de vrais secrets, et qu'il faut connaître ses limites pour s'y fier.

Sur le plan humain, j'ai appris à signaler une vulnérabilité de façon responsable : prévenir d'abord la personne concernée, sans exposer la clé une nouvelle fois et sans chercher de coupable, attendre que la correction soit faite, puis demander son accord avant de rendre l'incident public. C'est un cas typique en développement, et je suis satisfaite de l'avoir traité de bout en bout.

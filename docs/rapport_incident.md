# Rapport d'incident : clé d'API exposée dans l'historique git

*Ce document est un plan. Chaque section contient les questions auxquelles répondre. Remplacez les questions par votre propre texte. Ne citez ni la clé, ni le nom du dépôt, ni le nom des personnes.*

## 1. Résumé

En trois ou quatre phrases : que s'est‑il passé, quel était le risque, qu'est‑ce qui a été fait ?

## 2. Découverte

Comment la fuite a‑t‑elle été trouvée ? Quelle commande ou quel outil a été utilisé ? Pourquoi un simple coup d'œil au code actuel ne suffisait‑il pas ?

## 3. Chronologie

| Date | Événement |
|---|---|
| | Ajout de la clé dans le code |
| | Retrait de la clé du fichier |
| | Découverte de la fuite |
| | Signalement au propriétaire de la clé |
| | Révocation de la clé |

## 4. Analyse du risque

Pendant combien de temps la clé a‑t‑elle été publique ? Que pouvait faire un attaquant avec elle ? Y a‑t‑il des traces d'utilisation abusive dans l'historique de consommation du service ?

## 5. Cause

Pourquoi la clé s'est‑elle retrouvée dans le code ? Quelle contrainte du projet a mené à ce choix ? Pourquoi la correction faite à l'époque était‑elle incomplète ?

## 6. Remédiation

Quelles actions ont été menées, et dans quel ordre ? Pourquoi la révocation doit‑elle passer avant la réécriture de l'historique ?

## 7. Prévention

Quelles mesures empêcheraient que cela se reproduise ? Pensez au hook pre-commit, à la protection des envois de GitHub, aux variables d'environnement et à un appel d'API côté serveur plutôt que côté navigateur.

## 8. Leçons retenues

Qu'avez‑vous appris, techniquement et dans la façon de signaler un problème à un coéquipier ?

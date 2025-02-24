Quiz
====

Application de quiz, par des questions avec chaque fois 3 réponses prédéfinies possibles.

Exigence 1
----------

Le jeu démarre directement, il affiche la première question avec les 3 réponses proposées.
A chaque réponse, la question suivante est affichée.
Le nombre de question pour une partie est de 10.

Exigence 2
----------

Rajoutez la gestion du score.
Chaque bonne réponse ajoute 1 au score.
Le score s'affiche à la fin de la partie sous forme "Score obtenu / Nb total de question".

Rajoutez à la fin de la partie un bouton "New Game" qui relance une nouvelle partie.

Exigence 3
----------

Rajoutez un bouton "?" proche de la question, lorsqu'il est cliqué, le `hint` de la question s'affiche.

Exigence 4
----------

Modifiez la "source" des questions. Supprimez le tableau en "dur" dans le code, par la récupération de questions
à travers un service Web REST.

Ceci implique un changement de stratégie pour la détermination de ce qu'est une "partie" de jeu. A vous de choisir.
Il doit être possible de changer facilement la façon de récupérer les questions (pour par exemple avoir aussi un système
de stockage local).

Exigence 5
----------

Mettez en place ces différents types de parties:

 1. Rookie
    10 questions
    A chaque réponse: +1 au score si c'est la bonne, passe de toute façons à la suivante.
    
 2. Journeyman
    10 questions
    A chaque réponse: +1 au score si c'est la bonne, -1 au score si c'est la mauvaise, passe à la suivante seulement si c'est la bonne.
    
 3. Warrior
    Même chose que Journeyman mais avec 15 questions et restrictions de temps de 30 secondes pour la partie entière.
    
 4. Ninja
    Même chose que Warrior mais en plus avec une limitation du temps par question de 4 secondes.

Exigence 6
----------

Maintenant qu'il y a plusieurs types de parties, ajoutez un nouvel écran qui permette la séléction du type de partie avant de commencer
le jeu.

Objectif: gérer deux _écrans_ (views) dans une même application, passer de l'un à l'autre.


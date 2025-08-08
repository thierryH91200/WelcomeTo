


![Swift](https://img.shields.io/badge/Swift-5.7-orange) ![macOS](https://img.shields.io/badge/macOS-14-blue) ![License](https://img.shields.io/badge/License-MIT-green)
    <a href="https://github.com/thierryH91200/WelcomeTo/releases/latest" alt="Downloads">
          <img src="https://img.shields.io/github/downloads/thierryH91200/WelcomeTo/total.svg" /></a>

L'application SwiftUI s’appuie sur SwiftData pour la gestion des données et suit une structure moderne :

1. Gestion de l’état global
• La classe AppState (ObservableObject) gère l’état global de l’app :
   • databaseURL : l’URL de la base de données en cours
   • isProjectOpen : indique si un projet est ouvert

2. Cycle de vie de l’application
• WelcomeToApp est le point d’entrée principal (@main).
• Elle crée et conserve :
   • Un AppState partagé (pour l’état)
   • Un gestionnaire de projets récents (RecentProjectsManager)
   • Un contrôleur de données (DataController), qui encapsule le conteneur SwiftData

3. Initialisation et gestion de la base de données
• Au démarrage, un dossier spécifique (“WelcomeBDD”) est créé dans le dossier Documents de l’utilisateur pour stocker la base.
• Le conteneur de modèles SwiftData (ModelContainer) est initialisé avec ce chemin.
• L’application gère les undo via un UndoManager.

4. Navigation et affichage
• Si un projet est ouvert (isProjectOpen), l’app affiche ContentView avec le contexte de données.
• Sinon, elle présente une vue de bienvenue (WelcomeWindowView) pour ouvrir ou créer un projet, affichant aussi les projets récents.

5. Ouverture de projet
• La fonction openDocument(at:) permet d’ouvrir un projet : elle réinitialise le contrôleur de données et met à jour l’état global.

6. Architecture
• Utilisation de l’environnement SwiftUI pour partager le contexte de données (.environment(\.modelContext, …)) et l’état global (.environmentObject(appState)).
• Il existe une classe dédiée DataController pour encapsuler la configuration du modèle SwiftData.

⸻

En résumé

Ton application permet :
• De gérer des projets stockés localement (avec SwiftData)
• D’ouvrir/créer des projets, de lister les projets récents
• De passer d’un écran d’accueil à un écran principal selon l’état d’ouverture d’un projet

L’architecture suit les bonnes pratiques SwiftUI avec une séparation claire entre l’état, la gestion des données et l’interface utilisateur.

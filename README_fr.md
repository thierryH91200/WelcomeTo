


![Swift](https://img.shields.io/badge/Swift-5.7-orange) ![macOS](https://img.shields.io/badge/macOS-14-blue) ![License](https://img.shields.io/badge/License-MIT-green)
    <a href="https://github.com/thierryH91200/WelcomeTo/releases/latest" alt="Downloads">
          <img src="https://img.shields.io/github/downloads/thierryH91200/WelcomeTo/total.svg" /></a>

L'application macOS « WelcomeTo » propose une interface moderne pour la gestion de projets/documents, avec persistance des données grâce à SwiftData. Elle est structurée autour de deux principales fenêtres :

1. Écran d’accueil (WelcomeWindowView)
• Présente un écran d’accueil à l’utilisateur avec :
   • Le nom et la version de l’application.
   • Une liste de projets récents (affichés à droite).
   • Trois actions principales :
      • Créer un nouveau document (réinitialise la base de données).
      • Ouvrir un document existant (via une boîte de dialogue macOS).
      • Ouvrir un projet exemple.
• Utilise un design en HStack avec séparation visuelle.

2. Écran principal du projet (ContentView)
• Affiche la liste des éléments (items) stockés en base de données.
• Indique le nombre total d’items.
• Permet d’ajouter rapidement un nouvel item (avec la date/heure).
• Met l’accent sur la fenêtre principale lors de l’affichage.

3. Gestion de la donnée
• Utilisation de SwiftData pour la persistance des items dans un dossier dédié du répertoire Documents (WelcomeBDD/WelcomeTo.store).
• Les opérations CRUD sont réalisées via modelContext.

4. Structure de l’application
• Le point d’entrée principal est WelcomeToApp.
• Utilisation d’un objet d’état AppState (ObservableObject) pour piloter la navigation (écran d’accueil ou principal), et stocker l’URL de la base de données active.

5. Expérience utilisateur
• Une gestion de l’accueil avec animation de splash (SplashManager).
• Activation explicite de la fenêtre principale pour améliorer l’expérience utilisateur macOS.
• Prise en charge de l’annulation (UndoManager).

⸻

En résumé :
Il s’agit d’une application macOS de type « gestionnaire de projets/documents » avec écran d’accueil, navigation simple, persistance des données locale, et une expérience utilisateur adaptée à l’écosystème Apple.

© 2025 Kirill Rusinov. All rights reserved

> Note: Some assets and scene files are excluded from this repository due to their large size. 
> To get the full project with all assets, please contact me via Telegram: [@just_rusya](https://t.me/just_rusya)

# Monopoly-2
A 3D board game inspired by Monopoly, built with Godot Engine.  
This project experiments with AI-driven bots that can learn and evolve over time using a DNA-based system.  


##  Features
-  **Classic Monopoly mechanics**: buying properties, auctions, trading, building houses, mortgaging, and special tiles
-  **AI Bots with DNA system**
-  **Generational learning**
-  **3D gameplay** with interactive board and UI


## Development
- Engine: [Godot 4](https://godotengine.org/)  
- Language: [GDScript](https://docs.godotengine.org/)  
- Platforms: Windows, Linux, (MacOS planned)  


## AI & DNA System
Bots are not hardcoded:
- **DNA representation**: numeric parameters affecting risk-taking, trading, auctions, etc
- **Selection**: the best-performing bots are saved each generation
- **Mutation/Crossover**: random changes and mixing of DNA ensure diversity
- **Evaluation**: bots are judged by number of wins

This creates a kind of genetic algorithm where bots gradually improve at playing.

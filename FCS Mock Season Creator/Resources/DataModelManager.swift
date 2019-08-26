//
//  DataModelManager.swift
//  FCS Mock Season Creator
//
//  Created by Tyler Cheek on 7/16/19.
//  Copyright © 2019 Tyler Cheek. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import os.log

class DataModelManager {
    
    static let shared = DataModelManager()
    
    var allGames: [Game]?
    var allTeams: [Team]?
    var allConferences: [Conference]?
    
    init() {}
    
    public func loadTeamNamesByConference(teamNamesByConferenceName: [String : [String]]) {
        
        self.allTeams = [Team]()
        self.allConferences = [Conference]()
        for (conferenceName, teamNamesForConference) in teamNamesByConferenceName {
            let teamsInConference = teamNamesForConference.map { (teamName) -> Team in
                return Team(teamName: teamName, conferenceName: conferenceName)
            }
            teamsInConference.forEach({ (team) in
                saveOrCreateTeamMO(withTeam: team)
                self.allTeams?.append(team)
            })
            let conference = Conference(name: conferenceName, conferenceOption: nil, teams: teamsInConference)
            saveOrCreateConferenceMO(withConference: conference)
            self.allConferences?.append(conference)
        }
        
    }
    
    // Please note that this method WILL FAIL unless teams and conferences have been loaded into
    // the DataModelManager already
    public func loadGames(gameApiResponses: [GameApiResponse]) {
        
        let gamesFromApi = gameApiResponses.map { (gameApiResponse) -> GameFromApi in
            guard let homeConferenceName = Conference(withTeamName: gameApiResponse.homeTeam) else {
                os_log("Could not unwrap homeConferenceName in loadGames(gameApiResponses:) in DataModelManager", type: .debug)
                return GameFromApi()
            }
            guard let awayConferenceName = Conference(withTeamName: gameApiResponse.awayTeam) else {
                os_log("Could not unwrap awayConferenceName in loadGames(gameApiResponses:) in DataModelManager", type: .debug)
                return GameFromApi()
            }
            guard let gameFromApi = GameFromApi(
                id: gameApiResponse.id,
                homeTeamName: gameApiResponse.homeTeam,
                awayTeamName: gameApiResponse.awayTeam,
                winnerName: gameApiResponse.winner,
                avgConfidence: gameApiResponse.avgConfidence,
                homeConferenceName: homeConferenceName.name,
                awayConferenceName: awayConferenceName.name,
                avgHomeTeamScore: gameApiResponse.avgHomeTeamScore,
                avgAwayTeamScore: gameApiResponse.avgAwayTeamScore,
                week: gameApiResponse.week
            ) else {
                    os_log("Could not unwrap new game object in loadGames(gameApiResponses:) in DataModelManager", type: .debug)
                    return GameFromApi()
            }
            return gameFromApi
        }
        
        var newGamesList = [Game]()
        if let gamesFromCoreData = self.allGames {
            let gameIdsMappedToGamesFromCoreData = gamesFromCoreData.reduce([Int : Game]()) { (dict, game) -> [Int : Game] in
                var dict = dict
                dict[game.id] = game
                return dict
            }
            gamesFromApi.forEach { (gameFromApi) in
                let gameId = gameFromApi.id
                let game = Game(fromGameFromApi: gameFromApi)
                if let winner = gameFromApi.winner {
                    game.confidence = 100
                    game.winner = winner
                    newGamesList.append(game)
                    return
                }
                // At this point, we know that the winner is not set by the API
                if gameFromApi.contestants != gameIdsMappedToGamesFromCoreData[gameId]?.contestants ||
                        gameFromApi.conferences != gameIdsMappedToGamesFromCoreData[gameId]!.conferences {
                    newGamesList.append(game)
                    return
                }
                if let gameFromCoreData = gameIdsMappedToGamesFromCoreData[gameId] {
                    if gameFromCoreData.confidence == 100 {
                        gameFromCoreData.confidence = 50 // this is because the game used to have the winner set by the API but now it doesn't, so we need to reset the confidence back to 50 so it's not disabled
                    }
                    newGamesList.append(gameFromCoreData)
                } else {
                    newGamesList.append(game)
                }
            }
            self.allGames?.removeAll()
            newGamesList.forEach { (game) in
                saveOrCreateGameMO(withGame: game)
                self.allGames?.append(game)
            }
        } else {
            self.allGames = [Game]()
            gamesFromApi.forEach({ (gameFromApi) in
                let game = Game(fromGameFromApi: gameFromApi)
                saveOrCreateGameMO(withGame: game)
                self.allGames?.append(game)
            })
        }
        
    }
    
    public func getAllGames() -> [Game] {
        
        if let allGames = self.allGames {
            return allGames
        } else {
            loadGamesFromCoreData()
            guard let allGames = self.allGames else {
                fatalError("Could not get allGames in DataModelManager, even after calling loadGames(). Quitting...")
            }
            return allGames
        }
        
    }
    
    public func getAllTeams() -> [Team] {
        
        if let allTeams = self.allTeams {
            return allTeams
        } else {
            loadTeamsFromCoreData()
            guard let allTeams = self.allTeams else {
                fatalError("Could not get allTeams in DataModelManager, even after calling loadTeams(). Quitting...")
            }
            return allTeams
        }
        
    }
    
    public func getAllConferences() -> [Conference] {
        
        if let allConferences = self.allConferences {
            return allConferences
        } else {
            loadConferencesFromCoreData()
            guard let allConferences = self.allConferences else {
                fatalError("Could not get allConferences in DataModelManager, even after calling loadConferences(). Quitting...")
            }
            return allConferences
        }
        
    }
    
    public func saveOrCreateGameMO(withGame game: Game) {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "GameMO")
        fetchRequest.predicate = NSPredicate(format: "id == %d", game.id)
        
        do {
            let test = try managedContext.fetch(fetchRequest)
            
            guard !test.isEmpty else {
                saveNewGameMO(game: game, withContext: managedContext)
                return
            }
            
            let objectToDelete = test[0] as! GameMO
            managedContext.delete(objectToDelete)
            
            let gameMO = GameMO.newGameMO(fromGame: game, withContext: managedContext)
            
            gameMO.setValue(gameMO.avgAwayTeamScore, forKey: "avgAwayTeamScore")
            gameMO.setValue(gameMO.avgConfidence, forKey: "avgConfidence")
            gameMO.setValue(gameMO.avgHomeTeamScore, forKey: "avgHomeTeamScore")
            gameMO.setValue(gameMO.awayConferenceName, forKey: "awayConferenceName")
            gameMO.setValue(gameMO.awayTeamName, forKey: "awayTeamName")
            gameMO.setValue(gameMO.awayTeamScore, forKey: "awayTeamScore")
            gameMO.setValue(gameMO.confidence, forKey: "confidence")
            gameMO.setValue(gameMO.homeConferenceName, forKey: "homeConferenceName")
            gameMO.setValue(gameMO.homeTeamName, forKey: "homeTeamName")
            gameMO.setValue(gameMO.homeTeamScore, forKey: "homeTeamScore")
            gameMO.setValue(gameMO.id, forKey: "id")
            gameMO.setValue(gameMO.week, forKey: "week")
            gameMO.setValue(gameMO.winnerName, forKey: "winnerName")
            
            do {
                try managedContext.save()
            } catch let error as NSError {
                print("Could not update game to CoreData. \(error), \(error.userInfo)")
            }
        } catch {
            saveNewGameMO(game: game, withContext: managedContext)
        }
        
    }
    
    private func saveNewGameMO(game: Game, withContext managedContext: NSManagedObjectContext) {
        
        let newGameMO = GameMO.newGameMO(fromGame: game, withContext: managedContext)
        
        newGameMO.setValue(newGameMO.avgAwayTeamScore, forKey: "avgAwayTeamScore")
        newGameMO.setValue(newGameMO.avgConfidence, forKey: "avgConfidence")
        newGameMO.setValue(newGameMO.avgHomeTeamScore, forKey: "avgHomeTeamScore")
        newGameMO.setValue(newGameMO.awayConferenceName, forKey: "awayConferenceName")
        newGameMO.setValue(newGameMO.awayTeamName, forKey: "awayTeamName")
        newGameMO.setValue(newGameMO.awayTeamScore, forKey: "awayTeamScore")
        newGameMO.setValue(newGameMO.confidence, forKey: "confidence")
        newGameMO.setValue(newGameMO.homeConferenceName, forKey: "homeConferenceName")
        newGameMO.setValue(newGameMO.homeTeamName, forKey: "homeTeamName")
        newGameMO.setValue(newGameMO.homeTeamScore, forKey: "homeTeamScore")
        newGameMO.setValue(newGameMO.id, forKey: "id")
        newGameMO.setValue(newGameMO.week, forKey: "week")
        newGameMO.setValue(newGameMO.winnerName, forKey: "winnerName")
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save new team to CoreData. \(error), \(error.userInfo)")
        }
        
    }
    
    public func saveOrCreateTeamMO(withTeam team: Team) {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "TeamMO")
        fetchRequest.predicate = NSPredicate(format: "name == %@", team.name)
        
        do {
            let test = try managedContext.fetch(fetchRequest)
            
            guard !test.isEmpty else {
                saveNewTeamMO(team: team, withContext: managedContext)
                return
            }
            
            let objectToDelete = test[0] as! TeamMO
            managedContext.delete(objectToDelete)
            
            guard let teamMO = TeamMO.newTeamMO(fromTeam: team, withContext: managedContext) else {
                os_log("Could not unwrap teamMO from team in DataModelManager", type: .debug)
                return
            }
            
            teamMO.setValue(teamMO.name, forKey: "name")
            teamMO.setValue(teamMO.conferenceName, forKey: "conferenceName")
            
            do {
                try managedContext.save()
            } catch let error as NSError {
                print("Could not update team to CoreData. \(error), \(error.userInfo)")
            }
        } catch {
            saveNewTeamMO(team: team, withContext: managedContext)
        }
        
    }
    
    private func saveNewTeamMO(team: Team, withContext managedContext: NSManagedObjectContext) {
        
        guard let newTeamMO = TeamMO.newTeamMO(fromTeam: team, withContext: managedContext) else {
            os_log("Could not unwrap newTeamMO from team in DataModelManager", type: .debug)
            return
        }
        
        newTeamMO.setValue(newTeamMO.name, forKey: "name")
        newTeamMO.setValue(newTeamMO.conferenceName, forKeyPath: "conferenceName")
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save new team to CoreData. \(error), \(error.userInfo)")
        }
        
    }
    
    public func saveOrCreateConferenceMO(withConference conference: Conference) {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "ConferenceMO")
        fetchRequest.predicate = NSPredicate(format: "name == %@", conference.name)
        
        do {
            let test = try managedContext.fetch(fetchRequest)
            
            guard !test.isEmpty else {
                saveNewConferenceMO(conference: conference, withContext: managedContext)
                return
            }
            
            let objectToDelete = test[0] as! ConferenceMO
            managedContext.delete(objectToDelete)
            
            guard let conferenceMO = ConferenceMO.newConferenceMO(fromConference: conference, withContext: managedContext) else {
                os_log("Could not unwrap conferenceMO from conference in DataModelManager", type: .debug)
                return
            }
            
            conferenceMO.setValue(conferenceMO.name, forKey: "name")
            conferenceMO.setValue(conferenceMO.teamNames, forKey: "teamNames")
            
            do {
                try managedContext.save()
            } catch let error as NSError {
                print("Could not update conference to CoreData. \(error), \(error.userInfo)")
            }
        } catch {
            saveNewConferenceMO(conference: conference, withContext: managedContext)
        }
        
    }
    
    private func saveNewConferenceMO(conference: Conference, withContext managedContext: NSManagedObjectContext) {
        
        guard let newConferenceMO = ConferenceMO.newConferenceMO(fromConference: conference, withContext: managedContext) else {
            os_log("Could not unwrap newConferenceMO from conference in DataModelManager", type: .debug)
            return
        }
        
        newConferenceMO.setValue(newConferenceMO.name, forKey: "name")
        newConferenceMO.setValue(newConferenceMO.teamNames, forKeyPath: "teamNames")
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save new team to CoreData. \(error), \(error.userInfo)")
        }
        
    }
    
    public func loadGamesFromCoreData() {
        
        os_log("loadGamesFromCoreData() called", log: OSLog.default, type: .debug)
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<GameMO>(entityName: "GameMO")
        
        do {
            let gamesMO = try managedContext.fetch(fetchRequest)
            guard gamesMO.count > 0 else {
                os_log("Could not find any games in CoreData", type: .debug)
                return
            }
            os_log("Loading %d games", log: OSLog.default, type: .debug, gamesMO.count)
            self.allGames = gamesMO.map { (gameMO) -> Game in
                if let game = Game(fromGameMO: gameMO) {
                    return game
                } else {
                    return Game()
                }
            }
        } catch let error as NSError {
            print("Could not fetch games. \(error), \(error.userInfo)")
        }
        
    }
    
    public func loadTeamsFromCoreData() {
        
        os_log("loadTeamsFromCoreData() called", type: .debug)
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<TeamMO>(entityName: "TeamMO")
        
        do {
            let teamsMO = try managedContext.fetch(fetchRequest)
            guard teamsMO.count > 0 else {
                os_log("Could not find any teams in CoreData", type: .debug)
                return
            }
            os_log("Loading %d teams", log: OSLog.default, type: .debug, teamsMO.count)
            self.allTeams = teamsMO.map { (teamMO) -> Team in
                if let team = Team(fromTeamMO: teamMO) {
                    return team
                } else {
                    return Team(teamName: "None", conferenceName: "None")
                }
            }
        } catch let error as NSError {
            print("Could not fetch teams. \(error), \(error.userInfo)")
        }
        
    }
    
    public func loadConferencesFromCoreData() {
        
        os_log("loadConferencesFromCoreData() called", type: .debug)
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<ConferenceMO>(entityName: "ConferenceMO")
        
        do {
            let conferencesMO = try managedContext.fetch(fetchRequest)
            guard conferencesMO.count > 0 else {
                os_log("Could not find any conferences in CoreData", type: .debug)
                return
            }
            os_log("Loading %d conferences", log: OSLog.default, type: .debug, conferencesMO.count)
            self.allConferences = conferencesMO.map { (conferenceMO) -> Conference in
                if let conference = Conference(fromConferenceMO: conferenceMO) {
                    return conference
                } else {
                    return Conference(name: "None", conferenceOption: .none, teams: [Team(teamName: "None", conferenceName: "None")])
                }
            }
        } catch let error as NSError {
            print("Could not fetch teams. \(error), \(error.userInfo)")
        }
        
    }
    
    public func deleteAllGameRecords() {
        
        os_log("deleteAllGameRecords() called", type: .debug)
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "GameMO")
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try managedContext.execute(batchDeleteRequest)
        } catch {
            os_log("Could not batch delete all Game records")
        }
        
    }
    
    public func deleteAllTeamRecords() {
        
        os_log("deleteAllTeamRecords() called", type: .debug)
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "TeamMO")
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try managedContext.execute(batchDeleteRequest)
        } catch {
            os_log("Could not batch delete all Team records")
        }
        
    }
    
    public func deleteAllConferenceRecords() {
        
        os_log("deleteAllConferenceRecords() called", type: .debug)
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ConferenceMO")
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try managedContext.execute(batchDeleteRequest)
        } catch {
            os_log("Could not batch delete all Conference records")
        }
        
    }
    
}

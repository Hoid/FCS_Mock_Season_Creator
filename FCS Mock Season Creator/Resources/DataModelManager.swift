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
        
        let games = gameApiResponses.map { (gameApiResponse) -> Game in
            let contestantNames = gameApiResponse.contestants
            let conferenceNamesInGame = contestantNames.map({ (contestantName) -> String in
                if let conferenceName = Conference.name(forTeamName: contestantName) {
                    return conferenceName
                } else {
                    return "None"
                }
            })
            guard let game = Game(id: Int.random(in: 1...65535), contestantsNames: gameApiResponse.contestants, winnerName: gameApiResponse.contestants[0], confidence: 50, conferencesNames: conferenceNamesInGame, week: gameApiResponse.week) else {
                os_log("Could not unwrap new game object in loadGames(gameApiResponses:) in DataModelManager", type: .debug)
                return Game()
            }
            return game
        }
        self.allGames = [Game]()
        games.forEach({ (game) in
            saveOrCreateGameMO(withGame: game)
            self.allGames?.append(game)
        })
        
    }
    
    public func loadGames(gameNewApiResponses: [GameNewApiResponse]) {
        
        let gamesFromApi = gameNewApiResponses.map { (gameNewApiResponse) -> GameFromApi in
            let contestantNames = gameNewApiResponse.contestants
            let conferenceNamesInGame = contestantNames.map({ (contestantName) -> String in
                if let conferenceName = Conference.name(forTeamName: contestantName) {
                    return conferenceName
                } else {
                    return "None"
                }
            })
            if let winnerName = gameNewApiResponse.winner {
                guard let gameFromApi = GameFromApi(id: gameNewApiResponse.id, contestantsNames: gameNewApiResponse.contestants, winnerName: winnerName, confidence: 50, conferencesNames: conferenceNamesInGame, week: gameNewApiResponse.week) else {
                    os_log("Could not unwrap new game object in loadGames(gameApiResponses:) in DataModelManager", type: .debug)
                    return GameFromApi()
                }
                return gameFromApi
            } else {
                guard let gameFromApi = GameFromApi(id: gameNewApiResponse.id, contestantsNames: gameNewApiResponse.contestants, winnerName: nil, confidence: 50, conferencesNames: conferenceNamesInGame, week: gameNewApiResponse.week) else {
                    os_log("Could not unwrap new game object in loadGames(gameApiResponses:) in DataModelManager", type: .debug)
                    return GameFromApi()
                }
                return gameFromApi
            }
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
                if gameFromApi.contestants != gameIdsMappedToGamesFromCoreData[gameId]?.contestants ||
                    gameFromApi.conferences != gameIdsMappedToGamesFromCoreData[gameId]!.conferences {
                    newGamesList.append(game)
                    return
                }
                if let gameFromCoreData = gameIdsMappedToGamesFromCoreData[gameId] {
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
            
            guard let gameMO = GameMO.newGameMO(fromGame: game, withContext: managedContext) else {
                os_log("Could not unwrap gameMO from game in ConferenceGamesTableViewController", type: .debug)
                return
            }
            
            gameMO.setValue(gameMO.id, forKey: "id")
            gameMO.setValue(gameMO.conferencesNames, forKey: "conferencesNames")
            gameMO.setValue(gameMO.confidence, forKey: "confidence")
            gameMO.setValue(gameMO.contestantsNames, forKey: "contestantsNames")
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
        
        guard let newGameMO = GameMO.newGameMO(fromGame: game, withContext: managedContext) else {
            os_log("Could not unwrap newGameMO from game in DataModelManager", type: .debug)
            return
        }
        
        newGameMO.setValue(newGameMO.id, forKey: "id")
        newGameMO.setValue(newGameMO.conferencesNames, forKeyPath: "conferencesNames")
        newGameMO.setValue(newGameMO.confidence, forKeyPath: "confidence")
        newGameMO.setValue(newGameMO.contestantsNames, forKeyPath: "contestantsNames")
        newGameMO.setValue(newGameMO.winnerName, forKeyPath: "winnerName")
        
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

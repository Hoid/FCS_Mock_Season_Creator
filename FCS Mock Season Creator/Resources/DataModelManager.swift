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
    
    convenience init(teamNamesByConferenceName: [String : [String]]) {
        
        self.init()
        if let _ = self.allGames, let _ = self.allTeams, let _ = self.allConferences {
            loadTeams()
            loadConferences()
            loadGames()
        } else {
            os_log("Needed to initialize data in CoreData", type: .debug)
            for (conferenceName, teamNamesForConference) in teamNamesByConferenceName {
                let teamsInConference = teamNamesForConference.map { (teamName) -> Team in
                    return Team(teamName: teamName, conferenceName: conferenceName)
                }
                teamsInConference.forEach({ saveOrCreateTeamMO(withTeam: $0) })
                let conference = Conference(name: conferenceName, conferenceOption: nil, teams: teamsInConference)
                saveOrCreateConferenceMO(withConference: conference)
            }
        }
        
    }
    
    public func getAllGames() -> [Game] {
        
        if let allGames = self.allGames {
            return allGames
        } else {
            loadGames()
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
            loadTeams()
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
            loadConferences()
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
        fetchRequest.predicate = NSPredicate(format: "id == %@", game.id)
        
        do {
            let test = try managedContext.fetch(fetchRequest)
            
            guard !test.isEmpty else {
                saveNewGameMO(game: game, withContext: managedContext)
                return
            }
            
            let objectToDelete = test[0] as! GameMO
            managedContext.delete(objectToDelete)
            os_log("Deleting game from CoreData with contestants: (%s, %s)", type: .debug, objectToDelete.contestantsNames[0], objectToDelete.contestantsNames[1])
            
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
                os_log("Inserting game into CoreData with contestants: (%s, %s)", type: .debug, gameMO.contestantsNames[0], gameMO.contestantsNames[1])
            } catch let error as NSError {
                print("Could not update game to CoreData. \(error), \(error.userInfo)")
            }
        } catch {
            saveNewGameMO(game: game, withContext: managedContext)
        }
        
    }
    
    private func saveNewGameMO(game: Game, withContext managedContext: NSManagedObjectContext) {
        
        os_log("Could not fetch game from CoreData. Saving it as a new game.", type: .debug)
        
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
            os_log("Deleting team from CoreData with name: (%s)", type: .debug, objectToDelete.name)
            
            guard let teamMO = TeamMO.newTeamMO(fromTeam: team, withContext: managedContext) else {
                os_log("Could not unwrap teamMO from team in DataModelManager", type: .debug)
                return
            }
            
            teamMO.setValue(teamMO.name, forKey: "name")
            teamMO.setValue(teamMO.conferenceName, forKey: "conferenceName")
            
            do {
                try managedContext.save()
                os_log("Inserting team into CoreData with name: (%s)", type: .debug, teamMO.name)
            } catch let error as NSError {
                print("Could not update team to CoreData. \(error), \(error.userInfo)")
            }
        } catch {
            saveNewTeamMO(team: team, withContext: managedContext)
        }
        
    }
    
    private func saveNewTeamMO(team: Team, withContext managedContext: NSManagedObjectContext) {
        
        os_log("Could not fetch team from CoreData. Saving it as a new team.", type: .debug)
        
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
            os_log("Deleting conference from CoreData with name: (%s)", type: .debug, objectToDelete.name)
            
            guard let conferenceMO = ConferenceMO.newConferenceMO(fromConference: conference, withContext: managedContext) else {
                os_log("Could not unwrap conferenceMO from conference in DataModelManager", type: .debug)
                return
            }
            
            conferenceMO.setValue(conferenceMO.name, forKey: "name")
            conferenceMO.setValue(conferenceMO.teamNames, forKey: "teamNames")
            
            do {
                try managedContext.save()
                os_log("Inserting conference into CoreData with name: (%s)", type: .debug, conferenceMO.name)
            } catch let error as NSError {
                print("Could not update conference to CoreData. \(error), \(error.userInfo)")
            }
        } catch {
            saveNewConferenceMO(conference: conference, withContext: managedContext)
        }
        
    }
    
    private func saveNewConferenceMO(conference: Conference, withContext managedContext: NSManagedObjectContext) {
        
        os_log("Could not fetch team from CoreData. Saving it as a new team.", type: .debug)
        
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
    
    public func loadGames() {
        
        os_log("loadGames() called", log: OSLog.default, type: .debug)
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<GameMO>(entityName: "GameMO")
        
        do {
            var gamesMO = try managedContext.fetch(fetchRequest)
            os_log("Loading %d games", log: OSLog.default, type: .debug, gamesMO.count)
            if gamesMO.count == 0 {
                guard let game1 = GameMO.newGameMO(id: UUID().uuidString, contestants: ["Elon", "NC A&T"], winner: "Elon", confidence: 65, conferences: [.caa], week: 0, withContext: managedContext),
                    let game2 = GameMO.newGameMO(id: UUID().uuidString, contestants: ["James Madison", "Towson"], winner: "James Madison", confidence: 85, conferences: [.caa], week: 0, withContext: managedContext),
                    let game3 = GameMO.newGameMO(id: UUID().uuidString, contestants: ["Samford", "Youngstown State"], winner: "Samford", confidence: 75, conferences: [.mvfc], week: 0, withContext: managedContext),
                    let game4 = GameMO.newGameMO(id: UUID().uuidString, contestants: ["Elon", "Citadel"], winner: "Elon", confidence: 60, conferences: [.caa, .southern], week: 1, withContext: managedContext),
                    let game5 = GameMO.newGameMO(id: UUID().uuidString, contestants: ["Elon", "Richmond"], winner: "Elon", confidence: 80, conferences: [.caa], week: 2, withContext: managedContext) else {
                        os_log("Could not create stub games in DataModelManager.loadGames()", type: .default)
                        return
                }
                gamesMO = [game1, game2, game3, game4, game5]
                os_log("Needed to load games for the first time", log: OSLog.default, type: .debug)
                do {
                    try managedContext.save()
                } catch let error as NSError {
                    print("Could not save game to CoreData. \(error), \(error.userInfo)")
                }
            }
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
    
    public func loadTeams() {
        
        os_log("loadTeams() called", type: .debug)
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<TeamMO>(entityName: "TeamMO")
        
        do {
            var teamsMO = try managedContext.fetch(fetchRequest)
            os_log("Loading %d teams", log: OSLog.default, type: .debug, teamsMO.count)
            if teamsMO.count == 0 {
                guard let team1 = TeamMO.newTeamMO(name: "Elon", conferenceName: "CAA", withContext: managedContext),
                    let team2 = TeamMO.newTeamMO(name: "JMU", conferenceName: "CAA", withContext: managedContext),
                    let team3 = TeamMO.newTeamMO(name: "Youngstown State", conferenceName: "MVFC", withContext: managedContext),
                    let team4 = TeamMO.newTeamMO(name: "The Citadel", conferenceName: "Southern", withContext: managedContext)
                    else {
                        os_log("Could not create stub teams in DataModelManager.loadTeams()", type: .default)
                        return
                }
                teamsMO = [team1, team2, team3, team4]
                os_log("Needed to load teams for the first time", type: .debug)
                do {
                    try managedContext.save()
                } catch let error as NSError {
                    print("Could not save team to CoreData. \(error), \(error.userInfo)")
                }
            }
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
    
    public func loadConferences() {
        
        os_log("loadConferences() called", type: .debug)
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<ConferenceMO>(entityName: "ConferenceMO")
        
        do {
            var conferencesMO = try managedContext.fetch(fetchRequest)
            os_log("Loading %d conferences", log: OSLog.default, type: .debug, conferencesMO.count)
            if conferencesMO.count == 0 {
                guard let conference1 = ConferenceMO.newConferenceMO(name: "None", teamNames: ["None"], withContext: managedContext) else {
                        os_log("Could not create stub conference in DataModelManager.loadTeams()", type: .default)
                        return
                }
                conferencesMO = [conference1]
                os_log("Needed to load conferences for the first time", type: .debug)
                do {
                    try managedContext.save()
                } catch let error as NSError {
                    print("Could not save game to CoreData. \(error), \(error.userInfo)")
                }
            }
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

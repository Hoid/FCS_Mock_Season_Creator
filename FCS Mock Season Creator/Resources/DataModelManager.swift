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
            for (conferenceName, teamNamesForConference) in teamNamesByConferenceName {
                let teamsInConference = teamNamesForConference.map { (teamName) -> Team in
                    return Team(teamName: teamName, conferenceName: conferenceName)
                }
                teamsInConference.forEach({ saveOrCreateTeam(team: $0) })
                let conference = Conference(name: conferenceName, conferenceOption: nil, teams: teamsInConference)
                saveOrCreateConference(conference: conference)
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
    
    public func saveOrCreateGameMO(gameMO: GameMO) {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "GameMO")
        fetchRequest.predicate = NSPredicate(format: "id == %@", gameMO.id)
        
        do {
            let test = try managedContext.fetch(fetchRequest)
            
            let objectUpdate = test[0] as! GameMO
            objectUpdate.setValue(gameMO.id, forKey: "id")
            objectUpdate.setValue(gameMO.conferencesNames, forKeyPath: "conferencesNames")
            objectUpdate.setValue(gameMO.confidence, forKeyPath: "confidence")
            objectUpdate.setValue(gameMO.contestantsNames, forKeyPath: "contestantsNames")
            objectUpdate.setValue(gameMO.winnerName, forKeyPath: "winnerName")
            
            do {
                try managedContext.save()
                os_log("Updating Game to CoreData", type: .debug)
            } catch let error as NSError {
                print("Could not update game to CoreData. \(error), \(error.userInfo)")
            }
        } catch {
            os_log("Could not fetch game from CoreData. Saving it as a new game.", type: .debug)
            
            let entity = NSEntityDescription.entity(forEntityName: "Game", in: managedContext)!
            let newGameMO = GameMO(entity: entity, insertInto: managedContext)
            
            newGameMO.setValue(gameMO.id, forKey: "id")
            newGameMO.setValue(gameMO.conferencesNames, forKeyPath: "conferencesNames")
            newGameMO.setValue(gameMO.confidence, forKeyPath: "confidence")
            newGameMO.setValue(gameMO.contestantsNames, forKeyPath: "contestantsNames")
            newGameMO.setValue(gameMO.winnerName, forKeyPath: "winnerName")
            
            do {
                try managedContext.save()
            } catch let error as NSError {
                print("Could not save new game to CoreData. \(error), \(error.userInfo)")
            }
        }
        
    }
    
    public func saveOrCreateTeam(team: Team) {
        
        os_log("saveOrCreateTeam() called", type: .debug)
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        guard let teamMO = TeamMO.newTeamMO(fromTeam: team) else {
            os_log("Could not get new TeamMO from team in DataModelManager.saveOrCreateTeam()", type: .debug)
            return
        }
        
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "TeamMO")
        fetchRequest.predicate = NSPredicate(format: "name == %@", teamMO.name)
        do {
            let test = try managedContext.fetch(fetchRequest)
            
            let objectUpdate = test[0] as! TeamMO
            objectUpdate.setValue(teamMO.name, forKey: "name")
            objectUpdate.setValue(teamMO.conferenceName, forKey: "conferenceName")
            
            do {
                try managedContext.save()
                os_log("Updating Team to CoreData", type: .debug)
            } catch let error as NSError {
                print("Could not update team to CoreData. \(error), \(error.userInfo)")
            }
        } catch {
            os_log("Could not fetch team from CoreData. Saving it as a new team.", type: .debug)
            
            let entity = NSEntityDescription.entity(forEntityName: "TeamMO", in: managedContext)!
            let newTeamMO = TeamMO(entity: entity, insertInto: managedContext)
            
            newTeamMO.setValue(teamMO.name, forKey: "name")
            newTeamMO.setValue(teamMO.conferenceName, forKey: "conferenceName")
            
            do {
                try managedContext.save()
            } catch let error as NSError {
                print("Could not save new team to CoreData. \(error), \(error.userInfo)")
            }
        }
        
    }
    
    public func saveOrCreateConference(conference: Conference) {
        
        os_log("saveOrCreateConference() called", type: .debug)
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        guard let conferenceMO = ConferenceMO.newConferenceMO(fromConference: conference) else {
            os_log("Could not get new ConferenceMO from conference in DataModelManager.saveOrCreateConference()", type: .debug)
            return
        }
        
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "ConferenceMO")
        fetchRequest.predicate = NSPredicate(format: "name == %@", conferenceMO.name)
        do {
            let test = try managedContext.fetch(fetchRequest)
            
            let objectUpdate = test[0] as! ConferenceMO
            objectUpdate.setValue(conferenceMO.name, forKey: "name")
            objectUpdate.setValue(conferenceMO.teamNames, forKey: "teamNames")
            
            do {
                try managedContext.save()
                os_log("Updating Conference to CoreData", type: .debug)
            } catch let error as NSError {
                print("Could not update team to CoreData. \(error), \(error.userInfo)")
            }
        } catch {
            os_log("Could not fetch team from CoreData. Saving it as a new team.", type: .debug)
            
            let entity = NSEntityDescription.entity(forEntityName: "ConferenceMO", in: managedContext)!
            let newConferenceMO = ConferenceMO(entity: entity, insertInto: managedContext)
            
            newConferenceMO.setValue(conferenceMO.name, forKey: "name")
            newConferenceMO.setValue(conferenceMO.teamNames, forKey: "teamNames")
            
            do {
                try managedContext.save()
            } catch let error as NSError {
                print("Could not save new team to CoreData. \(error), \(error.userInfo)")
            }
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
                guard let game1 = GameMO.newGameMO(id: UUID().uuidString, contestants: ["Elon", "NC A&T"], winner: "Elon", confidence: 65, conferences: [.caa], week: 0),
                    let game2 = GameMO.newGameMO(id: UUID().uuidString, contestants: ["James Madison", "Towson"], winner: "James Madison", confidence: 85, conferences: [.caa], week: 0),
                    let game3 = GameMO.newGameMO(id: UUID().uuidString, contestants: ["Samford", "Youngstown State"], winner: "Samford", confidence: 75, conferences: [.mvfc], week: 0),
                    let game4 = GameMO.newGameMO(id: UUID().uuidString, contestants: ["Elon", "The Citadel"], winner: "Elon", confidence: 60, conferences: [.caa, .southern], week: 1),
                    let game5 = GameMO.newGameMO(id: UUID().uuidString, contestants: ["Elon", "Richmond"], winner: "Elon", confidence: 80, conferences: [.caa], week: 2) else {
                        os_log("Could not create stub games in DataModelManager.loadGames()", type: .default)
                        return
                }
                gamesMO = [game1, game2, game3, game4, game5]
                os_log("Needed to load games for the first time", log: OSLog.default, type: .debug)
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
                guard let team1 = TeamMO.newTeamMO(name: "Elon", conferenceName: "CAA"),
                    let team2 = TeamMO.newTeamMO(name: "JMU", conferenceName: "CAA"),
                    let team3 = TeamMO.newTeamMO(name: "Youngstown State", conferenceName: "MVFC"),
                    let team4 = TeamMO.newTeamMO(name: "The Citadel", conferenceName: "Southern")
                    else {
                        os_log("Could not create stub teams in DataModelManager.loadTeams()", type: .default)
                        return
                }
                teamsMO = [team1, team2, team3, team4]
                os_log("Needed to load teams for the first time", type: .debug)
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
                guard let conference1 = ConferenceMO.newConferenceMO(name: "None", teamNames: ["None"]) else {
                        os_log("Could not create stub conference in DataModelManager.loadTeams()", type: .default)
                        return
                }
                conferencesMO = [conference1]
                os_log("Needed to load conferences for the first time", type: .debug)
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
    
}

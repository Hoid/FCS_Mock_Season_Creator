//
//  FCS_Mock_Season_CreatorTests.swift
//  FCS Mock Season CreatorTests
//
//  Created by Tyler Cheek on 7/7/19.
//  Copyright © 2019 Tyler Cheek. All rights reserved.
//

import XCTest
@testable import FCS_Mock_Season_Creator

class FCS_Mock_Season_CreatorTests: XCTestCase {
    
    var games = [Game]()

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        guard let game1 = Game(id: "game1", contestantsNames: ["Elon", "NC A&T"], winnerName: "Elon", confidence: 65, conferencesNames: ["CAA", "MEAC"], week: 1) else {
            XCTFail("Could not create game in setUp of FCS_Mock_Season_CreatorTests")
            return
        }
        guard let game2 = Game(id: "game2", contestantsNames: ["Elon", "The Citadel"], winnerName: "Elon", confidence: 60, conferencesNames: ["CAA", "Southern"], week: 2) else {
            XCTFail("Could not create game in setUp of FCS_Mock_Season_CreatorTests")
            return
        }
        guard let game3 = Game(id: "game3", contestantsNames: ["Elon", "Richmond"], winnerName: "Elon", confidence: 80, conferencesNames: ["CAA"], week: 3) else {
            XCTFail("Could not create game in setUp of FCS_Mock_Season_CreatorTests")
            return
        }
        guard let game4 = Game(id: "game4", contestantsNames: ["Elon", "Wake Forest"], winnerName: "Wake Forest", confidence: 75, conferencesNames: ["CAA", "None"], week: 4) else {
            XCTFail("Could not create game in setUp of FCS_Mock_Season_CreatorTests")
            return
        }
        games.append(game1)
        games.append(game2)
        games.append(game3)
        games.append(game4)
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testTeamResultsData() throws {
        
        let teamResultsData = TeamResultsData(teamName: "Elon", games: games)
        XCTAssert(teamResultsData.numberOfGamesPlayed == 4)
        let avgConfidenceToWinEachGame = teamResultsData.avgConfidenceToWinEachGame
        print(avgConfidenceToWinEachGame)
        XCTAssert(avgConfidenceToWinEachGame.distance(to: 0.575) < 0.01)
        let likelihoodOfWinningTwoGames = teamResultsData.calculateProbOfWinningXNumberOfGames(gamesWon: 2)
        print(likelihoodOfWinningTwoGames)
        XCTAssert(likelihoodOfWinningTwoGames.distance(to: 0.2646) < 0.01)
        let mostLikelyRecord = teamResultsData.calculateMostLikelyRecord().recordStr
        print("Likelihood of going 0-4: " + String(teamResultsData.calculateProbOfWinningXNumberOfGames(gamesWon: 0)))
        print("Likelihood of going 1-3: " + String(teamResultsData.calculateProbOfWinningXNumberOfGames(gamesWon: 1)))
        print("Likelihood of going 2-2: " + String(teamResultsData.calculateProbOfWinningXNumberOfGames(gamesWon: 2)))
        print("Likelihood of going 3-1: " + String(teamResultsData.calculateProbOfWinningXNumberOfGames(gamesWon: 3)))
        print("Likelihood of going 4-0: " + String(teamResultsData.calculateProbOfWinningXNumberOfGames(gamesWon: 4)))
        print("Most likely record: " + mostLikelyRecord)
        XCTAssert(mostLikelyRecord == "2-2")
        
    }

}

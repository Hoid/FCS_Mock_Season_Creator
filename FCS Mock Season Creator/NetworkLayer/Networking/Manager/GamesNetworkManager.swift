//
//  GamesNetworkManager.swift
//  FCS Mock Season Creator
//
//  Created by Tyler Cheek on 7/19/19.
//  Copyright © 2019 Tyler Cheek. All rights reserved.
//

import Foundation

class GamesNetworkManager: NetworkManager {
    
    var environment: NetworkEnvironment = NetworkEnvironment.production
    var router = Router<GamesApi>()
    
    func getEnvironment() -> NetworkEnvironment {
        return environment
    }
    
    func getGames(completion: @escaping (_ games: [GameApiResponse]?, _ error: String?) -> ()) {
        
        router.request(.games) { data, response, error in
            
            if error != nil {
                completion(nil, "Please check your network connection.")
            }
            
            if let response = response as? HTTPURLResponse {
                let result = self.handleNetworkResponse(response)
                switch result {
                case .success:
                    guard let responseData = data else {
                        completion(nil, NetworkResponse.noData.rawValue)
                        return
                    }
                    do {
                        let apiResponse = try JSONDecoder().decode(GamesApiResponse.self, from: responseData)
                        completion(apiResponse.games, nil)
                    } catch {
                        print(error)
                        completion(nil, NetworkResponse.unableToDecode.rawValue)
                    }
                case .failure(let networkFailureError):
                    completion(nil, networkFailureError)
                }
            }
        }
        
    }
    
    func getGamesNew(completion: @escaping (_ games: [GameNewApiResponse]?, _ error: String?) -> ()) {
        
        router.request(.gamesNew) { data, response, error in
            
            if error != nil {
                completion(nil, "Please check your network connection.")
            }
            
            if let response = response as? HTTPURLResponse {
                let result = self.handleNetworkResponse(response)
                switch result {
                case .success:
                    guard let responseData = data else {
                        completion(nil, NetworkResponse.noData.rawValue)
                        return
                    }
                    do {
                        let apiResponse = try JSONDecoder().decode(GamesNewApiResponse.self, from: responseData)
                        completion(apiResponse.games, nil)
                    } catch {
                        print(error)
                        completion(nil, NetworkResponse.unableToDecode.rawValue)
                    }
                case .failure(let networkFailureError):
                    completion(nil, networkFailureError)
                }
            }
        }
        
    }
    
}

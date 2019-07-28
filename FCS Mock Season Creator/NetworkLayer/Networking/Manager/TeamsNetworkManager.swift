//
//  TeamsNetworkManager.swift
//  FCS Mock Season Creator
//
//  Created by Tyler Cheek on 7/27/19.
//  Copyright © 2019 Tyler Cheek. All rights reserved.
//

import Foundation

class TeamsNetworkManager: NetworkManager {
    
    var environment: NetworkEnvironment = NetworkEnvironment.production
    var router = Router<TeamsApi>()
    
    func getEnvironment() -> NetworkEnvironment {
        return environment
    }
    
    func getTeams(completion: @escaping (_ teamNames: [String]?, _ error: String?) -> ()) {
        
        router.request(.teams) { data, response, error in
            
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
                        let apiResponse = try JSONDecoder().decode(TeamsApiResponse.self, from: responseData)
                        completion(apiResponse.teamNames, nil)
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

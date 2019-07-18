//
//  TeamsByConferenceNetworkManager.swift
//  FCS Mock Season Creator
//
//  Created by Tyler Cheek on 7/16/19.
//  Copyright © 2019 Tyler Cheek. All rights reserved.
//

import Foundation

class TeamsByConferenceNetworkManager: NetworkManager {
    
    var environment: NetworkEnvironment = NetworkEnvironment.production
    var router = Router<TeamsByConferenceApi>()
    
    func getEnvironment() -> NetworkEnvironment {
        return environment
    }
    
    func getTeamsByConference(completion: @escaping (_ teamsByConference: [String : [String]]?, _ error: String?) -> ()) {
        
        router.request(.teamsByConference) { data, response, error in
            
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
                        let apiResponse = try JSONDecoder().decode(TeamsByConferenceApiResponse.self, from: responseData)
                        completion(apiResponse.teamsByConference, nil)
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

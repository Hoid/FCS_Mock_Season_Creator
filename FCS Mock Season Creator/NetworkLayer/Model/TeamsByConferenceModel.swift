//
//  TeamsByConferenceModel.swift
//  FCS Mock Season Creator
//
//  Created by Tyler Cheek on 7/16/19.
//  Copyright © 2019 Tyler Cheek. All rights reserved.
//

import Foundation

struct TeamsByConferenceApiResponse {
    let teamsByConference: [String : [String]]
}

extension TeamsByConferenceApiResponse: Decodable {
    
    private enum TeamsByConferenceApiResponseCodingKeys: String, CodingKey {
        case data = "data"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: TeamsByConferenceApiResponseCodingKeys.self)
        
        teamsByConference = try container.decode([String : [String]].self, forKey: .data)
        
    }
}


struct TeamsByConference {
    let teamsByConference: [String : [String]]
}

extension TeamsByConference: Decodable {
    
    enum TeamsByConferenceCodingKeys: String, CodingKey {
        case data = "data"
    }
    
    
    init(from decoder: Decoder) throws {
        let teamsByConferenceContainer = try decoder.container(keyedBy: TeamsByConferenceCodingKeys.self)
        
        teamsByConference = try teamsByConferenceContainer.decode([String : [String]].self, forKey: .data)
    }
}

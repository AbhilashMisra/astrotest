//
//  Fact.swift
//  astrotest
//
//  Created by Abhilash Mishra on 22/03/23.
//

import Foundation

struct Fact: Codable {
    let copyright: String?
    let date: Date
    let explanation: String
    let hdurl: String?
    let mediaType: String
    let serviceVersion: String
    let title: String
    let url: String
    
    enum CodingKeys: String, CodingKey {
        case copyright
        case date
        case explanation
        case hdurl
        case mediaType = "media_type"
        case serviceVersion = "service_version"
        case title
        case url
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.copyright = try? container.decode(String.self, forKey: .copyright)
        self.explanation = try container.decode(String.self, forKey: .explanation)
        self.hdurl = try? container.decode(String.self, forKey: .hdurl)
        self.mediaType = try container.decode(String.self, forKey: .mediaType)
        self.serviceVersion = try container.decode(String.self, forKey: .serviceVersion)
        self.title = try container.decode(String.self, forKey: .title)
        self.url = try container.decode(String.self, forKey: .url)
        
        let dateStr = try container.decode(String.self, forKey: .date)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = .current
        // Since date would be unique id for our problem, we can assume it will always be coming and in same fashion
        self.date = formatter.date(from: dateStr)!
    }
    
    init(copyright: String?, date: Date, explanation: String, hdurl: String?, mediaType: String, serviceVersion: String, title: String, url: String) {
        self.copyright = copyright
        self.date = date
        self.explanation = explanation
        self.hdurl = hdurl
        self.mediaType = mediaType
        self.serviceVersion = serviceVersion
        self.title = title
        self.url = url
    }
}

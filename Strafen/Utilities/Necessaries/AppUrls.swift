//
//  AppUrls.swift
//  Strafen
//
//  Created by Steven on 27.06.20.
//

import Foundation

/// Contains all urls for the app
struct AppUrls {
    
    /// Urls of the different app types
    struct AppTypesUrls {
        
        /// for person
        let person: URL
        
        /// for fine
        let fine: URL
        
        /// for reason
        let reason: URL
    }
    
    /// Contains all changer urls
    struct Changer {
        
        /// for new club
        let newClub: URL
        
        /// for changing club image
        let clubImage: URL
        
        init(_ appUrls: CodableAppUrls) {
            let baseUrl = URL(string: appUrls.baseUrl)!
            newClub = baseUrl.appendingPathComponent(appUrls.changer.newClub)
            clubImage = baseUrl.appendingPathComponent(appUrls.changer.clubImage)
        }
    }
    
    /// Used to decode app urls from json
    struct CodableAppUrls: Decodable {
        
        /// Used to decode urls of the different app types
        struct AppTypes: Decodable {
            
            /// for person
            let person: String
            
            /// for fine
            let fine: String
            
            /// for reason
            let reason: String
        }
        
        /// Used to decode urls for changers
        struct ChangerTypes: Decodable {
            
            /// for new club
            let newClub: String
            
            /// for changing club image
            let clubImage: String
        }
        
        /// Base url of server
        let baseUrl: String
        
        /// Url extensions for lists of different app types
        let lists: AppTypes
        
        /// Url extensions for image directory
        let imagesDirectory: String
        
        /// Url extensions for changer
        let changer: ChangerTypes
        
        /// Authorization for server
        let authorization: String
        
        /// Changer key
        let key: String
        
        /// Cipher Key
        let cipherKey: String
        
        /// Url extension for settings file
        let settings: String
    }
    
    /// Shared instance for singelton
    static let shared = AppUrls()
    
    /// Private init for singleton
    private init() {
        let decoder = JSONDecoder()
        codableAppUrls = try! decoder.decode(CodableAppUrls.self, from: appUrls.data(using: .utf8)!)
    }
    
    /// Used to decode app urls from json
    let codableAppUrls: CodableAppUrls
    
    /// Url for the different app lists
    ///
    /// nil if no person logged in
    var listUrls: AppTypesUrls? {
        guard let loggedInPerson = Settings.shared.person else { return nil }
        let baseUrl = URL(string: codableAppUrls.baseUrl)!
        let personUrl = baseUrl.appendingPathComponent(loggedInPerson.clubId.uuidString).appendingPathComponent(codableAppUrls.lists.person)
        let fineUrl = baseUrl.appendingPathComponent(loggedInPerson.clubId.uuidString).appendingPathComponent(codableAppUrls.lists.fine)
        let reasonUrl = baseUrl.appendingPathComponent(loggedInPerson.clubId.uuidString).appendingPathComponent(codableAppUrls.lists.reason)
        return AppTypesUrls(person: personUrl, fine: fineUrl, reason: reasonUrl)
    }
    
    /// Url for the image directory
    ///
    /// nil if no person logged in
    var imagesDirUrl: URL? {
        guard let loggedInPerson = Settings.shared.person else { return nil }
        let baseUrl = URL(string: codableAppUrls.baseUrl)!
        return baseUrl.appendingPathComponent(loggedInPerson.clubId.uuidString).appendingPathComponent(codableAppUrls.imagesDirectory)
    }
    
    /// Contains all changer urls
    var changer: Changer {
        Changer(codableAppUrls)
    }
    
    /// Contains username and password for website authorization
    var loginString: String {
        codableAppUrls.authorization
    }
    
    /// Changer key
    var key: String {
        codableAppUrls.key
    }
    
    /// Cipher Key
    var cipherKey: String {
        codableAppUrls.cipherKey
    }
    
    /// Url for settings file
    var settingsUrl: URL {
        let documentDirecory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let settingsUrl = documentDirecory.appendingPathComponent(codableAppUrls.settings)
        
        // Create settings file if it doesn't exist
        if !FileManager.default.fileExists(atPath: settingsUrl.path) {
            let encoder = JSONEncoder()
            let settingsData = try! encoder.encode(Settings.default)
            FileManager.default.createFile(atPath: settingsUrl.path, contents: settingsData, attributes: nil)
        }
        return settingsUrl
    }
}

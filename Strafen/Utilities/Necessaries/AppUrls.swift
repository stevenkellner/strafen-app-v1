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
    struct ListTypesUrls {
        
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
        
        /// for register new person
        let registerPerson: URL
        
        /// for sending code mail
        let mailCode: URL
        
        /// for changing person image
        let personImage: URL
        
        /// for person list
        let personList: URL
        
        /// for reason list
        let reasonList: URL
        
        /// for fine list
        let fineList: URL
        
        /// for late payment interest
        let latePaymentInterest: URL
        
        /// for force sign out
        let forceSignOut: URL
        
        init(_ appUrls: CodableAppUrls) {
            let baseUrl = URL(string: appUrls.baseUrl)!
            newClub = baseUrl.appendingPathComponent(appUrls.changer.newClub)
            clubImage = baseUrl.appendingPathComponent(appUrls.changer.clubImage)
            registerPerson = baseUrl.appendingPathComponent(appUrls.changer.registerPerson)
            mailCode = baseUrl.appendingPathComponent(appUrls.changer.mailCode)
            personImage = baseUrl.appendingPathComponent(appUrls.changer.personImage)
            personList = baseUrl.appendingPathComponent(appUrls.changer.personList)
            reasonList = baseUrl.appendingPathComponent(appUrls.changer.reasonList)
            fineList = baseUrl.appendingPathComponent(appUrls.changer.fineList)
            latePaymentInterest = baseUrl.appendingPathComponent(appUrls.changer.latePaymentInterest)
            forceSignOut = baseUrl.appendingPathComponent(appUrls.changer.forceSignOut)
        }
    }
    
    /// Shared instance for singelton
    static let shared = Self()
    
    /// Private init for singleton
    private init() {
        let decoder = JSONDecoder()
        codableAppUrls = try! decoder.decode(CodableAppUrls.self, from: appUrls.data(using: .utf8)!)
    }
    
    /// Used to decode app urls from json
    private var codableAppUrls: CodableAppUrls
    
    /// Url for the different app lists
    ///
    /// nil if no person logged in
    var listTypesUrls: ListTypesUrls? {
        guard let loggedInPerson = Settings.shared.person else { return nil }
        let baseUrl = URL(string: codableAppUrls.baseUrl)!.appendingPathComponent("clubs").appendingPathComponent(loggedInPerson.clubId.uuidString)
        let personUrl = baseUrl.appendingPathComponent(codableAppUrls.lists.person)
        let fineUrl = baseUrl.appendingPathComponent(codableAppUrls.lists.fine)
        let reasonUrl = baseUrl.appendingPathComponent(codableAppUrls.lists.reason)
        return ListTypesUrls(person: personUrl, fine: fineUrl, reason: reasonUrl)
    }
    
    /// Url of person list of given clubId
    func personListUrl(of clubId: UUID) -> URL {
        let baseUrl = URL(string: codableAppUrls.baseUrl)!
        return baseUrl.appendingPathComponent("clubs").appendingPathComponent(clubId.uuidString).appendingPathComponent(codableAppUrls.lists.person)
    }
    
    /// Url for the image directory of given clubId
    func imageDirUrl(of clubId: UUID) -> URL {
        let baseUrl = URL(string: codableAppUrls.baseUrl)!
        return baseUrl.appendingPathComponent("clubs").appendingPathComponent(clubId.uuidString).appendingPathComponent(codableAppUrls.imagesDirectory)
    }
    
    /// Url for the image directory
    ///
    /// nil if no person logged in
    var imagesDirUrl: URL? {
        guard let loggedInPerson = Settings.shared.person else { return nil }
        let baseUrl = URL(string: codableAppUrls.baseUrl)!
        return baseUrl.appendingPathComponent("clubs").appendingPathComponent(loggedInPerson.clubId.uuidString).appendingPathComponent(codableAppUrls.imagesDirectory)
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
        let archiveUrl = FileManager.default.sharedContainerUrl
        let settingsUrl = archiveUrl.appendingPathComponent(codableAppUrls.settings)
        
        // Create settings file if it doesn't exist
        if !FileManager.default.fileExists(atPath: settingsUrl.path) {
            let encoder = JSONEncoder()
            let settingsData = try! encoder.encode(Settings.default)
            FileManager.default.createFile(atPath: settingsUrl.path, contents: settingsData)
        }
        return settingsUrl
    }
    
    /// Url for notes file
    var notesUrl: URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let notesUrl = documentsDirectory.appendingPathComponent(codableAppUrls.notes)
        
        // Create notes file if it doesn't exist
        if !FileManager.default.fileExists(atPath: notesUrl.path) {
            FileManager.default.createFile(atPath: notesUrl.path, contents: "[]".data(using: .utf8))
        }
        return notesUrl
    }
    
    /// Url for allClubs
    var allClubsUrl: URL? {
        let baseUrl = URL(string: codableAppUrls.baseUrl)!
        return baseUrl.appendingPathComponent(codableAppUrls.lists.allClubs)
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
        
        /// for all clubs
        let allClubs: String
    }
    
    /// Used to decode urls for changers
    struct ChangerTypes: Decodable {
        
        /// for new club
        let newClub: String
        
        /// for changing club image
        let clubImage: String
        
        /// for register a new person
        let registerPerson: String
        
        /// for sending code mail
        let mailCode: String
        
        /// for changing person image
        let personImage: String
        
        /// for person list
        let personList: String
        
        /// for reason list
        let reasonList: String
        
        /// for fine list
        let fineList: String
        
        /// for late payment interest
        let latePaymentInterest: String
        
        /// for force Sign Out
        let forceSignOut: String
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
    
    /// Url extension for notes file
    let notes: String
}

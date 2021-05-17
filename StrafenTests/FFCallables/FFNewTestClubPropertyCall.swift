//
//  FFNewTestClubPropertyCall.swift
//  StrafenTests
//
//  Created by Steven on 06.05.21.
//

import Foundation
@testable import Strafen

/// Creates a test club property in database
struct FFNewTestClubPropertyCall: FFCallable {

    /// Id of test club to delete
    let clubId: Club.ID

    /// Url from club to property to delete
    let urlFromClub: URL

    /// New property
    let property: FirebaseParameterable

    let functionName = "newTestClubProperty"

    var parameters: FirebaseCallParameterSet {
        FirebaseCallParameterSet { parameters in
            parameters["clubId"] = clubId
            parameters["propertyPath"] = urlFromClub
            parameters["data"] = property
        }
    }
}

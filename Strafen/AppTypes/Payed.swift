//
//  Payed.swift
//  Strafen
//
//  Created by Steven on 11/7/20.
//

import Foundation

/// Fine payed
enum Payed {
    
    /// Payed
    case payed(date: Date)
    
    /// Unpayed
    case unpayed
}

// Extension of Payed to confirm to Decodable
extension Payed: Decodable, Equatable {
    
    /// Used to decode payed state and date
    private struct CodablePayed: Decodable {
        
        /// State (payed ot unpayed)
        let state: String
        
        /// Date of payment
        let payDate: Date?
    }
    
    /// Init from decoder
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawPayed = try container.decode(CodablePayed.self)
        switch rawPayed.state {
        case "unpayed":
            self = .unpayed
        case "payed":
            guard let date = rawPayed.payDate else {
                throw DecodingError.dataCorruptedError(in: container, debugDescription: "Date for payed not found.")
            }
            self = .payed(date: date)
        default:
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid state found: \(rawPayed.state)")
        }
    }
}

#if TARGET_MAIN_APP
// Extension of Payed to confirm to ParameterableObject
extension Payed: ParameterableObject {
    
    /// State of payment
    var state: String {
        switch self {
        case .unpayed:
            return "unpayed"
        case .payed(date: _):
            return "payed"
        }
    }
    
    /// Pay date (only for payed)
    var payDate: Date? {
        switch self {
        case .unpayed:
            return nil
        case .payed(date: let date):
            return date
        }
    }
    
    /// Object call with Firebase function as Parameter
    var parameterableObject: _ParameterableObject {
        ["state": state, "payDate": payDate?.parameterableObject]
    }
}
#endif

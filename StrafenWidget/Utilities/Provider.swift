//
//  Provider.swift
//  Strafen
//
//  Created by Steven on 24.07.20.
//

import WidgetKit
import SwiftUI

/// Timeline Provider of Strafen Widget
struct Provider: TimelineProvider {
    
    /// Time interval between two timeline requests
    ///
    /// 3600sec = 1h
    let timeIntervalToUpdate: TimeInterval = 3600
    
    /// Time interval between two timeline requests if no connection
    ///
    /// 300sec = 5min
    let timeIntervalToUpdateNoconnection: TimeInterval = 300
    
    /// Creates a snapshot of the widget
    func snapshot(with context: Context, completion: @escaping (WidgetEntry) -> ()) {
        completion(WidgetEntry(date: Date(), widgetEntryType: .noConnection))
    }
    
    /// Creates a timeline of the widget
    func timeline(with context: Context, completion: @escaping (Timeline<WidgetEntry>) -> ()) {
        
        // Check if person is logged in
        if let person = WidgetUrls.shared.person {
            
            // Enter dispatch group to fetch person- / reason- and finelist
            let dispatchGroup = DispatchGroup()
            dispatchGroup.enter()
            dispatchGroup.enter()
            
            // Get lists
            var reasonList: [WidgetReason]?
            var fineList: [WidgetFine]?
            
            // Fetch reason list
            WidgetListFetcher.shared.fetch(of: person.clubId) { (fetchedList: [WidgetReason]?) in
                reasonList = fetchedList
                dispatchGroup.leave()
            }
            
            // Fetch fine list
            WidgetListFetcher.shared.fetch(of: person.clubId) { (fetchedList: [WidgetFine]?) in
                
                // Filter list only for person
                fineList = fetchedList?.filter { $0.personId == person.id }
                dispatchGroup.leave()
            }
            
            // Check if all lists aren't nil
            dispatchGroup.notify(queue: .main) {
                if let reasonList = reasonList, let fineList = fineList {
                    
                    // Map fine list to get data from template
                    let fineNoTemplateList =  fineList.map { fine -> WidgetFineNoTemplate in
                        let fineReason = fine.fineReason.fineReasonCustom(reasonList: reasonList)
                        let fineNoTemplate = WidgetFineNoTemplate(date: fine.date, payed: fine.payed, number: fine.number, id: fine.id, fineReason: fineReason)
                        return fineNoTemplate
                    }
                    
                    // Get timeline
                    let dateForNextTimelineRequest = Date(timeIntervalSinceNow: timeIntervalToUpdate)
                    let widgetEntryType: WidgetEntryType = .success(person: person, fineList: fineNoTemplateList)
                    let entry = WidgetEntry(date: dateForNextTimelineRequest, widgetEntryType: widgetEntryType)
                    let timeline = Timeline(entries: [entry], policy: .atEnd)
                    completion(timeline)
                } else {
                    
                    // No internet connection
                    let dateForNextTimelineRequest = Date(timeIntervalSinceNow: timeIntervalToUpdateNoconnection)
                    let widgetEntryType: WidgetEntryType = .noConnection
                    let entry = WidgetEntry(date: dateForNextTimelineRequest, widgetEntryType: widgetEntryType)
                    let timeline = Timeline(entries: [entry], policy: .atEnd)
                    completion(timeline)
                }
            }
        } else {
            
            // No person is logged in
            let dateForNextTimelineRequest = Date(timeIntervalSinceNow: timeIntervalToUpdateNoconnection)
            let widgetEntryType: WidgetEntryType = .noPersonLoggedIn
            let entry = WidgetEntry(date: dateForNextTimelineRequest, widgetEntryType: widgetEntryType)
            let timeline = Timeline(entries: [entry], policy: .atEnd)
            completion(timeline)
        }
    }
}

/// Entry of timeline of Strafen Widget
struct WidgetEntry: TimelineEntry {
    
    /// Date of next timeline request
    let date: Date
    
    /// Widget entry type
    let widgetEntryType: WidgetEntryType
}

/// Type of Widget entry
enum WidgetEntryType {
    
    /// Widget entry type with success
    case success(person: WidgetUrls.CodableSettings.Person, fineList: [WidgetFineNoTemplate])
    
    /// Widget entry type with no connection
    case noConnection
    
    /// Widget entry type with no person logged in
    case noPersonLoggedIn
}
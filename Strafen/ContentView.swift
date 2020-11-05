//
//  ContentView.swift
//  Strafen
//
//  Created by Steven on 26.06.20.
//

import SwiftUI
import FirebaseAuth

/// View with all relevant app contents.
struct ContentView: View {
    
    /// Observed Object that contains all settings of the app of this device
    @ObservedObject var settings = NewSettings.shared
    
    /// List data that contains all datas of the different lists
    @ObservedObject var listData = ListData.shared
    
    var body: some View {
        ZStack {
            
            // Activity View
            ActivityView.shared
            
            if listData.forceSignedOut {
                
                // Force Sign Out View
                ContentForceSignedOutView()
                
            } else if settings.properties.person != nil && Auth.auth().currentUser != nil {
                
                Text("Log out")
                    .onTapGesture {
                        do {
                            try Auth.auth().signOut()
                            NewSettings.shared.properties.person = nil
                        } catch {
                            print(error)
                        }
                    }
                
                // Home Tabs View and Tab Bar
//                ContentHomeView()
//                    .onAppear {
//
//                        // Fetch note list
//                        ListData.note.list = nil
//                        ListData.note.fetch()
//
//                        ListData.shared.fetchLists()
//                    }
                
            } else {
                
                // Login Entry View
                LoginEntryView()
                    .edgesIgnoringSafeArea(.all)
                
            }
        }.onAppear {
            NewSettings.shared.applySettings()
        }
    }
    
    /// View to force sign out a signed in person
    struct ContentForceSignedOutView: View {
        
        /// Color scheme to get appearance of this device
        @Environment(\.colorScheme) var colorScheme
        
        var body: some View {
            ZStack {
                
                // Backgroud color
                colorScheme.backgroundColor
                
                // Force Signed Out View
                ForceSignedOutView()
                
            }.edgesIgnoringSafeArea(.all)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    /// Home Tab Views and Tab Bar
    struct ContentHomeView: View {
        
        /// Handler to dimiss from a subview to the previous view.
        @State var dismissHandler: DismissHandler = nil
        
        /// Color scheme to get appearance of this device
        @Environment(\.colorScheme) var colorScheme
        
        /// Active home tab
        @ObservedObject var homeTabs = HomeTabs.shared
        
        /// Size of the home view and tab bar on the screen
        @State var screenSize: CGSize?
        
        var body: some View {
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    
                    // Home Views
                    HomeTabsView(dismissHandler: $dismissHandler)
                        .edgesIgnoringSafeArea(.all)
                        .background(colorScheme.backgroundColor)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                    // Tab bar
                    TabBar(dismissHandler: $dismissHandler)
                        .edgesIgnoringSafeArea([.horizontal, .top])
                    
                }.frame(size: screenSize ?? geometry.size)
                    .onAppear {
                        screenSize = geometry.size
                    }
            }.frame(maxWidth: .infinity, maxHeight: .infinity)
                .onOpenURL { url in
                    homeTabs.active = url.pathComponents.first == "profileDetail" ? .profileDetail : homeTabs.active
                }
        }
    }
}

// TODO
import OSLog

/// Used to log messages
struct Logging {
    
    /// Shared instance for singelton
    static let shared = Self()
    
    /// Private init for singleton
    private init() {}
    
    let logLevelHigherEqual: OSLogType = .default
    
    /// Logges a message with given logging level
    func log(with level: OSLogType, _ messages: String..., file: String = #fileID, function: String = #function, line: Int = #line) {
        guard level.rawValue >= logLevelHigherEqual.rawValue else { return }
        let logger = Logger(subsystem: "Strafen-App", category: "File: \(file), in Function: \(function), at Line: \(line)")
        let message = messages.joined(separator: "\n\t")
        logger.log(level: level, "\(level.levelName.uppercased(), privacy: .public) | \(message, privacy: .public)")
    }
}

extension OSLogType {
    var levelName: String {
        switch self {
        case .default:
            return "(Default)"
        case .info:
            return "(Info)   "
        case .debug:
            return "(Debug)  "
        case .error:
            return "(Error)  "
        case .fault:
            return "(Fault)  "
        default:
            return "(Unknown)"
        }
    }
}

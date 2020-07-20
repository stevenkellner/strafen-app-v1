//
//  SignInEMailValidationView.swift
//  Strafen
//
//  Created by Steven on 30.06.20.
//

import SwiftUI

struct SignInEMailValidationView: View {
    
    /// States of SignInEMailValidationView
    enum PageState {
        
        /// Used in email code input page
        case codeInput
        
        /// Used in club join page
        case joinClub
    }
    
    /// Errors occurs on club code input
    enum ClubCodeError {
        
        /// No Internet connection
        case noInternet
        
        /// Unable to create UUID from Code
        case noValidCode
        
        /// no club with this Code
        case doesntExist
    }
    
    /// Input email
    @Binding var email: String
    
    /// Contains first and last name of a person
    let personName: PersonName
    
    /// Contains all properties for the login
    let personLogin: PersonLogin
    
    /// Used to indicate whether signIn sheet is displayed or not
    @Binding var showSignInSheet: Bool
    
    /// Input Email Code
    @State var inputEmailCode = ""
    
    /// Input club code
    @State var inputClubCode = ""
    
    /// Entered club id
    @State var clubId: UUID?
    
    /// club name of entered club id
    @State var clubName: String?
    
    /// States of SignInEMailValidationView
    @State var state: PageState = .codeInput
    
    /// Indicate whether confirm button is clicked or not
    @State var confirmButtonClicked = false
    
    /// Errors occurs on club code input
    @State var clubCodeError: ClubCodeError = .noValidCode
    
    /// Show club code input error alert
    @State var showClubCodeInputErrorAlert = false
    
    /// Show club email input error alert
    @State var showEmailCodeInputErrorAlert = false
    
    /// True if email keyboard is on screen
    @State var emailCodeKeyboardOnScreen = false
    
    /// Club list data
    @ObservedObject var clubListData = ListData.club
    
    /// Presentation mode
    @Environment(\.presentationMode) var presentationMode
    
    /// Color scheme to get appearance of this device
    @Environment(\.colorScheme) var colorScheme
    
    /// Observed Object that contains all settings of the app of this device
    @ObservedObject var settings = Settings.shared
    
    var body: some View {
        ZStack {
            
            // Navigation Link
            NavigationLink(destination: SignInSelectPersonView(personName: personName, personLogin: personLogin, clubId: clubId, clubName: clubName, showSignInSheet: $showSignInSheet), isActive: $confirmButtonClicked) {
                    EmptyView()
            }.frame(width: 0, height: 0)
            
            // Back Button
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    Text("Zurück")
                        .font(.text(25))
                        .foregroundColor(.textColor)
                        .padding(.leading, 15)
                        .onTapGesture {
                            presentationMode.wrappedValue.dismiss()
                        }
                    Spacer()
                }.padding(.top, 30)
                Spacer()
            }
            
            VStack(spacing: 0) {
                
                // Bar to wipe sheet down
                SheetBar()
                
                // Header
                Header("Registrieren")
                    .padding(.top, 30)
                
                // Content
                ZStack {
                    
                    // Code input page
                    VStack(spacing: 0) {
                        
                        Spacer()
                        
                        // Text
                        Text("Es wurde ein Bestätigungscode an deine E-Mail Adresse \(email) gesendet.")
                            .font(.text(25))
                            .foregroundColor(.textColor)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 25)
                        
                        // Code Text Field
                        CustomTextField("Bestätigungscode", text: $inputEmailCode, keyboardOnScreen: $emailCodeKeyboardOnScreen)
                            .frame(width: UIScreen.main.bounds.width * 0.95, height: 50)
                            .padding(.top, 50)
                            .alert(isPresented: $showEmailCodeInputErrorAlert) {
                                Alert(title: Text("Falscher Code"), message: Text("\(inputEmailCode) ist nicht der richtige Code."), dismissButton: .default(Text("Verstanden")))
                            }
                        
                        Spacer()
                        
                    }.opacity(state == .codeInput ? 1 : 0)
                        .offset(y: state == .codeInput ? emailCodeKeyboardOnScreen ? -130 : 0 : -100)
                        .clipShape(Rectangle())
                    
                    // Club join page
                    VStack(spacing: 0) {
                        
                        Spacer()
                        
                        // Text
                        Text("Vereinscode eingeben.\nDu bekommst den Code von deinem Trainer oder Kassier.")
                            .font(.text(20))
                            .foregroundColor(.textColor)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 25)
                        
                        HStack(spacing: 0) {
                            Spacer()
                        
                            // Club code text field
                            CustomTextField("Vereinscode", text: $inputClubCode, keyboardType: .numbersAndPunctuation)
                                .frame(width: UIScreen.main.bounds.width * 0.675, height: 50)
                            
                            Spacer()
                            
                            // Paste Button
                            Button {
                                if let pasteString = UIPasteboard.general.string {
                                    inputClubCode = pasteString
                                }
                            } label: {
                                Image(systemName: "doc.on.clipboard")
                                    .font(.system(size: 30, weight: .light))
                                    .foregroundColor(.textColor)
                            }
                            
                            Spacer()
                        }.padding(.top, 30)
                        
                        Spacer()
                        
                        // Text
                        Text("Wenn du der Kassier bist:\nErstelle eine neue Strafen Liste.")
                            .font(.text(20))
                            .foregroundColor(.textColor)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 25)
                        
                        // Button
                        NavigationLink(destination: SignInNewClubView(personName: personName, personLogin: personLogin, showSignInSheet: $showSignInSheet)) {
                            ZStack {
                                
                                // Outline
                                Outline()
                                    .fillColor(settings.style.fillColor(colorScheme, defaultStyle: Color.custom.orange))
                                
                                // Text
                                Text("Erstellen")
                                    .foregroundColor(settings.style == .default ? Color.custom.gray : Color.custom.orange)
                                    .font(.text(20))
                                    .lineLimit(1)
                                
                            }.frame(width: UIScreen.main.bounds.width * 0.95, height: 50)
                        }.padding(.top, 30)
                        
                        Spacer()
                    }.opacity(state == .joinClub ? 1 : 0)
                        .offset(y: state == .joinClub ? 0 : 100)
                    
                }
                
                // Confirm Button
                ConfirmButton("Weiter") {
                    switch state {
                    case .codeInput:
                        if inputEmailCode == SendCodeMail.shared.code {
                            withAnimation {
                                state = .joinClub
                            }
                        } else {
                            showEmailCodeInputErrorAlert = true
                        }
                    case .joinClub:
                        if let clubId = UUID(uuidString: inputClubCode) {
                            if let club = clubListData.list?.first(where: { $0.id == clubId }) {
                                ListData.person.list = nil
                                ListData.person.fetch(from: AppUrls.shared.personListUrl(of: clubId)) {
                                    // TODO no connection
                                }
                                confirmButtonClicked = true
                                self.clubId = club.id
                                clubName = club.name
                            } else {
                                clubCodeError = .doesntExist
                                showClubCodeInputErrorAlert = true
                            }
                        } else {
                            clubCodeError = .noValidCode
                            showClubCodeInputErrorAlert = true
                        }
                    }
                }.padding(.bottom, 50)
                    .alert(isPresented: $showClubCodeInputErrorAlert) {
                        switch clubCodeError {
                        case .doesntExist:
                            return Alert(title: Text("Kein Verein gefunden"), message: Text("Es wurde kein Verein mit diesem Code gefunden."), dismissButton: .default(Text("Verstanden")))
                        case .noInternet:
                            return Alert(title: Text("Kein Internet"), message: Text("Es wird eine Internetverbindung benötigt um sich zu registrieren."), dismissButton: .default(Text("Verstanden")))
                        case .noValidCode:
                            return Alert(title: Text("Kein gültiger Code"), message: Text("Der eingegebene Code hat nicht das richtige Format."), dismissButton: .default(Text("Verstanden")))
                        }
                    }

            }
        }.background(colorScheme.backgroundColor)
            .navigationTitle("title")
            .navigationBarHidden(true)
    }
}

#if DEBUG
struct SignInEMailValidationView_Previews: PreviewProvider {
    static var previews: some View {
        SignInEMailValidationView(email: .constant(""), personName: PersonName(firstName: "", lastName: ""), personLogin: PersonLoginEmail(email: "", password: ""), showSignInSheet: .constant(false))
            .edgesIgnoringSafeArea(.all)
    }
}
#endif

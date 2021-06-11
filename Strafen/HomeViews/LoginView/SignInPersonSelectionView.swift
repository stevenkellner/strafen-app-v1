//
//  SignInPersonSelectionView.swift
//  Strafen
//
//  Created by Steven on 18.05.21.
//

import SwiftUI

struct SignInPersonSelectionView: View {

    // MARK: input properties

    /// Contains all input properties
    struct InputProperties {

        /// Connection state of fetch person list
        var fetchConnectionState: ConnectionState = .notStarted

        /// Handler used to remove person list observer
        var removeObserver: (() -> Void)?

        /// Person list of the club
        var personList: [FirebasePerson]?

        /// Id of selected person
        var selectedPersonId: FirebasePerson.ID?

        /// Connection state for register button clicked
        var registerConnectionState: ConnectionState = .notStarted

        /// Error message
        var errorMessage: ErrorMessages?
    }

    // MARK: properties

    /// Sign in property with userId, name and club  id
    let signInProperty: SignInProperty.UserIdNameClubId

    /// Init with sign in property
    /// - Parameter signInProperty: Sign in property with userId, name and clubId
    init(signInProperty: SignInProperty.UserIdNameClubId) {
        self.signInProperty = signInProperty
    }

    /// All properties of the textfield inputs
    @State private var inputProperties = InputProperties()

    // MARK: body
    var body: some View {
        ZStack {

            // Background color
            Color.backgroundGray

            // Content
            VStack(spacing: 0) {

                // Back button
                BackButton()
                    .padding(.top, 50)

                // Header
                Header("select-person-header", table: .logInSignIn, comment: "Select person header")
                    .padding(.top, 10)

                // Select person text
                if inputProperties.fetchConnectionState != .failed && inputProperties.errorMessage == nil {
                    Text("select-name-if-available-message", table: .logInSignIn, comment: "Select name if available message")
                        .foregroundColor(.white)
                        .font(.system(size: 24, weight: .thin))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 15)
                        .lineLimit(2)
                        .padding(.top, 20)
                } else {
                    ErrorMessageView($inputProperties.errorMessage)
                        .padding(.top, 20)
                }

                Spacer()

                if inputProperties.fetchConnectionState == .passed,
                   let personList = inputProperties.personList {
                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: 15) {
                            ForEach(personList.sortedForList) { person in
                                PersonListRow(person, clubId: signInProperty.clubId, selected: $inputProperties.selectedPersonId)
                            }
                        }.padding(.vertical, 10)
                    }
                } else if inputProperties.fetchConnectionState == .failed {
                    Text("no-connection-message", table: .otherTexts, comment: "No connection message")
                        .foregroundColor(.white)
                        .font(.system(size: 24, weight: .thin))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 15)
                        .lineLimit(2)
                    Text("try-again-message", table: .otherTexts, comment: "Try again message")
                        .foregroundColor(.customRed)
                        .font(.system(size: 24, weight: .light))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 15)
                        .lineLimit(2)
                        .padding(.top, 30)
                        .onTapGesture(perform: fetchPersonList)
                } else {
                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: 15) {
                            ForEach([FirebasePerson].randomList(of: 5)) { person in
                                PersonListRow(person, clubId: signInProperty.clubId, selected: $inputProperties.selectedPersonId, placeholder: true)
                            }
                        }.padding(.vertical, 10)
                    }
                }

                Spacer()

                // Confirm button
                SingleButton("sign-in-button-text", table: .logInSignIn, comment: "Text of sign in button")
                    .fontSize(27)
                    .rightSymbol(name: "signpost.right")
                    .rightColor(.customGreen)
                    .connectionState($inputProperties.registerConnectionState)
                    .onClick(perform: handleRegisterButtonPress)
                    .padding(.bottom, 55)

            }
        }.maxFrame
            .onAppear(perform: fetchPersonList)
            .onDisappear { inputProperties.removeObserver?() }
    }

    // MARK: methods

    /// Fetches person list of selected club
    func fetchPersonList() {
        Self.fetchPersonList(signInProperty: signInProperty, inputProperty: $inputProperties)
    }

    /// Handles register button press
    func handleRegisterButtonPress() async {
        await Self.handleRegisterButtonPress(signInProperty: signInProperty, inputProperty: $inputProperties)
    }

    /// Fetches person list of selected club
    /// - Parameters:
    ///   - signInProperty: sign in property with user id, name and club id
    ///   - inputProperty: binding of input property
    static func fetchPersonList(signInProperty: SignInProperty.UserIdNameClubId, inputProperty: Binding<InputProperties>) {
        guard inputProperty.wrappedValue.fetchConnectionState.restart() == .passed else { return }
        inputProperty.wrappedValue.removeObserver?()
        async {
            do {
                let personList = try await FirebaseFetcher.shared.fetchList(FirebasePerson.self, clubId: signInProperty.clubId)
                inputProperty.wrappedValue.personList = personList
                inputProperty.wrappedValue.fetchConnectionState.passed()
            } catch {
                inputProperty.wrappedValue.fetchConnectionState.failed()
            }
        }
        inputProperty.wrappedValue.removeObserver = FirebaseObserver.shared.observeList(FirebasePerson.self, clubId: signInProperty.clubId) { updatePersonList in
            guard var personList = inputProperty.wrappedValue.personList else { return }
            updatePersonList(&personList)
            inputProperty.wrappedValue.personList = personList
        }
    }

    /// Handles register button press
    /// - Parameters:
    ///   - signInProperty: sign in property with user id, name and club id
    ///   - inputProperty: binding of input property
    static func handleRegisterButtonPress(signInProperty: SignInProperty.UserIdNameClubId, inputProperty: Binding<InputProperties>) async {
        guard inputProperty.wrappedValue.registerConnectionState.restart() == .passed,
              inputProperty.wrappedValue.personList != nil else { return }
        inputProperty.wrappedValue.errorMessage = nil
        do {
            let personId = inputProperty.wrappedValue.selectedPersonId ?? FirebasePerson.ID(rawValue: UUID())
            let callItem = FFRegisterPersonCall(signInProperty: signInProperty, personId: personId)
            let clubProperties = try await FirebaseFunctionCaller.shared.call(callItem)
            inputProperty.wrappedValue.registerConnectionState.passed()
            let club = Club(id: signInProperty.clubId, name: clubProperties.clubName, identifier: clubProperties.clubIdentifier, regionCode: clubProperties.regionCode, inAppPaymentActive: clubProperties.inAppPaymentActive)
            Settings.shared.person = Settings.Person(club: club, id: personId, name: signInProperty.name, signInDate: callItem.signInDate, isCashier: false)
        } catch {
            inputProperty.wrappedValue.errorMessage = .internalErrorSignIn
            inputProperty.wrappedValue.registerConnectionState.failed()
        }
    }

    // MARK: person list row

    /// Row of person list
    struct PersonListRow: View {

        /// Person of this row
        let person: FirebasePerson

        /// Club id
        let clubId: Club.ID

        /// Id of selected person
        @Binding var selectedPersonId: FirebasePerson.ID?

        /// Indicates whether the row is a placeholder
        let isPlaceholder: Bool

        /// Init with person and selected person id
        /// - Parameters:
        ///   - person: person of the row
        ///   - selectedPersonId: selected person id
        ///   - placeholder: indicates whether the row is a placeholder
        init(_ person: FirebasePerson, clubId: Club.ID, selected selectedPersonId: Binding<FirebasePerson.ID?>, placeholder: Bool = false) {
            self.person = person
            self.clubId = clubId
            self._selectedPersonId = selectedPersonId
            self.isPlaceholder = placeholder
        }

        /// Image of the person
        @State var image: UIImage?

        var body: some View {
            SingleOutlinedContent {
                HStack(spacing: 0) {
                    PersonRowImage(image: $image)
                        .padding(.leading, 10)
                    Text(person.name.formatted)
                        .foregroundColor(textColor)
                        .font(.system(size: 20, weight: .light))
                        .lineLimit(1)
                        .padding(.horizontal, 10)
                        .redacted(reason: isPlaceholder ? .placeholder : [])
                    Spacer()
                }
            }.frame(width: UIScreen.main.bounds.width * 0.95, height: 55)
                .onAppear(perform: fetchPersonImage)
                .onTapGesture(perform: handleTap)
        }

        /// Fetch person image
        func fetchPersonImage() {
            guard !isPlaceholder else { return }
            async {
                do {
                    image = try await FirebaseImageStorage.shared.getImage(.personImage(clubId: clubId, personId: person.id), size: .thumbsSmall)
                } catch {}
            }
        }

        /// Handle tap
        func handleTap() {
            guard !isPlaceholder, person.signInData == nil else { return }
            if person.id == selectedPersonId {
                selectedPersonId = nil
            } else {
                selectedPersonId = person.id
            }
        }

        /// Text color
        var textColor: Color {
            guard !isPlaceholder else { return .textColor }
            if person.signInData != nil {
                return .customRed
            } else if person.id == selectedPersonId {
                return .customGreen
            }
            return .textColor
        }
    }
}

extension Array where Element == FirebasePerson {

    /// Sortes person list for view
    fileprivate var sortedForList: [Element] {
        sorted(by: \.name.formatted)
    }
}

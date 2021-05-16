//
//  SingleButton.swift
//  Strafen
//
//  Created by Steven on 10.05.21.
//

import SwiftUI

/// Single button with a symbol
struct SingleButton: View {
    
    /// Text of the button
    let text: String
    
    /// Font size
    private var fontSize: CGFloat = 24
    
    /// Image of the left symbol
    private var leftImage: Image? = nil
    
    /// Image of the right symbol
    private var rightImage: Image? = nil
    
    /// Color of the left smbol
    private var leftColor: Color = .clear
    
    /// Color of the right symbol
    private var rightColor: Color = .clear
    
    /// Height of the left symbol
    private var leftSymbolHeight: CGFloat = 27
    
    /// Height of the right symbol
    private var rightSymbolHeight: CGFloat = 27
    
    /// Button handler
    private var buttonHandler: (() -> Void)? = nil
    
    /// Connection state
    private var connectionState: Binding<ConnectionState>? = nil
    
    /// Init with text of the button
    /// - Parameter text: text of the button
    init(_ text: String) {
        self.text = text
    }
    
    var body: some View {
        SingleOutlinedContent {
            ZStack {
                
                // Text
                Text(text)
                    .font(.system(size: fontSize, weight: .light))
                    .foregroundColor(.textColor)
                    .lineLimit(1)
                    .padding(.horizontal, 15)
                
                // Symbol
                if leftImage != nil || rightImage != nil {
                    HStack(spacing: 0) {
                        
                        // Left symbol
                        if let image = leftImage {
                            image.resizable()
                                .scaledToFit()
                                .foregroundColor(leftColor)
                                .frame(height: leftSymbolHeight)
                                .padding(.leading, 25)
                        }
                        
                        Spacer()
                        
                        // Right symbol
                        if connectionState?.wrappedValue == .loading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .textColor))
                                .frame(width: rightSymbolHeight, height: rightSymbolHeight)
                                .padding(.trailing, 25)
                        } else if let image = rightImage {
                            image.resizable()
                                .scaledToFit()
                                .foregroundColor(rightColor)
                                .frame(height: rightSymbolHeight)
                                .padding(.trailing, 25)
                        }
                        
                    }
                }
                
            }
        }.frame(width: UIScreen.main.bounds.width * 0.95, height: 55)
            .onTapGesture { buttonHandler?() }
    }
    
    /// Sets font size of the text
    /// - Parameter size: font size of the text
    /// - Returns: modified single button
    public func fontSize(_ size: CGFloat) -> SingleButton {
        var button = self
        button.fontSize = size
        return button
    }
    
    /// Sets left symbol of the button
    /// - Parameter image: left iamge of the button
    /// - Returns: modified single button
    public func leftSymbol(_ image: Image) -> SingleButton {
        var button = self
        button.leftImage = image
        return button
    }
    
    /// Sets right symbol of the button
    /// - Parameter image: right image of the button
    /// - Returns: modified single button
    public func rightSymbol(_ image: Image) -> SingleButton {
        var button = self
        button.rightImage = image
        return button
    }
    
    /// Sets left symbol of the button
    /// - Parameter symbolName: left symbol of the button
    /// - Returns: modified single button
    public func leftSymbol(name symbolName: String) -> SingleButton {
        var button = self
        button.leftImage = Image(systemName: symbolName)
        return button
    }
    
    /// Sets right symbol of the button
    /// - Parameter symbolName: right symbol of the button
    /// - Returns: modified single button
    public func rightSymbol(name symbolName: String) -> SingleButton {
        var button = self
        button.rightImage = Image(systemName: symbolName)
        return button
    }
    
    /// Sets color of the left symbol
    /// - Parameter color: color of the left symbol
    /// - Returns: modified single button
    public func leftColor(_ color: Color) -> SingleButton {
        var button = self
        button.leftColor = color
        return button
    }
    
    /// Sets color of the right symbol
    /// - Parameter color: color of the right symbol
    /// - Returns: modified single button
    public func rightColor(_ color: Color) -> SingleButton {
        var button = self
        button.rightColor = color
        return button
    }
    
    /// Sets height of the left symbol
    /// - Parameter height: height of the left symbol
    /// - Returns: modified single button
    public func leftSymbolHeight(_ height: CGFloat) -> SingleButton {
        var button = self
        button.leftSymbolHeight = height
        return button
    }
    
    /// Sets height of the right symbol
    /// - Parameter height: height of the right symbol
    /// - Returns: modified single button
    public func rightSymbolHeight(_ height: CGFloat) -> SingleButton {
        var button = self
        button.rightSymbolHeight = height
        return button
    }
    
    /// Sets button handler
    /// - Parameter buttonHandler: button handler
    /// - Returns: modified single button
    public func onClick(perform buttonHandler: @escaping () -> Void) -> SingleButton {
        var button = self
        button.buttonHandler = buttonHandler
        return button
    }
    
    /// Sets connection state
    /// - Parameter connectionState: connection state
    /// - Returns: modified single button
    public func connectionState(_ connectionState: Binding<ConnectionState>) -> SingleButton {
        var button = self
        button.connectionState = connectionState
        return button
    }

    
    /// Cancel button
    static let cancel = SingleButton("Abbrechen")
        .fontSize(27)
        .leftSymbol(name: "chevron.left.2")
        .leftColor(.customRed)
    
    /// Confirm button
    static let confirm = SingleButton("Bestätigen")
        .fontSize(27)
        .rightSymbol(name: "checkmark.seal")
        .rightColor(.customGreen)
    
    /// Continue button
    static let `continue` = SingleButton("Weiter")
        .fontSize(27)
        .rightSymbol(name: "chevron.right.2")
        .rightColor(.customGreen)
}
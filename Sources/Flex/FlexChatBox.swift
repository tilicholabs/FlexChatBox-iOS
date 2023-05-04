import SwiftUI

public struct FlexChatBox: View {
    
    let flexType: FlexType
    let textFieldPlaceHolder: String
    
    let onClickSend: (String) -> Void
    
    public init(flexType: FlexType,
                placeholder: String = "Type your text here",
                onClickSend: @escaping (String) -> Void) {
        self.flexType = flexType
        self.textFieldPlaceHolder = placeholder
        self.onClickSend = onClickSend
    }
    
    public var body: some View {
        FlexChatView(flexType: flexType,
                     placeholder: textFieldPlaceHolder,
                     onClickSend: onClickSend)
    }
}

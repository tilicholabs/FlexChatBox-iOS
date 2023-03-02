import SwiftUI

public struct FlexChatBox: View {
    
    let flexType: FlexType
    let textFieldPlaceHolder: String
    
    let flexCompletion: (FlexOutput) -> Void
    let onClickSend: (String?) -> Void
    
    public init(flexType: FlexType = .camera,
                placeholder: String = "Type your text here",
                flexCompletion: @escaping (FlexOutput) -> Void,
                onClickSend: @escaping (String?) -> Void) {
        self.flexType = flexType
        self.textFieldPlaceHolder = placeholder
        self.flexCompletion = flexCompletion
        self.onClickSend = onClickSend
    }
    
    public var body: some View {
        FlexChatView(flexType: flexType,
                     placeholder: textFieldPlaceHolder,
                     flexCompletion: flexCompletion,
                     onClickSend: onClickSend)
            .environmentObject(ViewModel())
    }
}

import SwiftUI

public struct FlexChatBox: View {
    
    let flexCompletion: (UIImage?) -> Void
    let onClickSend: (String?) -> Void
    
    public init(flexCompletion: @escaping (UIImage?) -> Void,
                onClickSend: @escaping (String?) -> Void) {
        self.flexCompletion = flexCompletion
        self.onClickSend = onClickSend
    }
    
    public var body: some View {
        FlexChatView(flexCompletion: flexCompletion, onClickSend: onClickSend)
            .environmentObject(ViewModel())
    }
}

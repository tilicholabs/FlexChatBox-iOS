import SwiftUI

public struct FlexChatBox: View {
    
    let completion: (UIImage?) -> Void
    
    public init(_ completion: @escaping (UIImage?) -> Void) {
        self.completion = completion
    }
    
    public var body: some View {
        FlexChatView(self.completion)
            .environmentObject(ViewModel())
    }
}

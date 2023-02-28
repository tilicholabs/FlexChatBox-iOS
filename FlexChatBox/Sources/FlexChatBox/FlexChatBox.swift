import SwiftUI

public struct FlexChatBox: View {
    
    public init() {}
    
    public var body: some View {
        FlexChatView()
            .environmentObject(ViewModel())
    }
}

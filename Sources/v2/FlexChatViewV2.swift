import Foundation
import SwiftUI

public struct FlexChatViewV2<Content>: View where Content: View {
    private var entity: Entity<Content>
    
    public init(selectedEntity: Entity<Content>) {
        self.entity = selectedEntity
    }
    
    public var body: some View {
        entity.invocationContentView
    }
}

struct FlexChatViewV2_Previews: PreviewProvider {
    static var previews: some View {
        FlexChatViewV2(selectedEntity: EntityBuilder.flexGalleryEntity({ _  in }))
    }
}

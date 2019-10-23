import SwiftUI

struct Carousel: View {
    
    struct Item: Identifiable {
        let id = NSUUID()
        var color: Color
        
        static let width: CGFloat = 200
    }
    
    @Binding var items: [Item]
    
    @State private var anchor: CGFloat = 0
    
    @GestureState private var translation: CGFloat?
    
    private var offset: CGFloat { anchor + (translation ?? 0) }
    
    private var stackWidth: CGFloat { CGFloat(items.count) * Item.width }

    private func nearestIndex(to offset: CGFloat) -> Int {
        var index = (-offset/Item.width).rounded()
        index = max(index, 0)
        index = min(index, CGFloat(items.count - 1))
        return Int(index)
    }
    
    func select(index: Int) {
        let offset = CGFloat(index) * Item.width
        
        withAnimation(.easeInOut(duration: 0.2)) {
            anchor = -offset
        }
    }
    
    var body: some View {
        GeometryReader() { geometry in
            HStack(alignment: .center, spacing: 0) {
                ForEach(self.items.indices) { i in
                    Rectangle()
                        .frame(width: Item.width, height: Item.width)
                        .foregroundColor(self.items[i].color)
                        .onTapGesture {
                            self.select(index: i)
                        }
                }
            }
            .offset(x: self.offset)
            .gesture(
                DragGesture().updating(self.$translation) { value, state, transaction in
                    state = value.translation.width
                }
                .onEnded { value in
                    self.anchor += value.translation.width
                    
                    let index = self.nearestIndex(to: self.anchor)

                    self.select(index: index)
                }
            )
            .position(x: geometry.size.width/2 + self.stackWidth/2 - Item.width/2, y: geometry.size.height/2)
        }
    }
    
}

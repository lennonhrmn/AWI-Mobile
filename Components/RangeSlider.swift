import SwiftUI

struct RangeSlider: View {
    @Binding var value: ClosedRange<Double>
    let bounds: ClosedRange<Double>
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 4)
                
                Rectangle()
                    .fill(Color.blue)
                    .frame(width: width(for: value, in: geometry),
                           height: 4)
                    .offset(x: offset(for: value.lowerBound, in: geometry))
                
                HStack(spacing: 0) {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 24, height: 24)
                        .shadow(radius: 2)
                        .offset(x: offset(for: value.lowerBound, in: geometry))
                        .gesture(dragGesture(for: \.lowerBound, in: geometry))
                    
                    Circle()
                        .fill(Color.white)
                        .frame(width: 24, height: 24)
                        .shadow(radius: 2)
                        .offset(x: offset(for: value.upperBound, in: geometry))
                        .gesture(dragGesture(for: \.upperBound, in: geometry))
                }
            }
        }
    }
    
    private func width(for range: ClosedRange<Double>, in geometry: GeometryProxy) -> CGFloat {
        let lower = offset(for: range.lowerBound, in: geometry)
        let upper = offset(for: range.upperBound, in: geometry)
        return upper - lower
    }
    
    private func offset(for value: Double, in geometry: GeometryProxy) -> CGFloat {
        let ratio = (value - bounds.lowerBound) / (bounds.upperBound - bounds.lowerBound)
        return ratio * (geometry.size.width - 24)
    }
    
    private func dragGesture(for bound: KeyPath<ClosedRange<Double>, Double>, in geometry: GeometryProxy) -> some Gesture {
        DragGesture()
            .onChanged { gesture in
                var newValue = gestureValue(gesture: gesture, in: geometry)
                newValue = max(bounds.lowerBound, min(bounds.upperBound, newValue))
                
                if bound == \ClosedRange<Double>.lowerBound {
                    if newValue < value.upperBound {
                        value = newValue...value.upperBound
                    }
                } else {
                    if newValue > value.lowerBound {
                        value = value.lowerBound...newValue
                    }
                }
            }
    }
    
    private func gestureValue(gesture: DragGesture.Value, in geometry: GeometryProxy) -> Double {
        let ratio = gesture.location.x / (geometry.size.width - 24)
        return bounds.lowerBound + (ratio * (bounds.upperBound - bounds.lowerBound))
    }
}

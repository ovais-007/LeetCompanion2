import SwiftUI

struct ProgressCircle: View {
    let progress: Int
    var body: some View {
        ZStack {
            Circle().stroke(Color.secondary.opacity(0.2), lineWidth: 8)
            Circle()
                .trim(from: 0, to: 0.75)
                .stroke(Color.accentColor, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                .rotationEffect(.degrees(-90))
            Text(progress.formatted()).font(.title2.bold())
        }
        .frame(width: 120, height: 120)
    }
}


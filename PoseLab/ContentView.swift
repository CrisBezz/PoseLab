import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var model: PoseLabViewModel

    var body: some View {
        ZStack(alignment: .bottom) {
            BodyTrackingView(service: model.trackingService)
                .ignoresSafeArea()

            VStack(spacing: 12) {
                HStack {
                    Label(model.statusText, systemImage: model.isTracking ? "figure.run" : "figure.stand")
                    Spacer()
                    Text("\(model.jointCount) joints").monospacedDigit()
                }
                .font(.subheadline.weight(.semibold))

                HStack {
                    Button(model.isSessionRunning ? "Stop" : "Start") { model.toggleTracking() }
                        .buttonStyle(.borderedProminent)
                    Button(model.isFrozen ? "Resume" : "Freeze Pose") { model.toggleFreeze() }
                        .buttonStyle(.bordered)
                        .disabled(!model.isTracking && !model.isFrozen)
                }
            }
            .padding(16)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
            .padding()
        }
        .onAppear {
            if !model.isSessionRunning { model.toggleTracking() }
        }
    }
}

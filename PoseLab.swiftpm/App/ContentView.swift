import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var model: PoseLabViewModel

    var body: some View {
        ZStack(alignment: .bottom) {
            preview
                .ignoresSafeArea()

            VStack(spacing: 12) {
                Picker(
                    "Mode",
                    selection: Binding(
                        get: { model.mode },
                        set: { model.switchMode(to: $0) }
                    )
                ) {
                    ForEach(PoseLabViewModel.Mode.allCases) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(.segmented)

                HStack(spacing: 10) {
                    Label(
                        model.statusText,
                        systemImage: statusIcon
                    )

                    Spacer()

                    Text("\(model.jointCount) joints")
                        .monospacedDigit()
                }
                .font(.subheadline.weight(.semibold))

                HStack(spacing: 12) {
                    Button(model.isSessionRunning ? "Stop" : "Start") {
                        model.toggleTracking()
                    }
                    .buttonStyle(.borderedProminent)

                    Button(model.isFrozen ? "Resume" : "Freeze Pose") {
                        model.toggleFreeze()
                    }
                    .buttonStyle(.bordered)
                    .disabled(!model.isTracking && !model.isFrozen)
                }
            }
            .padding(16)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
            .padding()
        }
        .overlay(alignment: .topLeading) {
            Text("PoseLab Body · V0.2a")
                .font(.caption.weight(.semibold))
                .padding(.horizontal, 10)
                .padding(.vertical, 7)
                .background(.ultraThinMaterial, in: Capsule())
                .padding()
        }
        .onAppear {
            if !model.isSessionRunning {
                model.activateCurrentMode()
            }
        }
    }

    @ViewBuilder
    private var preview: some View {
        switch model.mode {
        case .local, .camera:
            BodyTrackingView(service: model.trackingService)

        case .monitor:
            RemotePosePreview(pose: model.latestPose)
        }
    }

    private var statusIcon: String {
        switch model.mode {
        case .local:
            return model.isTracking ? "figure.run" : "figure.stand"
        case .camera:
            return "iphone.gen3.radiowaves.left.and.right"
        case .monitor:
            return "ipad.gen2"
        }
    }
}

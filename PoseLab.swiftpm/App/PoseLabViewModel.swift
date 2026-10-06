import Combine
import Foundation

@MainActor
final class PoseLabViewModel: ObservableObject {
    @Published private(set) var isSessionRunning = false
    @Published private(set) var isTracking = false
    @Published private(set) var isFrozen = false
    @Published private(set) var latestPose: PoseSnapshot?

    let trackingService = ARBodyTrackingService()
    private var cancellables = Set<AnyCancellable>()

    init() {
        trackingService.posePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] pose in
                guard let self else { return }
                isTracking = true

                guard !isFrozen else { return }
                latestPose = pose
            }
            .store(in: &cancellables)

        trackingService.trackingLostPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.isTracking = false
            }
            .store(in: &cancellables)
    }

    var jointCount: Int {
        latestPose?.joints.count ?? 0
    }

    var statusText: String {
        if !trackingService.isSupported {
            return "Body tracking unsupported on this device"
        }
        if isFrozen {
            return "Pose frozen"
        }
        if isTracking {
            return "Tracking performer"
        }
        if isSessionRunning {
            return "Looking for performer…"
        }
        return "Tracking stopped"
    }

    func toggleTracking() {
        if isSessionRunning {
            trackingService.stop()
            isSessionRunning = false
            isTracking = false
        } else {
            trackingService.start()
            isSessionRunning = true
        }
    }

    func toggleFreeze() {
        guard isTracking || isFrozen else { return }
        isFrozen.toggle()
        trackingService.isFrozen = isFrozen
    }
}

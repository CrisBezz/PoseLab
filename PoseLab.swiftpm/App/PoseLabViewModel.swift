import Combine
import Foundation
import UIKit

@MainActor
final class PoseLabViewModel: ObservableObject {
    enum Mode: String, CaseIterable, Identifiable {
        case local = "Local"
        case camera = "iPhone Camera"
        case monitor = "iPad Monitor"

        var id: String { rawValue }
    }

    @Published var mode: Mode = .local
    @Published private(set) var isSessionRunning = false
    @Published private(set) var isTracking = false
    @Published private(set) var isFrozen = false
    @Published private(set) var latestPose: PoseSnapshot?
    @Published private(set) var remoteStatus = "Remote off"
    @Published private(set) var remotePreviewImage: UIImage?

    let trackingService = ARBodyTrackingService()
    let remoteLink = RemotePoseLink()

    private var cancellables = Set<AnyCancellable>()
    private var lastRemoteSendTime: TimeInterval = 0

    init() {
        trackingService.posePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] pose in
                guard let self else { return }

                isTracking = true

                if mode == .camera {
                    let now = pose.timestamp
                    if now - lastRemoteSendTime >= 0.05 {
                        remoteLink.send(pose)
                        lastRemoteSendTime = now
                    }
                }

                guard !isFrozen else { return }
                latestPose = pose
            }
            .store(in: &cancellables)

        trackingService.previewFramePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] jpegData in
                guard let self, mode == .camera else { return }
                remoteLink.sendPreviewJPEG(jpegData)
            }
            .store(in: &cancellables)

        trackingService.trackingLostPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.isTracking = false
            }
            .store(in: &cancellables)

        remoteLink.remotePosePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] pose in
                guard let self,
                      mode == .monitor,
                      !isFrozen
                else { return }

                latestPose = pose
                isTracking = true
            }
            .store(in: &cancellables)

        remoteLink.remotePreviewPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] image in
                guard let self, mode == .monitor else { return }
                remotePreviewImage = image
            }
            .store(in: &cancellables)

        remoteLink.statusPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                self?.remoteStatus = status
            }
            .store(in: &cancellables)
    }

    var jointCount: Int {
        latestPose?.joints.count ?? 0
    }

    var statusText: String {
        if isFrozen { return "Pose frozen" }

        switch mode {
        case .local:
            if !trackingService.isSupported {
                return "Body tracking unsupported on this device"
            }
            if isTracking { return "Tracking performer" }
            if isSessionRunning { return "Looking for performer…" }
            return "Tracking stopped"

        case .camera:
            if !trackingService.isSupported {
                return "Body tracking unsupported on this device"
            }
            if isTracking { return remoteStatus }
            return "Camera: looking for performer…"

        case .monitor:
            return remoteStatus
        }
    }

    func activateCurrentMode() {
        switchMode(to: mode)
    }

    func switchMode(to newMode: Mode) {
        trackingService.stop()
        trackingService.previewEnabled = false
        remoteLink.stop()

        mode = newMode
        isSessionRunning = false
        isTracking = false
        isFrozen = false
        latestPose = nil
        remotePreviewImage = nil
        trackingService.isFrozen = false

        switch newMode {
        case .local:
            trackingService.start()
            isSessionRunning = true

        case .camera:
            remoteLink.startCamera()
            trackingService.previewEnabled = true
            trackingService.start()
            isSessionRunning = true

        case .monitor:
            remoteLink.startMonitor()
            isSessionRunning = true
        }
    }

    func toggleTracking() {
        switch mode {
        case .local:
            if isSessionRunning {
                trackingService.stop()
                isSessionRunning = false
                isTracking = false
            } else {
                trackingService.start()
                isSessionRunning = true
            }

        case .camera:
            if isSessionRunning {
                trackingService.stop()
                trackingService.previewEnabled = false
                remoteLink.stop()
                isSessionRunning = false
                isTracking = false
            } else {
                remoteLink.startCamera()
                trackingService.previewEnabled = true
                trackingService.start()
                isSessionRunning = true
            }

        case .monitor:
            if isSessionRunning {
                remoteLink.stop()
                remotePreviewImage = nil
                isSessionRunning = false
                isTracking = false
            } else {
                remoteLink.startMonitor()
                isSessionRunning = true
            }
        }
    }

    func toggleFreeze() {
        guard isTracking || isFrozen else { return }
        isFrozen.toggle()

        if mode != .monitor {
            trackingService.isFrozen = isFrozen
        }
    }
}

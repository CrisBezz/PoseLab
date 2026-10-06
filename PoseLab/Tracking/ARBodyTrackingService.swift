import ARKit
import Combine
import Foundation

final class ARBodyTrackingService: NSObject, ARSessionDelegate {
    let posePublisher = PassthroughSubject<PoseSnapshot, Never>()
    let trackingLostPublisher = PassthroughSubject<Void, Never>()
    let session = ARSession()
    var isFrozen = false

    override init() {
        super.init()
        session.delegate = self
    }

    func start() {
        guard ARBodyTrackingConfiguration.isSupported else {
            trackingLostPublisher.send()
            return
        }
        let configuration = ARBodyTrackingConfiguration()
        configuration.automaticSkeletonScaleEstimationEnabled = true
        session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }

    func stop() { session.pause() }

    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        guard !isFrozen,
              let body = anchors.compactMap({ $0 as? ARBodyAnchor }).first
        else { return }

        let definition = body.skeleton.definition
        let transforms = body.skeleton.jointModelTransforms
        var joints: [String: PoseSnapshot.Joint] = [:]

        for (index, name) in definition.jointNames.enumerated() where index < transforms.count {
            joints[name] = .init(name: name, modelTransform: transforms[index])
        }

        posePublisher.send(.init(
            timestamp: session.currentFrame?.timestamp ?? 0,
            estimatedScaleFactor: body.estimatedScaleFactor,
            bodyTransform: body.transform,
            joints: joints
        ))
    }

    func session(_ session: ARSession, didRemove anchors: [ARAnchor]) {
        if anchors.contains(where: { $0 is ARBodyAnchor }) {
            trackingLostPublisher.send()
        }
    }
}

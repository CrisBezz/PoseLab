import ARKit
import Combine
import CoreImage
import Foundation
import ImageIO
import UIKit

final class ARBodyTrackingService: NSObject, ARSessionDelegate {
    let posePublisher = PassthroughSubject<PoseSnapshot, Never>()
    let previewFramePublisher = PassthroughSubject<Data, Never>()
    let trackingLostPublisher = PassthroughSubject<Void, Never>()

    let session = ARSession()
    var isFrozen = false
    var previewEnabled = false

    private let imageContext = CIContext()
    private var lastPreviewTime: TimeInterval = 0

    var isSupported: Bool {
        ARBodyTrackingConfiguration.isSupported
    }

    override init() {
        super.init()
        session.delegate = self
    }

    func start() {
        guard isSupported else {
            trackingLostPublisher.send()
            return
        }

        let configuration = ARBodyTrackingConfiguration()
        configuration.automaticSkeletonScaleEstimationEnabled = true

        session.run(
            configuration,
            options: [.resetTracking, .removeExistingAnchors]
        )
    }

    func stop() {
        session.pause()
    }

    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        guard previewEnabled else { return }

        let now = frame.timestamp
        guard now - lastPreviewTime >= 0.20 else { return }
        lastPreviewTime = now

        guard let data = makePreviewJPEG(from: frame.capturedImage) else { return }
        previewFramePublisher.send(data)
    }

    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        guard !isFrozen,
              let body = anchors.compactMap({ $0 as? ARBodyAnchor }).first
        else { return }

        let definition = body.skeleton.definition
        let transforms = body.skeleton.jointModelTransforms
        let parentIndices = definition.parentIndices

        var joints: [String: PoseSnapshot.Joint] = [:]
        joints.reserveCapacity(definition.jointNames.count)

        for (index, name) in definition.jointNames.enumerated() where index < transforms.count {
            let parentName: String?

            if index < parentIndices.count {
                let parentIndex = parentIndices[index]
                if parentIndex >= 0 && parentIndex < definition.jointNames.count {
                    parentName = definition.jointNames[parentIndex]
                } else {
                    parentName = nil
                }
            } else {
                parentName = nil
            }

            joints[name] = .init(
                name: name,
                modelTransform: transforms[index],
                parentName: parentName
            )
        }

        posePublisher.send(
            PoseSnapshot(
                timestamp: session.currentFrame?.timestamp ?? 0,
                estimatedScaleFactor: body.estimatedScaleFactor,
                bodyTransform: body.transform,
                joints: joints
            )
        )
    }

    func session(_ session: ARSession, didRemove anchors: [ARAnchor]) {
        if anchors.contains(where: { $0 is ARBodyAnchor }) {
            trackingLostPublisher.send()
        }
    }

    func session(_ session: ARSession, didFailWithError error: Error) {
        trackingLostPublisher.send()
    }

    private func makePreviewJPEG(from pixelBuffer: CVPixelBuffer) -> Data? {
        var image = CIImage(cvPixelBuffer: pixelBuffer)
        image = image.oriented(previewOrientation())

        let extent = image.extent
        guard extent.width > 0, extent.height > 0 else { return nil }

        let maximumDimension: CGFloat = 640
        let scale = min(
            1,
            maximumDimension / max(extent.width, extent.height)
        )

        if scale < 1 {
            image = image.transformed(
                by: CGAffineTransform(scaleX: scale, y: scale)
            )
        }

        guard let cgImage = imageContext.createCGImage(
            image,
            from: image.extent
        ) else { return nil }

        return UIImage(cgImage: cgImage)
            .jpegData(compressionQuality: 0.38)
    }

    private func previewOrientation() -> CGImagePropertyOrientation {
        switch UIDevice.current.orientation {
        case .landscapeLeft:
            return .down
        case .landscapeRight:
            return .up
        case .portraitUpsideDown:
            return .left
        default:
            return .right
        }
    }
}

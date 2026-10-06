import ARKit
import Combine
import RealityKit
import SwiftUI
import UIKit

struct BodyTrackingView: UIViewRepresentable {
    let service: ARBodyTrackingService

    func makeCoordinator() -> Coordinator {
        Coordinator(service: service)
    }

    func makeUIView(context: Context) -> ARView {
        let view = ARView(frame: .zero)
        view.session = service.session
        view.automaticallyConfigureSession = false

        context.coordinator.attach(to: view)
        return view
    }

    func updateUIView(_ uiView: ARView, context: Context) {}

    final class Coordinator {
        private let root = AnchorEntity(world: .zero)
        private var jointEntities: [String: ModelEntity] = [:]
        private var boneEntities: [String: ModelEntity] = [:]
        private var cancellable: AnyCancellable?

        init(service: ARBodyTrackingService) {
            cancellable = service.posePublisher
                .receive(on: DispatchQueue.main)
                .sink { [weak self] pose in
                    self?.render(pose)
                }
        }

        func attach(to view: ARView) {
            view.scene.addAnchor(root)
        }

        private func render(_ pose: PoseSnapshot) {
            var worldPositions: [String: SIMD3<Float>] = [:]
            worldPositions.reserveCapacity(pose.joints.count)

            for (name, joint) in pose.joints {
                let worldTransform = simd_mul(pose.bodyTransform, joint.modelTransform)
                let position = SIMD3<Float>(
                    worldTransform.columns.3.x,
                    worldTransform.columns.3.y,
                    worldTransform.columns.3.z
                )

                worldPositions[name] = position

                let marker = jointEntity(named: name)
                marker.position = position
            }

            for (name, joint) in pose.joints {
                guard let parentName = joint.parentName,
                      let childPosition = worldPositions[name],
                      let parentPosition = worldPositions[parentName]
                else { continue }

                updateBone(
                    key: "\(parentName)->\(name)",
                    from: parentPosition,
                    to: childPosition
                )
            }
        }

        private func jointEntity(named name: String) -> ModelEntity {
            if let existing = jointEntities[name] {
                return existing
            }

            let marker = ModelEntity(
                mesh: .generateSphere(radius: 0.016),
                materials: [SimpleMaterial(color: .white, isMetallic: false)]
            )

            jointEntities[name] = marker
            root.addChild(marker)
            return marker
        }

        private func updateBone(
            key: String,
            from start: SIMD3<Float>,
            to end: SIMD3<Float>
        ) {
            let vector = end - start
            let length = simd_length(vector)

            guard length > 0.001 else { return }

            let bone: ModelEntity

            if let existing = boneEntities[key] {
                bone = existing
            } else {
                bone = ModelEntity(
                    mesh: .generateBox(size: SIMD3<Float>(0.009, 1.0, 0.009)),
                    materials: [SimpleMaterial(color: .white.withAlphaComponent(0.72), isMetallic: false)]
                )
                boneEntities[key] = bone
                root.addChild(bone)
            }

            bone.position = (start + end) * 0.5
            bone.scale = SIMD3<Float>(1, length, 1)
            bone.orientation = orientationFromYAxis(to: vector / length)
        }

        private func orientationFromYAxis(to direction: SIMD3<Float>) -> simd_quatf {
            let up = SIMD3<Float>(0, 1, 0)
            let dot = simd_dot(up, direction)

            if dot > 0.9999 {
                return simd_quatf(angle: 0, axis: SIMD3<Float>(1, 0, 0))
            }

            if dot < -0.9999 {
                return simd_quatf(angle: .pi, axis: SIMD3<Float>(1, 0, 0))
            }

            let axis = simd_normalize(simd_cross(up, direction))
            let angle = acos(max(-1, min(1, dot)))
            return simd_quatf(angle: angle, axis: axis)
        }
    }
}

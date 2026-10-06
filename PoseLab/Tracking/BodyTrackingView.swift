import ARKit
import RealityKit
import SwiftUI
import Combine

struct BodyTrackingView: UIViewRepresentable {
    let service: ARBodyTrackingService

    func makeCoordinator() -> Coordinator { Coordinator(service: service) }

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
        private var cancellable: AnyCancellable?

        init(service: ARBodyTrackingService) {
            cancellable = service.posePublisher
                .receive(on: DispatchQueue.main)
                .sink { [weak self] pose in self?.render(pose) }
        }

        func attach(to view: ARView) {
            view.scene.addAnchor(root)
        }

        private func render(_ pose: PoseSnapshot) {
            for (name, joint) in pose.joints {
                let marker: ModelEntity
                if let existing = jointEntities[name] {
                    marker = existing
                } else {
                    marker = ModelEntity(
                        mesh: .generateSphere(radius: 0.018),
                        materials: [SimpleMaterial(color: .white, isMetallic: false)]
                    )
                    jointEntities[name] = marker
                    root.addChild(marker)
                }
                marker.transform.matrix = simd_mul(pose.bodyTransform, joint.modelTransform)
            }
        }
    }
}

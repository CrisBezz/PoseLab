import SwiftUI
import simd

struct RemotePosePreview: View {
    let pose: PoseSnapshot?

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black

                if let pose {
                    Canvas { context, size in
                        let positions = projectedPositions(
                            pose: pose,
                            size: size
                        )

                        for joint in pose.joints.values {
                            guard let parentName = joint.parentName,
                                  let a = positions[joint.name],
                                  let b = positions[parentName]
                            else { continue }

                            var path = Path()
                            path.move(to: a)
                            path.addLine(to: b)
                            context.stroke(
                                path,
                                with: .color(.white.opacity(0.75)),
                                lineWidth: 4
                            )
                        }

                        for point in positions.values {
                            let rect = CGRect(
                                x: point.x - 5,
                                y: point.y - 5,
                                width: 10,
                                height: 10
                            )
                            context.fill(
                                Path(ellipseIn: rect),
                                with: .color(.white)
                            )
                        }
                    }
                } else {
                    VStack(spacing: 10) {
                        Image(systemName: "iphone.radiowaves.left.and.right")
                            .font(.system(size: 50))
                        Text("Waiting for remote pose")
                            .font(.headline)
                    }
                    .foregroundStyle(.white.opacity(0.75))
                }
            }
        }
    }

    private func projectedPositions(
        pose: PoseSnapshot,
        size: CGSize
    ) -> [String: CGPoint] {
        var raw: [String: SIMD2<Float>] = [:]

        for joint in pose.joints.values {
            let world = simd_mul(
                pose.bodyTransform,
                joint.modelTransform
            )

            raw[joint.name] = SIMD2<Float>(
                world.columns.3.x,
                world.columns.3.y
            )
        }

        guard !raw.isEmpty else { return [:] }

        let xs = raw.values.map(\.x)
        let ys = raw.values.map(\.y)

        guard let minX = xs.min(),
              let maxX = xs.max(),
              let minY = ys.min(),
              let maxY = ys.max()
        else { return [:] }

        let width = max(maxX - minX, 0.1)
        let height = max(maxY - minY, 0.1)
        let margin: CGFloat = 34

        let scale = min(
            max(1, (size.width - margin * 2) / CGFloat(width)),
            max(1, (size.height - margin * 2) / CGFloat(height))
        )

        var output: [String: CGPoint] = [:]

        for (name, value) in raw {
            let x = margin + CGFloat(value.x - minX) * scale
            let y = size.height - margin - CGFloat(value.y - minY) * scale
            output[name] = CGPoint(x: x, y: y)
        }

        return output
    }
}

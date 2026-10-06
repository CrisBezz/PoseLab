import SwiftUI
import simd
import UIKit

struct RemotePosePreview: View {
    let pose: PoseSnapshot?
    let previewImage: UIImage?

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black

                if let previewImage {
                    Image(uiImage: previewImage)
                        .resizable()
                        .scaledToFill()
                        .frame(
                            width: geometry.size.width,
                            height: geometry.size.height
                        )
                        .clipped()
                } else {
                    VStack(spacing: 10) {
                        Image(systemName: "iphone.radiowaves.left.and.right")
                            .font(.system(size: 50))
                        Text("Waiting for iPhone preview")
                            .font(.headline)
                    }
                    .foregroundStyle(.white.opacity(0.75))
                }

                VStack {
                    HStack {
                        Spacer()

                        skeletonInset
                            .frame(width: 190, height: 260)
                            .background(
                                .black.opacity(0.62),
                                in: RoundedRectangle(cornerRadius: 18)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 18)
                                    .stroke(.white.opacity(0.18))
                            )
                            .padding()
                    }

                    Spacer()
                }
            }
        }
    }

    private var skeletonInset: some View {
        GeometryReader { geometry in
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
                            with: .color(.white.opacity(0.8)),
                            lineWidth: 3
                        )
                    }

                    for point in positions.values {
                        let rect = CGRect(
                            x: point.x - 4,
                            y: point.y - 4,
                            width: 8,
                            height: 8
                        )

                        context.fill(
                            Path(ellipseIn: rect),
                            with: .color(.white)
                        )
                    }
                }
                .padding(10)
            } else {
                VStack(spacing: 6) {
                    Image(systemName: "figure.stand")
                    Text("Waiting for pose")
                        .font(.caption)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .foregroundStyle(.white.opacity(0.7))
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
        let margin: CGFloat = 12

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

import Foundation
import simd

struct PosePacket: Codable {
    struct JointPacket: Codable {
        let name: String
        let parentName: String?
        let matrix: [Float]
    }

    let timestamp: TimeInterval
    let estimatedScaleFactor: Double
    let bodyMatrix: [Float]
    let joints: [JointPacket]

    init(snapshot: PoseSnapshot) {
        timestamp = snapshot.timestamp
        estimatedScaleFactor = Double(snapshot.estimatedScaleFactor)
        bodyMatrix = Self.flatten(snapshot.bodyTransform)
        joints = snapshot.joints.values.map {
            JointPacket(
                name: $0.name,
                parentName: $0.parentName,
                matrix: Self.flatten($0.modelTransform)
            )
        }
    }

    func snapshot() -> PoseSnapshot? {
        guard let bodyTransform = Self.matrix(bodyMatrix) else { return nil }

        var output: [String: PoseSnapshot.Joint] = [:]
        output.reserveCapacity(joints.count)

        for joint in joints {
            guard let transform = Self.matrix(joint.matrix) else { continue }
            output[joint.name] = .init(
                name: joint.name,
                modelTransform: transform,
                parentName: joint.parentName
            )
        }

        return PoseSnapshot(
            timestamp: timestamp,
            estimatedScaleFactor: CGFloat(estimatedScaleFactor),
            bodyTransform: bodyTransform,
            joints: output
        )
    }

    private static func flatten(_ matrix: simd_float4x4) -> [Float] {
        [
            matrix.columns.0.x, matrix.columns.0.y, matrix.columns.0.z, matrix.columns.0.w,
            matrix.columns.1.x, matrix.columns.1.y, matrix.columns.1.z, matrix.columns.1.w,
            matrix.columns.2.x, matrix.columns.2.y, matrix.columns.2.z, matrix.columns.2.w,
            matrix.columns.3.x, matrix.columns.3.y, matrix.columns.3.z, matrix.columns.3.w
        ]
    }

    private static func matrix(_ values: [Float]) -> simd_float4x4? {
        guard values.count == 16 else { return nil }

        return simd_float4x4(
            SIMD4<Float>(values[0], values[1], values[2], values[3]),
            SIMD4<Float>(values[4], values[5], values[6], values[7]),
            SIMD4<Float>(values[8], values[9], values[10], values[11]),
            SIMD4<Float>(values[12], values[13], values[14], values[15])
        )
    }
}

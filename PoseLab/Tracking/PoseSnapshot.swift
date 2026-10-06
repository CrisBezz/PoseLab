import Foundation
import simd

struct PoseSnapshot: Sendable {
    struct Joint: Sendable {
        let name: String
        let modelTransform: simd_float4x4
    }

    let timestamp: TimeInterval
    let estimatedScaleFactor: Float
    let bodyTransform: simd_float4x4
    let joints: [String: Joint]
}

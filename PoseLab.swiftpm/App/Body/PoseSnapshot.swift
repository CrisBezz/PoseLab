import Foundation
import simd

struct PoseSnapshot {
    struct Joint {
        let name: String
        let modelTransform: simd_float4x4
        let parentName: String?
    }

    let timestamp: TimeInterval
    let estimatedScaleFactor: Float
    let bodyTransform: simd_float4x4
    let joints: [String: Joint]
}

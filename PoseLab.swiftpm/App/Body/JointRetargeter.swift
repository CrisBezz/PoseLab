import Foundation
import simd

struct JointRetargeter {
    struct Mapping {
        let sourceJoint: String
        let targetJoint: String
        let restCorrection: simd_quatf
    }

    let mappings: [Mapping]

    func rotations(from pose: PoseSnapshot) -> [String: simd_quatf] {
        var output: [String: simd_quatf] = [:]

        for mapping in mappings {
            guard let source = pose.joints[mapping.sourceJoint] else { continue }

            output[mapping.targetJoint] =
                mapping.restCorrection * simd_quatf(source.modelTransform)
        }

        return output
    }
}

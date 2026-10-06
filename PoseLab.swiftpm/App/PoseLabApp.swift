import SwiftUI

@main
struct PoseLabApp: App {
    @StateObject private var model = PoseLabViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(model)
        }
    }
}

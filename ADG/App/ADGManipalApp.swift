import SwiftUI

@main
struct ADGManipalApp: App {
    @State private var session = ADGSession()
    @State private var showSplash = true

    init() {
        URLCache.shared = URLCache(
            memoryCapacity: 60 * 1024 * 1024,
            diskCapacity: 250 * 1024 * 1024,
            diskPath: "adg-remote-images"
        )
    }

    var body: some Scene {
        WindowGroup {
            ZStack {
                if showSplash {
                    SplashView {
                        showSplash = false
                    }
                } else {
                    RootView()
                        .environment(session)          
                }
            }
        }
    }
}

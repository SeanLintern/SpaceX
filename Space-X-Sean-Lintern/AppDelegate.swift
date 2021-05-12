import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var coordinator: Coordinator?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let navigation = UINavigationController()

        window = UIWindow()
        window?.rootViewController = navigation
        window?.makeKeyAndVisible()

        if isRunningUITests() {
            self.coordinator = UITestHelperCoordinator(context: navigation)
        } else {
            self.coordinator = AppCoordinator(context: navigation)
        }

        coordinator?.start()
        
        return true
    }
    
    func isRunningUITests() -> Bool {
        return ProcessInfo.processInfo.environment.keys.contains("UITests")
    }
}

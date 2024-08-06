import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    private let sidebarViewController = SidebarViewController()
    private let contentViewController = ContentViewController()
    private var splitViewController: UISplitViewController!
    
    func application(_ application: UIApplication, 
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let splitVC = UISplitViewController(style: .doubleColumn)
        
        splitVC.viewControllers = [UINavigationController(rootViewController: sidebarViewController),
                                   UINavigationController(rootViewController: contentViewController)]
        
        self.splitViewController = splitVC
        
        let window = UIWindow(frame: UIScreen.main.bounds)
        
        window.rootViewController = splitVC
        window.makeKeyAndVisible()
        
        self.window = window
        
        return true
    }
}

import UIKit

extension UIApplication {
    var firstKeyWindow: UIWindow? {
        return UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.windows
            .first { $0.isKeyWindow }
    }
    
    var statusBarStyle: UIStatusBarStyle {
        return self.firstKeyWindow?.windowScene?.statusBarManager?.statusBarStyle ?? .default
    }
    
    func setStatusBarStyle(_ style: UIStatusBarStyle) {
        if let windowScene = self.firstKeyWindow?.windowScene {
            let viewController = windowScene.windows.first?.rootViewController
            viewController?.setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    func setStatusBarHidden(_ hidden: Bool, with animation: UIStatusBarAnimation) {
        guard let window = self.firstKeyWindow else { return }
        
        if animation == .none {
            window.windowLevel = hidden ? .statusBar : .normal
        } else {
            UIView.animate(withDuration: 0.3) {
                window.windowLevel = hidden ? .statusBar : .normal
            }
        }
    }
}
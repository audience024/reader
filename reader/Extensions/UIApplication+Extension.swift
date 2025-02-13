import UIKit

extension UIApplication {
    var firstKeyWindow: UIWindow? {
        return UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.windows
            .first { $0.isKeyWindow }
    }
    
    var statusBarStyle: UIStatusBarStyle {
        get {
            return firstKeyWindow?.windowScene?.statusBarManager?.statusBarStyle ?? .default
        }
        set {
            firstKeyWindow?.windowScene?.statusBarManager?.statusBarStyle = newValue
        }
    }
    
    func setStatusBarHidden(_ hidden: Bool, with animation: UIStatusBarAnimation) {
        guard let windowScene = firstKeyWindow?.windowScene else { return }
        let statusBarManager = windowScene.statusBarManager
        
        if animation == .none {
            statusBarManager?.isStatusBarHidden = hidden
        } else {
            UIView.animate(withDuration: 0.3) {
                statusBarManager?.isStatusBarHidden = hidden
            }
        }
    }
} 
import AppKit

class AnimationManager {
    static let shared = AnimationManager()
    
    func fadeSlideIn(view: NSView, fromY: CGFloat, toY: CGFloat, duration: TimeInterval = 0.3) {
        view.alphaValue = 0
        view.setFrameOrigin(NSPoint(x: view.frame.origin.x, y: fromY))
        
        NSAnimationContext.runAnimationGroup { context in
            context.duration = duration
            context.timingFunction = CAMediaTimingFunction(name: .easeOut)
            view.animator().alphaValue = 1
            view.animator().setFrameOrigin(NSPoint(x: view.frame.origin.x, y: toY))
        }
    }
    
    func fadeOut(view: NSView, duration: TimeInterval = 0.2, completion: (() -> Void)? = nil) {
        NSAnimationContext.runAnimationGroup { context in
            context.duration = duration
            view.animator().alphaValue = 0
        } completionHandler: {
            completion?()
        }
    }
    
    func bouncePress(layer: CALayer?, scaleTo: CGFloat = 0.92, duration: TimeInterval = 0.1) {
        guard let layer = layer else { return }
        let pressAnimation = CABasicAnimation(keyPath: "transform.scale")
        pressAnimation.fromValue = 1.0
        pressAnimation.toValue = scaleTo
        pressAnimation.duration = duration
        pressAnimation.autoreverses = true
        layer.add(pressAnimation, forKey: "press")
    }
    
    func crossFade(oldView: NSView?, newView: NSView?, duration: TimeInterval = 0.25) {
        NSAnimationContext.runAnimationGroup { context in
            context.duration = duration
            oldView?.animator().alphaValue = 0
            newView?.animator().alphaValue = 1
        }
    }
}

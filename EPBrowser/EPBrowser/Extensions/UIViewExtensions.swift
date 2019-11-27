//:
//:  UIView Animation Syntax Sugar
//:
//:  Created by Andyy Hope on 18/08/2016.
//:  Twitter: @andyyhope
//:  Medium: Andyy Hope, https://medium.com/@AndyyHope
//:  https://github.com/andyyhope/Blog_UIViewAnimationSyntaxSugar/blob/master/LICENSE

import UIKit

extension UIView {
    
    class Animator {
        typealias Completion = (Bool) -> Void
        typealias Animations = () -> Void
        
        fileprivate var animations: Animations
        fileprivate var completion: Completion?
        fileprivate let duration: TimeInterval
        fileprivate let delay: TimeInterval
        fileprivate let options: UIView.AnimationOptions
        
        init(duration: TimeInterval, delay: TimeInterval = 0, options: UIView.AnimationOptions = []) {
            self.animations = {}
            self.completion = nil
            self.duration = duration
            self.delay = delay
            self.options = options
        }
        
        func animations(_ animations: @escaping Animations) -> Self {
            self.animations = animations
            return self
        }
        
        func completion(_ completion: @escaping Completion) -> Self {
            self.completion = completion
            return self
        }
        
        func animate() {
            UIView.animate(withDuration: duration, delay: delay, animations: animations, completion: completion)
        }
    }
    
    final class SpringAnimator: Animator {
        
        fileprivate let damping: CGFloat
        fileprivate let velocity: CGFloat
        
        init(duration: TimeInterval, delay: TimeInterval = 0, damping: CGFloat, velocity: CGFloat, options: UIView.AnimationOptions = []) {
            self.damping = damping
            self.velocity = velocity
            
            super.init(duration: duration, delay: delay, options: options)
        }
        
        override func animate() {
            UIView.animate(withDuration: duration, delay: delay, usingSpringWithDamping: damping, initialSpringVelocity: velocity, options: options, animations: animations, completion: completion)
        }
    }
}




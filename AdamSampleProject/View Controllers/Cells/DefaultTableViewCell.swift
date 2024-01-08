//  AdamSampleProject

import CoreData
import UIKit

typealias ForceTouchAction = (_ force: Int, _ view: UIView) -> (Bool)

class DefaultTableViewCell: UITableViewCell {
    var forceTouchAction: ForceTouchAction?
    private var canForceTouch: Bool = false
    var wasForceTouched: Bool = false {
        didSet {
            self.canBeSelected = !wasForceTouched
        }
    }
    var canBeSelected: Bool = true
    var forceTouchImage: UIImage?
    var actioned: Bool = false
    
    func setForceTouchAllowed(_ allowed: Bool ) {
        if self.traitCollection.forceTouchCapability == .available {
            canForceTouch = allowed
        } else {
            canForceTouch = false
        }
    }
    
    func isForceTouchAllowed() -> Bool {
        return canForceTouch
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        wasForceTouched = false
        actioned = false
        super.touchesBegan(touches, with: event)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if forceTouchImage == nil {
        }
        
        if !canForceTouch {
            super.touchesMoved(touches, with: event)
            return
        }
        
        if actioned {
            let _ = forceTouchAction?(0, self)
            return
        }
        
        guard let touch = touches.first else {
            return
        }
        
        let percentageForce = Int((touch.force / touch.maximumPossibleForce) * 100)
        
        if percentageForce < 20 {
            return
        }
        
        wasForceTouched = true
        
        if let action = forceTouchAction {
            actioned = action(percentageForce, self)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let _ = forceTouchAction?(0, self)
        forceTouchImage = nil
        
        if !wasForceTouched {
            super.touchesEnded(touches, with: event)
        }
    }
}

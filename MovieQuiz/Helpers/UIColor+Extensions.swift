import UIKit

extension UIColor {
    static var testingYellow: UIColor {
        UIColor(named: "CustomYellow") ?? UIColor.black
    }
}


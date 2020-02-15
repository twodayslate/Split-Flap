import UIKit

extension UIViewController {
    /**
 - seealso: https://stackoverflow.com/a/54932223/193772
 */
    public func addActionSheetForiPad(actionSheet: UIViewController, sourceView _view: UIView? = nil, sourceRect _rect: CGRect? = nil, permittedArrowDirections _arrowDirections: UIPopoverArrowDirection? = nil) {
        let useView = (_view ?? self.view) as UIView
        let useRect = (_rect ?? CGRect(x: useView.bounds.midX, y: useView.bounds.midY, width: 0, height: 0)) as CGRect
        let useArrows = (_arrowDirections ?? []) as UIPopoverArrowDirection
        
        actionSheet.popoverPresentationController?.sourceView = useView
        actionSheet.popoverPresentationController?.sourceRect = useRect
        actionSheet.popoverPresentationController?.permittedArrowDirections = useArrows
    }
}

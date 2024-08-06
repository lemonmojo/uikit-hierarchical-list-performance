import Foundation
import UIKit

final class ContentViewController: UIViewController {
    @IBOutlet private weak var label: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    
    var item: ListItem? {
        didSet {
            updateView()
        }
    }
    
    init() {
        super.init(nibName: "ContentView", bundle: .main)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateView()
    }
}

private extension ContentViewController {
    func updateView() {
        guard let label,
              let imageView else {
            return
        }
        
        let text: String
        let imageName: String
        
        if let item {
            text = "Selected item: \(item.title)"
            imageName = item.systemImage
        } else {
            text = "No item selected"
            imageName = "info.circle"
        }
        
        guard let image = UIImage(systemName: imageName) else {
            fatalError()
        }
        
        label.text = text
        imageView.image = image
    }
}

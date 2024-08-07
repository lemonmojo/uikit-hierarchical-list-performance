import UIKit

final class SidebarViewController: UIViewController {
    private enum TreeSection: CaseIterable {
        case main
    }
    
    private typealias DS = UICollectionViewDiffableDataSource<TreeSection, ListItem>
    private typealias DSSnapshot = NSDiffableDataSourceSnapshot<TreeSection, ListItem>
    private typealias CellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, ListItem>
    
    // Flat example data.
//    private static let rootItem = ListItem.createFolder(leafsCount: 100_000,
//                                                        folderIndex: 1,
//                                                        leafStartIndex: 1)
    
    // Real-world example data with folder hierarchy.
    private static let rootItem = ListItem(title: "Root", children: [
        .createFolder(leafsCount: 25_000, folderIndex: 1, leafStartIndex: 1),
        .createFolder(leafsCount: 25_000, folderIndex: 2, leafStartIndex: 25_001),
        .createFolder(leafsCount: 25_000, folderIndex: 3, leafStartIndex: 50_001),
        .createFolder(leafsCount: 25_000, folderIndex: 4, leafStartIndex: 75_001)
    ])
    
    private var items: [ListItem] = SidebarViewController.rootItem.children ?? .init()
    
    private var selectedItem: ListItem? {
        didSet {
            let contentViewController = ContentViewController()
            let viewController = UINavigationController(rootViewController: contentViewController)
            
            showDetailViewController(viewController, sender: self)
            contentViewController.item = selectedItem
        }
    }
    
    private var collectionView: UICollectionView!
    private var dataSource: DS!
    
    override func loadView() {
        let collectionView = Self.createCollectionView(delegate: self)
        let dataSource = Self.createDataSource(with: collectionView)
        
        self.collectionView = collectionView
        self.dataSource = dataSource
        
        collectionView.dataSource = dataSource
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Shuffle", 
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(shuffle))
        
        self.view = collectionView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        applySnapshot(treeNodes: items, to: .main)
    }
    
    @objc
    private func shuffle() {
        items = items.shuffled()
        
        applySnapshot(treeNodes: items, to: .main)
        collectionView.reloadData()
    }
    
    private static func createCollectionView(delegate: UICollectionViewDelegate) -> UICollectionView {
        let config = UICollectionLayoutListConfiguration(appearance: .sidebar)
        let layout = UICollectionViewCompositionalLayout.list(using: config)
        
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        
        collectionView.delegate = delegate
        
        return collectionView
    }
    
    private static func createDataSource(with collectionView: UICollectionView) -> DS {
        let cellRegistration: CellRegistration = {
            CellRegistration { cell, indexPath, treeNode in
                var config = cell.defaultContentConfiguration()
                
                config.image = UIImage(systemName: treeNode.systemImage)
                config.text = treeNode.title
                config.secondaryText = treeNode.id.uuidString
                
                cell.contentConfiguration = config
                
                // include disclosure indicator for nodes with children
                cell.accessories = treeNode.children != nil ? [.outlineDisclosure()] : []
            }
        }()
        
        return DS(collectionView: collectionView) { collectionView, indexPath, treeNode -> UICollectionViewCell? in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: treeNode)
        }
    }
    
    private func applySnapshot(treeNodes: [ListItem], to section: TreeSection) {
        // reset section
        var snapshot = DSSnapshot()
        snapshot.appendSections([section])
        dataSource.apply(snapshot, animatingDifferences: false)
        
        // initial snapshot with the root nodes
        var sectionSnapshot = NSDiffableDataSourceSectionSnapshot<ListItem>()
        sectionSnapshot.append(treeNodes)
        
        func addItemsRecursively(_ nodes: [ListItem], to parent: ListItem?) {
            nodes.forEach { node in
                // for each node we add its children, then recurse into the children nodes
                if let children = node.children, !children.isEmpty {
                    sectionSnapshot.append(children, to: node)
                    addItemsRecursively(children, to: node)
                }
            }
        }
        
        addItemsRecursively(treeNodes, to: nil)
        dataSource.apply(sectionSnapshot, to: section, animatingDifferences: true)
    }
}

extension SidebarViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, 
                        didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath),
              let config = cell.contentConfiguration as? UIListContentConfiguration,
              let idStr = config.secondaryText,
              let id = UUID(uuidString: idStr),
              let item = Self.rootItem.itemWith(id: id) else {
            selectedItem = nil
            
            return
        }
        
        selectedItem = item
    }
}

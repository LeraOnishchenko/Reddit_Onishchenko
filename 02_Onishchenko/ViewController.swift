//
//  ViewController.swift
//  02_Onishchenko
//
//  Created by lera on 15.02.2022.
//
import UIKit
import SDWebImage
import SwiftUI
class ViewController: UIViewController , UINavigationControllerDelegate{
    // MARK: - IBOutlets

    @IBOutlet private weak var username: UILabel!
    @IBOutlet private weak var time: UILabel!
    @IBOutlet private weak var domain: UILabel!
    @IBOutlet private weak var share: NSLayoutConstraint!
    @IBOutlet private weak var comments: UIButton!
    @IBOutlet private weak var rating: UIButton!
    @IBOutlet private weak var bookmark: UIButton!
    @IBOutlet private weak var image: UIImageView!
    @IBOutlet private weak var textlab: UILabel!
    
    @IBOutlet private  weak var commentsContainerView: UIView!
    
    @IBAction func save(_ sender: Any) {
        saved()
    }
    func saved(){
        self.Post?.saved.toggle()
        let image = Post!.saved ? UIImage(systemName: "bookmark.fill") : UIImage(systemName: "bookmark")
        bookmark.setImage(image, for: .normal)
    }
    @IBAction func sharePost(_ sender: Any) {
        guard let Post = self.Post else{return}
        let items: [Any] = [Post.url]
                let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)

                present(controller, animated: true)
    }
    var Post: Post? = nil
    weak var delegate: PostTableViewCellDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCommentsView()
        navigationController?.delegate = self
        configView()
        addGesture()
        
    }
    func configView(){
        guard let Post = self.Post else{return}
        self.textlab.text = Post.title
        self.textlab.numberOfLines = 0
        self.username.text = Post.id
        self.domain.text =  Post.domain
        self.comments.setTitle(String((Post.num_comments)!), for: .normal)
        self.rating.setTitle(String(Post.rating), for: .normal)
        let calendar = Calendar.current
        let timeHour = calendar.component(.hour, from: Date(timeIntervalSince1970: (Post.created)!))
        self.time.text = (String(timeHour) + "h")
        self.image.sd_setImage(with: URL(string: Post.preview?.images.first?.source.url ?? "https://preview.redd.it/b561b7thjlr11.jpg?width=108&crop=smart&auto=webp&s=03d91d0d1a70ee9b5d6a8cf753bc4a661f29ed29"), completed: nil)
        let image = Post.saved ? UIImage(systemName: "bookmark.fill") : UIImage(systemName: "bookmark")
        bookmark.setImage(image, for: .normal)
        
    }
    private func addGesture() {
            let doubleTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.animatedSave))
        doubleTap.numberOfTapsRequired = 2
            self.image.addGestureRecognizer(doubleTap)
            self.image.isUserInteractionEnabled = true
           }
    
    @objc
    private func animatedSave() {
        if(self.Post?.saved == false){
            saved()
        let path = UIBezierPath()
            let centerX = self.image.bounds.midX
            let centerY = self.image.bounds.midY
        path.move(to: CGPoint(x: centerX-50, y: centerY-70))
        path.addLine(to: CGPoint(x: centerX+50, y: centerY-70))
        path.addLine(to: CGPoint(x: centerX+50, y: centerY+70))
        path.addLine(to: CGPoint(x: centerX, y: centerY))
        path.addLine(to: CGPoint(x: centerX-50, y: centerY+70))
        path.addLine(to: CGPoint(x: centerX-50, y: centerY-70))
        let shape = CAShapeLayer()
        shape.path = path.cgPath
        shape.lineWidth = 5.0
        shape.fillColor = UIColor.clear.cgColor
        shape.strokeColor = UIColor.black.cgColor
        let animation = CABasicAnimation(keyPath: "strokeEnd")
            animation.fromValue = self.Post!.saved ? 0.0 : 1.0
            animation.toValue = self.Post!.saved ? 1.0 : 0.0
        animation.duration = 1.5
        CATransaction.setCompletionBlock{ [weak self] in
            self?.image.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        }
        shape.add(animation, forKey: "drawLineAnimation")
            self.image.layer.addSublayer(shape)
        }
        
    }

    
    func navigationController(_ navigationController: UINavigationController, willShow PostListViewController: UIViewController, animated: Bool) {
        guard let Post = self.Post else{return}
        if let controller = PostListViewController as? PostListViewController{
            let index = controller.Posts.firstIndex(where: {$0.name == Post.name})
            if let index = index {
                controller.Posts[index].saved = Post.saved
            }
            controller.PostsView = controller.savedModeStatus ?
                controller.searchFilter() :
                controller.Posts
            controller.passDataToSceneDelegate()
            controller.loadTable()
        }
    }
    // MARK: - Comments
    private func loadCommentsView() {
        guard let post = self.Post else{return}
        guard let post_id = post.id else{return}
        let dataNew = try! Data(contentsOf: URL(string: "https://www.reddit.com/r/ios/comments/\(post_id)/.json")!)
        let myReddit = try! JSONDecoder().decode([CData].self, from:dataNew)
        let Comments = (myReddit[1].data?.children?.compactMap({$0.data}))!
        
        let hostVc = UIHostingController(rootView: CommentList(comments: Comments))
        self.addChild(hostVc)
        self.commentsContainerView.addSubview(hostVc.view)
        hostVc.didMove(toParent: self)
        
        hostVc.view.translatesAutoresizingMaskIntoConstraints = false
        hostVc.view.topAnchor.constraint(equalTo: commentsContainerView.topAnchor).isActive = true
        hostVc.view.trailingAnchor.constraint(equalTo: commentsContainerView.trailingAnchor).isActive = true
        hostVc.view.leadingAnchor.constraint(equalTo: commentsContainerView.leadingAnchor).isActive = true
        hostVc.view.bottomAnchor.constraint(equalTo: commentsContainerView.bottomAnchor).isActive = true
    }
}

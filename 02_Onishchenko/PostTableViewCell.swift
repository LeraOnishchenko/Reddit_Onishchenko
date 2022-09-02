//
//  PostTableViewCell.swift
//  02_Onishchenko

import UIKit
import SDWebImage


class PostTableViewCell: UITableViewCell {
    //MARK: - IBOutlet
    var savedButtonHandler: ((_ sender: Any) -> Void)?
    @IBAction func sharePost(_ sender: Any) {
        guard let post = self.post else {return}
        delegate?.shouldShare(post: post)
    }
    
    @IBAction func savePost(_ sender: Any) {
        if self.savedButtonHandler != nil{
            self.savedButtonHandler!(sender)
        }
    }

    @IBOutlet private weak var username: UILabel!
    @IBOutlet private weak var textlab: UILabel!
    @IBOutlet private weak var bookmark: UIButton!
    @IBOutlet private weak var immage: UIImageView!
    @IBOutlet private weak var domain: UILabel!
    @IBOutlet private weak var raiting: UIButton!
    @IBOutlet private weak var time: UILabel!
    @IBOutlet private weak var comments: UIButton!
    @IBOutlet private weak var share: UIButton!
    weak var delegate: PostTableViewCellDelegate?

   
    //MARK: - Config
    var post: Post? = nil
    func config(from data:Post){
        self.post = data
        self.textlab.text = data.title
        self.textlab.numberOfLines = 0
        self.username.text = data.author
        self.domain.text =  data.domain
        self.comments.setTitle(String((data.num_comments)!), for: .normal)
        self.share.setTitle(String(data.rating), for: .normal)
        let calendar = Calendar.current
        let timeHour = calendar.component(.hour, from: Date(timeIntervalSince1970: (data.created)!))
        self.time.text = (String(timeHour) + "h")
        self.immage.sd_setImage(with: URL(string: data.preview?.images.first?.source.url ?? "https://preview.redd.it/b561b7thjlr11.jpg?width=108&crop=smart&auto=webp&s=03d91d0d1a70ee9b5d6a8cf753bc4a661f29ed29"), completed: nil)
        let image = data.saved ? UIImage(systemName: "bookmark.fill") : UIImage(systemName: "bookmark")
        bookmark.setImage(image, for: .normal)
        addGesture()
    }
    private func addGesture() {
            let doubleTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.animatedSave))
            doubleTap.numberOfTapsRequired = 2
            self.immage.addGestureRecognizer(doubleTap)
            self.immage.isUserInteractionEnabled = true
           }
    func saved(){
        self.post?.saved.toggle()
        let image = post!.saved ? UIImage(systemName: "bookmark.fill") : UIImage(systemName: "bookmark")
        bookmark.setImage(image, for: .normal)
    }
    @objc
    private func animatedSave() {
        if(self.post?.saved == false){
            saved()
        let path = UIBezierPath()
            let centerX = self.immage.bounds.midX
            let centerY = self.immage.bounds.midY
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
            animation.fromValue = self.post!.saved ? 0.0 : 1.0
            animation.toValue = self.post!.saved ? 1.0 : 0.0
        animation.duration = 1.5
        CATransaction.setCompletionBlock{ [weak self] in
            self?.immage.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        }
        shape.add(animation, forKey: "drawLineAnimation")
            self.immage.layer.addSublayer(shape)
        }
        
    }

    

}



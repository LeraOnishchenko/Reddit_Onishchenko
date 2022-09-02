//
//  PostListViewController.swift
//  02_Onishchenko
//
import UIKit
import SDWebImage

class PostListViewController: UIViewController, UITableViewDelegate, PostTableViewCellDelegate, UISearchBarDelegate {
    

    func shouldShare(post: Post) {
        let items: [Any] = [post.url]
                let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
                present(controller, animated: true)
    }
    
    @IBAction func showSaved(_ sender: Any) {
        savedModeStatus.toggle()
        self.SearchBar.isHidden = !savedModeStatus
        self.PostsView = savedModeStatus ? searchFilter() : self.Posts
        self.tableView.reloadData()
        SearchBar.resignFirstResponder()
    }
    
//MARK: - IBOutlets
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var SearchBar: UISearchBar!
    @IBOutlet private weak var OnlySaved: UIButton!
    // MARK: - Properties
    weak var delegate: PostTableViewCellDelegate?
    private var saved: Bool = false
    let limit = 10
    var after = ""
    var searchWord = ""
    var Posts: [Post] = []
    var PostsView: [Post] = []
    var PostsSaved: [Post] = []
    var myReddit : Redit? = nil
    var savedStatus = false
    var sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as! SceneDelegate
    //MARK: - Lifecycle
    override func viewDidLoad(){
        super.viewDidLoad()
        setupTable()
        SearchBar.delegate = self
        self.SearchBar.isHidden = !savedModeStatus
        self.PostsSaved = sceneDelegate.PostsSaved
        let dataNew = try! Data(contentsOf: URL(string: "https://www.reddit.com/r/ios/top.json?limit=\(self.limit)&raw_json=1&after=\(self.after)")!)
        self.myReddit = try! JSONDecoder().decode(Redit.self, from:dataNew)
        DispatchQueue.main.async {
            self.Posts = (self.myReddit?.data.children.map({$0.data}))!
            // add local posts if not contain
            let idAll = self.Posts.map({$0.name})
            for (index,_) in self.PostsSaved.enumerated(){
                if !idAll.contains(self.PostsSaved[index].name){
                    self.Posts.append(self.PostsSaved[index])
                }
            }
            let idSaved = self.PostsSaved.map({$0.name})
            for (index,_) in self.Posts.enumerated(){
                if idSaved.contains(self.Posts[index].name){
                    self.Posts[index].saved = true
                }
            }
            self.PostsView = self.Posts
            self.tableView.reloadData()
        }
    }
    var savedModeStatus = false {
        didSet{
            if savedModeStatus{
                OnlySaved.setImage(UIImage(systemName: "bookmark.fill"), for: .normal)
                self.PostsView = searchFilter()
                savedStatus = true
            }
            else{
                OnlySaved.setImage(UIImage(systemName: "bookmark"), for: .normal)
                self.PostsView = self.Posts
                savedStatus = false
            }
        }
    }
    
    func passDataToSceneDelegate(){
        self.PostsSaved = self.Posts.filter({ $0.saved })
        sceneDelegate.PostsSaved = self.PostsSaved
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? ViewController,
            let index = tableView.indexPathForSelectedRow?.row
        {
            destination.Post = Posts[index]
            SearchBar.resignFirstResponder()
        }
    }
    private func reloadPosts(){
        after = (myReddit?.data.after!)!
        let dataNew = try! Data(contentsOf: URL(string: "https://www.reddit.com/r/ios/top.json?limit=\(limit)&raw_json=1&after=\(after)")!)
        myReddit = try! JSONDecoder().decode(Redit.self, from:dataNew)
        self.Posts += (myReddit?.data.children.map({$0.data}))!
        self.PostsView += (myReddit?.data.children.map({$0.data}))!
    }
    private func setupTable(){
        tableView.dataSource = self
        tableView.delegate = self
    }
    
}

  

 // MARK: - UITableViewDataSourse
extension PostListViewController: UITableViewDataSource{
    func searchBar(_ SearchBar: UISearchBar, textDidChange searchText: String) {
        self.PostsView = PostsSaved
        searchWord = searchText.lowercased()
        self.PostsView = searchFilter()
        print(searchFilter().count)
        self.tableView.reloadData()
    }
    func searchFilter() -> [Post]{
        //print(searchWord.count)
        if searchWord.count == 0 {
            passDataToSceneDelegate()
            return self.PostsSaved
        }
        return PostsView.filter({(($0.title?.lowercased().contains(searchWord))! ||
                              (($0.author?.lowercased().contains(searchWord))!) ||
                              (($0.domain?.lowercased().contains(searchWord))!)) &&
                                $0.saved})
    }
    func tableView(_ tableView: UITableView, hightForRowAt indexPath: IndexPath) -> CGFloat {
        500
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return self.PostsView.count
       // return 10
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: PostTableViewCell.self), for: indexPath) as! PostTableViewCell
        
        cell.savedButtonHandler = { sender in
            let index = self.Posts
                .firstIndex(where:
                                { $0.name == self.PostsView[indexPath.row].name }
                )
            if let index = index {
                if(sender is UITapGestureRecognizer){
                    self.Posts[index].saved = true
                }
                else{
                    self.Posts[index].saved.toggle()
                }
            }
            self.passDataToSceneDelegate()
            self.PostsSaved = self.searchFilter()
            self.PostsView = self.savedModeStatus ? self.PostsSaved : self.Posts
            self.tableView.reloadData()
        }
        cell.config(from: PostsView[indexPath.row])
        cell.delegate = self
        return cell
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == PostsView.count - 2 &&  savedStatus == false {
                self.reloadPosts()
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                }
            }
    @objc func loadTable() {
        self.tableView.reloadData()
    }
}

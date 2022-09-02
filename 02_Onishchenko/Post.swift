//
//  Post.swift
//  02_Onishchenko
//
//  Created by lera on 14.05.2022.
//

import Foundation

struct Redit: Codable{
    let data: Children
    
}
struct Children: Codable{
    let children : [Tew]
    let after: String?
}
struct Tew: Codable{
    let data: Post
}
struct Post: Codable{
    let name: String?
    let url: String?
    let title: String?
    let author: String?
    let domain: String?
    let num_comments: Int?
    let id: String?
    let ups: Int?
    let downs: Int?
    var rating: Int{
        return (ups ?? 0) + (downs ?? 0)
    }
    let created: Double?
    let preview: Image?
    var saved: Bool = false
   
}
struct Image: Codable {
    let images: [SourceDTO]
}
struct SourceDTO: Codable{
    let source: UrlDTO
}
struct UrlDTO: Codable{
    let url: String
}

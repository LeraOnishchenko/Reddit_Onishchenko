//
//  PostViewDelegate.swift
//  02_Onishchenko
//
//  Created by lera on 14.05.2022.
//

import UIKit
protocol PostTableViewCellDelegate : AnyObject{
    func shouldShare(post:Post)
}

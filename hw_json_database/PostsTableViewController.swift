//
//  PostsTableViewController.swift
//  hw_json_database
//
//  Created by Anna on 02.08.17.
//  Copyright © 2017 Anna. All rights reserved.
//

import UIKit
import CoreData

class PostsTableViewController: UITableViewController {
    
    var refreshCount = 0
    var refresh: UIRefreshControl!
    
    var usersArray: [User] = []
    var postsArray: [Posts] = []
    
    override func viewWillAppear(_ animated: Bool) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequestPost: NSFetchRequest<Posts> = Posts.fetchRequest()
        do {
            postsArray = try context.fetch(fetchRequestPost)
        } catch {
            print(error.localizedDescription)
        }
        
        let fetchRequestUser: NSFetchRequest<User> = User.fetchRequest()
        do {
            usersArray = try context.fetch(fetchRequestUser)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.pullDown()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postsArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userPostCellIdentifier", for: indexPath)
        
        if let myCell = cell as? PostsTableViewCell {
            
            let titlePost = postsArray[indexPath.row]
            let userPosts = usersArray[indexPath.row]
            
            myCell.userIdLable.text = "User: \(String(userPosts.userId))"
            myCell.postIdLabel.text = "Post №: \(String(titlePost.id))"
            myCell.postTitleLabel.text = titlePost.title
            myCell.postBodyLabel.text = titlePost.body
            
            tableView.estimatedRowHeight = 44
            tableView.rowHeight = UITableViewAutomaticDimension
        }
        
        return cell
    }
    
    // MARK: - JSON Download
    func jsonDownload () {
        if let url = URL(string: "http://jsonplaceholder.typicode.com/posts?userId=\(refreshCount)") {
            if url == URL(string: "") {
                print("нет интернета")
            } else {
                let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                    if let taskError = error {
                        print(taskError.localizedDescription)
                        return
                    }
                    
                    if let downloadetData = data {
                        if let json = (try? JSONSerialization.jsonObject(with: downloadetData, options: [])) as? [[String:Any]] {
                            
                            let appDelegate = UIApplication.shared.delegate as! AppDelegate
                            let context = appDelegate.persistentContainer.viewContext
                            
                            //                        let fetchRequest: NSFetchRequest<Posts> = Posts.fetchRequest()
                            //                        do {
                            //                            let result = try context.fetch(fetchRequest)
                            //                            if result.isEmpty {
                            
                            for dictionary in json {
                                if let userId = dictionary["userId"] as? Int32,
                                    let id = dictionary["id"] as? Int32,
                                    let title = dictionary["title"] as? String,
                                    let body = dictionary["body"] as? String {
                                    
                                        self.savePost(userId: userId, id: id, title: title, body: body)
                                }
                            }
                            //                            }
                            //                        } catch {
                            //                            print(error.localizedDescription)
                            //                        }
                        }
                    }
                }
                task.resume()
            }
        }
    }
    
    // MARK: - Refresh
    func pullDown () {
        refresh = UIRefreshControl()
        refresh.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresh.addTarget(self, action: #selector(PostsTableViewController.addPosts), for: UIControlEvents.valueChanged)
        tableView.addSubview(refresh)
    }
    
    func addPosts ( ) {
        refreshCount += 1
        print(refreshCount)
            self.jsonDownload()
        //tableView.reloadData()
        refresh.endRefreshing()
    }
    
    // MARK: - Save to the database
    func savePost(userId: Int32, id: Int32, title: String, body: String) {
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let entity = NSEntityDescription.entity(forEntityName: "Posts", in: context)
            let postObject = NSManagedObject(entity: entity!, insertInto: context) as! Posts
            
            postObject.id = id
            postObject.title = title
            postObject.body = body
            
            do {
                try context.save()
                postsArray.insert(postObject, at: 0)
                print("Saved post! Good job")
            } catch {
                print(error.localizedDescription)
            }
            
            let entityUser = NSEntityDescription.entity(forEntityName: "User", in: context)
            let userObject = NSManagedObject(entity: entityUser!, insertInto: context) as! User
            userObject.userId = userId
            
            do {
                try context.save()
                usersArray.insert(userObject, at: 0)
                print("Saved user! Good job")
            } catch {
                print(error.localizedDescription)
            }
            tableView.reloadData()
    }
    
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

//
//  MoviesViewController.swift
//  MovieViewer
//
//  Created by Kate Suttner on 1/7/16.
//  Copyright © 2016 CodePath. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD


class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
@IBOutlet weak var tableView: UITableView!

    var movies: [NSDictionary]?
    
    var endpoint: String!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
    
    let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refreshControlAction:", forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)
    
        
    tableView.dataSource = self
    tableView.delegate = self
    

    let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
    let url = NSURL(string:"https://api.themoviedb.org/3/movie/\(endpoint)?api_key=\(apiKey)")
    
    let request = NSURLRequest(URL: url!)
    let session = NSURLSession(
        configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
        delegate:nil,
        delegateQueue:NSOperationQueue.mainQueue()
    )
    
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        
    let task : NSURLSessionDataTask = session.dataTaskWithRequest(request,
        completionHandler: { (dataOrNil, response, error) in
            if let data = dataOrNil {
                if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                    data, options:[]) as? NSDictionary {
                        NSLog("response: \(responseDictionary)")
         
        
                        self.delay(1,closure: {MBProgressHUD.hideHUDForView(self.view, animated: true)})
                        self.movies = (responseDictionary["results"] as! [NSDictionary])
                        self.tableView.reloadData()
                }
            }
    });
    task.resume() 
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func refreshControlAction(refreshControl: UIRefreshControl) {
        self.tableView.reloadData()
        refreshControl.endRefreshing()
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let movies = movies {
            return movies.count
        } else {
            return 0
        }
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as! MovieCell
        
        let movie = movies![indexPath.row]
        let title = movie["title"] as! String
        let overview = movie["overview"] as! String
        cell.titleLabel.text = title
        cell.overviewLabel.text = overview
        
        let baseUrl = "http://image.tmdb.org/t/p/w500"
        
        if let posterPath = movie["poster_path"] as? String{
        let imageURL = NSURL(string: baseUrl + posterPath)
        cell.posterView.setImageWithURL(imageURL!)
        }
       
        
        print("row \(indexPath.row)")
        return cell
    }
 
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
        ),
        dispatch_get_main_queue(), closure)
        
    }
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let cell = sender as! UITableViewCell
        let indexpath = tableView.indexPathForCell(cell)
        let movie = movies![indexpath!.row]
        
        let detailViewController = segue.destinationViewController  as! DetailViewController
        detailViewController.movie = movie
        
        
        print ("prepare for segue called")
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        

}


}
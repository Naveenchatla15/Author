//
//  ViewController.swift
//  Photos1
//
//  Created by Mac on 04/05/23.
//

import UIKit
import Alamofire
import MBProgressHUD
import Kingfisher
import AudioToolbox

class ViewController: UIViewController {
    
    private let refreshControl = UIRefreshControl()
    @IBOutlet weak var photosTB : UITableView!
    
    var pageCount = 1
    private var isFetchingImages = false
    var  photosResponseArray = Array<PhotosResponseModel>()
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 10.0, *) {
            photosTB.refreshControl = refreshControl
        } else {
            photosTB.addSubview(refreshControl)
        }
        refreshControl.addTarget(self, action: #selector(refreshWeatherData(_:)), for: .valueChanged)
        refreshControl.tintColor = UIColor(red:0.25, green:0.72, blue:0.85, alpha:1.0)
        
        self.photosTB.delegate = self
        self.photosTB.dataSource = self
        self.photosTB.prefetchDataSource = self
        
        self.photosTB.estimatedRowHeight = 100
        self.photosTB.rowHeight = UITableView.automaticDimension
        registerCellForTableView()
    }
    
    //MARK :- Two type of API Calls
    // 1 :: ->  Defualt URLSession
    // 2 :: ->  Alamofire
    
    override func viewWillAppear(_ animated: Bool) {
        photosResponseArray.removeAll()
        print(photosResponseArray)
        self.photosAPICall(params: ["page" : "\(pageCount)" , "limit" : "20"])
        
        //        authorsAPICallByAlamofire()
    }
    
    //MARK:- Pull to refresh
    @objc private func refreshWeatherData(_ sender: Any) {
        self.photosAPICall(params: ["page" : "\(pageCount)" , "limit" : "20"])
    }
    
    //MARK:- Dismis dialog
    @objc func dismissOnTapOutside(){
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK:- checkBtnAction
    @objc func checkBtnAction(sender : UIButton){
        self.photosResponseArray[sender.tag].isChecked = self.photosResponseArray[sender.tag].isChecked == true ? false : true
        
        let indexPosition = IndexPath(row: sender.tag, section: 0)
        photosTB.reloadRows(at: [indexPosition], with: .none)
    }
    
    //MARK:- downloadBtnAction
    @objc func downloadBtnAction(sender : UIButton){
        
        guard let imageUrl = self.photosResponseArray[sender.tag].downloadURL else { return }
        let url = URL(string: imageUrl)
        
        let data = try? Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
        UIImageWriteToSavedPhotosAlbum(UIImage(data: data!)!, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    //MARK: - Add image to Library
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            showToast(message: error.localizedDescription)
        } else {
            
            let systemSoundID: SystemSoundID = 1007
            AudioServicesPlaySystemSound(systemSoundID)
            showToast(message: "Successfully downloaded")
            
        }
    }
    
}


extension ViewController :  UITableViewDataSource , UITableViewDelegate, UITableViewDataSourcePrefetching {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.photosResponseArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PhotosTableViewCell", for: indexPath) as! PhotosTableViewCell
        
        cell.checkBtn.tag = indexPath.row
        cell.downloadBtn.tag = indexPath.row
        cell.downloadBtn.addTarget(self, action: #selector(downloadBtnAction(sender:)), for: .touchUpInside)
        cell.checkBtn.addTarget(self, action: #selector(checkBtnAction(sender:)), for: .touchUpInside)
        cell.authornameLbl.text = self.photosResponseArray[indexPath.row].author ?? ""
        cell.downloadBtn.isEnabled = self.photosResponseArray[indexPath.row].downloadURL == "" ? false : true
        cell.configureCell(value: self.photosResponseArray[indexPath.row].downloadURL ?? "")
        if self.photosResponseArray[indexPath.row].isChecked == true {
            cell.checkBtn.setImage(UIImage(named: "check"), for: .normal)
        }
        else
        {
            cell.checkBtn.setImage(UIImage(named: "uncheck"), for: .normal)
        }
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let description = self.photosResponseArray[indexPath.row].author ?? ""
        if self.photosResponseArray[indexPath.row].isChecked == true
        {
            let uialert = UIAlertController(title: "WELCOME", message: description, preferredStyle: .alert)
            self.present(uialert, animated: true, completion:{
                uialert.view.superview?.isUserInteractionEnabled = true
                uialert.view.superview?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.dismissOnTapOutside)))
            })
        }
        else
        {
            let alert = UIAlertController(title: "Author", message: description, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        
        for index in indexPaths {
            if index.row >= self.photosResponseArray.count - 2 {
                self.photosAPICall(params: ["page" : "\(pageCount)", "limit" : "20"])
                break
            }
        }
    }
    //    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    //        if indexPath.row == self.photosResponseArray.count - 1 {
    //            pageCount += 1
    //            self.photosAPICall(params: ["page" : "\(pageCount)", "limit" : "20"])
    //        }
    //
    //    }
    
}

extension ViewController {
    private func registerCellForTableView() {
        self.photosTB.register(UINib(nibName: "PhotosTableViewCell", bundle: nil), forCellReuseIdentifier: "PhotosTableViewCell")
    }
    
    
    //MARK:- photosAPICall()
    func photosAPICall(params : [String:String])
    {
        MBProgressHUD.showAdded(to: self.view, animated: true)
        let urlComp = NSURLComponents(string: "https://picsum.photos/v2/list?page={page}&limit={limit}")!
        var items = [URLQueryItem]()
        
        for (key,value) in params {
            items.append(URLQueryItem(name: key, value: value))
        }
        items = items.filter{!$0.name.isEmpty}
        if !items.isEmpty {
            urlComp.queryItems = items
        }
        var urlRequest = URLRequest(url: urlComp.url!)
        print(urlComp.url!)
        urlRequest.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            DispatchQueue.main.async {
                MBProgressHUD.hide(for: self.view, animated: true)
            }
            
            guard let httpResponse = response as? HTTPURLResponse, let receivedData = data
            else {
                print("error: not a valid http response")
                return
            }
            switch (httpResponse.statusCode)
            {
            case 200:
                
                let response = NSString (data: receivedData, encoding: NSUTF8StringEncoding)
                print("response is \(String(describing: response))")
                
                if let jsonData = data {
                    let photosResponseModel = try? JSONDecoder().decode([PhotosResponseModel].self, from: jsonData)
                    self.photosResponseArray.append(contentsOf: photosResponseModel!)
                    print(self.photosResponseArray[0].author!)
                    print(self.photosResponseArray.count)
                    
                } else if let error = error {
                    print("HTTP Request Failed \(error)")
                }
                break
            case 400:
                
                break
            default:
                print("wallet GET request got response \(httpResponse.statusCode)")
            }
            DispatchQueue.main.async {
                self.photosTB.reloadData()
                self.refreshControl.endRefreshing()
                self.pageCount += 1
            }
        }
        task.resume()
    }
    
    
    func authorsAPICallByAlamofire() {
        isFetchingImages = true
        APIClient.fetchImages2(atPage: self.pageCount) { (response, error) in
            guard let response1 = response else { return }
            print("Response ::  -> ", response1)
            self.photosResponseArray.append(contentsOf: response1)
            print(self.photosResponseArray[0].author!)
            print(self.photosResponseArray.count)
            self.photosTB.reloadData()
            self.pageCount += 1
            self.isFetchingImages = false
        }
    }
    
}

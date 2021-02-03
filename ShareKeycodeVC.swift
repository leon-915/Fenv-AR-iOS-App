//
//  ShareKeycodeVC.swift
//  Fenvyu
//
//  Created by Admin on 5/17/20.
//  Copyright © 2020 admin. All rights reserved.
//

import UIKit
import Social
import FBSDKShareKit
import TwitterKit

class ShareKeycodeVC: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var wrapper: UIView!
    
    @IBOutlet weak var keycodeLabel: UILabel!
    @IBOutlet weak var qrCodeWrapper: UIView!
    @IBOutlet weak var qrCodeImageView: UIImageView!
    @IBOutlet weak var copyButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var socialWrapper: UIView!
    
    var project: FenvyuProject?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: true)
        (tabBarController as! FenvyuTabVC).showTabView(show: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        updateWrappers()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    
    func setupUI() {
        title = "Share"
        
        copyButton.layer.cornerRadius = 20
        copyButton.layer.borderWidth = 1
        copyButton.layer.borderColor = UIColor.lightGray.cgColor
        
        shareButton.layer.cornerRadius = 20
        shareButton.layer.borderWidth = 1
        shareButton.layer.borderColor = UIColor.lightGray.cgColor
        
        qrCodeWrapper.layer.borderWidth = 5.0
        qrCodeWrapper.layer.borderColor = UIColor.lightGray.cgColor
        
        guard let keycode = project?.keycode else {
            return
        }
        
        keycodeLabel.text = keycode
        qrCodeImageView.image = keycode.generateQRCode()
    }
    
    func updateWrappers() {
        let height = socialWrapper.frame.maxY + 40
        scrollView.contentSize = CGSize(width: scrollView.frame.width, height: height)
    }
    
    @IBAction func tapBackButton(_ sender: Any) {
        navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func tapCopyButton(_ sender: UIButton) {
        guard let keycode = keycodeLabel.text, let qrCode = qrCodeImageView.image else {
            return
        }
        
        UIPasteboard.general.string = keycode
//        UIPasteboard.general.image = qrCode
    }
    
    @IBAction func tapShareButton(_ sender: UIButton) {
        guard let keycode = keycodeLabel.text, let qrCode = qrCodeImageView.image else {
            return
        }
        
        // set up activity view controller
        let objectsToShare = [keycode, qrCode] as [Any]
        
        let activityViewController = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash

        // exclude some activity types from the list (optional)
        activityViewController.excludedActivityTypes = [UIActivity.ActivityType.airDrop,
                                                        UIActivity.ActivityType.postToFacebook]

        // present the view controller
        self.present(activityViewController, animated: true, completion: nil)
        
    }
    
    @IBAction func tapTwitterButton(_ sender: UIButton) {
        guard let keyCode = keycodeLabel.text, let qrCode = qrCodeImageView.image else {
            return
        }
        
        if TWTRTwitter.sharedInstance().sessionStore.hasLoggedInUsers() {
            // App must have at least one logged-in user to compose a Tweet
            /*
            let vc = TWTRComposer()
            vc.setText("Tweet text")
            vc.setImage(qrCode)
            vc.setURL(URL(string: "https://dev.twitter.com"))
            vc.show(from: self) { (result) in
                print("Result = \(result.rawValue)")
            }
            */
            
            showTwitterComposer(keyCode: keyCode, qrCode: qrCode)
        }
        else {
            // Log in, and then check again
            TWTRTwitter.sharedInstance().logIn { session, error in
                if session != nil { // Log in succeeded
                    self.showTwitterComposer(keyCode: keyCode, qrCode: qrCode)
                }
                else {
                    let alert = UIAlertController(title: "No Twitter Accounts Available", message: "You must log in before presenting a composer.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action) in
                        
                    }))
                    self.present(alert, animated: false, completion: nil)
                }
            }
        }
    }
    
    @IBAction func tapInstagramButton(_ sender: UIButton) {
        guard let qrCode = qrCodeImageView.image else {
            return
        }

        guard let imageData = qrCode.jpegData(compressionQuality: 1.0), let image = UIImage(data: imageData) else {
            return
        }
        
        let albumName = "Fenvyu"
        PHPhotoLibrary.shared().savePhoto(image: image, albumName: albumName) { (asset) in
            guard let asset = asset else {
                return
            }
            
            let url = URL(string: "instagram://library?LocalIdentifier=(\(asset.localIdentifier)")!
            
            DispatchQueue.main.async {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url)
                }
                else {
                    self.showAlert(msg: "Instagram is not installed", handler: nil)
                }
            }
        }
    }
    
    @IBAction func tapFbButton(_ sender: UIButton) {
        guard let qrCode = qrCodeImageView.image else {
            return
        }
        
//        let share = [qrCode, keycode] as [Any]
//        let activityVC = UIActivityViewController(activityItems: share,
//                                                  applicationActivities: nil)
//        activityVC.popoverPresentationController?.sourceView = self.view
//        self.present(activityVC, animated: true, completion: nil)
        
        
//        let serviceTypeFacebook = "Facebook"
//        if SLComposeViewController.isAvailable(forServiceType: serviceTypeFacebook) {
//            let fbShare:SLComposeViewController = SLComposeViewController(forServiceType: serviceTypeFacebook)
//            fbShare.setInitialText(keycode)
//            fbShare.add(qrCode)
//
//            self.present(fbShare, animated: true, completion: nil)
//        }
//        else {
//            self.showAlert(msg: "Please login to a Facebook account to share.", handler: nil)
//        }
        
        
        #if targetEnvironment(simulator)
        showAlert(title: "Error", msg: "Sharing an image will not work on a simulator. Please build to a device and try again.", handler: nil)
        return
        #endif

        let photo = SharePhoto(image: qrCode, userGenerated: true)
        
        let content = SharePhotoContent()
        content.photos = [photo]

        let dialog = ShareDialog(fromViewController: self, content: content, delegate: self)

        // Recommended to validate before trying to display the dialog
        do {
            try dialog.validate()
        }
        catch {
            showAlert(msg: error.localizedDescription, handler: nil)
        }

        dialog.show()
    }
    
    func showTwitterComposer(keyCode: String, qrCode: UIImage) {
        let vc = TWTRComposer()
        vc.setText(keyCode)
        vc.setImage(qrCode)
//        vc.setURL(URL(string: "https://dev.twitter.com"))
        vc.show(from: self) { (result) in
            print("Result = \(result.rawValue)")
        }
    }
    
    func deleteFenvyuAlbum(albumName: String, completion: ((Bool, Error?) -> Void)? = nil) {
        let options = PHFetchOptions()
        options.predicate = NSPredicate(format: "title = %@", albumName)
        let album = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumRegular, options: options)
//        let album = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: options)
        
        // check if album is available
        if album.firstObject != nil {
            // request to delete album
            PHPhotoLibrary.shared().performChanges({
                PHAssetCollectionChangeRequest.deleteAssetCollections(album)
            }, completionHandler: { (success, error) in
                if success {
                    print(" \(albumName) removed succesfully")
                    completion?(true, nil)
                } else if error != nil {
                    print("request failed. please try again")
                    completion?(true, nil)
                }
            })
        } else {
            print("requested album \(albumName) not found in photos")
            completion?(true, nil)
        }
    }
}


extension ShareKeycodeVC: SharingDelegate {

    func sharer(_ sharer: Sharing, didCompleteWithResults results: [String : Any]) {
        print(results)
        showAlert(title: "Share Success", msg: "Succesfully shared: \(results)", handler: nil)
    }

    func sharer(_ sharer: Sharing, didFailWithError error: Error) {
        showAlert(msg: error.localizedDescription, handler: nil)
    }

    func sharerDidCancel(_ sharer: Sharing) {
        showAlert(title: "Cancelled", msg: "Sharing cancelled", handler: nil)
    }
}

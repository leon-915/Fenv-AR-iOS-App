//
//  PhotoOptionsVC.swift
//  Fenvyu
//
//  Created by Admin on 5/10/20.
//  Copyright © 2020 admin. All rights reserved.
//

import UIKit
import SVProgressHUD

class PhotoOptionsVC: UIViewController {
    
    @IBOutlet weak var cameraRollButton: UIButton!
    @IBOutlet weak var googleDriveButton: UIButton!
    @IBOutlet weak var dropboxButton: UIButton!
    
    var customPicker: CustomPicker!
    var googleDrivePicker: GoogleDrivePicker!
    var dropboxPicker: DropboxPicker!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        initUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: true)
        (tabBarController as! FenvyuTabVC).showTabView(show: true)
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "ShowCustomPicker" {
            customPicker = segue.destination as? CustomPicker
            customPicker.delegate = self
            customPicker.isSelectingMarker = true
        }
        else if segue.identifier == "ShowGoogleDrivePicker" {
            let nvc = segue.destination as? UINavigationController
            googleDrivePicker = nvc?.topViewController as? GoogleDrivePicker
            googleDrivePicker.delegate = self
            googleDrivePicker.mediaOption = .MarkerImage
        }
        else if segue.identifier == "ShowDropboxPicker" {
            let nvc = segue.destination as? UINavigationController
            dropboxPicker = nvc?.topViewController as? DropboxPicker
            dropboxPicker.delegate = self
            dropboxPicker.mediaOption = .MarkerImage
        }
        else if segue.identifier == "ShowCreateProjectVC" {
            let imageInfo = sender as? ImageInfo
            let project = FenvyuProject()
            project.markerImageData = imageInfo?.imageData
            project.markerImageName = imageInfo?.imageName
            project.markerSize = project.markerImageData?.count
            
            let vc = segue.destination as? CreateProjectVC
            vc?.setCurrentProject(project: project)
        }
    }
    
    
    // MARK: - Main functions
    
    func initUI() {
        title = "Choose your marker"
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: nil, style: .plain, target: nil, action: nil)
        
        cameraRollButton.layer.borderWidth = 1
        cameraRollButton.layer.borderColor = UIColor.lightGray.cgColor
        cameraRollButton.layer.cornerRadius = 20
        
        googleDriveButton.layer.borderWidth = 1
        googleDriveButton.layer.borderColor = UIColor.lightGray.cgColor
        googleDriveButton.layer.cornerRadius = 20
        
        dropboxButton.layer.borderWidth = 1
        dropboxButton.layer.borderColor = UIColor.lightGray.cgColor
        dropboxButton.layer.cornerRadius = 20
        
    }

    @IBAction func tapCameraRollButton(_ sender: Any) {
        performSegue(withIdentifier: "ShowCustomPicker", sender: nil)
    }
    
    @IBAction func tapGoogleDriveButton(_ sender: Any) {
        self.performSegue(withIdentifier: "ShowGoogleDrivePicker", sender: nil)
    }
    
    @IBAction func tapDropboxButton(_ sender: Any) {
        self.performSegue(withIdentifier: "ShowDropboxPicker", sender: nil)
    }
    
    @IBAction func unwindToPhotoOptionsVC(_ unwindSegue: UIStoryboardSegue) {
        // Use data from the view controller which initiated the unwind segue
    }
}


extension PhotoOptionsVC: CustomPickerDelegate {
    func customPickerDidCancel(_ picker: CustomPicker) {
        picker.dismiss(animated: true, completion: nil)
        customPicker = nil
    }

    func customPicker(_ picker: CustomPicker, didSelectMarkerImage image: Image) {
        DispatchQueue.main.async {
            SVProgressHUD.show()
        }
        
//        AssetsManager.shared.getImageFromAsset(asset: image.asset) { (uiimage) in
//            SVProgressHUD.dismiss()
//
//            guard let markerImage = uiimage else {
//                return
//            }
//
//            picker.dismiss(animated: true) {
//                self.customPicker = nil
//
//                self.performSegue(withIdentifier: "ShowCreateProjectVC", sender: markerImage)
//            }
//        }
        
        picker.dismiss(animated: true) {
            self.customPicker = nil

            guard let markerImageInfo = AssetsManager.shared.getImageInfoFromAsset(asset: image.asset) else {
//            guard let markerImage = AssetsManager.shared.getImageFromAsset(asset: image.asset) else {
                SVProgressHUD.dismiss()
                return
            }

            SVProgressHUD.dismiss()
            
            self.performSegue(withIdentifier: "ShowCreateProjectVC", sender: markerImageInfo)
        }
    }

    func customPicker(_ picker: CustomPicker, didSelectImages images: [Image]) {
        picker.dismiss(animated: true, completion: nil)
        customPicker = nil
    }

    func customPicker(_ picker: CustomPicker, didSelectVideo video: Video) {
        picker.dismiss(animated: true, completion: nil)
        customPicker = nil
    }
    
}


extension PhotoOptionsVC: GoogleDrivePickerDelegate {
    func googleDrivePicker(_ picker: GoogleDrivePicker, didSelectImageInfos infos: [ImageInfo]) {
        picker.dismiss(animated: true) {
            self.googleDrivePicker = nil

            let markerImageInfo = infos[0]
            self.performSegue(withIdentifier: "ShowCreateProjectVC", sender: markerImageInfo)
        }
    }
    
    func googleDrivePicker(_ picker: GoogleDrivePicker, didSelectMedia mediaURL: URL) {
        picker.dismiss(animated: true, completion: nil)
        googleDrivePicker = nil
    }
    
    func googleDrivePickerDidCancel(_ picker: GoogleDrivePicker) {
        picker.dismiss(animated: true, completion: nil)
        googleDrivePicker = nil
    }
    
}


extension PhotoOptionsVC: DropboxPickerDelegate {
    func dropboxPicker(_ picker: DropboxPicker, didSelectImageInfos infos: [ImageInfo]) {
        picker.dismiss(animated: true) {
            self.dropboxPicker = nil

            let markerImageInfo = infos[0]
            self.performSegue(withIdentifier: "ShowCreateProjectVC", sender: markerImageInfo)
        }
    }
    
    func dropboxPicker(_ picker: DropboxPicker, didSelectMedia mediaURL: URL) {
        picker.dismiss(animated: true, completion: nil)
        googleDrivePicker = nil
    }
    
    func dropboxPickerDidCancel(_ picker: DropboxPicker) {
        picker.dismiss(animated: true, completion: nil)
        googleDrivePicker = nil
    }
    
}

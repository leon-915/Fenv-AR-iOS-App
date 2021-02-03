//
//  SaveProjectVC.swift
//  Fenvyu
//
//  Created by Admin on 5/15/20.
//  Copyright © 2020 admin. All rights reserved.
//

import UIKit

class SaveProjectVC: UIViewController {

    @IBOutlet weak var wrapper: UIView!
    @IBOutlet weak var projectNameField: UITextField!
    @IBOutlet weak var bottomWrapper: UIView!
    @IBOutlet weak var bottomBgView: UIView!
    
    @IBOutlet weak var publishWrapper: UIView!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var checkButton: UIButton!
    
    var project: FenvyuProject!
    var isProjectForPublish: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        initUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: true)
        navigationItem.setHidesBackButton(true, animated: true)
        
        (tabBarController as! FenvyuTabVC).showTabView(show: false)
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "ShowShareKeycodeVC" {
            let vc = segue.destination as? ShareKeycodeVC
            vc?.project = sender as? FenvyuProject
        }
    }
    
    
    func initUI() {
        wrapper.layer.cornerRadius = 15.0
        wrapper.layer.borderWidth = 0.5
        wrapper.layer.borderColor = UIColor.white.cgColor
        
        publishWrapper.layer.cornerRadius = 20.0
        publishWrapper.layer.borderWidth = 0.5
        publishWrapper.layer.borderColor = UIColor.white.cgColor
        
        bottomBgView.layer.cornerRadius = 20
        bottomBgView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        bottomBgView.shadow(color: UIColor.darkGray)
        
        projectNameField.text = project.projectName
        showPublishWrapper(show: isProjectForPublish)
    }
    
    @IBAction func tapCheckButton(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        
        if sender.isSelected {
            
        }
    }
    
    func checkFileSizeLimit() -> Bool {
        let markerSize = project.markerSize ?? project.markerImageData?.count ?? 0
        let payloadsSize = project.getPayloadsSize()
        let totalSize = markerSize + payloadsSize
        
        guard let price = AppManager.shared.prices.last else {
            return false
        }
        
        let limit = price.size * 1000 * 1000
        return totalSize <= limit
    }
    
    @IBAction func tapSaveButton(_ sender: Any) {
        if !checkFileSizeLimit() {
            showAlert(msg: "The files you selected are bigger than the server allows") { (action) in
                
            }
            return
        }
        
        guard let name = projectNameField.text, !name.isEmpty else {
            projectNameField.becomeFirstResponder()
            return
        }
        
        project.projectName = name
        
        AppManager.shared.saveProjectToLocal(project: project) { (saved, error) in
//        saveProject { (saved, error) in
            if saved {
                AppManager.shared.addNewProject(project: self.project)
                
                self.navigationController?.popToRootViewController(animated: true)
            }
            else {
                self.showAlert(msg: error ?? "Failed to save project") { (action) in
                    
                }
            }
        }
    }
    
    @IBAction func tapPublishButton(_ sender: Any) {
        if !checkFileSizeLimit() {
            showAlert(msg: "The files you selected are bigger than the server allows") { (action) in
                
            }
            return
        }
        
        guard let name = projectNameField.text, !name.isEmpty else {
            projectNameField.becomeFirstResponder()
            return
        }
        
        project.projectName = name
        
        showPublishWrapper(show: true)
    }
    
    @IBAction func tapOkPublishButton(_ sender: Any) {
        
        if isProjectForPublish && project.projectId != nil {
            // already saved project
            publishProject()
        }
        else {
            let projectLocalId = project.projectLocalId
            
            // new project
            saveProject { (saved, error) in
                if saved {
                    if projectLocalId != nil {
                        AppManager.shared.deleteProjectFromLocal(projectLocalId: projectLocalId!) { (deleted, error) in
                        }
                    }
                    
                    AppManager.shared.addNewProject(project: self.project)
                    
                    self.publishProject()
                }
                else {
                    self.showAlert(msg: error ?? "Failed to save project") { (action) in
                        
                    }
                }
            }
        }
    }
    
    @IBAction func tapBackButton(_ sender: Any) {
        if publishWrapper.alpha == 1 {
            navigationController?.popToRootViewController(animated: true)
        }
        else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func tapProfileButton(_ sender: Any) {
        let mainTabVC = tabBarController as! FenvyuTabVC
        mainTabVC.tapTabButton(mainTabVC.tabButtonProfile)
    }
    
    @IBAction func tapProjectListButton(_ sender: Any) {
        let mainTabVC = tabBarController as! FenvyuTabVC
        mainTabVC.tapTabButton(mainTabVC.tabButtonProjects)
    }
    
    @IBAction func tapHomeButton(_ sender: Any) {
        let mainTabVC = tabBarController as! FenvyuTabVC
        mainTabVC.tapTabButton(mainTabVC.tabButtonHome)
    }
    
    func showPublishWrapper(show: Bool) {
        view.window?.endEditing(true)
        
        let markerSize = project.markerSize ?? project.markerImageData?.count ?? 0
        let payloadsSize = project.getPayloadsSize()
        let totalSize = markerSize + payloadsSize
        
        let appManager = AppManager.shared
        let price = appManager.getPrice(with: totalSize)
        let formattedAmount = String(format: "%.2f", (price as NSString).doubleValue)
        
        let cardNumber = "xx \(String(appManager.authUser?.creditCardNumber?.suffix(4) ?? ""))"
        
        self.descLabel.text = String(format: "Project: %@\nMB: %@\n\nWill be published using:\nCredit Card: Visa %@\n\nAnd will be charged: $%@",
                                     project.projectName,
                                     totalSize.fileSizeString,
                                     cardNumber,
                                     formattedAmount)
//        "Project: \(project!.projectName) Will be published.\n\nCredit Card: Visa \(cardNumber)\nWill be charged: $\(formattedAmount)"
        
        UIView.animate(withDuration: 0.2, animations: {
            self.wrapper.alpha = show ? 0.0 : 1.0
            self.publishWrapper.alpha = show ? 1.0 : 0.0
        }) { (finished) in
            
        }
    }
    
    func getJSONStringOfActions(fenvyuActions: [FenvyuPayloadAction]) -> String {
        var actions = [[String: String]]()
        for fenvyuAction in fenvyuActions {
            if let title = fenvyuAction.title, let data = fenvyuAction.data {
                let action = [G.title: title, G.data: data, G.font: fenvyuAction.fontName]
                actions.append(action)
            }
        }
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: actions, options: []) else {
            return ""
        }

        let jsonString = String(data: jsonData, encoding: .utf8)  ?? ""
        print("JSON string = \(jsonString)")
        
        return jsonString
    }
    
    func saveProject(completion:@escaping (_ saved: Bool, _ error: String?) -> Void) {
        view.window?.endEditing(true)
        
        var path = "projects/create"
        let authToken = AppShared.getAuthToken()
        let jsonActions = getJSONStringOfActions(fenvyuActions: project.actions)
        
        var params = [
            G.name: project.projectName,
            G.videoDirection: "0",
            G.buttons: jsonActions
        ]
        
        // Edit project already saved
        if let projectId = project.projectId {
            path = "projects/edit/\(projectId)"
        }
        
        var files = [UploadFile]()
        
        guard let markerImageName = project.markerImageName, let markerImageData = project.markerImageData else {
            completion(false, nil)
            return
        }
        
        let markerImageFile = UploadFile(name: markerImageName, key: G.markerImage, data: markerImageData)
        files.append(markerImageFile)
        
        if project.payloadVideos.count > 0 {
            let payloadVideo = project.payloadVideos[0]
            if let videoUrl = payloadVideo.videoFileURL {
                let videoName = videoUrl.lastPathComponent
                let videoExtension = videoUrl.pathExtension
                let mimeType = "video/\(videoExtension)"

                let videoData = try! Data(contentsOf: videoUrl)
                let videoFile = UploadFile(name: videoName, key: G.payloadVideo, data: videoData, mimeType: mimeType)
                files.append(videoFile)
            }
            
            params[G.videoDirection] = "\(payloadVideo.videoRotateCount)"
        }
        else {
            for payloadImage in project.payloadImages {
                guard
                    let imageFileName = payloadImage.imageName,
                    let imageData = payloadImage.imageData else {
                    continue
                }
                
                let imageNameExtension = AppManager.documentDirectoryURL.appendingPathComponent(imageFileName).pathExtension
                let imageName = "\(payloadImage.rotateCount).\(imageNameExtension)"
                let imageFile = UploadFile(name: imageName, key: "payloadImages[]", data: imageData)
                files.append(imageFile)
            }
        }
        
        
        SVProgressHUD.show()
        AppWebClient.performMultipartRequest(path: path, authToken: authToken, params: params, files: files) { (json) in
            SVProgressHUD.dismiss()

            guard let json = json, let response = Mapper<FenvyuResModel>().map(JSONString: json.rawString()!) else {
                print("Response is not valid.")
                completion(false, nil)
                return
            }

            guard response.status?.lowercased() == G.success else {
                print(response.message ?? "")
                completion(false, response.message)
                return
            }
            
            guard let project = response.data?.project else {
                completion(false, nil)
                return
            }
            
            self.project = project

            completion(true, nil)
        }
    }
    
    func publishProject() {
        guard let projectId = project.projectId else {
            return
        }
        
        let isSingleUse = checkButton.isSelected ? 1 : 0
        
        SVProgressHUD.show()
        AppWebClient.PublishProject(projectId: projectId, isSingleUse: isSingleUse) { (json) in
            SVProgressHUD.dismiss()

            guard let json = json, let response = Mapper<FenvyuResModel>().map(JSONString: json.rawString()!) else {
                SVProgressHUD.showError(withStatus: "Response is not valid.")
                return
            }

            guard response.status?.lowercased() == G.success else {
                self.showAlert(msg: response.message, handler: nil)
                return
            }
            
            guard let project = response.data?.project else {
                self.showAlert(msg: "Failed to publish project", handler: nil)
                return
            }
            
            self.project = project
            
            DispatchQueue.main.async {
//                self.navigationController?.popToRootViewController(animated: true)
                self.performSegue(withIdentifier: "ShowShareKeycodeVC", sender: self.project)
            }
        }
    }
}

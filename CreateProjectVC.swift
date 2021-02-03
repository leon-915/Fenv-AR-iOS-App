//
//  CreateProjectVC.swift
//  Fenvyu
//
//  Created by Admin on 5/10/20.
//  Copyright © 2020 admin. All rights reserved.
//

import UIKit
import AVKit
import MobileCoreServices
import SVProgressHUD
import Photos

class CreateProjectVC: UIViewController {
    
    @IBOutlet weak var markerWrapper: UIView!
    @IBOutlet weak var markerWrapperWidth: NSLayoutConstraint!
    @IBOutlet weak var markerCropView: UIView!
    @IBOutlet weak var markerScrollView: UIScrollView!
    @IBOutlet weak var markerImageView: UIImageView!
    
    @IBOutlet weak var payloadWrapper: UIView!
    @IBOutlet weak var payloadCropView: UIView!
    @IBOutlet weak var payloadCollectionView: UICollectionView!
    @IBOutlet weak var payloadVideoView: UIView!
    @IBOutlet weak var payloadOpacitySlider: UISlider!
    @IBOutlet weak var payloadImagesPageControl: UIPageControl!
    
    @IBOutlet weak var sizeWrapper: UIView!
    @IBOutlet weak var sizeWrapperBottom: NSLayoutConstraint!
    @IBOutlet weak var sizeLabel: UILabel!
    
    @IBOutlet weak var imagesButton: UIButton!
    @IBOutlet weak var videoButton: UIButton!
    @IBOutlet weak var audioButton: UIButton!
    
    @IBOutlet weak var actionButtonsWrapper: UIView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var rotateButton: UIButton!
    @IBOutlet weak var actionsButton: UIButton!
    @IBOutlet weak var testButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    
    private var curProject = FenvyuProject()
    
//    var markerImage: UIImage?
//    var payloadImages = [FenvyuPayloadImage]()
//    var payloadActions = [FenvyuPayloadAction]()
    
//    var videoURL: URL?
//    var videoRotateCount = 0
    var videoPlayer: AVPlayer?
    let videoController = AVPlayerViewController()
    
    var imagePicker = UIImagePickerController()
    var customPicker: CustomPicker!
    var documentPicker: DocumentPicker!
    var googleDrivePicker: GoogleDrivePicker!
    var dropboxPicker: DropboxPicker!
    
    
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
        
//        AppManager.shared.clearAudioAssets()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
//        updateWrappers()
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "ShowCustomPicker" {
            customPicker = segue.destination as? CustomPicker
            customPicker.delegate = self
            customPicker.isSelectingMarker = false
        }
        else if segue.identifier == "ShowGoogleDrivePicker" {
            let nvc = segue.destination as? UINavigationController
            googleDrivePicker = nvc?.topViewController as? GoogleDrivePicker
            googleDrivePicker.delegate = self
            googleDrivePicker.mediaOption = sender as! MediaOption
        }
        else if segue.identifier == "ShowDropboxPicker" {
            let nvc = segue.destination as? UINavigationController
            dropboxPicker = nvc?.topViewController as? DropboxPicker
            dropboxPicker.delegate = self
            dropboxPicker.mediaOption = sender as! MediaOption
        }
        else if segue.identifier == "ShowActionsVC" {
            let vc = segue.destination as? ActionsVC
            vc?.reloadActions(with: curProject.actions)
        }
        else if segue.identifier == "ShowSaveProjectVC" {
            let vc = segue.destination as? SaveProjectVC
            vc?.project = sender as? FenvyuProject
            vc?.isProjectForPublish = false
        }
        else if segue.identifier == "ShowRunProjectVC" {
            let vc = segue.destination as? RunProjectVC
            vc?.isTestProject = true
        }
    }
    
    
    // MARK: - Main functions
    
    func setCurrentProject(project: FenvyuProject) {
        curProject = project.clone()
    }
    
    func getCurrentProject(withRotatedImage: Bool = false) -> FenvyuProject? {
        let project = curProject.clone()
        if withRotatedImage, !payloadCollectionView.isHidden {
            /*
            project.payloadImages = [FenvyuPayloadImage]()
            
            for curPayloadImage in curProject.payloadImages {
                guard let imageData = curPayloadImage.imageData, let image = UIImage(data: imageData) else {
                    continue
                }
                
                let payloadImage = curPayloadImage.clone()
                if curPayloadImage.rotateCount > 0 {
                    guard let rotatedImage = image.rotate(radians: CGFloat(Double.pi / 2) * CGFloat(curPayloadImage.rotateCount)) else {
                        continue
                    }
                    payloadImage.imageData = rotatedImage
                    payloadImage.rotateCount = 0
                }
                project.payloadImages.append(payloadImage)
            }
            */
            
            for payloadImage in project.payloadImages {
                if payloadImage.rotateCount > 0 {
                    _ = payloadImage.getRotatedImage()
                }
            }
        }
        return project
    }
    
    func setActinos(payloadActions: [FenvyuPayloadAction]) {
        curProject.actions = payloadActions
    }

    func initUI() {
        title = nil
        print("FRAME: \(view.frame)")
        
        actionButtonsWrapper.layer.cornerRadius = 20
        actionButtonsWrapper.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        actionButtonsWrapper.shadow(color: UIColor.darkGray)
        
        payloadOpacitySlider.setThumbImage(UIImage(named: "ic_slider"), for: .normal)
        
        payloadWrapper.alpha = 0
        payloadCollectionView.isHidden = true
        payloadVideoView.isHidden = true
        
        rotateButton.alpha = 0
        actionsButton.alpha = 0
        testButton.alpha = 0
        saveButton.alpha = 0
        
        
        if let markerImageData = curProject.markerImageData {
            self.markerImageView.image = UIImage(data: markerImageData)
        }

        showPayloadWrapper()
        
        showSizeWrapper(show: true)
    }
    
    func updateWrappers() {
        let frame = markerWrapper.frame
        markerWrapperWidth.constant = min(frame.width, frame.height)
        
        view.layoutIfNeeded()
    }
    
    @IBAction func tapBackButton(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func tapRotateButton(_ sender: Any) {
        if payloadCollectionView.isHidden {
            rotatePayloadVideo()
        }
        else {
            rotatePayloadImage()
        }
    }
    
    @IBAction func tapActionsButton(_ sender: Any) {
        performSegue(withIdentifier: "ShowActionsVC", sender: nil)
    }
    
    @IBAction func tapTestButton(_ sender: Any) {
        playCurrentProject()
    }
    
    @IBAction func tapSaveButton(_ sender: Any) {
        let project = getCurrentProject()
        
        performSegue(withIdentifier: "ShowSaveProjectVC", sender: project)
    }
    
    @IBAction func tapImagesButton(_ sender: Any) {
//        performSegue(withIdentifier: "ShowCustomPicker", sender: nil)
        showPayloadOptionsSheet(mediaOption: .PayloadImages)
    }
    
    @IBAction func tapVideoButton(_ sender: Any) {
//        openVideoGallery()
        showPayloadOptionsSheet(mediaOption: .PayloadVideo)
    }
    
    @IBAction func tapAudioButton(_ sender: Any) {
        showPayloadOptionsSheet(mediaOption: .PayloadAudio)
    }

    @IBAction func sliderChanged(_ sender: UISlider) {
        payloadCollectionView.alpha = CGFloat(sender.value)
        payloadVideoView.alpha = CGFloat(sender.value)
        
    }
    
    func showPayloadOptionsSheet(mediaOption: MediaOption) {
//        let optionsSheet = UIAlertController(title: nil, message: "Select Payload Image(s) from", preferredStyle: .actionSheet)
        var sheetTitle = ""
        switch mediaOption {
        case .PayloadVideo:
            sheetTitle = "Select Payload Video from"
        case .PayloadAudio:
            sheetTitle = "Select Payload MP3 from"
        default:
            sheetTitle = "Select Payload Image(s) from"
        }
        let optionsSheet = UIAlertController(title: nil, message: sheetTitle, preferredStyle: .actionSheet)
        optionsSheet.view.tintColor = UIColor.black
        
        let subview = (optionsSheet.view.subviews.first?.subviews.first?.subviews.first!)! as UIView
        subview.backgroundColor = UIColor.white //UIColor(red: (145/255.0), green: (200/255.0), blue: (0/255.0), alpha: 1.0)
        
        if mediaOption == .PayloadAudio {
            optionsSheet.addAction(UIAlertAction(title: "Documents", style: .default, handler: { (actuib) in
                self.showDocumentPicker()
            }))
        }
        else {
            optionsSheet.addAction(UIAlertAction(title: "Camera Roll", style: .default, handler: { (actuib) in
                if mediaOption == .PayloadImages {
                    self.performSegue(withIdentifier: "ShowCustomPicker", sender: nil)
                }
                else {
                    self.openVideoGallery()
                }
            }))
        }
        optionsSheet.addAction(UIAlertAction(title: "Google Drive", style: .default, handler: { (actuib) in
            self.performSegue(withIdentifier: "ShowGoogleDrivePicker", sender: mediaOption)
        }))
        optionsSheet.addAction(UIAlertAction(title: "Dropbox", style: .default, handler: { (actuib) in
            self.performSegue(withIdentifier: "ShowDropboxPicker", sender: mediaOption)
        }))
        optionsSheet.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (actuib) in
            
        }))

        present(optionsSheet, animated: true, completion: nil)
    }
    
    func showVideoPicker() {
        let alertController = UIAlertController(title: "Choose Video", message: nil, preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: .default) {
            UIAlertAction in
            self.openCamera()
        }
        let gallaryAction = UIAlertAction(title: "Gallary", style: .default) {
            UIAlertAction in
            self.openVideoGallery()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) {
            UIAlertAction in
        }
        
        // Add the actions
        alertController.addAction(cameraAction)
        alertController.addAction(gallaryAction)
        alertController.addAction(cancelAction)
        alertController.popoverPresentationController?.sourceView = self.view
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func openCamera() {
        if (UIImagePickerController .isSourceTypeAvailable(.camera)) {
            imagePicker.delegate = self
            imagePicker.sourceType = .camera
            imagePicker.allowsEditing = true
            imagePicker.modalPresentationStyle = .fullScreen
            self.present(imagePicker, animated: true, completion: nil)
        }
        else {
            let alert = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) {
                UIAlertAction in
            }
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func openVideoGallery() {
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.mediaTypes = [kUTTypeMovie as String]
        imagePicker.modalPresentationStyle = .fullScreen
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func showDocumentPicker() {
        documentPicker = DocumentPicker(presentationController: self, delegate: self)
        documentPicker.present(from: view)
    }
    
    func didSelectAssets(assets: [Image]) {
        var infos = [ImageInfo]()
        for index in 0 ..< assets.count {
            let asset = assets[index]
            
            guard let imageInfo = AssetsManager.shared.getImageInfoFromAsset(asset: asset.asset) else {
//            guard let image: UIImage = AssetsManager.shared.getImageFromAsset(asset: asset.asset) else {
                continue
            }
            
            infos.append(imageInfo)
        }
        
        didSelectImageInfos(infos: infos)
    }
    
    func didSelectImageInfos(infos: [ImageInfo]) {
        curProject.payloadImages = [FenvyuPayloadImage]()
        curProject.payloadVideos = [FenvyuPayloadVideo]()
        for index in 0 ..< infos.count {
            let payloadImage = FenvyuPayloadImage()
            let imageInfo = infos[index]
            payloadImage.imageData = imageInfo.imageData
//            payloadImage.imageName = "image_\(index).png"
            payloadImage.imageName = imageInfo.imageName
            payloadImage.fileSize = imageInfo.imageData?.count
            
            curProject.payloadImages.append(payloadImage)
        }
        
        // hide progress hud
        SVProgressHUD.dismiss()
        
        // Show Payload wrapper
        showPayloadWrapper(payloadOverlay: .Images)
    }
    
    func didSelectVideo(videoURL: URL?) {
        guard let videoURL = videoURL else {
            return
        }

        let payloadVideo = FenvyuPayloadVideo()
        payloadVideo.videoFileURL = videoURL
        payloadVideo.videoRotateCount = 0
        payloadVideo.fileSize = Int(videoURL.fileSize)
        payloadVideo.mediaOption = AppShared.isMediaFile(for: .PayloadAudio, name: videoURL.lastPathComponent) ? .PayloadAudio : .PayloadVideo
        
        curProject.payloadImages = [FenvyuPayloadImage]()
        curProject.payloadVideos = [FenvyuPayloadVideo]()
        curProject.payloadVideos.append(payloadVideo)
        
        // Show Payload wrapper
        showPayloadWrapper(payloadOverlay: .Video)
    }
    
    func showPayloadWrapper(payloadOverlay: PayloadOverlay = .None) {
        
        payloadWrapper.alpha = 0
        payloadCollectionView.isHidden = true
        payloadVideoView.isHidden = true
        videoPlayer?.pause()
        
        rotateButton.alpha = 0
        actionsButton.alpha = 0
        testButton.alpha = 0
        saveButton.alpha = 0
        
        if payloadOverlay == .Images {
            showImagePayload()
        }
        else if payloadOverlay == .Video {
            showVideoPayload()
        }
        else {
            if curProject.payloadImages.count > 0 {
                showImagePayload()
            }
            else if curProject.payloadVideos.count > 0 {
                showVideoPayload()
            }
        }
        
        showSizeWrapper(show: true)
    }
    
    func showImagePayload() {
        payloadWrapper.alpha = 1
        payloadCollectionView.isHidden = false
        payloadVideoView.isHidden = true
        
        payloadOpacitySlider.value = 0.5
        payloadCollectionView.alpha = CGFloat(payloadOpacitySlider.value)
        
        payloadImagesPageControl.alpha = 1
        payloadImagesPageControl.numberOfPages = curProject.payloadImages.count
        
        rotateButton.alpha = 1
        actionsButton.alpha = 1
        testButton.alpha = 1
        saveButton.alpha = 1

        payloadCollectionView.reloadData()
        payloadCollectionView.contentOffset = CGPoint.zero
    }
    
    func showVideoPayload() {
        let payloadVideo = curProject.payloadVideos[0]
        guard let videoURL = payloadVideo.videoFileURL else {
            return
        }
        
        _ = AppShared.getVideoOrientation(url: videoURL)
        
        payloadWrapper.alpha = 1
        payloadCollectionView.isHidden = true
        payloadVideoView.isHidden = false
        
        payloadOpacitySlider.value = 0.5
        payloadVideoView.alpha = CGFloat(payloadOpacitySlider.value)
        
        payloadImagesPageControl.alpha = 0
        
        rotateButton.alpha = 1
        actionsButton.alpha = 1
        testButton.alpha = 1
        saveButton.alpha = 1
        
        let videoPlayerItem = AVPlayerItem(url: videoURL)
        videoPlayer = AVPlayer(playerItem: videoPlayerItem)
//        videoPlayer = AVPlayer(url: videoURL)
        videoController.player = videoPlayer
        videoController.videoGravity = AVLayerVideoGravity.resize
        videoController.updatesNowPlayingInfoCenter = false
        
        payloadVideoView.addSubview(videoController.view)
        videoController.view.g_pinCenter()
        videoController.view.g_pin(size: payloadVideoView.bounds.size)
        
//        payloadVideo.videoRotateCount = 0
        videoController.view.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi/2) * CGFloat(payloadVideo.videoRotateCount))
        fitPayloadVideoViewSize()
        
        videoPlayer!.play()
    }
    
    func fitPayloadVideoViewSize() {
        guard let markerImageData = curProject.markerImageData, let marker = UIImage(data: markerImageData) else {
            return
        }
        
//        let width = self.markerImageView.frame.width
        let width = view.frame.width
        var markerSize = marker.size

        let payloadVideo = curProject.payloadVideos[0]
        if payloadVideo.videoRotateCount % 2 == 1 {
            markerSize = CGSize(width: markerSize.height, height: markerSize.width)
        }
        
        var size = CGSize.zero
        if (markerSize.width > markerSize.height) {
            size.width = width
            size.height = width * markerSize.height / markerSize.width
        }
        else {
            size.width = width * markerSize.width / markerSize.height
            size.height = width
        }
        videoController.view.g_pin(size: size)
        view.layoutIfNeeded()
    }
    
    func getCurrentItem() -> Int? {
        let pageWidth: CGFloat = payloadCollectionView.frame.size.width
        let fractionalPage: CGFloat = payloadCollectionView.contentOffset.x / pageWidth
        let item = lround(Double(fractionalPage))
        
        return item
    }
    
    func getPayloadImageCell(item: Int) -> PayloadImageCell? {
        let indexPath = IndexPath(item: item, section: 0)
        let cell = payloadCollectionView.cellForItem(at: indexPath) as? PayloadImageCell
        
        return cell
    }
    
    func rotatePayloadImage() {
        if payloadCollectionView.isHidden {
            return
        }
        
        guard let item = self.getCurrentItem() else {
            return
        }
        
        guard let cell = getPayloadImageCell(item: item) else {
            return
        }

        let payloadImage = curProject.payloadImages[item]
        payloadImage.rotateCount = (payloadImage.rotateCount + 1) % 4
        print("Index = \(item) : RotateCount = \(payloadImage.rotateCount)")
        
        UIView.animate(withDuration: 0.2, animations: {
            cell.imageView.transform = cell.imageView.transform.rotated(by: CGFloat(Double.pi/2))
            cell.fitImageViewSize(to: self.curProject.markerImageData, rotateCount: payloadImage.rotateCount)
        }) { (finished) in
        }
    }
    
    func rotatePayloadVideo() {
        if payloadVideoView.isHidden {
            return
        }
        
        let payloadVideo = curProject.payloadVideos[0]
        payloadVideo.videoRotateCount = (payloadVideo.videoRotateCount + 1) % 4
        UIView.animate(withDuration: 0.2, animations: {
            self.videoController.view.transform = self.videoController.view.transform.rotated(by: CGFloat(Double.pi/2))
            self.fitPayloadVideoViewSize()
        }) { (finished) in
            print("payloadVideoView = \(self.payloadVideoView.frame)", self.videoController.view.frame)
        }
    }
    
    func saveRotateCount() -> Int {
        guard let item = self.getCurrentItem() else {
            return 0
        }
        
        let payloadImage = curProject.payloadImages[item]
        payloadImage.rotateCount = (payloadImage.rotateCount + 1) % 4
//        print("Index = \(item) : RotateCount = \(image.rotateCount)")
        
        return payloadImage.rotateCount
    }
    
    func playCurrentProject() {
        guard curProject.markerImageData != nil else {
            return
        }
        
        guard let project = getCurrentProject(withRotatedImage: true) else {
            return
        }
        
        var projects = [FenvyuProject]()
        projects.append(project)
        
        AppManager.shared.targetProjects = projects
        
        if videoPlayer != nil {
            videoPlayer?.pause()
        }
        
        self.performSegue(withIdentifier: "ShowRunProjectVC", sender: nil)
    }
    
    @IBAction func unwindToCreateProjectVC(_ unwindSegue: UIStoryboardSegue) {
        // Use data from the view controller which initiated the unwind segue
        
//        let sourceViewController = unwindSegue.source
    }
    
    func showSizeWrapper(show: Bool) {
        sizeWrapper.alpha = 0
        
        if show {
            let markerSize = curProject.markerSize ?? curProject.markerImageData?.count ?? 0
            let payloadsSize = curProject.getPayloadsSize()
            
            sizeLabel.text = String(format: "Marker size: %@\nPayloads size: %@",
                                    markerSize.fileSizeString, payloadsSize.fileSizeString)
            
            let viewHeight = view.frame.height
            if viewHeight > 800 {
//                let tup = payloadImagesPageControl.frame.maxY
//                let bottom = actionButtonsWrapper.frame.minY
                
                sizeWrapperBottom.constant = actionButtonsWrapper.frame.height + 10
            }
            else {
                let bottom = payloadCropView.frame.maxY
                sizeWrapperBottom.constant = viewHeight - bottom
            }
        }
        else {
            sizeWrapperBottom.constant = 0
        }
        
        UIView.animate(withDuration: 0.1, animations: {
            self.view.layoutIfNeeded()
        }) { (finished) in
            self.sizeWrapper.alpha = show ? 1 : 0
        }
    }
}


// MARK: - UIScrollViewDelegate
extension CreateProjectVC: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView != payloadCollectionView {
            return
        }
        
        let pageWidth: CGFloat = scrollView.frame.size.width
        let fractionalPage: CGFloat = scrollView.contentOffset.x / pageWidth
        let page = lround(Double(fractionalPage))
        
        payloadImagesPageControl.currentPage = page
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return nil
        
        if scrollView == markerScrollView {
            return markerImageView
        }
        else if scrollView == payloadCollectionView {
            return nil
        }
        
        let indexPath = IndexPath(item: scrollView.tag, section: 0)
        guard let cell = payloadCollectionView.cellForItem(at: indexPath) as? PayloadImageCell else {
            return nil
        }
        
        return cell.imageView
    }
}


// MARK: - UIImagePickerControllerDelegate
extension CreateProjectVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//        picker.dismiss(animated: true, completion: nil)
//
//        let videoURL = info[UIImagePickerController.InfoKey.mediaURL] as? URL
//        didSelectVideo(videoURL: videoURL)
        
        guard let videoAsset = info[UIImagePickerController.InfoKey.phAsset] as? PHAsset else {
            return
        }
    
        AssetsManager.shared.getVideoURLFromAsset(videoAsset: videoAsset) { (videoURL) in
            guard let videoURL = videoURL else {
                return
            }
            
            let videoData = try! Data(contentsOf: videoURL)
            print("\n=====> Selected Video Name = \(videoAsset.originalFilename ?? "") : \(videoData.fileSizeString) (\(videoData.count))\nvideoURL = \(videoURL)")
            
            DispatchQueue.main.async {
                picker.dismiss(animated: true, completion: nil)
                
                self.didSelectVideo(videoURL: videoURL)
            }
        }
    }
}


// MARK: - CustomPickerDelegate
extension CreateProjectVC: CustomPickerDelegate {
    func customPickerDidCancel(_ picker: CustomPicker) {
        picker.dismiss(animated: true, completion: nil)
        customPicker = nil
    }

    func customPicker(_ picker: CustomPicker, didSelectMarkerImage image: Image) {
        picker.dismiss(animated: true, completion: nil)
        customPicker = nil
    }

    func customPicker(_ picker: CustomPicker, didSelectImages images: [Image]) {
        DispatchQueue.main.async {
            SVProgressHUD.show()
        }
        
        picker.dismiss(animated: true) {
            self.customPicker = nil
            self.didSelectAssets(assets: images)
        }
    }

    func customPicker(_ picker: CustomPicker, didSelectVideo video: Video) {
        picker.dismiss(animated: true, completion: nil)
        customPicker = nil
    }
}


// MARK: - DocumentDelegate
extension CreateProjectVC: DocumentDelegate {
    func didPickDocuments(documents: [Document]?) {
        guard let documents = documents, !documents.isEmpty else {
            return
        }
        
        let document = documents[0]
        let mediaURL = document.fileURL
        
        self.documentPicker = nil
        self.didSelectVideo(videoURL: mediaURL)
    }
}


// MARK: - GoogleDrivePickerDelegate
extension CreateProjectVC: GoogleDrivePickerDelegate {
    func googleDrivePicker(_ picker: GoogleDrivePicker, didSelectImageInfos infos: [ImageInfo]) {
        picker.dismiss(animated: true) {
            self.googleDrivePicker = nil
            self.didSelectImageInfos(infos: infos)
        }
    }
    
    func googleDrivePicker(_ picker: GoogleDrivePicker, didSelectMedia mediaURL: URL) {
        picker.dismiss(animated: true) {
            self.googleDrivePicker = nil
            self.didSelectVideo(videoURL: mediaURL)
        }
    }
    
    func googleDrivePickerDidCancel(_ picker: GoogleDrivePicker) {
        picker.dismiss(animated: true, completion: nil)
        googleDrivePicker = nil
    }
}


// MARK: - DropboxPickerDelegate
extension CreateProjectVC: DropboxPickerDelegate {
    func dropboxPicker(_ picker: DropboxPicker, didSelectImageInfos infos: [ImageInfo]) {
        picker.dismiss(animated: true) {
            self.dropboxPicker = nil
            self.didSelectImageInfos(infos: infos)
        }
    }
    
    func dropboxPicker(_ picker: DropboxPicker, didSelectMedia mediaURL: URL) {
        picker.dismiss(animated: true) {
            self.dropboxPicker = nil
            self.didSelectVideo(videoURL: mediaURL)
        }
    }
    
    func dropboxPickerDidCancel(_ picker: DropboxPicker) {
        picker.dismiss(animated: true, completion: nil)
        googleDrivePicker = nil
    }
}


extension CreateProjectVC: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    // MARK: - UICollectionViewDataSource
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return curProject.payloadImages.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PayloadImageCell", for: indexPath) as! PayloadImageCell
        
        let payloadImage = curProject.payloadImages[(indexPath as NSIndexPath).item]
        if let imageData = payloadImage.imageData {
            cell.imageView.image = UIImage(data: imageData)
        }
        cell.scrollView.tag = indexPath.item
        
        cell.fitImageViewSize(to: curProject.markerImageData, rotateCount: payloadImage.rotateCount)
        cell.imageView.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi/2) * CGFloat(payloadImage.rotateCount))
//        print("Item = \(indexPath.item) : rotate = \(payloadImage.rotateCount) : width = \(cell.imageViewWidth.constant) : height = \(cell.imageViewHeight.constant)")
        
        return cell
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let image = curProject.payloadImages[(indexPath as NSIndexPath).item]
        print(image)
    }
}

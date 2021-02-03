//
//  RunProjectVC.swift
//  Fenvyu
//
//  Created by Admin on 5/12/20.
//  Copyright © 2020 admin. All rights reserved.
//

import UIKit
import MobileCoreServices
import ARKit
import AVFoundation


class RunProjectVC: UIViewController {
    
    @IBOutlet weak var trackingLabel: UILabel!
    @IBOutlet weak var exitButton: UIButton!
    
    @IBOutlet weak var fenvyuSceneView: ARSCNView!
    
    var fenvyuConfiguration = ARImageTrackingConfiguration()
    var fenvyuSession = ARSession()
    
    var fenvyuVideoNodes = [FenvyuNode]()
    var fenvyuAudioNodes = [FenvyuNode]()
    var fenvyuNodeforTest: FenvyuNode?
    
    var isTestProject: Bool = false
    
    /// An array of `AudioAsset` objects representing the m4a files used for playback in this sample.
    var audioAssets = [AudioAsset]()
    
    /// The instance of `AssetPlaybackManager` that the app uses for managing playback.
    let assetPlaybackManager = AssetPlaybackManager()
    
    /// The instance of `RemoteCommandManager` that the app uses for managing remote command events.
    var remoteCommandManager: RemoteCommandManager!
    
    var deviceOrientation: UIDeviceOrientation! = .portrait
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        exitButton.setTitle(isTestProject ? "Exit Test Mode" : "Exit", for: .normal)
        
        // Add device orientation notification
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        NotificationCenter.default.addObserver(self, selector: #selector(deviceDidRotate(notification:)), name: UIDevice.orientationDidChangeNotification, object: nil)
        
        audioAssets = [AudioAsset]()
        
        setupRemoteCommandManager()
        addRemoteCommandObserver()
        
        startARSession()
        
        runProject()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        fenvyuSceneView.session.pause()
        
        UIDevice.current.endGeneratingDeviceOrientationNotifications()
    }
    
    deinit {
        removeRemoteCommandObserver()
    }
    

    /*
    // MARK: - Navigation -

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    // MARK: - RemoteCommand Manager and Observers -
    
    @objc func deviceDidRotate(notification: NSNotification) {
        self.deviceOrientation = UIDevice.current.orientation
        
    }
    
    func setupRemoteCommandManager() {
        // Initializer the `RemoteCommandManager`.
        remoteCommandManager = RemoteCommandManager(assetPlaybackManager: assetPlaybackManager)
        
        // Always enable playback commands in MPRemoteCommandCenter.
        remoteCommandManager.activatePlaybackCommands(true)
//        remoteCommandManager.toggleNextTrackCommand(true)
//        remoteCommandManager.togglePreviousTrackCommand(true)
    }
    
    func addRemoteCommandObserver() {
        // Add the notification observers needed to respond to events from the `AssetPlaybackManager`.
        let notificationCenter = NotificationCenter.default
        
        notificationCenter.addObserver(self, selector: #selector(RunProjectVC.handleRemoteCommandNextTrackNotification(notification:)), name: AssetPlaybackManager.nextTrackNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(RunProjectVC.handleRemoteCommandPreviousTrackNotification(notification:)), name: AssetPlaybackManager.previousTrackNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(RunProjectVC.handleRemoteCommandPlayNotification(notification:)), name: AssetPlaybackManager.playNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(RunProjectVC.handleRemoteCommandPauseNotification(notification:)), name: AssetPlaybackManager.pauseNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(RunProjectVC.handleRemoteCommandDidPlayToEndTimeNotification(notification:)), name: AssetPlaybackManager.didPlayToEndTimeNotification, object: nil)
    }
    
    func removeRemoteCommandObserver() {
        // Remove all notification observers.
        let notificationCenter = NotificationCenter.default
        
        notificationCenter.removeObserver(self, name: AssetPlaybackManager.nextTrackNotification, object: nil)
        notificationCenter.removeObserver(self, name: AssetPlaybackManager.previousTrackNotification, object: nil)
        notificationCenter.removeObserver(self, name: AssetPlaybackManager.playNotification, object: nil)
        notificationCenter.removeObserver(self, name: AssetPlaybackManager.pauseNotification, object: nil)
        notificationCenter.removeObserver(self, name: AssetPlaybackManager.didPlayToEndTimeNotification, object: nil)
    }
    
    
    // MARK: - Notification Handler Methods -
    
    @objc func handleRemoteCommandNextTrackNotification(notification: Notification) {
        guard let assetName = notification.userInfo?[AudioAsset.nameKey] as? String else { return }
        guard let assetIndex = audioAssets.firstIndex(where: {$0.assetName == assetName}) else { return }
        
        print("RemoteCommand NextTrack")
        if assetIndex < audioAssets.count - 1 {
//            assetPlaybackManager.player = AVPlayer()
            assetPlaybackManager.audioAsset = audioAssets[assetIndex + 1]
        }
    }
    
    @objc func handleRemoteCommandPreviousTrackNotification(notification: Notification) {
        guard let assetName = notification.userInfo?[AudioAsset.nameKey] as? String else { return }
        guard let assetIndex = audioAssets.firstIndex(where: {$0.assetName == assetName}) else { return }
        
        print("RemoteCommand PreviousTrack")
        if assetIndex > 0 {
//            assetPlaybackManager.player = AVPlayer()
            assetPlaybackManager.audioAsset = audioAssets[assetIndex - 1]
        }
    }
    
    @objc func handleRemoteCommandPlayNotification(notification: Notification) {
        guard let assetName = notification.userInfo?[AudioAsset.nameKey] as? String else { return }
        guard let assetIndex = audioAssets.firstIndex(where: {$0.assetName == assetName}) else { return }
        
        print("RemoteCommand Play")
        if assetIndex < audioAssets.count {
            assetPlaybackManager.player.play()
            
            DispatchQueue.main.async {
                self.handleAudioNodes(toBePlaying: true)
            }
        }
    }
    
    @objc func handleRemoteCommandPauseNotification(notification: Notification) {
        guard let assetName = notification.userInfo?[AudioAsset.nameKey] as? String else { return }
        guard let assetIndex = audioAssets.firstIndex(where: {$0.assetName == assetName}) else { return }
        
        print("RemoteCommand Pause")
        if assetIndex < audioAssets.count {
            assetPlaybackManager.player.pause()
            
            DispatchQueue.main.async {
                self.handleAudioNodes(toBePlaying: false)
            }
        }
    }
    
    @objc func handleRemoteCommandDidPlayToEndTimeNotification(notification: Notification) {
        guard let assetName = notification.userInfo?[AudioAsset.nameKey] as? String else { return }
        guard let assetIndex = audioAssets.firstIndex(where: {$0.assetName == assetName}) else { return }
        
        print("RemoteCommand DidPlayToEndTime")
        if assetIndex < audioAssets.count {
            assetPlaybackManager.player.seek(to: CMTime.zero)
            
            DispatchQueue.main.async {
                self.handleAudioNodes(toBePlaying: false)
            }
        }
    }
    
    
    // MARK: - Audio Assets Methods -
    
    func clearAudioAssets() {
        assetPlaybackManager.stop()
        audioAssets.removeAll()
    }
    
    func addAudioAsset(with fileURL: URL) {
        var asset = audioAssets.first(where: {$0.urlAsset.url.absoluteString == fileURL.absoluteString})
        if asset == nil {
            let fileName = fileURL.lastPathComponent
            asset = AudioAsset(assetName: fileName, urlAsset: AVURLAsset(url: fileURL))
            
            audioAssets.append(asset!)
        }
        
        assetPlaybackManager.audioAsset = asset
    }
    
    
    // MARK: - UI methods -
    
    @IBAction func tapExitButton(_ sender: Any) {
        stopVideoNodes()
        clearAudioAssets()
        
        dismiss(animated: true, completion: nil)
    }
    
    
    // MARK:- ARSession -
    
    func startARSession() {
        fenvyuSceneView.session = fenvyuSession
        fenvyuSceneView.delegate = self
        fenvyuSceneView.session.delegate = self
        
        //Add recognizer to sceneview
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(gesture:)))
        fenvyuSceneView.addGestureRecognizer(tapGesture)

        //Add recognizer to sceneview
//        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(gesture:)))
//        fenvyuSceneView.addGestureRecognizer(panGesture)
        
        let swipeLeftGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(gesture:)))
        swipeLeftGesture.direction = .left
        fenvyuSceneView.addGestureRecognizer(swipeLeftGesture)
        
        let swipeRightGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(gesture:)))
        swipeRightGesture.direction = .right
        fenvyuSceneView.addGestureRecognizer(swipeRightGesture)
        
        let swipeUpGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(gesture:)))
        swipeUpGesture.direction = .up
        fenvyuSceneView.addGestureRecognizer(swipeUpGesture)
        
        let swipeDownGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(gesture:)))
        swipeDownGesture.direction = .down
        fenvyuSceneView.addGestureRecognizer(swipeDownGesture)
        
        tapGesture.require(toFail: swipeLeftGesture)
        tapGesture.require(toFail: swipeRightGesture)
        tapGesture.require(toFail: swipeUpGesture)
        tapGesture.require(toFail: swipeDownGesture)
    }
    
    //Method called when Tap
    @objc func handleTap(gesture: UITapGestureRecognizer) {
        if gesture.state == .ended {
            let location: CGPoint = gesture.location(in: fenvyuSceneView)
            let hits = fenvyuSceneView.hitTest(location, options: nil)
            if !hits.isEmpty {
                guard let node = hits.first?.node else {
                    print("=====> Cannot get node")
                    return
                }
                
                guard let parentNode = node.parent as? FenvyuNode else {
                    print("=====> Parent is not a FenvyuNode")
                    return
                }
                
                // Check video player or video control or audio overlay node has been tapped
                if node == parentNode.videoPlayerNode || node == parentNode.videoControlNode || node == parentNode.audioOverlayNode {
                    print("=====> Media Node has been tapped")
                    guard let videoControl = parentNode.videoControlNode else {
                        return
                    }
                    
                    if let videoPlayer = parentNode.payloadVideoPlayer {
                        if videoPlayer.timeControlStatus == .playing {
                            videoControl.removeAllActions()
                            
                            if videoControl.isHidden {
                                videoControl.isHidden = false
                                parentNode.hideVideoControlsInSeconds(seconds: 3.0)
                                return
                            }
                            
                            videoPlayer.pause()
                            videoControl.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "btn_movie_play")
                            print("=====> Video was paused")
                        }
                        else {
                            videoPlayer.play()
                            videoControl.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "btn_movie_pause")
                            print("=====> Video is playing now.")
                            
                            parentNode.hideVideoControlsInSeconds(seconds: 3.0)
                        }
                    }
                    else {
                        if self.assetPlaybackManager.player.timeControlStatus == .playing {
                            videoControl.removeAllActions()
                            
                            if videoControl.isHidden {
                                videoControl.isHidden = false
                                parentNode.hideVideoControlsInSeconds(seconds: 3.0)
                                return
                            }
                            
                            self.assetPlaybackManager.pause()
                            videoControl.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "btn_movie_play")
                            print("=====> Audio was paused")
                        }
                        else {
                            self.assetPlaybackManager.play()
                            videoControl.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "btn_movie_pause")
                            print("=====> Audio is playing now.")
                            
                            parentNode.hideVideoControlsInSeconds(seconds: 3.0)
                        }
                    }
                    
                    return
                }
                
                guard let actionPlane = node.geometry else {
                    print("=====> Cannot get plane of action node")
                    return
                }

                guard let actionTitle = node.value(forUndefinedKey: "ActionTitle") as? String else {
                    print("=====> Invalid action title")
                    return
                }

                guard let actionData = actionPlane.value(forUndefinedKey: "ActionData") as? String else {
                    print("=====> Invalid action data")
                    return
                }
                
                print("Action : \(actionTitle) - \(actionData)")
                let actionExpand = SCNAction.scale(by: 1.2, duration: 0.1)
                node.runAction(actionExpand) {
                    node.runAction(SCNAction.scale(by: 1/1.2, duration: 0.1)) {
                        DispatchQueue.main.async {
                            self.runAction(actionData: actionData)
                        }
                    }
                }
            }
        }
    }
    
    // Method called when Pan
    @objc func handlePan(gesture: UISwipeGestureRecognizer) {
        print("=====> Pan gesture")
    }
    
    // Method called when Swipe
    @objc func handleSwipe(gesture: UISwipeGestureRecognizer) {
        if gesture.state == .ended {
            let location: CGPoint = gesture.location(in: fenvyuSceneView)
            let hits = fenvyuSceneView.hitTest(location, options: nil)
            if !hits.isEmpty {
                guard let node = hits.first?.node else {
                    print("=====> Cannot get Node")
                    return
                }
                
                guard let nodeGeometry = node.geometry else {
                    print("=====> Cannot get geometry of Node")
                    return
                }
                
                guard let contents = nodeGeometry.firstMaterial?.diffuse.contents else {
                    print("=====> Cannot get contents from geometry of Node")
                    return
                }
                
                if contents is AVPlayer {
                    print("=====> Video Node cannot be swiped")
                    return
                }
                
                guard let parentNode = node.parent as? FenvyuNode else {
                    print("=====> Parent is not a FenvyuNode")
                    return
                }
                
                guard let project = parentNode.project else {
                    return
                }

                if project.payloadImages.count > 1 {
                    guard var nodeIndex = node.value(forUndefinedKey: "NodeIndex") as? Int else {
                        print("=====> Invalid payload image")
                        return
                    }

//                    let deviceOrientation = UIDevice.current.orientation
                    guard let offset = getOffsetNodeIndex(deviceOrientation: self.deviceOrientation, swipeDirection: gesture.direction) else {
                        return
                    }
                    nodeIndex = (nodeIndex + project.payloadImages.count + offset) % project.payloadImages.count
                    
//                    if gesture.direction == .left {
//                        nodeIndex = (nodeIndex + 1) % project.payloadImages.count
//                    }
//                    else if gesture.direction == .right {
//                        nodeIndex = (nodeIndex + project.payloadImages.count - 1) % project.payloadImages.count
//                    }

                    let newPayloadImage = project.payloadImages[nodeIndex]
                    node.setValue(nodeIndex, forKey: "NodeIndex")
                    node.geometry?.firstMaterial?.diffuse.contents = newPayloadImage.getRotatedImage()

                }
            }
        }
    }
    
    func getOffsetNodeIndex(deviceOrientation: UIDeviceOrientation, swipeDirection: UISwipeGestureRecognizer.Direction) -> Int? {
        var offset: Int?

        switch (deviceOrientation, swipeDirection) {
        case (.portrait, .left):
            offset = 1
        case (.portraitUpsideDown, .right):
            offset = 1
        case (.landscapeLeft, .up):
            offset = 1
        case (.landscapeRight, .down):
            offset = 1
        case (.portrait, .right):
            offset = -1
        case (.portraitUpsideDown, .left):
            offset = -1
        case (.landscapeLeft, .down):
            offset = -1
        case (.landscapeRight, .up):
            offset = -1
        default:
            break
        }
        
        return offset
    }
    
    func runProject() {
        guard let projects = AppManager.shared.targetProjects else {
            return
        }
        
        // init video nodes
        fenvyuVideoNodes = [FenvyuNode]()
        fenvyuAudioNodes = [FenvyuNode]()
        
        let physicalWidth: CGFloat = 0.1
        
        var referenceImages = Set<ARReferenceImage>()
        for index in 0 ..< projects.count {
            let project = projects[index]
            
            guard let markerImageData = project.markerImageData, let markerImage = UIImage(data: markerImageData) else {
                DispatchQueue.main.async {
                    self.trackingLabel.showText("Failed to get Marker Image.", andHideAfter: 3)
                }
                continue
            }

            guard let cgImage = markerImage.cgImage else {
                DispatchQueue.main.async {
                    self.trackingLabel.showText("Failed to get CGImage.", andHideAfter: 3)
                }
                continue
            }
            
            let referenceImage = ARReferenceImage(cgImage, orientation: .up, physicalWidth: physicalWidth)
            referenceImage.name = "\(index)"
            
            referenceImages.insert(referenceImage)
        }
        
        fenvyuConfiguration.maximumNumberOfTrackedImages = AppManager.shared.maxCountOfTrackedImages
        fenvyuConfiguration.trackingImages = referenceImages
        fenvyuSession.run(fenvyuConfiguration, options: [.resetTracking, .removeExistingAnchors])
        
        DispatchQueue.main.async {
            self.trackingLabel.showText("Images Generated Sucesfully", andHideAfter: 3)
        }
    }
    
    func runAction(actionData: String) {
        var urlString = ""
        if (actionData.firstIndex(of: ".") != nil) {
            if actionData.hasPrefix("http") {
                urlString = actionData
            }
            else {
                urlString = "http://\(actionData)"
            }
        }
        else {
            if actionData.hasPrefix("tel") {
                urlString = actionData
            }
            else {
                urlString = "tel://\(actionData)"
            }
        }
        
        guard let url = URL(string: urlString) else {
            return
        }
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:]) { (complete) in
                
            }
        }
        else {
            self.showAlert(msg: "Invalid action url")
        }
    }
    
    func getVideoNode(projectId: Int) -> FenvyuNode? {
        for videoNode in fenvyuVideoNodes {
            if videoNode.project?.projectId == projectId {
                return videoNode
            }
        }
        return nil
    }
    
    func stopVideoNodes() {
        if isTestProject {
            if let node = fenvyuNodeforTest, let videoPlayer = node.payloadVideoPlayer {
                videoPlayer.pause()
                node.payloadVideoPlayer = nil
            }
        }
        else {
            for fenvyuNode in fenvyuVideoNodes {
                if let videoPlayer = fenvyuNode.payloadVideoPlayer {
                    videoPlayer.pause()
                    fenvyuNode.payloadVideoPlayer = nil
                    print("Paused Video player of node")
                }
            }
        }
    }
    
    func handleAudioNodes(toBePlaying: Bool) {
        if isTestProject {
            guard let audioNode = fenvyuNodeforTest,
                  let project = audioNode.project,
                  !project.payloadVideos.isEmpty else { return }
            
            let payloadVideo = project.payloadVideos[0]
            if payloadVideo.mediaOption == .PayloadAudio {
                updateAudioNode(audioNode: audioNode, toBePlaying: toBePlaying)
            }
        }
        else {
            for audioNode in fenvyuAudioNodes {
                if let project = audioNode.project, !project.payloadVideos.isEmpty {
                    let payloadVideo = project.payloadVideos[0]
                    if payloadVideo.mediaOption == .PayloadAudio {
                        if payloadVideo.videoFileURL?.absoluteString == assetPlaybackManager.audioAsset.urlAsset.url.absoluteString {
                            updateAudioNode(audioNode: audioNode, toBePlaying: toBePlaying)
                        }
                        else {
                            updateAudioNode(audioNode: audioNode, toBePlaying: false)
                        }
                    }
                }
            }
        }
    }
    
    func updateAudioNode(audioNode: FenvyuNode, toBePlaying: Bool) {
        print("##### updateAudioNode to be \(toBePlaying ? "playing" : "paused")")
        guard let videoControl = audioNode.videoControlNode else {
            return
        }
        
        if toBePlaying {
            videoControl.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "btn_movie_pause")
            videoControl.isHidden = false
            
            audioNode.hideVideoControlsInSeconds(seconds: 3.0)
        }
        else {
            videoControl.removeAllActions()
            
            videoControl.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "btn_movie_play")
            videoControl.isHidden = false
        }
    }
}


// MARK:- ARSCNViewDelegate -

extension RunProjectVC: ARSCNViewDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let imageAnchor = anchor as? ARImageAnchor, let imageName = imageAnchor.name?.capitalized else {
            return
        }
        
        trackingLabel.showText("\(imageName) Detected", andHideAfter: 5)
        
        let referenceImage: ARReferenceImage = imageAnchor.referenceImage
        guard let strIndex = referenceImage.name else {
            return
        }
        
        let index = Int(strIndex)!
        guard let projects = AppManager.shared.targetProjects, index < projects.count else {
            return
        }
        
        print("AR node index = \(index)")
        
        let project = projects[index]
        let fenvyuNode = FenvyuNode(withReferenceImage: referenceImage, project: project, vc: self)
        node.addChildNode(fenvyuNode)
        
        
        print("Current video node count = \(fenvyuVideoNodes.count) : audio node count = \(fenvyuAudioNodes.count)")
        if project.payloadVideos.count > 0 {
            if isTestProject {
                fenvyuNodeforTest = fenvyuNode
                
                print("Set new node for test project")
            }
            else {
                if let projectId = project.projectId {
                    let payloadVideo = project.payloadVideos[0]
                    if payloadVideo.mediaOption == .PayloadVideo {
                        guard fenvyuVideoNodes.firstIndex(where: {$0.project?.projectId == projectId}) == nil else { return }
                        
                        fenvyuVideoNodes.append(fenvyuNode)
                        print("Added new video node")
                    }
                    else if payloadVideo.mediaOption == .PayloadAudio {
                        guard fenvyuAudioNodes.firstIndex(where: {$0.project?.projectId == projectId}) == nil else { return }
                        
                        fenvyuAudioNodes.append(fenvyuNode)
                        print("Added new audio node")
                    }
                }
            }
        }
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
//        print("didUpdate node")
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRenderScene scene: SCNScene, atTime time: TimeInterval) {
//        print("didRenderScene node")
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        print("didRemove node")
    }
}


// MARK:- ARSessionDelegate -

extension RunProjectVC: ARSessionDelegate {
    
    // MARK: - ARSessionDelegate -
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        print("SessionDelegate cameraDidChangeTrackingState")
        
        switch camera.trackingState {
        case .notAvailable, .limited:
            print("notAvailable")
        case .normal:
            print("normal")
        }
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        print("SessionDelegate didFailWithError")
        guard error is ARError else { return }
        
        let errorWithInfo = error as NSError
        let messages = [
            errorWithInfo.localizedDescription,
            errorWithInfo.localizedFailureReason,
            errorWithInfo.localizedRecoverySuggestion
        ]
        
        // Use `flatMap(_:)` to remove optional error messages.
        let errorMessage = messages.compactMap({ $0 }).joined(separator: "\n")
        
        trackingLabel.showText("The AR session failed." + errorMessage, andHideAfter: 3)
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        print("SessionDelegate sessionWasInterrupted")
        print("""
        SESSION INTERRUPTED
        The session will be reset after the interruption has ended.
        """)
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        print("SessionDelegate sessionInterruptionEnded")
        trackingLabel.showText("RESETTING SESSION", andHideAfter: 3)
        
        restartExperience()
    }
    
    func sessionShouldAttemptRelocalization(_ session: ARSession) -> Bool {
        return true
    }
    
    // MARK: - Interface Actions -
    
    func restartExperience() {
        print("restartExperience")
    }
    
}

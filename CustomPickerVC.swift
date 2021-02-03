//
//  CustomPickerVC.swift
//  Fenvyu
//
//  Created by Admin on 5/8/20.
//  Copyright © 2020 admin. All rights reserved.
//

import UIKit
import AVFoundation


let cellSpacing: CGFloat = 2
//public var imageLimit: Int = 4
public var imageLimit: Int = 0

public protocol CustomPickerDelegate: class {
    func customPicker(_ picker: CustomPicker, didSelectMarkerImage image: Image)
    func customPicker(_ picker: CustomPicker, didSelectImages images: [Image])
    func customPicker(_ picker: CustomPicker, didSelectVideo video: Video)
    func customPickerDidCancel(_ picker: CustomPicker)
}


public class CustomPicker: UIViewController {
    
    @IBOutlet weak var bottomBgView: UIView!
    @IBOutlet weak var titleItem: UINavigationItem!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var chooseButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    public weak var delegate: CustomPickerDelegate?
    
    var isSelectingMarker = true
    
    var items: [Image] = []
    let assetsManager = AssetsManager.shared
    var selectedAlbum: Album?
    let once = Once()
    let cart = Cart()
    
    
    public override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        cart.delegates.add(self)
        
        setup()
        
        self.check()
    }
    
    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        if UIDevice.current.orientation.isLandscape {
            print("Landscape")
            self.collectionView.reloadData()
        }
        else {
            print("Portrait")
            self.collectionView.reloadData()
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - Setup

    func setup() {
        view.backgroundColor = UIColor.white
        
        bottomBgView.layer.cornerRadius = 20
        bottomBgView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        bottomBgView.shadow(color: UIColor.darkGray)
        
        self.doneButton.alpha = self.isSelectingMarker ? 1.0 : 0.0
        self.chooseButton.alpha = self.isSelectingMarker ? 0.0 : 1.0
    }

    func check() {
        if Permission.Photos.status == .notDetermined {
            Permission.Photos.request { [weak self] in
                self?.check()
            }
            return
        }

        /*
        if Permission.Camera.status == .notDetermined {
            Permission.Camera.request { [weak self] in
                self?.check()
            }

            return
        }
        */

        DispatchQueue.main.async {
            self.loadPhotos()
        }
    }

    // MARK: - Action

    @IBAction func tapCloseButton(_ sender: UIBarButtonItem) {
        delegate?.customPickerDidCancel(self)
    }
    
    @IBAction func tapDoneButton(_ sender: UIButton) {
        guard !cart.images.isEmpty else {
            return
        }
        
        let image = cart.images[0]
        delegate?.customPicker(self, didSelectMarkerImage: image)
    }
    
    @IBAction func tapChooseButton(_ sender: UIButton) {
        guard !cart.images.isEmpty else {
            return
        }
        
        let images = cart.images
        delegate?.customPicker(self, didSelectImages: images)
    }


    // MARK: - Logic

    func show(album: Album) {
        items = album.items
        collectionView.reloadData()
        collectionView.setContentOffset(CGPoint.zero, animated: false)
    }

    func refreshSelectedAlbum() {
        if let selectedAlbum = selectedAlbum {
            selectedAlbum.reload()
            show(album: selectedAlbum)
        }
    }

    // MARK: - View
    
    func loadPhotos() {
        once.run {
            assetsManager.reloadPhotos {
                if let album = self.assetsManager.albums.first {
                    self.selectedAlbum = album
                    self.show(album: album)
                }
            }
        }
    }
}


extension CustomPicker: CartDelegate {
    public func cart(_ cart: Cart, didAdd image: Image, newlyTaken: Bool) {
        if newlyTaken {
            refreshSelectedAlbum()
        }
    }
    
    public func cart(_ cart: Cart, didRemove image: Image) {
//        refreshView()
    }

    public func cartDidReload(_ cart: Cart) {
        refreshSelectedAlbum()
    }
}


extension CustomPicker: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    // MARK: - UICollectionViewDataSource
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! ImageCell
        let item = items[(indexPath as NSIndexPath).item]
        
        cell.setup()
        cell.configure(item)
        configureFrameView(cell, indexPath: indexPath)
        
        return cell
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let isLandscape = UIDevice.current.orientation.isLandscape
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        let columnCount: CGFloat = isLandscape ? (screenHeight > 375 ? 7 : 5) : (screenWidth > 375 ? 4 : 3)
        
        let size = (collectionView.bounds.size.width - (columnCount - 1) * cellSpacing) / columnCount
        return CGSize(width: size, height: size)
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = items[(indexPath as NSIndexPath).item]
        
        if cart.images.contains(item) {
            cart.remove(item)
        }
        else {
            if isSelectingMarker {
                cart.reset()
                cart.add(item)
            }
            else {
                if imageLimit == 0 || imageLimit > cart.images.count {
                    cart.add(item)
                }
            }
        }
        
        configureFrameViews()
    }
    
    func configureFrameViews() {
        for case let cell as ImageCell in collectionView.visibleCells {
            if let indexPath = collectionView.indexPath(for: cell) {
                configureFrameView(cell, indexPath: indexPath)
            }
        }
    }
    
    func configureFrameView(_ cell: ImageCell, indexPath: IndexPath) {
        let item = items[(indexPath as NSIndexPath).item]
        
        if let index = cart.images.firstIndex(of: item) {
            cell.wrapper.layer.borderWidth = 3.0
            
            cell.frameView.g_quickFade()
            if !isSelectingMarker {
                cell.label.alpha = 1
                cell.label.text = "\(index + 1)"
            }
        }
        else {
            cell.wrapper.layer.borderWidth = 0
            cell.frameView.alpha = 0
            cell.label.alpha = 0
        }
    }
}

//
//  HomeVC.swift
//  Fenvyu
//
//  Created by Admin on 5/10/20.
//  Copyright © 2020 admin. All rights reserved.
//

import UIKit

class HomeVC: UIViewController {
    
    @IBOutlet weak var helpButton: UIButton!
    @IBOutlet weak var createButton: UIButton!
    @IBOutlet weak var experienceButton: UIButton!
    
    var tipView: EasyTipView?
    
    
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !AppShared.isSkipTutorial() {
//            showTutorial()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        tipView?.dismiss()
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "ShowRunProjectVC" {
            let vc = segue.destination as? RunProjectVC
            vc?.isTestProject = false
        }
        else if segue.identifier == "ShowAddKeycodeVC" {
            let vc = segue.destination as! AddKeycodeVC
            vc.delegate = self
            vc.isFromHomeExperience = true
        }
    }
    
    
    // MARK: - Main functions
    
    func initUI() {
        navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
        
        title = "Home"
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 22.0),
                                                                   NSAttributedString.Key.foregroundColor: UIColor.white]
        
        helpButton.layer.cornerRadius = 20.0
        helpButton.layer.borderWidth = 2.0
        helpButton.layer.borderColor = UIColor.white.cgColor
        
        createButton.layer.borderWidth = 1
        createButton.layer.borderColor = UIColor.lightGray.cgColor
        createButton.layer.cornerRadius = 20
        
        experienceButton.layer.borderWidth = 1
        experienceButton.layer.borderColor = UIColor.lightGray.cgColor
        experienceButton.layer.cornerRadius = 20
    }
    
    @IBAction func tapHelpButton(_ sender: UIButton) {
        if let url = URL(string: G.HelpLink) {
            UIApplication.shared.open(url)
        }
    }
    
    @IBAction func tapCreateButton(_ sender: Any) {
        if tipView != nil {
            tipView?.dismiss(withCompletion: {
                self.performSegue(withIdentifier: "ShowPhotoOptionsVC", sender: nil)
            })
        }
        else {
            performSegue(withIdentifier: "ShowPhotoOptionsVC", sender: nil)
        }
    }
    
    @IBAction func tapExperienceButton(_ sender: Any) {
//        let appManager = AppManager.shared
//        appManager.targetProjects = appManager.getAvailableProjects()
//
//        self.performSegue(withIdentifier: "ShowRunProjectVC", sender: nil)
        
        self.performSegue(withIdentifier: "ShowAddKeycodeVC", sender: nil)
    }
    
    func showRunProjectVC() {
        let appManager = AppManager.shared
        appManager.targetProjects = appManager.getAvailableProjects()

        performSegue(withIdentifier: "ShowRunProjectVC", sender: nil)
    }
    
    func showTutorial() {
        let text = "To create your own project, please tap the \"Create\" button."
        
        var preferences = EasyTipView.globalPreferences
        preferences.drawing.shadowColor = UIColor.white
        preferences.drawing.shadowRadius = 2
        preferences.drawing.shadowOpacity = 0.75
        
        let tip = EasyTipView(text: text, preferences: preferences, delegate: self)
        tip.show(forView: createButton)
        tipView = tip
    }
}


extension HomeVC: EasyTipViewDelegate {
    func easyTipViewDidTap(_ tipView: EasyTipView) {
        
    }
    
    func easyTipViewDidDismiss(_ tipView: EasyTipView) {
        print("\(tipView) did dismiss!")
    }
}


extension HomeVC: AddKeycodeVCDelegate {
    func addKeycodeVC(_ vc: AddKeycodeVC, didAddNewkeycodes keycodes: [FenvyuKeycode]) {
        let appManager = AppManager.shared
        for keycode in keycodes {
            appManager.addNewKeycode(newKeycode: keycode)
            appManager.updateAvailableKeycodeIds(keycodeId: keycode.keycodeId!, available: keycode.isAvailable)
        }
        appManager.targetProjects = appManager.getAvailableProjects()
        
        self.dismiss(animated: true) {
            self.performSegue(withIdentifier: "ShowRunProjectVC", sender: nil)
        }
    }
    
    func addKeycodeVCDidCancel(_ vc: AddKeycodeVC) {
        self.dismiss(animated: true) {
            
        }
    }
    
    func addKeycodeVCDidSkip(_ vc: AddKeycodeVC) {
        self.dismiss(animated: true) {
            self.showRunProjectVC()
        }
    }
}

//
//  ActivateKeycodeVC.swift
//  Fenvyu
//
//  Created by Admin on 5/17/20.
//  Copyright © 2020 admin. All rights reserved.
//

import UIKit

class ActivateKeycodeVC: UIViewController {
    
    @IBOutlet weak var wrapper: UIView!
    @IBOutlet weak var keycodeField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        initUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: true)
        (tabBarController as! FenvyuTabVC).showTabView(show: true)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    func initUI() {
        wrapper.layer.cornerRadius = 15.0
        wrapper.layer.borderWidth = 0.5
        wrapper.layer.borderColor = UIColor.white.cgColor
        
        // test code
        keycodeField.text = "Dj4fb69sbtrik6fk5skr"
        // test
    }

    @IBAction func tapActivateButton(_ sender: Any) {
        guard let keycode = keycodeField.text else {
            keycodeField.becomeFirstResponder()
            return
        }
        
        loadProjectWithKeycode(keycode: keycode)
    }
    
    func loadProjectWithKeycode(keycode: String) {
        
        navigationController?.popToRootViewController(animated: true)
        
        let mainTabVC = (tabBarController as! FenvyuTabVC)
        mainTabVC.tapTabButton(mainTabVC.tabButtonKeycodes)
    }
}

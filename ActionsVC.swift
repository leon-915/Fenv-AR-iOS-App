//
//  ActionsVC.swift
//  Fenvyu
//
//  Created by Admin on 5/14/20.
//  Copyright © 2020 admin. All rights reserved.
//

import UIKit

class ActionsVC: UIViewController {
    
    @IBOutlet weak var actionsTableView: UITableView!
    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var addActionButton: UIButton!
    @IBOutlet weak var bottomBgView: UIView!
    
    var actions = [FenvyuPayloadAction]()
    var fontNames = ["Arial", "Georgia", "Helvetica", "Symbol", "Times New Roman"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        initUI()
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        if (segue.identifier == "UnwindToCreateProjectVC") {
            let vc = segue.destination as! CreateProjectVC
            vc.setActinos(payloadActions: actions)
        }
    }
    
    
    // MARK: - Main functions
    
    func initUI() {
        title = "Actions"
        
        bottomBgView.layer.cornerRadius = 20
        bottomBgView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        bottomBgView.shadow(color: UIColor.darkGray)
        
        if actions.isEmpty {
            let newAction = FenvyuPayloadAction()
            actions.append(newAction)
        }
        updateFooterViewStatus()
    }
    
    func reloadActions(with payloadActions: [FenvyuPayloadAction]) {
        for index in 0 ..< payloadActions.count {
            let action = payloadActions[index]
            
            let newAction = FenvyuPayloadAction()
            newAction.actionId = action.actionId
            newAction.title = action.title
            newAction.data = action.data
            newAction.fontName = action.fontName
            
            actions.append(newAction)
        }
    }
    
    @IBAction func tapFontButton(_ sender: UIButton) {
        let action = actions[sender.tag]
        
        let fontSheet = UIAlertController(title: nil, message: "Select font", preferredStyle: .actionSheet)
        fontSheet.view.tintColor = UIColor.black
        
        let subview = (fontSheet.view.subviews.first?.subviews.first?.subviews.first!)! as UIView
        subview.backgroundColor = UIColor.white //UIColor(red: (145/255.0), green: (200/255.0), blue: (0/255.0), alpha: 1.0)
        
        for fontName in fontNames {
            fontSheet.addAction(UIAlertAction(title: fontName, style: .default, handler: { (actuib) in
                action.fontName = fontName

                let cell = self.actionsTableView.cellForRow(at: IndexPath(row: sender.tag, section: 0)) as! ActionCell
                let font = UIFont(name: fontName, size: 17.0)
                cell.titleField.font = font
            }))
        }
        fontSheet.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (actuib) in
        }))

        present(fontSheet, animated: true, completion: nil)
    }
    
    @IBAction func tapAddActionButton(_ sender: Any) {
        guard actions.count < 4 else {
            return
        }
        
        let newAction = FenvyuPayloadAction()
        actions.append(newAction)
        
        updateFooterViewStatus()
        
        actionsTableView.beginUpdates()
        actionsTableView.reloadSections(IndexSet(integer: 0), with: .automatic)
        actionsTableView.endUpdates()
    }
    
    @IBAction func tapBackButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func tapSaveButton(_ sender: Any) {
        // test code
        for action in actions {
            print("\(action.data!.count)")
        }
        // test
        performSegue(withIdentifier: "UnwindToCreateProjectVC", sender: nil)
    }
    
    func updateFooterViewStatus() {
        footerView.frame = actions.count > 3 ?
            CGRect(x: 0, y: 0, width: actionsTableView.frame.width, height: 10) :
            CGRect(x: 0, y: 0, width: actionsTableView.frame.width, height: 60)
        addActionButton.alpha = actions.count > 3 ? 0 : 1
    }
}


extension ActionsVC: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return actions.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ActionCell", for: indexPath) as! ActionCell

        // Configure the cell...
        
        let action = actions[indexPath.row]
        cell.buttonLabel.text = "Action \(indexPath.row + 1)"
        
        cell.titleField.text = action.title
        cell.titleField.tag = indexPath.row * 10 + 1
        cell.dataField.text = action.data
        cell.dataField.tag = indexPath.row * 10 + 2
        cell.fontButton.tag = indexPath.row
        
        let fontName = action.fontName
        cell.titleField.font = UIFont(name: fontName, size: 17.0)
        
        return cell
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            // handle delete (by removing the data from your array and updating the tableview)
            
//            tableView.beginUpdates()
//            actions.remove(at: indexPath.row)
//            tableView.deleteRows(at: [indexPath], with: .automatic)
//            updateFooterViewStatus()
//            tableView.endUpdates()
            
            actions.remove(at: indexPath.row)
            updateFooterViewStatus()
            
            if actions.count > 0 {
                tableView.beginUpdates()
                tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
                tableView.endUpdates()
            }
            else {
                tableView.reloadData()
            }
            
        }
    }
}


extension ActionsVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}


extension ActionsVC: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let index = textField.tag / 10
        let action = actions[index]
        
        if let text = textField.text, let textRange = Range(range, in: text) {
            let updatedText = text.replacingCharacters(in: textRange, with: string)
            if textField.tag % 10 == 1 {
                action.title = updatedText
            }
            else {
                action.data = updatedText
            }
        }
        
        return true
    }
}

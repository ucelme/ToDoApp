import UIKit
import RealmSwift

class AddToDoListController: UITableViewController, UITextFieldDelegate {

    @IBOutlet weak var listNameLabel: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        listNameLabel.delegate = self
        listNameLabel.becomeFirstResponder()
    }

    @IBAction func saveButtonClicked(_ sender: UIButton) {
        let item = ToDoList()
        item.title = listNameLabel.text!
        
        try! realm.write {
            realm.add(item)
        }
        
        dismiss(animated: true, completion: nil)
        NotificationCenter.default.post(name: Notification.Name("added"), object: nil)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let oldText = listNameLabel.text!
        let stringRange = Range(range, in:oldText)!
        let newText = oldText.replacingCharacters(in: stringRange, with: string)
        saveButton.isEnabled = !newText.isEmpty
        return true
    }

}
    


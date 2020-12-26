import UIKit
import RealmSwift
import UserNotifications

class AddListController: UITableViewController, UITextFieldDelegate {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    let notificationCenter = UNUserNotificationCenter.current()
    
    var list: List<ToDoListItems>!
    var editItem: ToDoListItems?

    var datePickerVisible = false
    var remindDate = Date()

    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var listName: UITextField!
    @IBOutlet var dateCell: UITableViewCell!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var switchRemind: UISwitch!
    @IBOutlet weak var timeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        listName.delegate = self
        listName.becomeFirstResponder()
        
        updatedateLabel()
        
        if let editItem = editItem {
            
            title = "\(editItem.title)"
        
            listName.text = editItem.title
            datePicker.date = editItem.remindDate
            switchRemind.isOn = editItem.remind
            remindDate = editItem.remindDate

            appDelegate.removeNotification(id: editItem.id)
    
            saveButton.isEnabled = true
        } else {
            listName.becomeFirstResponder()
        }

    }
    
    @IBAction func remindToggle(_ sender: UISwitch) {
        if switchRemind.isOn {
          let center = UNUserNotificationCenter.current()
          center.requestAuthorization(options: [.alert, .sound]) {
            granted, error in
            
          }
        }
    }
    
    @IBAction func datePickerDate(_ sender: UIDatePicker) {
        remindDate = datePicker.date
        updatedateLabel()
    }
    
    func updatedateLabel() {
      let formatter = DateFormatter()
      formatter.dateStyle = .medium
      formatter.timeStyle = .short
      formatter.locale = Locale(identifier: "en_UK")
      timeLabel.text = formatter.string(from: remindDate)
    }
    
    func showDatePicker() {
      datePickerVisible = true
      
      let indexPathDateRow = IndexPath(row: 1, section: 1)
      let indexPathDatePicker = IndexPath(row: 2, section: 1)
      
      if let dateCell = tableView.cellForRow(at: indexPathDateRow) {
        dateCell.detailTextLabel!.textColor = dateCell.detailTextLabel!.tintColor
      }
      
      tableView.beginUpdates()
      tableView.insertRows(at: [indexPathDatePicker], with: .fade)
      tableView.reloadRows(at: [indexPathDateRow], with: .none)
      tableView.endUpdates()
      
      datePicker.setDate(remindDate, animated: false)
    }
    
    func hideDatePicker() {
      if datePickerVisible {
        datePickerVisible = false
        
        let indexPathDateRow = IndexPath(row: 1, section: 1)
        let indexPathDatePicker = IndexPath(row: 2, section: 1)
        
        if let cell = tableView.cellForRow(at: indexPathDateRow) {
          cell.detailTextLabel!.textColor = UIColor.black
        }
        tableView.beginUpdates()
        tableView.reloadRows(at: [indexPathDateRow], with: .none)
        tableView.deleteRows(at: [indexPathDatePicker], with: .fade)
        tableView.endUpdates()
      }
    }
    
    @IBAction func saveButtonClicked(_ sender: UIButton) {
        
        if let editItem = editItem {
            try! realm.write {
                editItem.title = listName.text!
                editItem.remind = switchRemind.isOn
                editItem.id = UUID().uuidString
                editItem.remindDate = remindDate
            }
            
            if editItem.remind && editItem.remindDate > Date() {
                requestAutorization()
                appDelegate.scheduleNotification(name: editItem.title, id: editItem.id, date: editItem.remindDate)
            }

        } else {
            let item = ToDoListItems()
            item.title = listName.text!
            item.remind = switchRemind.isOn
            item.remindDate = remindDate
            item.id = UUID().uuidString

            try! realm.write {
                list.append(item)
            }
            
            if item.remind && item.remindDate > Date() {
                requestAutorization()
                appDelegate.scheduleNotification(name: item.title, id: item.id, date: item.remindDate)
            }
        }
        
        dismiss(animated: true, completion: nil)
        NotificationCenter.default.post(name: Notification.Name("added"), object: nil)
    }
    
    func requestAutorization() {
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
            print("Permission granted: \(granted)")
            
            guard granted else { return }
            self.getNotificationSettings()
        }
    }

    func getNotificationSettings() {
        notificationCenter.getNotificationSettings { (settings) in
            print("Notification settings: \(settings)")
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      if section == 1 && datePickerVisible {
        return 3
      } else {
        return super.tableView(tableView, numberOfRowsInSection: section)
      }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
      if indexPath.section == 1 && indexPath.row == 2 {
        return 217
      } else {
        return super.tableView(tableView, heightForRowAt: indexPath)
      }
    }
    
    override func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int {
      var newIndexPath = indexPath
      if indexPath.section == 1 && indexPath.row == 2 {
        newIndexPath = IndexPath(row: 0, section: indexPath.section)
      }
      return super.tableView(tableView, indentationLevelForRowAt: newIndexPath)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 1 && indexPath.row == 2 {
          return dateCell
        } else {
          return super.tableView(tableView, cellForRowAt: indexPath)
        }
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
      if indexPath.section == 1 && indexPath.row == 1 {
        return indexPath
      } else {
        return nil
      }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      tableView.deselectRow(at: indexPath, animated: true)
        listName.resignFirstResponder()
      if indexPath.section == 1 && indexPath.row == 1 {
        if !datePickerVisible {
          showDatePicker()
        } else {
          hideDatePicker()
        }
      }
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let oldText = listName.text!
        let stringRange = Range(range, in:oldText)!
        let newText = oldText.replacingCharacters(in: stringRange, with: string)
        saveButton.isEnabled = !newText.isEmpty
        return true
    }



}

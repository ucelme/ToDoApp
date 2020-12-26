import UIKit
import RealmSwift

class ToDoListController: UITableViewController {
    
    var toDoList: Results<ToDoList>!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        toDoList = realm.objects(ToDoList.self)

        NotificationCenter.default.addObserver(self, selector: #selector(added), name: Notification.Name("added"), object: nil)
    }
    
    @objc func added() {
        tableView.reloadData()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return toDoList?.count ?? 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListCell", for: indexPath)
        
        let list = toDoList[indexPath.row]
    
        cell.textLabel?.text = list.title
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
            let list = toDoList[indexPath.row]
                
            try! realm.write {
            realm.delete(list)
            }

            let indexPaths = [indexPath]
            tableView.deleteRows(at: indexPaths, with: .automatic)
    }
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        let list = toDoList[indexPath.row]

        let alert = UIAlertController(title: "Edit Item", message: nil, preferredStyle: .alert)
        alert.addTextField { (textfield) in
            textfield.text = list.title
        }

           let submit = UIAlertAction(title: "Save", style: .default) { [unowned alert] _ in
            let newItem = alert.textFields![0]
            if newItem.text != "" {
                
                try! realm.write {
                    list.title = newItem.text!
                }
                self.tableView.reloadData()
            }
           }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        alert.addAction(cancel)
        alert.addAction(submit)

        present(alert, animated: true)

        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }


    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "ShowList" {
    let controller = segue.destination as! ListController
    if let indexPath = tableView.indexPath(for: sender as! UITableViewCell) {
        controller.list = toDoList[indexPath.row].item
        controller.toDo = toDoList[indexPath.row]
        }
    }
 }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "AddList" {
            if toDoList.count > 3 && !UserDefaults.standard.bool(forKey: "Premium") {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let controller = storyboard.instantiateViewController(withIdentifier: "Premium")
                self.present(controller, animated: true, completion: nil)
                return false
            }
        }

        return true
    }

    
}

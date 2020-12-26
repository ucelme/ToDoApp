import UIKit
import RealmSwift

class ListController: UITableViewController {
    
    var list: List<ToDoListItems>!
    var toDo: ToDoList!

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(added), name: Notification.Name("added"), object: nil)

        title = toDo.title
        
        tableView.separatorInset = .zero
    }
    
    @objc func added() {
        tableView.reloadData()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListCell", for: indexPath)

        let item = list[indexPath.row]
        
        cell.textLabel?.text = item.title
        
        if item.checked {
            cell.imageView?.image = UIImage(systemName: "circle.fill")?.withRenderingMode(.alwaysTemplate)
            cell.imageView?.tintColor = .black
      } else {
        cell.imageView?.image = UIImage(systemName: "circle")?.withRenderingMode(.alwaysTemplate)
        cell.imageView?.tintColor = .black
      }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
            let item = list[indexPath.row]
                
            try! realm.write {
            realm.delete(item)
            }

            let indexPaths = [indexPath]
            tableView.deleteRows(at: indexPaths, with: .automatic)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let item = list[indexPath.row]

        try! realm.write {
            item.checked.toggle()
        }
        
        if let cell = tableView.cellForRow(at: indexPath) {

            if item.checked {
                cell.imageView?.image = UIImage(systemName: "circle.fill")?.withRenderingMode(.alwaysTemplate)
                cell.imageView?.tintColor = .black
          } else {
            cell.imageView?.image = UIImage(systemName: "circle")?.withRenderingMode(.alwaysTemplate)
            cell.imageView?.tintColor = .black

          }
    }
                
        tableView.deselectRow(at: indexPath, animated: true)
    }

    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {

        tableView.deselectRow(at: indexPath, animated: true)
        
        let cell = tableView.cellForRow(at: indexPath)!
        performSegue(withIdentifier: "EditItem", sender: cell)

    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
      return getfooterView()
  }

    func getfooterView() -> UIView
    {
        let header = UIView(frame: CGRect(x: 0, y: 0, width: Double(self.tableView.frame.size.width), height: 45))
        let button = UIButton()
         button.frame = CGRect(x: 0, y: 0, width: header.frame.size.width , height: header.frame.size.height)
        button.backgroundColor = .clear
        button.setTitle("Add Task", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(submitAction), for: .touchUpInside)

        header.addSubview(button)
        header.bringSubviewToFront(button)
        return header
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 45
    }

    @objc func submitAction() {
        if list.count > 6 && !UserDefaults.standard.bool(forKey: "Premium") {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "Premium")
            self.present(controller, animated: true, completion: nil)
        } else {
            performSegue(withIdentifier: "AddItem", sender: nil)
        }
    }
        
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "AddItem" {
    let controller = segue.destination as! UINavigationController
    let targetController = controller.topViewController as! AddListController
    targetController.list = list
    } else if segue.identifier == "EditItem" {
        let controller = segue.destination as! UINavigationController
        let targetController = controller.topViewController as! AddListController
        if let indexPath = tableView.indexPath(for: sender as! UITableViewCell) {
            targetController.editItem = list[indexPath.row]
        }
    }
 }
    



}

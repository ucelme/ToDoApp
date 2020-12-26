import RealmSwift

let realm = try! Realm()

class ToDoList: Object {
    @objc dynamic var title = ""
    var item = List<ToDoListItems>()
}

class ToDoListItems: Object {
    @objc dynamic var title = ""
    @objc dynamic var checked = false
    @objc dynamic var remind = false
    @objc dynamic var id = ""
    @objc dynamic var remindDate = Date()
}

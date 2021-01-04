import UIKit

class CustomNotification: NSObject {
    
    weak var observer: AnyObject?
    var selector: Selector
    var userInfo = [AnyHashable: Any]()
    
    init(value: AnyObject, completion: Selector) {
        self.observer = value
        self.selector = completion
    }
}


class CustomNotificationCenter {
    

    static let defaultCenter = CustomNotificationCenter()
    
    private var _map: [String: [CustomNotification]] = [:]
    
    private var map: [String: [CustomNotification]] {
        get {
            var map: [String: [CustomNotification]] = [:]
            queue.async {
                map = self._map
            }
            return map
        } set {
            queue.sync(flags: .barrier) {
                _map = newValue
            }
        }
    }
    
    private let queue = DispatchQueue(label: "ObserverQueue", qos: .default, attributes: .concurrent)
    
    private init() {}
    
    func postNotification(name: String, userInfo: [AnyHashable : Any]?) {
        if let items = self.map[name] {
            if let itemsNew = items.compactMap({ $0.observer }) as? [CustomNotification] {
                for notification in itemsNew {
                    var newObject = notification
                    newObject.userInfo = ["userInfo" : userInfo]
                    print("perform selector c alled")
                    notification.observer?.performSelector(inBackground: notification.selector, with: newObject)
                }
            }
        }
    }
    
    func addObserver(observer: AnyObject, name: String, selector: Selector) {
        if var notification = self.map[name] {
            notification.append(CustomNotification(value: observer, completion: selector))
            self.map[name] = notification
        } else {
            self.map[name] = [CustomNotification(value: observer, completion: selector)]
        }
    }
    
    func removeObserver(name: String) {
        self.map[name] = nil
    }
    
    func removeObserver(observer: AnyObject) {
        for key in self.map.keys {
            if var items = self.map[key] {
                items.removeAll { (notification) -> Bool in
                    return (notification.observer === observer)
                }
            }
        }
    }
}



class A: UIViewController {
  
    func post() {
        CustomNotificationCenter.defaultCenter.postNotification(name: "a", userInfo: ["abc" : "abcd"])
    }
}

class B: UIViewController {
    func add() {
        print("enter in ADd")
        CustomNotificationCenter.defaultCenter.addObserver(observer: self, name: "a", selector: #selector(abc(notification:)))
    }
    
    @objc func abc(notification: CustomNotification) {
        print("enter in method")
        let userInfo = notification.userInfo
        print(userInfo)
    }
}


class C: UIViewController {
    func add() {
        print("enter in ADd")
        CustomNotificationCenter.defaultCenter.addObserver(observer: self, name: "a", selector: #selector(abc(notification:)))
    }
    
    @objc func abc(notification: CustomNotification) {
        print("enter in method")
        let userInfo = notification.userInfo
        print(userInfo)
    }
}

let b = B()
b.add()
let c = C()
c.add()
let a = A()
a.post()

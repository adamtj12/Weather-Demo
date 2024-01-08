//  AdamSampleProject

import UIKit
import CoreData

typealias PerformOnContextClosure = (_ context: NSManagedObjectContext) -> ()

//Mostly boiler plate code required for Core Data
class CoreDataHelper: NSObject {
    static var sharedInstance = CoreDataHelper()
    static let DatabaseName = "AdamSampleProject"
    
    override init() {
        super.init()
        let selector = #selector(CoreDataHelper.contextChangedNotification(_:))
        NotificationCenter.default.addObserver(self, selector: selector, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
    }
    
    static func restart() {
        sharedInstance.restart()
    }
    
    fileprivate func restart() {
        createPersistentStore(withCoordinator: self.persistentStoreCoordinator)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
    }
    
    @objc func contextChangedNotification(_ notification: Foundation.Notification) {
        guard let object = notification.object else {
            return
        }
        
        guard let _ = object as? NSManagedObjectContext else {
            return
        }
        
        performClosureOnContext(self.backgroundManagedObjectContext, wait: false, save: false) { [weak self] (context) in
            self?.backgroundManagedObjectContext.mergeChanges(fromContextDidSave: notification)
        }
        
        performClosureOnContext(self.mainManagedObjectContext, wait: false, save: false) { [weak self] (context) in
            self?.mainManagedObjectContext.mergeChanges(fromContextDidSave: notification)
        }
    }
    
    lazy var applicationDocumentsDirectory: URL = {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = Bundle.main.url(forResource: "AdamSampleProject", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = { [unowned self] in
        return self.createPersistentStoreCoordinator()
    }()
    
    fileprivate func createPersistentStoreCoordinator() -> NSPersistentStoreCoordinator {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        createPersistentStore(withCoordinator: coordinator)
        
        return coordinator
    }
    
    fileprivate func createPersistentStore(withCoordinator coordinator: NSPersistentStoreCoordinator) {
        let url = self.applicationDocumentsDirectory.appendingPathComponent("\(CoreDataHelper.DatabaseName).sqlite")
        let options: [AnyHashable: Any] = [NSMigratePersistentStoresAutomaticallyOption: 1,
                                           NSInferMappingModelAutomaticallyOption: 1,
                                           NSPersistentStoreFileProtectionKey: FileProtectionType.completeUntilFirstUserAuthentication]
        
        let failureReason = "There was an error creating or loading the application's saved data."
        do {
            for store in coordinator.persistentStores {
                try coordinator.remove(store)
            }
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: options)
        } catch {
            var dict = [String: Any]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            
            dict[NSUnderlyingErrorKey] = error as Error
        }
    }
    
    lazy var mainManagedObjectContext: NSManagedObjectContext = { [unowned self] in
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        
        let mergePolicy = NSMergePolicy(merge: .overwriteMergePolicyType)
        managedObjectContext.mergePolicy = mergePolicy
        
        return managedObjectContext
    }()
    
    lazy var testManagedObjectContext: NSManagedObjectContext = { [unowned self] in
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        
        let mergePolicy = NSMergePolicy(merge: .overwriteMergePolicyType)
        managedObjectContext.mergePolicy = mergePolicy
        
        return managedObjectContext
    }()

    
    lazy var backgroundManagedObjectContext: NSManagedObjectContext = { [unowned self] in
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        
        let mergePolicy = NSMergePolicy(merge: .overwriteMergePolicyType)
        managedObjectContext.mergePolicy = mergePolicy
        
        return managedObjectContext
    }()
    
    func saveContext(_ context: NSManagedObjectContext) {
        if context.persistentStoreCoordinator == nil {
            return
        }
        if context.hasChanges {
            do {
                try context.save()
            } catch {
            }
        }
    }
    
    fileprivate func deleteDatabase() {
        self.performClosureOnContext(mainManagedObjectContext, wait: true, save: true) { (context) in
            for entityDescription in self.managedObjectModel.entities {
                guard let name = entityDescription.name else {
                    continue
                }
                
                self.deleteObjectsForEntity(name, context: context)
            }
        }
    }
    
    fileprivate func deleteObjectsForEntity(_ name: String, context: NSManagedObjectContext) {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: name)
        
        do {
            let fetchedObjects = try context.fetch(fetchRequest)
            
            for object in fetchedObjects {
                self.deleteObject(object, context: context)
            }
        } catch {
            return
        }
    }
}

//Custom convenience methods as an addition to the boiler plate code
extension CoreDataHelper {
    fileprivate func performClosureOnContext(_ context: NSManagedObjectContext, wait: Bool, save: Bool, closure: @escaping PerformOnContextClosure) {
        if wait {
            #if DEBUG
            if Thread.isMainThread && context == CoreDataHelper.backgroundContext() {
//                printIfDebug("****** Pausing main thread to wait on background context. This is a serious error! ******")
            }
            #else
            #endif
            
            context.performAndWait({ [weak self] () -> Void in
                autoreleasepool {
                     closure(context)
                    
                    if save {
                        self?.saveContext(context)
                    }
                }
            })
        } else {
            context.perform({ [weak self] () -> Void in
                autoreleasepool {
                    closure(context)
                    
                    if save {
                        self?.saveContext(context)
                    }
                }
            })
        }
    }
    
    fileprivate func deleteObject(_ object: NSManagedObject, context: NSManagedObjectContext) {
        context.delete(object)
    }
    
    static func mainContext() -> NSManagedObjectContext {
        return sharedInstance.mainManagedObjectContext
    }
    
    static func backgroundContext() -> NSManagedObjectContext {
        return sharedInstance.backgroundManagedObjectContext
    }
    
    static func performClosureOnContext(_ context: NSManagedObjectContext, wait: Bool, save: Bool, closure: @escaping PerformOnContextClosure) {
        sharedInstance.performClosureOnContext(context, wait: wait, save: save, closure: closure)
    }
    
    static func saveContext(_ context: NSManagedObjectContext) {
        sharedInstance.saveContext(context)
    }
    
    static func deleteObject(_ object: NSManagedObject, context: NSManagedObjectContext) {
        sharedInstance.deleteObject(object, context: context)
    }
    
    static func deleteDatabase() {
        sharedInstance.deleteDatabase()
    }
}

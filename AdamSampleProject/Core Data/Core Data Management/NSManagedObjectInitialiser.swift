//  AdamSampleProject

import Foundation
import CoreData

func readAllObjects<T>(ofType type: T.Type, context: NSManagedObjectContext) -> [T] where T:NSManagedObject {
    return readAllObjects(ofType: type, specificAttributes: nil, context: context)
}

func readAllObjects<T>(ofType type: T.Type, specificAttributes: [String]?, context: NSManagedObjectContext) -> [T] where T:NSManagedObject {
    let fetchRequest = NSManagedObject.createFetchRequestForEntity(ofType: type)
    if let unwrappedSpecificAttributes = specificAttributes {
        fetchRequest.propertiesToFetch = unwrappedSpecificAttributes
    }
     return NSManagedObject.executeFetchRequest(ofType: type, fetchRequest: fetchRequest, context: context)
}

func readObject<T>(ofType type: T.Type, attributeName: String, value: String, context: NSManagedObjectContext) -> T? where T:NSManagedObject {
    let fetchRequest = NSManagedObject.createFetchRequestForEntity(ofType: type)
    let predicate = NSPredicate(format: "%K == %@", argumentArray: [attributeName, value])
    fetchRequest.predicate = predicate
    let resultArray = NSManagedObject.executeFetchRequest(ofType: type, fetchRequest: fetchRequest, context: context)
    if let result = resultArray.first {
        return result
    } else {
        return nil
    }
}

func readObjects<T>(ofType type: T.Type, predicate: NSPredicate, context: NSManagedObjectContext) -> [T] where T:NSManagedObject {
    let fetchRequest = NSManagedObject.createFetchRequestForEntity(ofType: type)
    fetchRequest.predicate = predicate
    let resultArray = NSManagedObject.executeFetchRequest(ofType: type, fetchRequest: fetchRequest, context: context)
    return resultArray
}

func readOrCreateObject<T>(ofType type: T.Type, attributeName: String, value: String, context: NSManagedObjectContext) -> T where T:NSManagedObject {
    let result = readObject(ofType: type, attributeName: attributeName, value: value, context: context)
    if let unwrappedResult = result {
        return unwrappedResult
    } else {
        return createObject(ofType: type, attributeName: attributeName, value: value, context: context)
    }
}

func createObject<T>(ofType type: T.Type, attributeName: String, value: String, context: NSManagedObjectContext) -> T where T:NSManagedObject {
    let entityDescription = NSEntityDescription.entity(forEntityName: NSManagedObject.entityName(type), in: context)
    let managedObject = type.init(entity: entityDescription!, insertInto: context)
    return managedObject
}

extension NSManagedObject {
    fileprivate static func entityName<T>(_ type: T.Type) -> String where T: NSManagedObject {
        var entityName: String = ""
        if #available(iOS 10.0, *) {
            entityName = type.entity().name ?? String(describing: type)
        }
        return entityName
    }
        
    static fileprivate func createFetchRequestForEntity<T>(ofType type: T.Type) -> NSFetchRequest<T> where T:NSManagedObject {
        let fetchRequest = NSFetchRequest<T>(entityName: entityName(type))
        fetchRequest.returnsObjectsAsFaults = false
        return fetchRequest
    }
    
    static func executeFetchRequest<T>(ofType type: T.Type, fetchRequest: NSFetchRequest<T>, context: NSManagedObjectContext) -> [T] where T:NSManagedObject {
        var result: [T] = []
        
        CoreDataHelper.performClosureOnContext(context, wait: true, save: false, closure: { (closureContext) in
            do {
                let fetchResult = try closureContext.fetch(fetchRequest)
                result = fetchResult
            } catch {
                return
            }
        })
        return result
    }
}

//
//  Database.swift
//  contax
//
//  Created by developer on 12/6/18.
//  Copyright © 2018 btinoco. All rights reserved.
//

import Foundation
import CoreData
import AppKit


class CoreDataManager {
    var managedContext:NSManagedObjectContext!
    
    init(){
        guard let appDelegate:AppDelegate = NSApplication.shared.delegate as? AppDelegate else { return }
        
        self.managedContext = appDelegate.persistentContainer.viewContext
    }
    
    func write(entityName:String, record:Dictionary<String,Any>){
        let entity = NSEntityDescription.entity(forEntityName: entityName, in: self.managedContext)!
        let managedRecord = NSManagedObject(entity: entity, insertInto: self.managedContext)
        
        for field in record{
            managedRecord.setValue(field.value, forKey:field.key)
        }
        
        do{
            try self.managedContext.save()
        }catch let error as NSError{
            print("Save failed: \(error)")
        }
    }
    
    func read(entityName:String, withFormat:String?, andValues:CVarArg?)->[Dictionary<String,Any>]{
        var records:[Dictionary<String, Any>] = []
        let fetchRequest:NSFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        
        if(withFormat != nil && andValues != nil){
            fetchRequest.predicate = NSPredicate(format: withFormat!, andValues!)
        }
        
        do{
            let managedRecords = try self.managedContext.fetch(fetchRequest)
            
            for managedRecord in managedRecords as! [NSManagedObject]{
                var record:Dictionary<String, Any> = [:]
                
                for attribute in managedRecord.entity.attributesByName.keys{
                    record[attribute] = managedRecord.value(forKey: attribute)
                }
                
                records.append(record)
            }
            return records
        }catch let error as NSError{
            print("Read failed: \(error)")
            
            return records
        }
    }
    
    func update(entityName:String, key:String, value:Any, format:String, values:CVarArg){
        let fetchRequest:NSFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        
        fetchRequest.predicate = NSPredicate(format: format, values)
        
        do{
            let test = try self.managedContext.fetch(fetchRequest)
            
            let record = test[0] as! NSManagedObject
            
            record.setValue(value, forKey:key)
            
            do{
                try self.managedContext.save()
            }catch let error as NSError{
                print("Updated failed: \(error)")
            }
            
        }catch let error as NSError{
            print("Update failed: \(error)")
        }
    }
    
    func delete(entityName:String, format:String, values:CVarArg){
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        
        fetchRequest.predicate = NSPredicate(format:format, values)
        
        do{
            let test = try self.managedContext.fetch(fetchRequest)
            
            let record = test[0] as! NSManagedObject
            
            self.managedContext.delete(record)
            
            do{
                try self.managedContext.save()
            }catch let error as NSError{
                print("Delete failed: \(error)")
            }
        }catch let error as NSError{
            print("Delete failed: \(error)")
        }
    }
    
    func reset(entityName:String){
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        
        fetchRequest.returnsObjectsAsFaults = false
        
        do{
            let managedRecords = try self.managedContext.fetch(fetchRequest)
            
            for record in managedRecords{
                let recordData:NSManagedObject = record as! NSManagedObject
                
                self.managedContext.delete(recordData)
            }
        }catch let error as NSError{
            print("Delete failed: \(error)")
        }
    }
}

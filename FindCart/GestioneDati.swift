//
//  GestioneDati.swift
//  ViewST
//
//  Created by Francesco Laiti on 02/03/18.
//  Copyright © 2018 francescolaiti. All rights reserved.
//

import Foundation
import UIKit
import CoreData

var materialeArray: [String] = []
var dettagliArray: [String] = []

class GestioneDati {
    
    func creoVariabile(dato: String) {
        
        //store core data
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let newMat = NSEntityDescription.insertNewObject(forEntityName: "Materiale", into: context)
        let photo = UIImage(named: "immagine_default.jpg")
        let imageData: NSData = UIImagePNGRepresentation(photo!)! as NSData
        
        newMat.setValue(dato, forKey: "nome")
        newMat.setValue("", forKey: "modello")
        newMat.setValue("", forKey: "note")
        newMat.setValue("", forKey: "stato")
        newMat.setValue("", forKey: "n_carrello")
        newMat.setValue("", forKey: "provenienza")
        newMat.setValue("", forKey: "quantita")
        newMat.setValue("", forKey: "ble")
        newMat.setValue(imageData, forKey: "immagine")
        
        do {
            try context.save()
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            print("SAVED")
        }
        catch {
            print ("error")
        }
    }
    
    
    func leggoVariabili() {
        materialeArray.removeAll()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Materiale")
        request.returnsObjectsAsFaults = false
        
        do {
            let results = try context.fetch(request)
            
            if results.count > 0
            {
                for result in results as! [NSManagedObject]
                {
                    if let nome = result.value(forKey: "nome") as? String
                    {
                        materialeArray.append(nome)
                    }
                    
                }
                print (materialeArray)
            }
        }
        catch{
            print ("error")
        }
    }
    
    
    func cambioValore(dato: String, attributo: String, valore_ass: String){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Materiale")
        request.returnsObjectsAsFaults = false
        
        do {
            let results = try context.fetch(request)
            
            if results.count > 0
            {
                for result in results as! [NSManagedObject]
                {
                    if let nome = result.value(forKey: "nome") as? String
                    {
                        print (nome)
                        if nome == valore_ass{
                            result.setValue(dato, forKey: attributo)
                        do {
                            try context.save()
                            print("dato salvato con successo!")
                            UINotificationFeedbackGenerator().notificationOccurred(.success)
                        }
                        catch{

                        }
                    }
                }
            }
        }
        }
        catch {
            print ("error")
        }
    }
    
    
    
    func chiedoDettagli(attributo: String) -> String {
        var quantitaArray: [String] = []
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Materiale")
        request.returnsObjectsAsFaults = false
        
        do {
            let results = try context.fetch(request)
            
            if results.count > 0
            {
                for result in results as! [NSManagedObject]
                {
                    if let quantita = result.value(forKey: attributo) as? String
                    {
                        quantitaArray.append(quantita)
                    }
                }
            }
        }
        catch{
            print ("error")
        }
        return quantitaArray[posizioneInArray!]
    }
    
    func cancellare(elimina: String) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Materiale")
        
        do {
            let results = try context.fetch(request)
            
            if results.count > 0
            {
                for result in results as! [NSManagedObject]
                {
                    if let nome = result.value(forKey: "nome") as? String
                    {
//                        print (nome)
                        if nome == elimina {
                            context.delete(result)
                            do {
                                try context.save()
                                UINotificationFeedbackGenerator().notificationOccurred(.success)
                                print("dato \(nome) eliminato con successo!")
                            }
                            catch{
                                print("error")
                            }
                        }
                    }
                }
            }
        }
        catch {
            print ("error")
        }
    }
    
    
    func chiedoDettagliPerCella(attributo: String) -> Array<Any> {
        var quantitaArray: [String] = []
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Materiale")
        request.returnsObjectsAsFaults = false
        
        do {
            let results = try context.fetch(request)
            
            if results.count > 0
            {
                for result in results as! [NSManagedObject]
                {
                    if let quantita = result.value(forKey: attributo) as? String
                    {
                        quantitaArray.append(quantita)
                    }
                    
                    //                    if let quantita = result.value(forKey: "quantita") as? String
                    //                    {
                    //                        quantitaArray.append(quantita)
                    //                    }
                }
            }
        }
        catch{
            print ("error")
        }
        return quantitaArray
    }
    
    
    func ripristinoCompleto () -> Bool {
        
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let context = delegate.persistentContainer.viewContext
        
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Materiale")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        
        do {
            try context.execute(deleteRequest)
            try context.save()
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            print("cancellato tutto con successo!")
            return true
        } catch {
            print ("errore")
            return false
        }
    }

}


//
//  Immagine.swift
//  ViewST
//
//  Created by Francesco Laiti on 09/03/18.
//  Copyright © 2018 francescolaiti. All rights reserved.
//

import UIKit
import CoreData

class Immagine: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIScrollViewDelegate {

    @IBOutlet var scroll: UIScrollView!
    @IBOutlet var immagine: UIImageView!
    
    @IBAction func importa(_ sender: Any) {

        aggiungiImmagine()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.scroll.minimumZoomScale = 1.0
        self.scroll.maximumZoomScale = 5.0
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(Immagine.zoom))
        tap.numberOfTapsRequired = 2
        scroll.addGestureRecognizer(tap)
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        DispatchQueue.main.async {
            self.chiedoImmagine()
        }
        
//            self.immagine.transform = self.immagine.transform.rotated(by: CGFloat(Double.pi / 2))
    //        print("passato da willAppear")
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return immagine
    }
    
    @objc func zoom(sender: UITapGestureRecognizer) {
        
        if (scroll.zoomScale < 1.5) {
            scroll.setZoomScale(scroll.maximumZoomScale, animated: true)
            
        } else {
            scroll.setZoomScale(scroll.minimumZoomScale, animated: true)
            
        }
        
    }

    func aggiungiImmagine() {
        
        let alert = UIAlertController(title: "Aggiungi foto", message: "Scegli da dove vuoi importare l'immagine:", preferredStyle: UIAlertControllerStyle.alert)

        
        alert.addAction(UIAlertAction(title: "Fotocamera", style: .default, handler: { [weak alert] (_) in self.importaDaFotocamera()}))
        
        alert.addAction(UIAlertAction(title: "Album foto", style: .default, handler: { [weak alert] (_) in self.importaDaAlbum()}))
        
        alert.addAction(UIAlertAction(title: "Annulla", style: UIAlertActionStyle.default, handler: {(action) in alert.dismiss(animated: true, completion: nil)}))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func importaDaFotocamera(){
        
        let image = UIImagePickerController()
        image.delegate = self
        
        image.sourceType = UIImagePickerControllerSourceType.camera
        
        image.allowsEditing = false
        
        self.present(image, animated: true)
        
    }
    
    func importaDaAlbum(){
        
        let image = UIImagePickerController()
        image.delegate = self
        
        image.sourceType = UIImagePickerControllerSourceType.photoLibrary
        
        image.allowsEditing = false
        
        self.present(image, animated: true)
        
    }
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {

            immagine.image = image
            salvaImmagine()
//            immagine.transform = immagine.transform.rotated(by: CGFloat(3*(Double.pi / 2)))
//            print("passato da picker")
        }
        else {
            
            print("errore visualizzazione foto")
            
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func salvaImmagine(){
        
        let imageData: NSData = UIImageJPEGRepresentation(immagine.image!,0.5)! as NSData
        
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
//                        print (nome)
                        if nome == invioSegue {
                            result.setValue(imageData, forKey: "immagine")
                            do {
                                try context.save()
                                print("immagine per \(nome) salvato con successo!")
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
    
    
    func chiedoImmagine(){
        
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
//                        print (nome)
                        if nome == invioSegue {
                            let foto = result.value(forKey: "immagine") as! NSData
                            immagine.image = UIImage(data: foto as Data )
                            print("immagine trovata per \(nome)")
                        }
                    }
                }
            }
        }
        catch {
            print ("error")
        }
    }
    
}

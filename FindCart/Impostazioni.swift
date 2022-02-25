//
//  Impostazioni.swift
//  ViewST
//
//  Created by Francesco Laiti on 05/03/18.
//  Copyright © 2018 francescolaiti. All rights reserved.
//

import UIKit

class Impostazioni: UIViewController {

    @IBOutlet var creaCSVbottone: UIButton!
    @IBOutlet var reset: UIButton!
    @IBOutlet var esecuzione: UILabel!
    @IBOutlet var testo: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        reset.layer.cornerRadius = 8
        esecuzione.layer.masksToBounds = true
        esecuzione.layer.cornerRadius = 15
        creaCSVbottone.layer.cornerRadius = 8
        
        testo.layer.borderColor = UIColor.black.cgColor
        testo.layer.borderWidth = 0.5
        // Do any additional setup after loading the view.
    }
    
    @IBAction func resetDati(_ sender: Any) {
        
        confermaEliminazione()
        
    }
    
    func confermaEliminazione(){
        
        let alert = UIAlertController(title: "Reset", message: "Sei sicuro di voler eliminare i tuoi dati e riportare l'app allo stato iniziale?", preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "Si, elimino", style: .default, handler: {[weak alert] (_) in
            let confermaUtente = chiamoGD.ripristinoCompleto()
            if confermaUtente {
                self.esecuzione.text = "Completato!"
            }
            else {
                self.esecuzione.text = "Errore"
            }
        }))
        
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: {(action) in alert.dismiss(animated: true, completion: nil)}))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    //CREARE FILE .CVS PER ESPORTARLO, CREARE UN INVENTARIO
    
    @IBAction func esportaCSV(_ sender: Any) {
        
        let alert = UIAlertController(title: "Crea file", message: "Inserisci il nome da dare al tuo file .CVS:", preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addTextField { (textField) in
            textField.text = "Inventario"
        }
        
        alert.addAction(UIAlertAction(title: "Annulla", style: .default, handler: {(action) in alert.dismiss(animated: true, completion: nil)}))
        
        alert.addAction(UIAlertAction(title: "Condividi", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
            self.creaCSV(nomeFile: (textField?.text)!)
        }))
        
        self.present(alert, animated: true, completion: nil)

        
    }
    func creaCSV(nomeFile: String){
        
        let fileName = "\(nomeFile).csv"
        let path = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)
        
        var csvText = "Nome,Modello,Stato corrente,Provenienza,N° carrello,Quantità,Note\n"
        
        var nome = chiamoGD.chiedoDettagliPerCella(attributo: "nome")
        var modello = chiamoGD.chiedoDettagliPerCella(attributo: "modello")
        var stato = chiamoGD.chiedoDettagliPerCella(attributo: "stato")
        var prov = chiamoGD.chiedoDettagliPerCella(attributo: "provenienza")
        var carrello = chiamoGD.chiedoDettagliPerCella(attributo: "n_carrello")
        var qt = chiamoGD.chiedoDettagliPerCella(attributo: "quantita")
        var note = chiamoGD.chiedoDettagliPerCella(attributo: "note")
        
        var i = 0
        while i < nome.count {
            let nuovaLinea = "\(nome[i]),\(modello[i]),\(stato[i]),\(prov[i]),\(carrello[i]),\(qt[i]),\(note[i])\n"
            csvText.append(nuovaLinea)
            
            i = i + 1
        }
        
        do {
            try csvText.write(to: path!, atomically: true, encoding: String.Encoding.utf8)
            print("file creato con successo!")
         
        let vc = UIActivityViewController(activityItems: [path], applicationActivities: [])
            
            if (UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad)
            {
                //ios > 8.0
                    vc.popoverPresentationController?.sourceView = super.view
            }
            

            present(vc, animated: true, completion: nil)
            
        } catch {
            print("Errore nella creazione del file .CSV")
            print("\(error)")
            creaCSVbottone.setTitle("Errore", for: .normal)
        }
    
    }
    
    func prova()
    {
        print("ricevuto passo e chiudo")
        let alert = UIAlertController(title: "Crea file", message: "Inserisci il nome da dare al tuo file .CVS:", preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addTextField { (textField) in
            textField.text = "Inventario"
        }
        
        alert.addAction(UIAlertAction(title: "Annulla", style: .default, handler: {(action) in alert.dismiss(animated: true, completion: nil)}))
        
        alert.addAction(UIAlertAction(title: "Condividi", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
            self.creaCSV(nomeFile: (textField?.text)!)
        }))
        
        self.present(alert, animated: true, completion: nil)

    }
}



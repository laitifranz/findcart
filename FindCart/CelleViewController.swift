//
//  CelleViewController.swift
//  ViewST
//
//  Created by Francesco Laiti on 02/03/18.
//  Copyright © 2018 francescolaiti. All rights reserved.
//

import UIKit

var datoSalvare: String?
let chiamoGD = GestioneDati()
var invioSegue: String?
var posizioneInArray: Int?

class CelleViewController: UITableViewController, UISearchResultsUpdating  {
    
    var aggiungiNuovo: String = ""
    var resultSearchController: UISearchController?
    var listaFiltrata = [""]

    @IBOutlet var celleView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        chiamoGD.leggoVariabili()
        
        self.resultSearchController = ({
            // creo un oggetto di tipo UISearchController
            let controller = UISearchController(searchResultsController: nil)
            // rimuove la tableView di sottofondo in modo da poter successivamente visualizzare gli elementi cercati
            controller.dimsBackgroundDuringPresentation = false

            // il searchResultsUpdater, ovvero colui che gestirà gli eventi di ricerca, sarà la ListaTableViewController (o self)
            controller.searchResultsUpdater = self
//            controller.searchBar.scopeButtonTitles = ["Tutti", "Abitacolo", "Ruote"]
            // impongo alla searchBar, contenuta all'interno del controller, di adattarsi alle dimensioni dell'applicazioni
            controller.searchBar.sizeToFit()



            // atacco alla parte superiore della TableView la searchBar
            self.tableView.tableHeaderView = controller.searchBar

            // restituisco il controller creato
            return controller
        })()
        
         //Uncomment the following line to preserve selection between presentations
         self.clearsSelectionOnViewWillAppear = false

//         //Uncomment the following line to display an Edit button in the navigation bar for this view controller.
//         self.navigationItem.leftBarButtonItem = self.editButtonItem
        
        celleView.delegate = self
        celleView.dataSource = self
        
        self.tableView.reloadData()
        print(materialeArray)
    }

    override func viewWillAppear(_ animated: Bool) {
        chiamoGD.leggoVariabili()
        self.tableView.reloadData()
    }
    
    
    @IBAction func aggiungiButton(_ sender: Any) {
        
        addAlert()
        
    }
    
    
     //CAMPO RICERCA
    func updateSearchResults(for searchController: UISearchController) {
        print ("inizio ricerca")
        resultSearchController!.searchBar.showsScopeBar = false
//        let scopes = resultSearchController!.searchBar.scopeButtonTitles
//        let currentScope = scopes![resultSearchController!.searchBar.selectedScopeButtonIndex] as String
//        print (searchController.searchBar.text!)
        self.filtraContenuti(testoCercato: searchController.searchBar.text!)
        
    }
    
    
    func filtraContenuti(testoCercato: String) {
        
        print("sto filtrando i contenuti")
        
        listaFiltrata.removeAll(keepingCapacity: true)
        for x in materialeArray {
            var justOne = false
            if((x.range(of: testoCercato.localizedLowercase) != nil) && justOne == false) {
                print("aggiungo \(x) alla listaFiltrata")
                listaFiltrata.append(x)
                justOne = true
            }
        }
        self.tableView.reloadData()
    }
    

    // CREAZIONE CELLE
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        guard let controller = self.resultSearchController else {
            return 0
        }
        
        if controller.isActive {
            return self.listaFiltrata.count
        } else {
            return materialeArray.count
        }
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cella", for: indexPath) as! CustomTableViewCell
        
        var materiale = ""
        
        if self.resultSearchController!.isActive {
            materiale = listaFiltrata[indexPath.row]
            cell.statoCella.text = ""
        } else {
            //ricavo un elemento della lista in posizione row (il num di riga) e lo conservo
            materiale = materialeArray[indexPath.row]
            let nomePerCella = chiamoGD.chiedoDettagliPerCella(attributo: "stato")
            let qtPerCella = chiamoGD.chiedoDettagliPerCella(attributo: "quantita")
            if ((qtPerCella[indexPath.row] as! String).isEmpty && (nomePerCella[indexPath.row] as! String).isEmpty) {
                cell.statoCella.text = ("-")
            }
            else if ((qtPerCella[indexPath.row] as! String).isEmpty){
                cell.statoCella.text = ("Stato: \((nomePerCella[indexPath.row] as! String))")
            }
            else if ((nomePerCella[indexPath.row] as! String).isEmpty){
                cell.statoCella.text = ("-")
            }
            else{
                cell.statoCella.text = ("Stato: \((nomePerCella[indexPath.row] as! String)) | \((qtPerCella[indexPath.row] as! String)) qt")
            }
        }
        cell.cellaView?.layer.masksToBounds = true
        cell.cellaView?.layer.cornerRadius = 5
        cell.nomeCella.text = materiale.firstUppercased

        cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        // Configure the cell...

        return cell
    }

//    PREPARO LA PAGINA SUCCESSIVA
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "dettaglioMaterialeSegue" {
            let materialeDetailViewController = segue.destination as! BluetoothCommand
            let indexPath = self.tableView.indexPathForSelectedRow!

            if (resultSearchController?.isActive)! {
                let TitoloDestinazione = listaFiltrata[indexPath.row].firstUppercased
                materialeDetailViewController.title = TitoloDestinazione
                
                invioSegue = listaFiltrata[indexPath.row]
                var conta = 0
                for x in materialeArray {
                    if x == invioSegue {
                        posizioneInArray = conta
                    }
                    conta += 1
                }
               resultSearchController?.isActive = false
            }
            
            else {
                let TitoloDestinazione = materialeArray[indexPath.row].firstUppercased
                materialeDetailViewController.title = TitoloDestinazione
                invioSegue = materialeArray[indexPath.row]
                posizioneInArray = indexPath.row
            }
        }
    }
    
    
    
     //ALERT VARI

    func addAlert() {
        
        let alert = UIAlertController(title: "Nuovo oggetto", message: "Inserisci qui sotto il nome da assegnare al nuovo elemento:", preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addTextField { (textField) in
            textField.text = ""
        }
        
        alert.addAction(UIAlertAction(title: "Annulla", style: UIAlertActionStyle.default, handler: {(action) in alert.dismiss(animated: true, completion: nil)}))
        
        alert.addAction(UIAlertAction(title: "Aggiungi", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
            self.aggiungiNuovo = (textField?.text)!
            datoSalvare = self.aggiungiNuovo
            self.continua()
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    func continua(){
        var controllo = false
        for x in materialeArray {
            if datoSalvare == x {
                print("gia presente il nome")
                controllo = true
            }
        }
        
        if controllo || (datoSalvare?.isEmpty)! {
            print("esiste gia non lo salvo")
        }
            
        else{
            chiamoGD.creoVariabile(dato: datoSalvare!)
            chiamoGD.leggoVariabili()
            //        print (datoSalvare)
            self.tableView.reloadData()
        }
    }
    
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            // Delete the row from the data source
            chiamoGD.cancellare(elimina: materialeArray[indexPath.row])
            chiamoGD.leggoVariabili()
            print("cancellato")
            self.tableView.reloadData()
            
        }
    }

}


extension String {
    var firstUppercased: String {
        guard let first = first else { return "" }
        return String(first).uppercased() + dropFirst()
    }
}

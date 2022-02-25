//
//  BluetoothCommand.swift
//  AppST_Bluetooth
//
//  Created by Francesco Laiti on 30/01/18.
//  Copyright © 2018 francescolaiti. All rights reserved.
//

//
//  ViewController.swift
//  InvioBLE
//
//  Created by Francesco Laiti on 19/01/18.
//  Copyright © 2018 francescolaiti. All rights reserved.
//

/*  STRUTTURA DI UN BLE:
 
 Profile >
 Service >
 Characteristic >
 Properties, Value....
 
 */

import UIKit
import CoreBluetooth
import LocalAuthentication

class BluetoothCommand: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate, UITextFieldDelegate {
    
    var manager: CBCentralManager!
    var peripheral: CBPeripheral!
    var conferma: Bool?
    var activeTextField: UITextField!
    var check = true
    
    @IBOutlet var statoApp: UILabel!
    @IBOutlet var attivaDisattiva: UIButton!
    @IBOutlet var stato: UILabel!
//    @IBOutlet var spegniDisp: UIButton!
    
    @IBOutlet var modello: UITextField!
    @IBOutlet var condizione: UITextField!
    @IBOutlet var prov: UITextField!
    @IBOutlet var carrello: UITextField!
    @IBOutlet var qt: UITextField!
    @IBOutlet var note: UITextField!
    @IBOutlet var elemento: UITextField!
    @IBOutlet var bleNome: UITextField!
    
    let service_BLE = CBUUID(string: "0000A000-0000-1000-8000-00805F9B34FB")
    let character_BLE_RX = CBUUID(string: "0000A001-0000-1000-8000-00805F9B34FB")
    let character_BLE_TX = CBUUID(string: "0000A002-0000-1000-8000-00805F9B34FB")
    
    //    let service_BLE = CBUUID(string: "0000180E-0000-1000-8000-00805F9B34FB")
    //    let character_BLE_RX = CBUUID(string: "00002A37-0000-1000-8000-00805F9B34FB")
    //    let character_BLE_TX = CBUUID(string: "0000A002-0000-1000-8000-00805F9B34FB")
    
    var rxCaratteristica: CBCharacteristic?
    var txCaratteristica: CBCharacteristic?
    
    var characteristicASCIIValue = NSString()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        manager = CBCentralManager(delegate: self, queue: nil)
        // Do any additional setup after loading the view, typically from a nib.
        stato.layer.masksToBounds = true
        stato.layer.cornerRadius = 15
        attivaDisattiva.layer.cornerRadius = 8
//        spegniDisp.layer.cornerRadius = 8
        
        let center: NotificationCenter = NotificationCenter.default
        center.addObserver(self, selector: #selector(keyboardDidShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        center.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        modello.delegate = self
        bleNome.delegate = self
        condizione.delegate = self
        prov.delegate = self
        carrello.delegate = self
        qt.delegate = self
        note.delegate = self
        elemento.delegate = self

    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        modello.text = chiamoGD.chiedoDettagli(attributo: "modello")
        condizione.text = chiamoGD.chiedoDettagli(attributo: "stato")
        prov.text = chiamoGD.chiedoDettagli(attributo: "provenienza")
        carrello.text = chiamoGD.chiedoDettagli(attributo: "n_carrello")
        qt.text = chiamoGD.chiedoDettagli(attributo: "quantita")
        note.text = chiamoGD.chiedoDettagli(attributo: "note")
        elemento.text = chiamoGD.chiedoDettagli(attributo: "nome")
        bleNome.text = chiamoGD.chiedoDettagli(attributo: "ble")

    }
    
    
    //GESTIONE BLUETOOTH
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {  //controllo il bluetooth se è attivo
        if central.state == CBManagerState.poweredOn {
            print ("bluetooth disponibile")
            statoApp.text = "Pronto"
            attivaDisattiva.isEnabled = true
        }
        else {
            print ("bluetooth non disponibile")
            statoApp.text = "Attiva bluetooth"
            attivaDisattiva.isEnabled = false
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber)  //instaurare connessione con il dispositivo con riferimento a variabile 'nome_BLE'
    {
        let device = (advertisementData as NSDictionary).object(forKey: CBAdvertisementDataLocalNameKey) as? NSString
        
        if device?.contains(chiamoGD.chiedoDettagli(attributo: "ble")) == true {
            self.manager.stopScan()
            
            self.peripheral = peripheral
            self.peripheral.delegate = self
            
            manager.connect(peripheral, options: nil)
            statoApp.text = "Trovato device"
            print("connesso al device")
        }
    }
    
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) { // in caso di errore collegamento
        print("Failed to connect to \(peripheral). (\(error!.localizedDescription))")
    }
    
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {  //scan di servizi nel dispositivo connesso
        
        //        statoConnessione.setTitle("Connesso a \(peripheral)", for: .normal)
        
        print("*****************************")
        print("Connection complete")
        print("Peripheral info: \(peripheral)")
        
        //        //Discovery callback
        //        peripheral.delegate = self
        
        peripheral.discoverServices(nil)
    }
    
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {  //scan di caratteristiche nel dispositivo connesso
        for service in peripheral.services! {
            
            let thisService = service as CBService
            
            if service.uuid == service_BLE{
                peripheral.discoverCharacteristics(nil, for: thisService)
            }
        }
        print("Trovati i seguenti servizi: \(peripheral.services!)")
    }
    
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
        print("*******************************************************")
        
        if error != nil {
            statoApp.text = "Errore caratteristiche"
            print("ERROR DISCOVERING CHARACTERISTICS: \(String(describing: error?.localizedDescription))")
            return
        }
        
        print("Trovate le seguenti caratteristiche: \(service.characteristics!)\n Numero caratteristiche: \(service.characteristics?.count ?? 0)")
        
        
        for characteristic in service.characteristics! {
            
            if characteristic.uuid == character_BLE_RX {
                rxCaratteristica = characteristic
                
                peripheral.setNotifyValue(true, for: rxCaratteristica!) //quando si aggiorna dato viene notificato a sistema
                peripheral.readValue(for: characteristic)
                print("Rx Characteristic: \(characteristic.uuid)")
                
            }
            
            if characteristic.uuid == character_BLE_TX {
                txCaratteristica = characteristic
                
                print("Tx Characteristic: \(characteristic.uuid)")
                writeValue(data: "1")
                statoApp.text = "Sta suonando"
                attivaDisattiva.setTitleColor(UIColor(red:1.00, green:0.25, blue:0.25, alpha:1.0), for: .normal)
                attivaDisattiva.setTitle("Spegni dispositivo", for: .normal)
            }
        }
        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) { //invio conferma dato interessato
        guard error == nil else {
            print("Error discovering services: error")
            statoApp.text = "Errore invio dato"
            return
        }
        
        print("Messaggio inviato")
    }
    
    //Write function
    func writeValue(data: String){
        let valueString = (data as NSString).data(using: String.Encoding.utf8.rawValue)
        if let peripheral = peripheral{
            if let txCharacteristic = txCaratteristica {
                print("inviato \(data)")
                peripheral.writeValue(valueString!, for: txCharacteristic, type: CBCharacteristicWriteType.withResponse)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) { //notifica ogni volta che viene moidificato un darto per la lettura
        
        //        print(String(bytes: characteristic.value!, encoding: String.Encoding.utf8))
        //        print(Int(strtoul(str, nil, 16)))
        //        let dataBLE = String(data: characteristic.value!, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
        //        print(dataBLE)
        //        let dato = String(data: characteristic.value!, encoding: .utf32BigEndian)
        if let string = String(data: characteristic.value!, encoding: .utf16) {  //altrimenti .utf8
            //            let asciivalore = String(data: string, encoding: .ascii)
            var value: String? = nil
            for element in string.unicodeScalars {
                value = "\(element.value)"
            }
            
            print("Stringa con utf16:\(string)")
            print("Stringa con unicode:\(value ?? "null")")
        } else {
            print("not a valid UTF-8 sequence")
        }
        
        //        if let str = NSString(bytes: data,length: data.count,encoding: NSUTF8StringEncoding) as? String {
        //            print("Byte array : (data) -> String : (str)")
        //        } else {
        //            print("Not a valid UTF-8 sequence")
        //
        //            var b = 0
        //            NSData(bytes: bytes, length: sizeof(Int)).getBytes(&b, length: sizeof(Int))
        //
        //        let s1 = String(dato, radix: 16, uppercase: true)
        //
        //            print("SUUS:\(s1)")
        //        print(characteristic.value!)
        
        //        if characteristic == rxCaratteristica {
        //            if let ASCIIstring = NSString(data: characteristic.value!, encoding: String.Encoding.utf8.rawValue) {
        //                characteristicASCIIValue = ASCIIstring
        //                print("Value Recieved: \((characteristicASCIIValue as String))")
        //                print("Valore letto pulito:\(characteristic.value!)")
        //                let byteArray = [Int8](characteristic.value!)
        //                print("Valore byteArray :\(byteArray)")
        ////                NotificationCenter.default.post(name:NSNotification.Name(rawValue: "Notify"), object: nil)
        //            }
        //        }
    }
    
    func centralManager(central: CBCentralManager,didDisconnectPeripheral peripheral: CBPeripheral,error: NSError?) { //funzione usata nel caso si disconnesse improvvisamente
        statoApp.text = "Disconnesso, riavvio"
        central.scanForPeripherals(withServices: nil, options: nil)
        
    }
    
    func cancelPeripheralConnection(_ peripheral: CBPeripheral){ //funzione per disconnettere il dispositivo
        
        print("disconnesso dal dispositivo da pulsante app")
        
    }
    
    func disconnectFromDevice () { //funzione personale per disconnettere il dispositivo
        if peripheral != nil {
            manager.cancelPeripheralConnection(peripheral!)
        }
    }

    
    @IBAction func cambioStatoConnessione(_ sender: Any) {
        
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
//        autenticazione()
        inizioConnessione()
        
    }
    
    
    //GESTIONE TASTIERA
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField = textField
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
    
    @objc func keyboardDidShow(notification: Notification){
        
        let info: NSDictionary = notification.userInfo! as NSDictionary
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        let keyboardY = self.view.frame.size.height - keyboardSize.height
        let editingTextFieldY: CGFloat! = self.activeTextField?.frame.origin.y
        
        print(editingTextFieldY)
        if editingTextFieldY > keyboardY - 60 {
            UIView.animate(withDuration: 0.25, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: { self.view.frame = CGRect(x:0, y:self.view.frame.origin.y - (editingTextFieldY! - (keyboardY - 60)), width: self.view.bounds.width, height: self.view.bounds.height)}, completion: nil)
        }
        
    }
    
    @objc func keyboardWillHide(notification: Notification){
        
        UIView.animate(withDuration: 0.25, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: { self.view.frame = CGRect(x:0, y:0, width: self.view.bounds.width, height: self.view.bounds.height)}, completion: nil)
        
    }
    
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
//
//        self.view.endEditing(true)
//    }

    
    
    @IBAction func modelloChange(_ sender: Any) {
        chiamoGD.cambioValore(dato: modello.text!, attributo: "modello", valore_ass: invioSegue!)
    }
    
    @IBAction func condChange(_ sender: Any) {
        chiamoGD.cambioValore(dato: condizione.text!, attributo: "stato", valore_ass: invioSegue!)
    }
    
    @IBAction func provChange(_ sender: Any) {
        chiamoGD.cambioValore(dato: prov.text!, attributo: "provenienza", valore_ass: invioSegue!)
    }
    
    @IBAction func carrelloChange(_ sender: Any) {
        chiamoGD.cambioValore(dato: carrello.text!, attributo: "n_carrello", valore_ass: invioSegue!)
    }
    
    @IBAction func qtChange(_ sender: Any) {
        chiamoGD.cambioValore(dato: qt.text!, attributo: "quantita", valore_ass: invioSegue!)
    }
    
    @IBAction func noteChange(_ sender: Any) {
        chiamoGD.cambioValore(dato: note.text!, attributo: "note", valore_ass: invioSegue!)
    }
    @IBAction func elementoChange(_ sender: Any) {
        chiamoGD.cambioValore(dato: elemento.text!, attributo: "nome", valore_ass: invioSegue!)
    }
    @IBAction func bleNome(_ sender: Any) {
        chiamoGD.cambioValore(dato: bleNome.text!, attributo: "ble", valore_ass: invioSegue!)
    }
    
    
    //AUTENTICAZIONE PER CAMBIO DATI
//    func autenticazione() {
//        let context: LAContext = LAContext()
//
//        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil){
//            context.evaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Autenticarsi per chiamare il dispositivo", reply: { (wasSuccessfull, error) in
//                if wasSuccessfull{
//                    self.inizioConnessione()
//                }
//                else{
//                    print("errore autenticazione")
//                }
//            })
//        }
//    }
    
    func inizioConnessione (){
        DispatchQueue.main.async{
            if self.check{
                self.attivaDisattiva.setTitleColor(UIColor(red:1.00, green:0.90, blue:0.00, alpha:1.0), for: .normal)
                self.attivaDisattiva.setTitle("Cerco dispositivo", for: .normal)
//                self.attivaDisattiva.isEnabled = false
                self.statoApp.text = "Scansiono..."
                self.manager.scanForPeripherals(withServices: nil, options: nil)
                self.check = false
        }
        else {
                self.writeValue(data: "0")
                self.attivaDisattiva.setTitleColor(UIColor(red:0.24, green:0.81, blue:0.33, alpha:1.0), for: .normal)
                self.attivaDisattiva.setTitle("Trova dispositivo", for: .normal)
                self.attivaDisattiva.setTitleColor(UIColor(red:1, green:1, blue:1, alpha:1.0), for: .normal)
                self.statoApp.text = "Pronto"
                self.check = true
                
        }
    }
        print (self.check)
    }
    
}



//
//  ViewController.swift
//  MuseSampleSwift
//
//  Created by Ahmer Mughal on 21.12.23.
//

import UIKit
import CoreBluetooth


class ViewController: UIViewController {

    private static let CELLREUSEID = "TableViewCell"
    
    
    // MARK: Variables
    /// Create an instance of CharacterListContentView as the view for this view controller
    private let contentView = MainContentView()
    private let museManager : IXNMuseManagerIos = IXNMuseManagerIos.sharedManager()
    private var selectedMuse : IXNMuse?
    
    private var lastBlink: Bool?
    private var lastJawClench: Bool?
    
    private var detectAgain = true
    
    private var logs : [String] = []
    
    private let bluetoothManager : CBCentralManager = CBCentralManager()
    private var btState : Bool = false
    
    
    // MARK: Override Functions
    /// Loads the content view as the parent view of the view controller
    override func loadView() {
        self.view = contentView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        configureBluetoothManager()
        
        configureMuseManager()
        
        configureLogManager()
        
        configureTableView()
        
        configureButtonTapGestures()
    }
    
    
    @objc private func disconnectButtonTapped(){
        if let selectedMuse{
            selectedMuse.disconnect()
        }
    }
    
    @objc private func scanButtonTapped(){
        museManager.startListening()
        contentView.tableView.reloadData()
        logMuse(str: "Scanning Started")
    }
    
    @objc private func stopScanButtonTapped(){
        museManager.stopListening()
        contentView.tableView.reloadData()
        logMuse(str: "Scanning Stopped")

    }
    
    
    private func connectMuse(){
        if let selectedMuse {
            
            // Setup listening to connection state
            selectedMuse.register(self)
            
            
            selectedMuse.register(self, type: .artifacts)
            
            
            selectedMuse.register(self, type: .avgBodyTemperature)
            
            
            selectedMuse.register(self, type: .alphaAbsolute)
            
            
            selectedMuse.register(self, type: .betaAbsolute)
            
            selectedMuse.runAsynchronously()
        }
    }
    
    
    private func logMuse(str: String){
        logs.insert(str, at: 0)
        
        DispatchQueue.main.async {
            self.contentView.textView.text = self.logs.joined(separator: "\n")
        }
    }
    
    private func configureMuseManager(){
        museManager.museListener = self
    }
    
    private func configureBluetoothManager(){
        
        bluetoothManager.delegate = self
        
    }
    
    private func configureLogManager(){
        IXNLogManager.instance()?.setLogListener(self)
    }
    
    /// Configure the table view
    private func configureTableView() {
        /// Register the character table view cell class
        contentView.tableView.register(UITableViewCell.self, forCellReuseIdentifier: ViewController.CELLREUSEID)

        
        /// Set the table view datasource to self
        /// so we can populate the tableview
        contentView.tableView.dataSource = self
        
        /// Set the table view delegate to self
        /// so tap gestures on tableview rows can be listened to
        contentView.tableView.delegate = self
    }
    
    private func configureButtonTapGestures(){
        
        contentView.disconnectButton.addTarget(self, action: #selector(disconnectButtonTapped), for: .touchUpInside)
        contentView.scanButton.addTarget(self, action: #selector(scanButtonTapped), for: .touchUpInside)
        contentView.stopScanButton.addTarget(self, action: #selector(stopScanButtonTapped), for: .touchUpInside)
        
    }


}

extension ViewController : UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return museManager.getMuses().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: ViewController.CELLREUSEID)
        
        
        let muses = museManager.getMuses()
        
        if indexPath.row < muses.count{
            
            let muse = muses[indexPath.row]
            cell?.textLabel?.text = "\(muse.getName()) - V\(muse.getModel().rawValue)"
            
        }
        
        return cell ?? UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let muses = museManager.getMuses()
        
        if indexPath.row < muses.count{
            
            let muse = muses[indexPath.row]
            
            selectedMuse?.disconnect()
            selectedMuse = muse
            
            connectMuse()
            
            self.logMuse(str: "======Choose to connect muse \(muse.getName()) \(muse.getMacAddress())======\n")
            
        }
        
    }
    
    
}

extension ViewController : CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        btState = central.state == .poweredOn ? true : false
        
    }
    
    
}


// MARK:- MUSE Callbacks

extension ViewController : IXNMuseListener, IXNMuseConnectionListener, IXNMuseDataListener, IXNLogListener {
    
    
    func receive(_ packet: IXNMuseDataPacket?, muse: IXNMuse?) {
        
        if packet?.packetType() == .alphaAbsolute{
            
           let alphaValStr =  String(format: "%5.2f %5.2f %5.2f %5.2f", packet?.values()[IXNEeg.EEG1.rawValue].doubleValue ?? 0.0,
                   packet?.values()[IXNEeg.EEG2.rawValue].doubleValue ?? 0.0,
                   packet?.values()[IXNEeg.EEG3.rawValue].doubleValue ?? 0.0,
                   packet?.values()[IXNEeg.EEG4.rawValue].doubleValue ?? 0.0)
            
            logMuse(str: alphaValStr)
        }else if packet?.packetType() == .avgBodyTemperature {
            
            
            logMuse(str: "Body Temp: \(packet?.values())")
            
        }
        
    }
    
    
    
    func receive(_ packet: IXNMuseArtifactPacket, muse: IXNMuse?) {
        
        
       // if detectAgain {
            
           // DispatchQueue.main.asyncAfter(deadline: .now() + 1){
               
            //    self.detectAgain = false


                
            //}
            
            
            if packet.blink && packet.blink != lastBlink {
                print("Blink Detected: \(packet.blink)")
                logMuse(str: "Blink Detected: \(packet.blink)")
            
            } else if packet.jawClench && packet.jawClench != self.lastJawClench {
                print("Jaw Clench Detected: \(packet.jawClench)")
                logMuse(str: "Jaw Clench Detected: \(packet.jawClench)")
            }
            

            
            self.lastBlink = packet.blink
            self.lastJawClench = packet.jawClench
 
            
       // }
        

        
    }
    
    
    
    func receive(_ packet: IXNMuseConnectionPacket, muse: IXNMuse?) {
     
        var currentState = ""
        switch packet.currentConnectionState{
            
        case .unknown:
            currentState = "Unknown"
        case .connected:
            currentState = "Connected"

        case .connecting:
            currentState = "Connecting"

        case .disconnected:
            currentState = "Disconnected"

        case .needsUpdate:
            currentState = "Needs update"

        case .needsLicense:
            currentState = "Needs license"

        @unknown default:
            currentState = "Impossible connection state"
        }
        
        logMuse(str: "connect: \(currentState)")
        
    }
    
    
    func museListChanged() {
        contentView.tableView.reloadData()
    }
    
    
    func receiveLog(_ log: IXNLogPacket) {
        let str = String(format: "%@: %f raw:%d %@", log.tag, log.timestamp, log.raw, log.message)
        logMuse(str: str)
    }
    
    
}



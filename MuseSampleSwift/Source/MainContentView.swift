//
//  MainView.swift
//  MuseSampleSwift
//
//  Created by Ahmer Mughal on 21.12.23.
//

import UIKit


class MainContentView: UIView{
    
    // MARK: UI Elements
    let tableView = UITableView()
    let disconnectButton = UIButton()
    let scanButton = UIButton()
    let stopScanButton = UIButton()
    let textView = UITextView()
    
    
    // MARK: Init Functions
    /// Initialize the view
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        /// Setup the view
        setupView()
        
        /// Setup the table view
        setupTableView()
        
        setupTextView()
        
        setupButtons()
        
        /// Layout the UI elements
        layoutUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: Private Functions
    /// Setup the view
    private func setupView() {
        /// Additional view setup can be done here if needed
    }
    
    /// Setup the table view
    private func setupTableView() {
        /// Set the background color of the table view to clear
        tableView.backgroundColor = .clear
    }
    
    private func setupTextView(){
        textView.backgroundColor = .clear
        textView.textColor = .black
    }
    
    private func setupButtons(){
        
        disconnectButton.setTitle("Disconnect", for: .normal)
        disconnectButton.setTitleColor(.systemBlue, for: .normal)
        
        scanButton.setTitle("Scan", for: .normal)
        scanButton.setTitleColor(.systemBlue, for: .normal)

        stopScanButton.setTitle("Stop Scan", for: .normal)
        stopScanButton.setTitleColor(.systemBlue, for: .normal)


    }
    
    
    /// Layout the UI elements
    private func layoutUI() {
        let views = [tableView, disconnectButton, scanButton, stopScanButton, textView]
        
        for view in views {
            view.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(view)
        }
        
        NSLayoutConstraint.activate([
            /// Set constraints to position the table view to cover the entire safe area of the view
            tableView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8),
            tableView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -8),
            tableView.heightAnchor.constraint(equalToConstant: 150),
            
            disconnectButton.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 8),
            disconnectButton.leadingAnchor.constraint(equalTo: tableView.leadingAnchor),

            scanButton.topAnchor.constraint(equalTo: disconnectButton.topAnchor),
            scanButton.centerXAnchor.constraint(equalTo: tableView.centerXAnchor),
            
            stopScanButton.topAnchor.constraint(equalTo: disconnectButton.topAnchor),
            stopScanButton.trailingAnchor.constraint(equalTo: tableView.trailingAnchor),
            
            textView.topAnchor.constraint(equalTo: disconnectButton.bottomAnchor, constant: 8),
            textView.leadingAnchor.constraint(equalTo: tableView.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: tableView.trailingAnchor),
            textView.bottomAnchor.constraint(equalTo: self.bottomAnchor)


        ])
    }
    
}

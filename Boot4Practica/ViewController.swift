//
//  ViewController.swift
//  Boot4Practica
//
//  Created by Juan Antonio Martin Noguera on 21/03/2017.
//  Copyright © 2017 COM. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var acount: AZSCloudStorageAccount!
    var blobClient: AZSCloudBlobClient!
    var model: [Any] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    
        setupAzureStorageConnect()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "VerContainer" {
            let vc = segue.destination as! ContainerBrowser
            vc.blobClient = blobClient
            vc.nameCurrentContainer = (sender as! AZSCloudBlobContainer).name
        }
    }
    
    @IBAction func addNewConatiner(_ sender: Any) {
        let containerRef =  blobClient.containerReference(fromName: "ejemplo1")
        
        containerRef.createContainerIfNotExists(with: .container, requestOptions: nil, operationContext: nil) { (error, noExits) in
            if let _ = error {
                print("\(error?.localizedDescription)")
                return
            }
            
            if noExits {
                self.readAllContainers()
            }
        
        }
        
    }
    
    func setupAzureStorageConnect() {

        // SECURITY FIX: Azure Storage credentials must not be hardcoded in source code.
        // Load from Info.plist, environment variable, or a secure keychain at runtime.
        guard let accountName = Bundle.main.object(forInfoDictionaryKey: "AZS_ACCOUNT_NAME") as? String,
              let accountKey = Bundle.main.object(forInfoDictionaryKey: "AZS_ACCOUNT_KEY") as? String else {
            print("ERROR: Azure Storage credentials not configured in Info.plist")
            return
        }
        let credetials = AZSStorageCredentials(accountName: accountName, accountKey: accountKey)
        do {
            acount = try AZSCloudStorageAccount(credentials: credetials, useHttps: true)
            blobClient = acount.getBlobClient()
            readAllContainers()
            
        } catch let error {
            print("\(error.localizedDescription)")
        }
    }
    
    fileprivate func readAllContainers() {
        blobClient.listContainersSegmented(with: nil,
                                           prefix: nil,
                                           containerListingDetails: AZSContainerListingDetails.all,
                                           maxResults: -1,
                                           completionHandler: { (error, containersResults) in
                                            
                                            if let _ = error {
                                                print("\(error?.localizedDescription)")
                                                return
                                            }
                                            
                                            
                                            self.model = (containersResults?.results)!
                                            
                                            DispatchQueue.main.async {
                                                self.tableView.reloadData()
                                            }
        
        
        })

    }


}


extension ViewController {
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Obtener la referencia al Container a consultar
        
        let item = model[indexPath.row] as! AZSCloudBlobContainer
        performSegue(withIdentifier: "VerContainer", sender: item)
        
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if model.isEmpty {
          return 0
        }
        
        return model.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CELDA", for: indexPath)
        
        let item = model[indexPath.row] as! AZSCloudBlobContainer
        
        cell.textLabel?.text = item.name
        
        return cell
    }
}
























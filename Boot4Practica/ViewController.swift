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

        // SECURITY: Azure Storage credentials must NOT be hardcoded/committed to source
        // control. Provide them at runtime via environment variables (e.g. set
        // AZURE_STORAGE_ACCOUNT_NAME / AZURE_STORAGE_ACCOUNT_KEY in the Xcode scheme's
        // "Environment Variables", which are not stored in this file) or another secret
        // store, and keep them out of git.
        //
        // NOTE: a real Azure Storage account key was previously committed in this file
        // (git history). That key is exposed and MUST be rotated/regenerated from the
        // Azure Portal even though it has been removed here.
        let env = ProcessInfo.processInfo.environment
        guard let accountName = env["AZURE_STORAGE_ACCOUNT_NAME"],
              let accountKey = env["AZURE_STORAGE_ACCOUNT_KEY"] else {
            print("Azure Storage credentials not configured. Set AZURE_STORAGE_ACCOUNT_NAME and AZURE_STORAGE_ACCOUNT_KEY environment variables.")
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
























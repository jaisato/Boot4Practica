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
        // setupAzureStorageConnect() returns without building a client when the
        // credentials are missing, and blobClient is implicitly unwrapped. The
        // button stays tappable, so on a fresh checkout this crashed the app
        // instead of leaving the configuration error on the console where the
        // guard above put it.
        guard let blobClient = blobClient else {
            print("Azure Storage is not configured, so there is nothing to create a container on. "
                + "See SECURITY.md.")
            return
        }

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
    
    /// Reads a value from Info.plist, letting an environment variable of the
    /// same name win. The scheme's environment is the convenient place to put a
    /// key while developing; the plist entry is what a build uses.
    fileprivate func configurationValue(_ key: String) -> String? {
        if let fromEnvironment = ProcessInfo.processInfo.environment[key], !fromEnvironment.isEmpty {
            return fromEnvironment
        }

        guard let fromPlist = Bundle.main.object(forInfoDictionaryKey: key) as? String,
              !fromPlist.isEmpty,
              !fromPlist.hasPrefix("$(") else {
            return nil
        }

        return fromPlist
    }

    func setupAzureStorageConnect() {

        // The account name and key used to be literals right here. An Azure
        // Storage account key is not a client credential: it grants full read,
        // write and delete over every container in the account, and this file
        // is in a public repository, so the key that was here has to be treated
        // as compromised and rotated in the Azure portal. Removing it from the
        // source does not unpublish it - it stays in the git history.
        //
        // Note that a key shipped inside an app bundle is extractable whatever
        // holds it; the right long-term answer is a SAS token issued by a
        // backend. This at least keeps it out of version control.
        guard let accountName = configurationValue("AZURE_STORAGE_ACCOUNT_NAME"),
              let accountKey = configurationValue("AZURE_STORAGE_ACCOUNT_KEY") else {
            // A plain string literal, not a """ block: this target is Swift 3,
            // which has no multi-line string literals.
            print("Missing Azure Storage credentials. Set AZURE_STORAGE_ACCOUNT_NAME and "
                + "AZURE_STORAGE_ACCOUNT_KEY in the scheme's environment, or as Info.plist "
                + "entries fed from a build setting.")
            return
        }

        let credentials = AZSStorageCredentials(accountName: accountName, accountKey: accountKey)
        do {
            acount = try AZSCloudStorageAccount(credentials: credentials, useHttps: true)
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
























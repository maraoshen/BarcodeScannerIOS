//
//  itemViewController.swift
//  view trial2
//
//  Created by mara shen on 2/7/15.
//  Copyright (c) 2015 mara shen. All rights reserved.
//

import UIKit

class itemViewController: UIViewController {

    @IBOutlet weak var message: UILabel!
    var barcodeStr = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        println("Barcode Found. Bar code is: \(barcodeStr)")
        message.text = "Barcode Found. Bar code is: \(barcodeStr)"
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

//
//  ViewController.swift
//  Example
//
//  Created by Ihab yasser on 13/11/2023.
//

import UIKit
import EYContactsPicker

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        var theme = PickerTheme()
        theme.tintColor = .green
        let vc = PickContactsViewController(title: "test", description: "test description", pickerType: .list, country: .all , totalSelection: 100, theme: theme ,  isRTL: false) { contacts in
            for conatact in contacts {
                print(conatact.name ?? "")
                print(conatact.phoneNumber)
            }
        }
        self.present(vc, animated: true)
    }


}


//
//  ViewController.swift
//  SwiftCircularSlider
//
//  Created by Admin on 17.07.15.
//  Copyright (c) 2015 tarasova_aa. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var circularSlider: UICircularSlider!
    
    @IBOutlet var label: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        circularSlider.addTarget(self, action: "circularSliderValueChanged:", forControlEvents: .ValueChanged)
        circularSlider.value = circularSlider.minimumValue
        updateLabel()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func circularSliderValueChanged(sender: UICircularSlider) {
        updateLabel()
    }

    @IBAction func generateRandomValue(sender: AnyObject) {
        let arc4randoMax:Double = 0x100000000
        let upper = circularSlider.maximumValue
        let lower = Float(circularSlider.minimumValue)

        var r = Float((Double(arc4random()) / arc4randoMax)) 
        r = r*(upper - lower) + lower
        circularSlider.setValue(Float(Int(r)), animated: true)
        
        updateLabel()
        
    }
    func updateLabel() {
        label.text = NSNumberFormatter.localizedStringFromNumber(circularSlider.value, numberStyle: .DecimalStyle)
    }

}


//
//  MaxMin.swift
//  Final Project Part 3
//
//  Created by IIT PHYS 440 on 9/15/23.
//

import Foundation


func getMin(value1:[Double]) -> (Double) {
    
    var min = 1E56
   
    
    for item in value1 {
        
        if item == 0 {}
        else if (item < min) {
            min = item
        }
        
        
    }
    
    return min
    
    
}

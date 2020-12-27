//
//  GenderModel.swift
//  Clima
//
//  Created by 김우성 on 2020/12/27.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import Foundation

struct GenderModel {
    let gender: String
    
    var genderImage: String {
        switch gender {
        case "male":
            return ""
        case "female":
            return ""
        default:
            return ""
        }
    }
}

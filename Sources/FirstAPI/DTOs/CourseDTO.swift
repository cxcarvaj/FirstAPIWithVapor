//
//  CourseDTO.swift
//  FirstAPI
//
//  Created by Carlos Xavier Carvajal Villegas on 15/5/25.
//

import Vapor

struct CourseDTO: Content {
    let id: Int?
    let name: String
    let type: CourseType
    let people: [PersonDTO]?
}


extension Courses {
    var toDTO: CourseDTO {
        CourseDTO(id: id, name: name, type: type, people: nil)
    }
}

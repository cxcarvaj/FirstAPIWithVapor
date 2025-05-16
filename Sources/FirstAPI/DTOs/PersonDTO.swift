//
//  PersonDTO.swift
//  FirstAPI
//
//  Created by Carlos Xavier Carvajal Villegas on 14/5/25.
//

import Vapor

struct PersonDTO: Content {
    let name: String
    let email: String
    let address: String?
    let course: CourseDTO?
}

extension Person {
    var toDTO: PersonDTO {
        PersonDTO(name: name, email: email, address: address, course: course?.toDTO)
    }
}

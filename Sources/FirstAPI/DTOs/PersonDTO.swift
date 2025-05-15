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
}

//
//  WebDTO.swift
//  FirstAPI
//
//  Created by Carlos Xavier Carvajal Villegas on 16/5/25.
//

import Foundation

struct PeopleWeb: Encodable {
    let title: String
    let people: [PersonWebDTO]
}

struct PersonWeb: Encodable {
    let title: String
    let person: PersonWebDTO
    var error: String? = nil
}

struct PersonWebDTO: Codable {
    let id: UUID?
    let name: String
    let email: String
    let address: String?
}

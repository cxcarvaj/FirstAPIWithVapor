//
//  RegistrationDTO.swift
//  FirstAPI
//
//  Created by Carlos Xavier Carvajal Villegas on 15/5/25.
//

import Vapor

struct RegistrationDTO: Content {
    let id: Int
    let email: String
}

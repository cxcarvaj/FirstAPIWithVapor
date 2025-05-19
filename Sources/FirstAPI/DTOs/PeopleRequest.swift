//
//  PeopleRequest.swift
//  FirstAPI
//
//  Created by Carlos Xavier Carvajal Villegas on 16/5/25.
//

import Vapor

struct PeopleForProject: Content {
    let project: String
    let emails: [String]
}

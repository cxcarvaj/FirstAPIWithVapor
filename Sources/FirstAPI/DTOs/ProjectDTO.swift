//
//  ProjectDTO.swift
//  FirstAPI
//
//  Created by Carlos Xavier Carvajal Villegas on 15/5/25.
//

import Vapor

struct ProjectDTO: Content {
    var id: UUID?
    let name: String
    let summary: String?
    let type: ProjectType
}


extension Projects {
    var toDTO: ProjectDTO {
        ProjectDTO(id: nil, name: name, summary: summary, type: type)
    }
}

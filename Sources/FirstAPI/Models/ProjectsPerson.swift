//
//  ProjectsPerson.swift
//  FirstAPI
//
//  Created by Carlos Xavier Carvajal Villegas on 16/5/25.
//

import Vapor
import Fluent

final class ProjectsPerson: Model, Content, @unchecked Sendable {
    static let schema = "projects_person"
    
    @ID(key: .id) var id: UUID?
    @Parent(key: "person") var person: Person
    @Parent(key: "project") var project: Projects
    
    init() {}
    
    init(id: UUID? = nil, person: Person, project: Projects) throws {
        self.id = id
        self.$project.id = try project.requireID()
        self.$person.id = try person.requireID()

    }
}

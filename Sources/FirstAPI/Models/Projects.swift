//
//  Projects.swift
//  FirstAPI
//
//  Created by Carlos Xavier Carvajal Villegas on 15/5/25.
//

import Vapor
import Fluent

enum ProjectType: String, Codable {
    case design, frontend, backend, mobile, none
}

final class Projects: Model, Content, @unchecked Sendable {
    static let schema = "projects"
    
    @ID(key: .id) var id: UUID?
    @Field(key: "name") var name: String
    @Field(key: "summary") var summary: String?
    @Enum(key: "type") var type: ProjectType
    
    @Siblings(through: ProjectsPerson.self, from: \.$project, to: \.$person) var people: [Person]
    
    init() { }
    
    init(id: UUID? = nil, name: String, summary: String? = nil, type: ProjectType) {
        self.id = id
        self.name = name
        self.summary = summary
        self.type = type
    }
}

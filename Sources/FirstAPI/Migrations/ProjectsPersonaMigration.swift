//
//  ProjectsPersonaMigration.swift
//  FirstAPI
//
//  Created by Carlos Xavier Carvajal Villegas on 16/5/25.
//

import Vapor
import Fluent

struct ProjectsPersonaMigration: AsyncMigration {
    
    func prepare(on database: any Database) async throws {
        try await database.schema(ProjectsPerson.schema)
            .id()
            .field("person", .uuid, .references(Person.schema, .id), .required)
            .field("project", .uuid, .references(Projects.schema, .id), .required)
            .unique(on: "person", "project")
            .create()
    }
    
    func revert(on database: any Database) async throws {
        try await database.schema(ProjectsPerson.schema)
                   .delete()
    }
}

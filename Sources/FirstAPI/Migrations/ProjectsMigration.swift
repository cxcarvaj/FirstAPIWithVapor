//
//  ProjectsMigration.swift
//  FirstAPI
//
//  Created by Carlos Xavier Carvajal Villegas on 16/5/25.
//

import Vapor
import Fluent

struct ProjectsMigration: AsyncMigration {
    func prepare(on database: any Database) async throws {
        let projectTypes = try await database.enum("project_type")
            .case("design")
            .case("frontend")
            .case("backend")
            .case("mobile")
            .case("none")
            .create()
        
        try await database.schema(Projects.schema)
            .id()
            .field("name", .string, .required)
            .field("summary", .string)
            .field("type", projectTypes, .required, .custom("DEFAULT 'none'"))
            .create()
    }
    
    func revert(on database: any Database) async throws {
        try await database.schema(Projects.schema)
            .delete()
        try await database.enum("project_type")
            .delete()
    }
}

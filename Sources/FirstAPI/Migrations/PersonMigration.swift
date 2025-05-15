//
//  PersonMigration.swift
//  FirstAPI
//
//  Created by Carlos Xavier Carvajal Villegas on 14/5/25.
//

import Vapor
import Fluent

struct PersonMigration: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema(Person.schema)
            .id()
            .field("name", .string, .required)
            .field("email", .string, .required)
            .field("address", .string)
            .unique(on: "email")
            .create()
    }
    
    func revert(on database: any Database) async throws {
        try await database.schema(Person.schema)
            .delete()
    }
}

struct PersonCoursesMigration: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema(Person.schema)
            .field("course", .int, .references(Courses.schema, .id))
            .update()
    }
    
    func revert(on database: any Database) async throws {
        try await database.schema(Person.schema)
            .field("course", .int, .references(Courses.schema, .id))
            .delete()
    }
}

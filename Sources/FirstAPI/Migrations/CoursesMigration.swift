//
//  CoursesMigration.swift
//  FirstAPI
//
//  Created by Carlos Xavier Carvajal Villegas on 15/5/25.
//

import Vapor
import Fluent

//struct EnumMigration: AsyncMigration {
//
//    func prepare(on database: any Database) async throws {
//        let _ = try await database.enum("course_type")
//            .case("smp")
//            .case("sdp")
//            .case("vdp")
//            .case("sap")
//            .create()
//    }
//    
//    func revert(on database: any Database) async throws {
//
//    }
//}


struct CoursesMigration: AsyncMigration {
    func prepare(on database: any Database) async throws {
        let type = try await database.enum("course_type")
            .case("smp")
            .case("sdp")
            .case("vdp")
            .case("sap")
            .create()

        try await database.schema(Courses.schema)
            .field(.id, .int, .identifier(auto: true))
            .field("name", .string, .required)
            .field("type", type, .required)
            .create()
    }
    
    func revert(on database: any Database) async throws {
        try await database.schema(Courses.schema)
            .delete()
        try await database.enum("course_type")
            .delete()
    }
}

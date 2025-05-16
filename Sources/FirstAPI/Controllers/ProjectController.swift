//
//  ProjectController.swift
//  FirstAPI
//
//  Created by Carlos Xavier Carvajal Villegas on 15/5/25.
//

import Vapor
import Fluent

struct ProjectController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let api = routes.grouped("projects")
        api.post("create", use: createProject)
        api.get("getAll", use: getAll)
        api.get("getAllPretty", use: getAllPretty)
        api.put("update", use: updateProject)
        api.delete("delete", use: deleteProject)
        api.get("assignProject", use: assignProject)
    }
    
    func createProject(req: Request) async throws -> HTTPStatus {
            let dto = try req.content.decode(ProjectDTO.self)
            let newProject = Projects(name: dto.name, summary: dto.summary, type: dto.type)
            try await newProject.create(on: req.db)
            return .created
        }
        
        func getAll(req: Request) async throws -> [Projects] {
            try await Projects.query(on: req.db).all()
        }
        
        func getAllPretty(req: Request) async throws -> [ProjectDTO] {
            try await Projects.query(on: req.db).all().map(\.toDTO)
        }
        
        func updateProject(req: Request) async throws -> HTTPStatus {
            let dto = try req.content.decode(ProjectDTO.self)
            guard let project = try await Projects.find(dto.id, on: req.db) else { throw Abort(.notFound) }
            project.name = dto.name
            project.summary = dto.summary
            project.type = dto.type
            try await project.update(on: req.db)
            return .accepted
        }
        
        func deleteProject(req: Request) async throws -> HTTPStatus {
            let dto = try req.content.decode(ProjectDTO.self)
            guard let project = try await Projects.find(dto.id, on: req.db) else { throw Abort(.notFound) }
            try await project.delete(on: req.db)
            return .accepted
        }
        
        func assignProject(req: Request) async throws -> HTTPStatus {
            guard let projectName = req.query[String.self, at: "project"],
                  let personName = req.query[String.self, at: "person"] else {
                throw Abort(.badRequest, reason: "No se ha incluido el parámetro person y project.")
            }
            if let project = try await Projects
                .query(on: req.db)
                .filter(\.$name == projectName)
                .first(),
               let person = try await Person
                   .query(on: req.db)
                   .filter(\.$name == personName)
                   .first() {
                try await project.$people.attach(person, method: .ifNotExists, on: req.db)
            }
            return .accepted
        }
}

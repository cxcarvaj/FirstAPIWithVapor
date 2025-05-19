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
        api.get("deassignProject", use: deassignProject)
        api.get("peopleByProject", use: peopleByProject)
        api.get("peopleByProjectWith", use: peopleByProjectWith)
    }
    
    func createProject(_ req: Request) async throws -> HTTPStatus {
        let dto = try req.content.decode(ProjectDTO.self)
        let newProject = Projects(name: dto.name, summary: dto.summary, type: dto.type)
        try await newProject.create(on: req.db)
        return .created
    }
        
    func getAll(_ req: Request) async throws -> [Projects] {
        try await Projects.query(on: req.db).all()
    }
        
    func getAllPretty(_ req: Request) async throws -> [ProjectDTO] {
        try await Projects.query(on: req.db).all().map(\.toDTO)
    }
        
    func updateProject(_ req: Request) async throws  -> HTTPStatus {
        let dto = try req.content.decode(ProjectDTO.self)
        guard let project = try await Projects.find(dto.id, on: req.db) else { throw Abort(.notFound) }
        project.name = dto.name
        project.summary = dto.summary
        project.type = dto.type
        try await project.update(on: req.db)
        return .accepted
    }
        
    func deleteProject(_ req: Request) async throws  -> HTTPStatus {
        let dto = try req.content.decode(ProjectDTO.self)
        guard let project = try await Projects.find(dto.id, on: req.db) else { throw Abort(.notFound) }
        try await project.delete(on: req.db)
        return .accepted
    }
        
    func assignProject(_ req: Request) async throws -> HTTPStatus {
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
    
    func deassignProject(_ req: Request) async throws -> HTTPStatus {
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
               .first(),
           try await project.$people.isAttached(to: person, on: req.db) {
            try await project.$people.detach(person, on: req.db)
            return .accepted
        } else {
            throw Abort(.notFound, reason: "No existe la asociación entre el proyecto y la persona")
        }
    }
    
    func peopleByProject(_ req: Request) async throws -> [PersonDTO] {
        guard let projectName = req.query[String.self, at: "project"] else {
            throw Abort(.badRequest, reason: "No se ha incluido el parámetro project.")
        }
        
        if let project = try await Projects
            .query(on: req.db)
            .filter(\.$name == projectName)
            .first() {
            return try await project.$people
                .query(on: req.db)
                .all()
                .map(\.toDTO)
        } else {
            throw Abort(.notFound, reason: "No existe el proyecto: \(projectName)")
        }
    }
    
    func peopleByProjectWith(_ req: Request) async throws -> ProjectDTO {
        guard let projectName = req.query[String.self, at: "project"] else {
            throw Abort(.badRequest, reason: "No se ha incluido el parámetro project.")
        }
        
        if let project = try await Projects
            .query(on: req.db)
            .with(\.$people)
            .filter(\.$name == projectName)
            .first() {
            return project.toDTO
        } else {
            throw Abort(.notFound, reason: "No existe el proyecto: \(projectName)")
        }
    }
    
    func assignProjectBatch(_ req: Request) async throws -> HTTPStatus {
        let request = try req.content.decode(PeopleForProject.self)
        if let project = try await Projects
            .query(on: req.db)
            .filter(\.$name == request.project)
            .first() {
            try await req.db.transaction { db in
                for email in request.emails {
                    if let person = try await Person.query(on: db)
                        .filter(\.$email == email)
                        .first() {
                            try await project.$people.attach(person, method: .ifNotExists, on: db)
                        }
                }
            }
            return .accepted
        } else {
            throw Abort(.notFound, reason: "No existe el proyecto: \(request.project)")
        }
    }
    

}

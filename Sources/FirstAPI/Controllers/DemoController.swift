//
//  DemoController.swift
//  FirstAPI
//
//  Created by Carlos Xavier Carvajal Villegas on 14/5/25.
//

import Vapor

struct DemoController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        //        localhost:8080/api/clients
        //        routes.get("api", "clientes")
        let demo = routes.grouped("demo")
        demo.get("hello", use: hello)
        demo.get("greets", use: greets)
        demo.get("greet", use: greet)
        demo.get("whatsup", ":name", use: whatsup)
        demo.get("client", ":id", use: client)
        demo.post("altaCliente", use: altaCliente)
        demo.get("getWallpaper", use: getWallpaper)

    }
    
    func hello(req: Request) throws -> String {
        "Hello World!"
    }
            
    func greets(req: Request) throws -> String {
        guard let nombre = req.query[String.self, at: "name"] else {
            throw Abort(.badRequest, reason: "Tha 'name' is missing")
        }
        return "Hello \(nombre)"
    }
            
    func greet(req: Request) throws -> String {
        if let name = req.query[String.self, at: "name"] {
            "Hola \(name)"
        } else {
            "Hello"
        }
    }
            
    func whatsup(req: Request) throws -> String {
        let name = try req.parameters.require("name")
        return "What's up \(name)?"
    }
            
    func client(req: Request) throws -> String {
        guard let id = req.parameters.get("id", as: Int.self) else {
            throw Abort(
                .badRequest,
                reason: "The id number parameter is required"
            )
        }
                
        return "Client: \(id)"
    }
            
    func altaCliente(req: Request) throws -> String {
        let content = try req.content.decode(ClienteAlta.self)
        return "Alta de cliente con ID: \(content.id) y nombre: \(content.name)"
    }
    
    func getWallpaper(req: Request) async throws -> Response {
        guard let wallpaperNum = req.query[Int.self, at: "id"] else {
            throw Abort(.badRequest, reason: "There is no id in the params")
        }
        //URI se usa para rutas del disco, no para URL's
//        let uri = URI(string: req.application.directory.workingDirectory + "Images/vapor\(wallpaperNum.formatted(.number.precision(.integerLength(2)))).png")
        let basePath = req.application.directory.workingDirectory
        let fileName = "vapor\(wallpaperNum.formatted(.number.precision(.integerLength(2)))).png"
        let url = URL(fileURLWithPath: basePath)
            .appendingPathComponent("Images")
            .appendingPathComponent(fileName)
        
        if FileManager.default.fileExists(atPath: url.path) {
            return try await req.fileio.asyncStreamFile(at: url.path, mediaType: .png)
        } else {
            throw Abort(.notFound, reason: "There is no wallpaper with id: \(wallpaperNum)")
        }
    }
}

// Content es lo mismo que Codable en Vapor
struct ClienteAlta: Content {
    let id: Int
    let name: String
}

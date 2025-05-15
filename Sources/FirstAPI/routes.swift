import Fluent
import Vapor

func routes(_ app: Application) throws {
    try app.routes.register(collection: DemoController())
    try app.routes.register(collection: PeopleController())
}

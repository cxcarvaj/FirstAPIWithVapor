import Fluent
import Vapor

func routes(_ app: Application) throws {
    try app.routes.register(collection: DemoController())
    try app.routes.register(collection: PersonController())
    try app.routes.register(collection: CoursesController())
    try app.routes.register(collection: ProjectController())
}

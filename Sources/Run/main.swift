import App
import Vapor

var env = try Environment.detect()

guard Environment.get("POCKETBASE_HOST") != nil else {
    fatalError("Pocketbase host not found")
}

try LoggingSystem.bootstrap(from: &env)
let app = Application(env)
defer { app.shutdown() }
try configure(app)
try app.run()

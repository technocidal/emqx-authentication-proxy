import Vapor

func routes(_ app: Application) throws {
    
    struct AuthRequest: Content {
        let identity: String
        let password: String
    }
    
    struct AuthResponse: Content {
        let result: String
        let isSuperuser: Bool
        
        enum CodingKeys: String, CodingKey {
            case result, isSuperuser = "is_superuser"
        }
    }
    
    app.post("authenticate") { req async throws -> AuthResponse in
        guard let pocketbaseHost = Environment.get("POCKETBASE_HOST") else {
            throw Abort(.internalServerError)
        }
        
        let credentials = try req.content.decode(AuthRequest.self)
        let pocketbase = URI("\(pocketbaseHost)/api/collections/users/auth-with-password")
        let pocketbaseResponse = try await req.client.post(
            pocketbase,
            headers: [
                "Content-Type": "application/json"
            ],
            content: credentials
        )
        
        req.logger.info("Pocketbase responded with \(pocketbaseResponse)")
        
        if pocketbaseResponse.status == .ok {
            return AuthResponse(result: "allow", isSuperuser: false)
        } else {
            return AuthResponse(result: "ignore", isSuperuser: false)
        }
    }
}

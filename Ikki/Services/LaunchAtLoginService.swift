import Foundation
import ServiceManagement

final class LaunchAtLoginService {
    static let shared = LaunchAtLoginService()
    
    private let service = SMAppService.mainApp

    var isEnabled: Bool {
        return service.status == .enabled
    }

    func enable() throws {
        try service.register()
    }

    func disable() throws {
        try service.unregister()
    }
}

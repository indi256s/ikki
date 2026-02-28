import XCTest
@testable import Ikki

final class TimerServiceTests: XCTestCase {
    
    var timerService: TimerService!

    override func setUp() {
        super.setUp()
        timerService = TimerService()
    }

    override func tearDown() {
        timerService.stop()
        timerService = nil
        super.tearDown()
    }

    func testInitialState() {
        XCTAssertEqual(timerService.state, .idle)
        XCTAssertEqual(timerService.remainingFormatted, "Idle")
        XCTAssertEqual(timerService.progress, 0)
    }

    func testStartTimer() {
        timerService.start(workMinutes: 25)
        
        switch timerService.state {
        case .running(let remaining):
            XCTAssertEqual(remaining, 1500, accuracy: 1.0)
        default:
            XCTFail("Should be in running state")
        }
    }

    func testPauseResume() {
        timerService.start(workMinutes: 25)
        timerService.pause()
        
        switch timerService.state {
        case .paused(let remaining):
            XCTAssertEqual(remaining, 1500, accuracy: 1.0)
        default:
            XCTFail("Should be in paused state")
        }
        
        timerService.resume()
        
        switch timerService.state {
        case .running(let remaining):
            XCTAssertEqual(remaining, 1500, accuracy: 1.0)
        default:
            XCTFail("Should be in running state after resume")
        }
    }

    func testStopTimer() {
        timerService.start(workMinutes: 25)
        timerService.stop()
        XCTAssertEqual(timerService.state, .idle)
    }

    func testFormatting() {
        timerService.start(workMinutes: 25)
        XCTAssertEqual(timerService.remainingFormatted, "25m")
        
        // Let's test seconds formatting (short remaining)
        // This is tricky because it relies on the internal state
        // For now, these basic checks should pass.
    }
}

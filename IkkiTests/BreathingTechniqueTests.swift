import XCTest
@testable import Ikki

final class BreathingTechniqueTests: XCTestCase {

    func testPhaseCalculations() {
        let cyclicSighing = BreathingTechnique.cyclicSighing
        
        // Cyclic Sighing: Inhale (3.5), Hold (0.5), Exhale (6.0)
        let phases = cyclicSighing.phases
        XCTAssertEqual(phases.count, 3)
        XCTAssertEqual(phases[0].label, "INHALE")
        XCTAssertEqual(phases[0].duration, 3.5)
        XCTAssertEqual(phases[1].label, "HOLD")
        XCTAssertEqual(phases[1].duration, 0.5)
        XCTAssertEqual(phases[2].label, "EXHALE")
        XCTAssertEqual(phases[2].duration, 6.0)
    }

    func testTotalDurationCalculation() {
        let cyclicSighing = BreathingTechnique.cyclicSighing
        // (3.5 + 0.5 + 6.0) * 10 = 100 seconds
        XCTAssertEqual(cyclicSighing.totalDurationSeconds, 100)
    }

    func testAllCasesHavePhases() {
        for technique in BreathingTechnique.allCases {
            XCTAssertFalse(technique.phases.isEmpty, "\(technique.displayName) should have at least one phase.")
            XCTAssertTrue(technique.totalDurationSeconds > 0, "\(technique.displayName) should have a positive duration.")
        }
    }
}

import XCTest
@testable import WordPress

final class JetpackBrandingTextProviderTests: XCTestCase {

    // MARK: Private Variables

    private var remoteFeatureFlagsStore: RemoteFeatureFlagStoreMock!
    private var remoteConfigStore = RemoteConfigStoreMock()
    private var currentDateProvider: MockCurrentDateProvider!
    private var removalDeadline: Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: "2022-10-10") ?? Date()
    }

    // MARK: Setup

    override func setUp() {
        remoteFeatureFlagsStore = RemoteFeatureFlagStoreMock()
        currentDateProvider = MockCurrentDateProvider()
        remoteConfigStore.removalDeadline = "2022-10-10"
    }

    // MARK: Tests

    func testNormalPhaseText() {
        // Given
        let provider = JetpackBrandingTextProvider(screen: MockBrandedScreen.defaultScreen, featureFlagStore: remoteFeatureFlagsStore)

        // When
        let text = provider.brandingText()

        // Then
        XCTAssertEqual(text, "Jetpack powered")
    }

    func testPhaseOneText() {
        // Given
        let provider = JetpackBrandingTextProvider(screen: MockBrandedScreen.defaultScreen, featureFlagStore: remoteFeatureFlagsStore)
        remoteFeatureFlagsStore.removalPhaseOne = true

        // When
        let text = provider.brandingText()

        // Then
        XCTAssertEqual(text, "Jetpack powered")
    }

    func testPhaseTwoText() {
        // Given
        let provider = JetpackBrandingTextProvider(screen: MockBrandedScreen.defaultScreen, featureFlagStore: remoteFeatureFlagsStore)
        remoteFeatureFlagsStore.removalPhaseTwo = true

        // When
        let text = provider.brandingText()

        // Then
        XCTAssertEqual(text, "Get the Jetpack app")
    }

    func testDefaultText() {
        // Given
        let provider = JetpackBrandingTextProvider(screen: MockBrandedScreen.defaultScreen, featureFlagStore: remoteFeatureFlagsStore)
        remoteFeatureFlagsStore.removalPhaseFour = true

        // When
        let text = provider.brandingText()

        // Then
        XCTAssertEqual(text, "Jetpack powered")
    }
}

// MARK: Helpers

private extension JetpackBrandingTextProviderTests {
    struct MockBrandedScreen: JetpackBrandedScreen {
        let featureName: String?
        let isPlural: Bool
        let analyticsId: String

        static var defaultScreen: MockBrandedScreen = .init(featureName: "Feature",
                                                            isPlural: false,
                                                            analyticsId: "")
    }

    enum Constants {
        static let secondsInDay = 86_400
    }

    private func dateBefore(_ date: Date,
                            months: Int = 0,
                            weeks: Int = 0,
                            days: Int = 0) -> Date {
        let calendar = Calendar.current
        let components = DateComponents(month: -months, day: -days, second: -1, weekOfYear: -weeks)
        let newDate = calendar.date(byAdding: components, to: date)
        return newDate ?? date
    }
}

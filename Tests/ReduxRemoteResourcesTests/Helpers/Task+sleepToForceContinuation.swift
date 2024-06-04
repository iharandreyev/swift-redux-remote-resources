import Foundation

extension Task where Success == Never, Failure == Never {
    /// Sleeps for 5ms to force asyncrony.
    ///
    /// - Discussion:
    /// Useful for reducer tests, since TCA runs reducers on the main thread. If there is no delay, all effects run one-by-one, an it's impossible to cancel running effect.
    @inline(__always)
    static func sleepToForceContinuation() async throws {
        try await sleep(nanoseconds: 1_000_000 * 5)
    }
}

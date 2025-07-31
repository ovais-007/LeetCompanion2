//
//  LeetCodeViewModel.swift
//  LeetCodeStats
//

import Foundation
import AppKit
import UserNotifications

// MARK: - Public models

struct Contest: Decodable {
    let title: String
    let startTime: Date

    // Manual initializer
    init(title: String, startTime: Date) {
        self.title = title
        self.startTime = startTime
    }

    private enum CodingKeys: String, CodingKey { case title, startTime }
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        title = try c.decode(String.self, forKey: .title)
        let ts = try c.decode(Double.self, forKey: .startTime)
        startTime = Date(timeIntervalSince1970: ts)
    }
}

struct DailyProblem {
    let title: String
    let url: URL
}

// MARK: - ViewModel

@MainActor
final class LeetCodeViewModel: ObservableObject {
    // Published Values
    @Published var username = "(loading…)"
    @Published var ranking: Int?
    @Published var totalSolved = 0
    @Published var easySolved = 0
    @Published var midSolved = 0
    @Published var hardSolved = 0
    @Published var nextContest: Contest?
    @Published var today: DailyProblem?

    // Entry point
    func load() async {
        // Keychain.delete() // Uncomment for testing

        guard let cookie = obtainCookie() else { return }

        do {
            username = try await fetchUsername(with: cookie)

            let stats = try await fetchStats(with: cookie)
            try await Task.sleep(nanoseconds: 1_000_000_000)

            let contest = try await fetchNextContest(with: cookie)
            try await Task.sleep(nanoseconds: 1_000_000_000)

            let daily = try await fetchDaily(with: cookie)

            apply(stats: stats)
            nextContest = contest
            today = daily
            scheduleNotification(for: contest)
        } catch {
            print("LeetCode fetch error:", error)
            username = "(error - check console)"
        }
    }

    private func obtainCookie() -> String? {
        print("🔍 Starting cookie search...")

        if let c = Keychain.read() {
            print("✅ Found cookie in Keychain: \(c.prefix(20))...")
            return c
        }

        if let c = browserCookie() {
            print("✅ Found cookie in browser: \(c.prefix(20))...")
            Keychain.save(token: c)
            return c
        }

        print("🔍 Prompting for cookie...")
        var token: String? = nil
        Task { token = await promptForCookie() }
        RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.1))

        if let token = token {
            print("✅ Got token from manual prompt: \(token.prefix(20))...")
            return token
        }

        print("❌ No token from manual prompt")
        return nil
    }

    private func browserCookie() -> String? {
        let url = URL(string: "https://leetcode.com")!
        let cookies = HTTPCookieStorage.shared.cookies(for: url) ?? []
        print("🍪 Total cookies for leetcode.com: \(cookies.count)")
        return cookies.first(where: { $0.name == "LEETCODE_SESSION" })?.value
    }
}

// MARK: - Networking

private extension LeetCodeViewModel {
    struct UserEnvelope: Decodable {
        struct Status: Decodable { let username: String }
        let userStatus: Status
    }

    struct StatsEnvelope: Decodable {
        struct MatchedUser: Decodable {
            struct SubmitStatsGlobal: Decodable {
                struct AC: Decodable {
                    let difficulty: String
                    let count: Int
                }
                let acSubmissionNum: [AC]
            }
            struct Profile: Decodable {
                let ranking: Int?
            }
            let submitStatsGlobal: SubmitStatsGlobal
            let profile: Profile
        }
        let matchedUser: MatchedUser?
    }

    struct ContestListEnvelope: Decodable {
        let upcomingContests: [Contest]
    }

    struct DailyEnvelope: Decodable {
        struct Active: Decodable {
            struct Q: Decodable { let title: String; let titleSlug: String }
            let question: Q
        }
        let activeDailyCodingChallengeQuestion: Active
    }

    struct AuthenticationError: Error { let description: String }
    struct APIError: Error {
        let description: String
        let statusCode: Int
    }

    func query<R: Decodable>(
        _ type: R.Type,
        body: String,
        cookie: String
    ) async throws -> R {
        var req = URLRequest(url: URL(string: "https://leetcode.com/graphql")!)
        req.httpMethod = "POST"
        req.httpBody = body.data(using: .utf8)
        req.addValue("application/json", forHTTPHeaderField: "Content-Type")
        req.addValue("Mozilla/5.0", forHTTPHeaderField: "User-Agent")
        req.addValue("LEETCODE_SESSION=\(cookie)", forHTTPHeaderField: "Cookie")
        req.addValue("https://leetcode.com", forHTTPHeaderField: "Referer")

        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        let session = URLSession(configuration: config)

        let (data, response) = try await session.data(for: req)

        if let httpResponse = response as? HTTPURLResponse {
            print("🔍 HTTP Status Code: \(httpResponse.statusCode)")
            if httpResponse.statusCode != 200 {
                throw APIError(description: "HTTP \(httpResponse.statusCode)", statusCode: httpResponse.statusCode)
            }
        }

        if let responseString = String( data:data, encoding: .utf8) {
            print("🔍 Raw API Response:", responseString.prefix(500))
            if responseString.trimmingCharacters(in: .whitespacesAndNewlines).hasPrefix("<") {
                throw AuthenticationError(description: "Received HTML instead of JSON — login cookie likely expired")
            }
        }

        let result = try JSONDecoder().decode(GraphQLRoot<R>.self, from: data)
        return result.data
    }

    func fetchUsername(with cookie: String) async throws -> String {
        let gql = #"{"query":"{ userStatus { username } }"}"#
        let result = try await query(UserEnvelope.self, body: gql, cookie: cookie)
        return result.userStatus.username
    }

    func fetchStats(with cookie: String) async throws -> StatsEnvelope {
        let escapedUsername = username.replacingOccurrences(of: "\"", with: "\\\"")
        let gql = #"{"query":"{ matchedUser(username:\"\#(escapedUsername)\") { submitStatsGlobal { acSubmissionNum { difficulty count } } profile { ranking } } }"}"#
        return try await query(StatsEnvelope.self, body: gql, cookie: cookie)
    }

    func fetchNextContest(with cookie: String) async throws -> Contest {
        let gql = #"{"query":"{ upcomingContests { title startTime } }"}"#
        let result = try await query(ContestListEnvelope.self, body: gql, cookie: cookie)
        return result.upcomingContests.first ?? Contest(title: "No upcoming contest", startTime: Date())
    }

    func fetchDaily(with cookie: String) async throws -> DailyProblem {
        let gql = #"{"query":"{ activeDailyCodingChallengeQuestion { question { title titleSlug } } }"}"#
        let result = try await query(DailyEnvelope.self, body: gql, cookie: cookie)
        let q = result.activeDailyCodingChallengeQuestion.question
        return DailyProblem(title: q.title, url: URL(string: "https://leetcode.com/problems/\(q.titleSlug)")!)
    }
}

// MARK: - Data binding & notification

private extension LeetCodeViewModel {
    func apply(stats env: StatsEnvelope) {
        guard let user = env.matchedUser else { return }
        let stats = user.submitStatsGlobal.acSubmissionNum.reduce(into: [String: Int]()) {
            $0[$1.difficulty.lowercased()] = $1.count
        }

        ranking = user.profile.ranking
        easySolved = stats["easy"] ?? 0
        midSolved = stats["medium"] ?? 0
        hardSolved = stats["hard"] ?? 0
        totalSolved = stats["all"] ?? 0
    }

    func scheduleNotification(for contest: Contest?) {
        guard let contest else { return }

        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { granted, _ in
            guard granted else { return }

            center.removePendingNotificationRequests(withIdentifiers: ["contest-reminder"])

            let content = UNMutableNotificationContent()
            content.title = "LeetCode Contest Reminder"
            content.body = "\(contest.title) starts in 15 minutes"

            let fireDate = Calendar.current.date(byAdding: .minute, value: -15, to: contest.startTime) ?? contest.startTime
            let comps = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: fireDate)

            let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)

            let request = UNNotificationRequest(identifier: "contest-reminder", content: content, trigger: trigger)
            center.add(request)
        }
    }
}

// MARK: - Manual cookie prompt

@MainActor
extension LeetCodeViewModel {
    func promptForCookie() async -> String? {
        return await withCheckedContinuation { cont in
            let alert = NSAlert()
            alert.messageText = "Paste your LEETCODE_SESSION cookie"
            alert.informativeText = """
            To authenticate, please:
            1. Open leetcode.com and log in
            2. Open Developer Tools → Application → Cookies
            3. Copy the LEETCODE_SESSION cookie value
            """
            alert.addButton(withTitle: "Submit")
            alert.addButton(withTitle: "Cancel")

            let field = NSSecureTextField(frame: NSRect(x: 0, y: 0, width: 300, height: 20))
            field.placeholderString = "Paste LEETCODE_SESSION here"
            alert.accessoryView = field

            let result = alert.runModal()
            let token = field.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)

            if result == .alertFirstButtonReturn && !token.isEmpty {
                Keychain.save(token: token)
                cont.resume(returning: token)
            } else {
                cont.resume(returning: nil)
            }
        }
    }
}


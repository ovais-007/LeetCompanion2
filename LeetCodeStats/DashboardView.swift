import SwiftUI

struct DashboardView: View {
    @StateObject private var viewModel = LeetCodeViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                Text("Leet Companion")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text(viewModel.username)
                    .font(.title2)
                    .foregroundColor(usernameColor)

                if let ranking = viewModel.ranking {
                    Text("Global Ranking: \(ranking.formatted(.number.grouping(.automatic)))")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }

                // Stats Grid
                LazyVGrid(columns: [GridItem(), GridItem()], spacing: 16) {
                    StatsCard(title: "Total", count: viewModel.totalSolved, color: .blue)
                    StatsCard(title: "Easy", count: viewModel.easySolved, color: .green)
                    StatsCard(title: "Medium", count: viewModel.midSolved, color: .orange)
                    StatsCard(title: "Hard", count: viewModel.hardSolved, color: .red)
                }
                .padding(.top)

                // Contest Info
                if let contest = viewModel.nextContest {
                    ContestCard(contest: contest)
                }

                // Daily Challenge
                if let daily = viewModel.today {
                    DailyChallengeCard(problem: daily)
                }

                // Refresh + Quit Buttons
                HStack {
                    Spacer()

                    Button("Quit") {
                        NSApp.terminate(nil)
                    }
                    .foregroundColor(.red)

                    Button {
                        Task { await viewModel.load() }
                    } label: {
                        Label("Refresh", systemImage: "arrow.clockwise")
                    }
                    .buttonStyle(.borderedProminent)
                }
                .font(.subheadline)
                .padding(.horizontal)
                .padding(.bottom)
            }
            .padding()
        }
        .onAppear {
            Task { await viewModel.load() }
        }
    }

    private var usernameColor: Color {
        if viewModel.username.contains("error") {
            return .red
        } else if viewModel.username.contains("loading") {
            return .orange
        } else {
            return .primary
        }
    }
}

// MARK: - Stats Card

struct StatsCard: View {
    let title: String
    let count: Int
    let color: Color

    var body: some View {
        VStack {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)

            Text("\(count)")
                .font(.title)
                .fontWeight(.medium)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity, minHeight: 80)
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(10)
    }
}

// MARK: - Contest Card

struct ContestCard: View {
    let contest: Contest

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Upcoming Contest", systemImage: "trophy")
                .font(.headline)
                .foregroundColor(.secondary)

            Text(contest.title)
                .font(.title3)
                .fontWeight(.bold)

            Text(contest.startTime, style: .relative)
                .font(.subheadline)
                .foregroundColor(.blue)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.gray.opacity(0.15))
        .cornerRadius(12)
    }
}

// MARK: - Daily Challenge Card

struct DailyChallengeCard: View {
    let problem: DailyProblem

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Today's Challenge", systemImage: "calendar")
                .font(.headline)
                .foregroundColor(.secondary)

            Text(problem.title)
                .font(.title3)
                .fontWeight(.bold)

            if problem.isSolved {
                Label(" You've already solved this!", systemImage: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.subheadline)
            } else {
                Button("Solve Now") {
                    NSWorkspace.shared.open(problem.url)
                }
                .foregroundColor(.blue)
                .font(.subheadline)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.gray.opacity(0.15))
        .cornerRadius(12)
    }
}



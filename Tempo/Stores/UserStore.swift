//
//  UserStore.swift
//  Tempo
//
//  Created by Ronnie Gu on 2026-04-27.
//

import Observation
import Foundation

@MainActor
@Observable
final class UserStore {
    var setting: UserSettings
    var profile: UserProfile
    var todayStatement: DayStatement
    var pastStatements: [DayStatement]

    private(set) var activeUserID: String?
    private(set) var isSynchronizing = false
    private(set) var lastSyncError: String?

    @ObservationIgnored private let repository: UserDataRepository
    @ObservationIgnored private var pendingSyncTask: Task<Void, Never>?

    init(repository: UserDataRepository = UserDataRepository()) {
        self.repository = repository

        let snapshot = UserSnapshot.fresh()
        profile = snapshot.profile
        setting = snapshot.setting
        todayStatement = snapshot.todayStatement
        pastStatements = snapshot.pastStatements
    }

    // activates local and remote data belonging to one authenticated user, if supabase table unavailable, local is still usable
    func activate(for userID: String) async {
        pendingSyncTask?.cancel()
        activeUserID = userID
        isSynchronizing = true
        lastSyncError = nil

        defer {
            if activeUserID == userID {
                isSynchronizing = false
            }
        }

        let cachedSnapshot = repository.loadCachedSnapshot(for: userID)
        let startingSnapshot = cachedSnapshot ?? UserSnapshot.fresh()
        apply(startingSnapshot)

        if cachedSnapshot == nil {
            do {
                try repository.saveCachedSnapshot(startingSnapshot, for: userID)
            } catch {
                recordSyncError(error, operation: "initial local save", userID: userID)
            }
        }

        do {
            let synchronizedSnapshot = try await repository.synchronize(
                userID: userID,
                cachedSnapshot: cachedSnapshot
            )

            guard activeUserID == userID else {
                return
            }

            apply(synchronizedSnapshot)
        } catch {
            recordSyncError(error, operation: "Supabase synchronization", userID: userID)
        }

        guard activeUserID == userID else {
            return
        }

        checkForNewDay()
    }

    // removes the current account from memory without deleting its local cache.
    func deactivate() {
        pendingSyncTask?.cancel()
        pendingSyncTask = nil
        activeUserID = nil
        isSynchronizing = false
        lastSyncError = nil
        apply(UserSnapshot.fresh())
    }

    func saveSetting() {
        persistCurrentState()
    }

    func saveProfile() {
        persistCurrentState()
    }

    func loadTodayStatement() {
        reloadCachedState()
    }

    func loadPastStatements() {
        reloadCachedState()
    }

    func saveTodayStatement() {
        persistCurrentState()
    }

    func savePastStatements() {
        persistCurrentState()
    }

    func saveAll() {
        persistCurrentState()
    }

    // forces pending local changes to Supabase before sign-out or suspension
    func flush() async {
        guard let userID = activeUserID else {
            return
        }

        pendingSyncTask?.cancel()
        pendingSyncTask = nil

        let snapshot = currentSnapshot()
        do {
            try repository.saveCachedSnapshot(snapshot, for: userID)
        } catch {
            recordSyncError(error, operation: "local save", userID: userID)
        }

        await pushToSupabase(snapshot, for: userID)
    }

    func checkForNewDay() {
        guard activeUserID != nil else {
            return
        }

        let calendar = Calendar.current
        let now = Date()
        let currentDay = calendar.startOfDay(for: now)
        let statementDay = calendar.startOfDay(for: todayStatement.date)

        if statementDay == currentDay {
            return
        }

        let closedStatement = StatementCalculator.snapshot(
            for: todayStatement,
            hourlyRate: setting.hourlyRate,
            isClosed: true
        )

        pastStatements.append(closedStatement)

        var nextDay = calendar.date(byAdding: .day, value: 1, to: statementDay)
        while let missedDay = nextDay, missedDay < currentDay {
            pastStatements.append(
                DayStatement(
                    date: missedDay,
                    isClosed: true,
                    hourlyRateSnapshot: setting.hourlyRate
                )
            )
            nextDay = calendar.date(byAdding: .day, value: 1, to: missedDay)
        }

        todayStatement = DayStatement(
            date: now,
            isClosed: false,
            hourlyRateSnapshot: setting.hourlyRate
        )

        persistCurrentState()
    }

    private func reloadCachedState() {
        guard let userID = activeUserID,
              let snapshot = repository.loadCachedSnapshot(for: userID) else {
            return
        }

        apply(snapshot)
    }

    private func persistCurrentState() {
        guard let userID = activeUserID else {
            return
        }

        let snapshot = currentSnapshot()

        do {
            try repository.saveCachedSnapshot(snapshot, for: userID)
        } catch {
            recordSyncError(error, operation: "local save", userID: userID)
            return
        }

        scheduleSupabaseSync(snapshot, for: userID)
    }

    private func scheduleSupabaseSync(_ snapshot: UserSnapshot, for userID: String) {
        pendingSyncTask?.cancel()
        pendingSyncTask = Task { [weak self] in
            do {
                try await Task.sleep(nanoseconds: 350_000_000)
            } catch {
                return
            }

            guard !Task.isCancelled, let self else {
                return
            }

            await self.pushToSupabase(snapshot, for: userID)
        }
    }

    private func pushToSupabase(_ snapshot: UserSnapshot, for userID: String) async {
        do {
            try await repository.saveRemoteSnapshot(snapshot, for: userID)
            if activeUserID == userID {
                lastSyncError = nil
            }
        } catch {
            recordSyncError(error, operation: "Supabase save", userID: userID)
        }
    }

    private func currentSnapshot() -> UserSnapshot {
        UserSnapshot(
            profile: profile,
            setting: setting,
            todayStatement: todayStatement,
            pastStatements: pastStatements
        )
    }

    private func apply(_ snapshot: UserSnapshot) {
        profile = snapshot.profile
        setting = snapshot.setting
        todayStatement = snapshot.todayStatement
        pastStatements = snapshot.pastStatements
    }

    private func recordSyncError(_ error: Error, operation: String, userID: String) {
        guard activeUserID == userID else {
            return
        }

        let message = "\(operation) failed: \(error.localizedDescription)"
        lastSyncError = message
        print(message)
    }
}

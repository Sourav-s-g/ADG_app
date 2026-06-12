import Foundation
import Observation
import PhotosUI
import SwiftUI
import UIKit

@MainActor
@Observable
final class BoardViewModel {
    // MARK: - Core Board State
    var members: [BoardMember] = []
    var selectedMember: BoardMember?
    var draft: BoardMember = .empty
    var selectedPhoto: PhotosPickerItem?
    var isEditing = false
    var isLoading = false
    var errorMessage: String?
    
    // MARK: - About Us Text State
    var aboutText: String = defaultAboutText
    var aboutDraft: String = ""
    var isEditingAboutText = false

    private let repository: ADGRepository

    init(repository: ADGRepository = .shared) {
        self.repository = repository
    }
    
    var currentMembers: [BoardMember] {
        members
            .filter { $0.isCurrent }
            .sorted { $0.sortOrder < $1.sortOrder }
    }

    var previousMembers: [BoardMember] {
        members
            .filter { !$0.isCurrent }
            .sorted {
                if $0.boardYear == $1.boardYear {
                    return $0.sortOrder < $1.sortOrder
                }
                return $0.boardYear > $1.boardYear
            }
    }

    // MARK: - Load Logic
    func load() async {
        isLoading = true
        defer { isLoading = false }

        do {
            members = try await repository.fetchBoardMembers()
        } catch {
            errorMessage = error.localizedDescription
        }

        do {
            aboutText = try await repository.fetchAboutText()
        } catch {
            aboutText = Self.defaultAboutText
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - About Us Persistence
    func saveAboutText() async {
        isLoading = true
        defer { isLoading = false }
        do {
            try await repository.updateAboutText(aboutDraft)
            aboutText = aboutDraft
            isEditingAboutText = false
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Board Member Operations
    func beginCreate() {
        draft = .empty
        draft.sortOrder = (members.map(\.sortOrder).max() ?? -1) + 1
        selectedPhoto = nil
        isEditing = true
    }

    func beginEdit(_ member: BoardMember) {
        draft = member
        selectedPhoto = nil
        isEditing = true
    }

    func move(from source: IndexSet, to destination: Int) async {
        members.move(fromOffsets: source, toOffset: destination)
        do {
            for index in members.indices {
                members[index].sortOrder = index
                try await repository.upsertBoardMember(members[index])
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func save() async {
        do {
            if let selectedPhoto,
               let data = try await selectedPhoto.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                draft.headshotURL = try await repository.uploadJPEG(image, folder: "board")
            }
            try await repository.upsertBoardMember(draft)
            isEditing = false
            await load()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func delete(_ member: BoardMember) async {
        do {
            try await repository.deleteBoardMember(id: member.id)
            await load()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

private extension BoardViewModel {
    static let defaultAboutText = "Apple Developers Group is a student community at MIT Manipal focused on building thoughtful products, learning Apple technologies, and growing together through events, workshops, and projects."
}

private extension BoardMember {
    static var empty: BoardMember {
        BoardMember(
            id: UUID(),
            name: "",
            role: "",
            domain: "",
            bio: "",
            headshotURL: nil,
            githubURL: nil,
            linkedInURL: nil,
            sortOrder: 0,
            boardYear: "2026",
            isCurrent: true
        )
    }
}

import Foundation
import Observation
import PhotosUI
import SwiftUI
import UIKit

@MainActor
@Observable
final class AnnouncementsViewModel {
    var announcements: [Announcement] = []
    var draft = Announcement(
        id: UUID(),
        title: "",
        body: "",
        posterURL: nil,
        isPinned: false,
        priority: 0,
        publishedAt: Date()
    )
    var selectedPhoto: PhotosPickerItem?
    var isEditing = false
    var isLoading = false
    var errorMessage: String?

    private let repository: ADGRepository

    init(repository: ADGRepository = .shared) {
        self.repository = repository
    }

    func load() async {
        isLoading = true
        defer { isLoading = false }
        do {
            announcements = try await repository.fetchAnnouncements()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func beginCreate() {
        draft = Announcement(
            id: UUID(),
            title: "",
            body: "",
            posterURL: nil,
            isPinned: false,
            priority: 0,
            publishedAt: Date()
        )
        selectedPhoto = nil
        isEditing = true
    }

    func beginEdit(_ announcement: Announcement) {
        draft = announcement
        selectedPhoto = nil
        isEditing = true
    }

    func save() async {
        do {
            if let selectedPhoto,
               let data = try await selectedPhoto.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                draft.posterURL = try await repository.uploadJPEG(image, folder: "announcements")
            }
            try await repository.upsertAnnouncement(draft)
            isEditing = false
            await load()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func delete(_ announcement: Announcement) async {
        do {
            try await repository.deleteAnnouncement(id: announcement.id)
            await load()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

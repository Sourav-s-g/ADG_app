import Foundation

struct Announcement: Identifiable, Codable, Hashable {
    var id: UUID
    var title: String
    var body: String
    var posterURL: String?
    var isPinned: Bool
    var priority: Int
    var publishedAt: Date

    enum CodingKeys: String, CodingKey {
        case id, title, body
        case posterURL = "poster_url"
        case isPinned = "is_pinned"
        case priority
        case publishedAt = "published_at"
    }
}

struct Event: Identifiable, Codable, Hashable {
    var id: UUID
    var title: String
    var summary: String
    var venue: String
    var startsAt: Date
    var capacity: Int
    var registeredCount: Int
    var coverImageURL: String?
    var registrationMethod: RegistrationMethod
    var registrationURL: String?
    var registrationEnabled: Bool = true
    var requiredFields: RegistrationFieldConfig

    var isPast: Bool { startsAt < Date() }
    var isRegistrationOpen: Bool { registrationEnabled }
    var isLive: Bool {
        let now = Date()
        let liveWindowEnd = startsAt.addingTimeInterval(2 * 60 * 60)
        return startsAt <= now && now <= liveWindowEnd
    }
    
    enum CodingKeys: String, CodingKey {
        case id, title, summary, venue, capacity
        case startsAt = "starts_at"
        case registeredCount = "registered_count"
        case coverImageURL = "cover_image_url"
        case registrationMethod = "registration_method"
        case registrationURL = "registration_url"
        case registrationEnabled = "registration_enabled"
        case requiredFields = "required_fields"
    }
}

extension Event {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        summary = try container.decode(String.self, forKey: .summary)
        venue = try container.decode(String.self, forKey: .venue)
        startsAt = try container.decode(Date.self, forKey: .startsAt)
        capacity = try container.decode(Int.self, forKey: .capacity)
        registeredCount = try container.decode(Int.self, forKey: .registeredCount)
        coverImageURL = try container.decodeIfPresent(String.self, forKey: .coverImageURL)
        registrationMethod = try container.decode(RegistrationMethod.self, forKey: .registrationMethod)
        registrationURL = try container.decodeIfPresent(String.self, forKey: .registrationURL)
        registrationEnabled = try container.decodeIfPresent(Bool.self, forKey: .registrationEnabled) ?? true
        requiredFields = try container.decodeIfPresent(RegistrationFieldConfig.self, forKey: .requiredFields) ?? .standard
    }
}

enum RegistrationMethod: String, Codable, CaseIterable, Identifiable {
    case externalLink = "external_link"
    case nativeForm = "native_form"

    var id: String { rawValue }
}

struct RegistrationFieldConfig: Codable, Hashable {
    var phone: Bool
    var registrationNumber: Bool
    var department: Bool
    var year: Bool
    var notes: Bool

    enum CodingKeys: String, CodingKey {
        case phone
        case registrationNumber = "registration_number"
        case department
        case year
        case notes
    }

    static let standard = RegistrationFieldConfig(
        phone: true,
        registrationNumber: true,
        department: false,
        year: false,
        notes: false
    )

    init(
        phone: Bool = false,
        registrationNumber: Bool = false,
        department: Bool = false,
        year: Bool = false,
        notes: Bool = false
    ) {
        self.phone = phone
        self.registrationNumber = registrationNumber
        self.department = department
        self.year = year
        self.notes = notes
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        phone = try container.decodeIfPresent(Bool.self, forKey: .phone) ?? false
        registrationNumber = try container.decodeIfPresent(Bool.self, forKey: .registrationNumber) ?? false
        department = try container.decodeIfPresent(Bool.self, forKey: .department) ?? false
        year = try container.decodeIfPresent(Bool.self, forKey: .year) ?? false
        notes = try container.decodeIfPresent(Bool.self, forKey: .notes) ?? false
    }
}

struct Registration: Identifiable, Codable, Hashable {
    var id: UUID
    var eventID: UUID
    var userID: UUID?
    var studentName: String
    var email: String
    var customInputs: [String: String]
    var createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id, email
        case eventID = "event_id"
        case userID = "user_id"
        case studentName = "student_name"
        case customInputs = "custom_inputs"
        case createdAt = "created_at"
    }

    init(
        id: UUID,
        eventID: UUID,
        userID: UUID?,
        studentName: String,
        email: String,
        customInputs: [String: String],
        createdAt: Date
    ) {
        self.id = id
        self.eventID = eventID
        self.userID = userID
        self.studentName = studentName
        self.email = email
        self.customInputs = customInputs
        self.createdAt = createdAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        eventID = try container.decode(UUID.self, forKey: .eventID)
        userID = try container.decodeIfPresent(UUID.self, forKey: .userID)
        studentName = try container.decode(String.self, forKey: .studentName)
        email = try container.decode(String.self, forKey: .email)
        createdAt = try container.decode(Date.self, forKey: .createdAt)

        customInputs = (try? container.decode([String: String].self, forKey: .customInputs))
            ?? (try? container.decode([String: RegistrationInputValue].self, forKey: .customInputs).compactMapValues(\.displayValue))
            ?? [:]
    }
}

private enum RegistrationInputValue: Decodable {
    case string(String)
    case number(Double)
    case bool(Bool)
    case empty

    var displayValue: String? {
        switch self {
        case .string(let value):
            return value.isEmpty ? nil : value
        case .number(let value):
            return value.truncatingRemainder(dividingBy: 1) == 0 ? String(Int(value)) : String(value)
        case .bool(let value):
            return value ? "Yes" : "No"
        case .empty:
            return nil
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if container.decodeNil() {
            self = .empty
        } else if let value = try? container.decode(String.self) {
            self = .string(value)
        } else if let value = try? container.decode(Bool.self) {
            self = .bool(value)
        } else if let value = try? container.decode(Double.self) {
            self = .number(value)
        } else {
            self = .empty
        }
    }
}

struct NewRegistration: Encodable {
    var eventID: UUID
    var userID: UUID?
    var studentName: String
    var email: String
    var customInputs: [String: String]

    enum CodingKeys: String, CodingKey {
        case email
        case eventID = "event_id"
        case userID = "user_id"
        case studentName = "student_name"
        case customInputs = "custom_inputs"
    }
}

struct RegisteredEvent: Decodable, Hashable {
    var eventID: UUID

    enum CodingKeys: String, CodingKey {
        case eventID = "event_id"
    }
}

struct BoardMember: Identifiable, Codable, Hashable {
    var id: UUID
    var name: String
    var role: String
    var domain: String
    var bio: String
    var headshotURL: String?
    var githubURL: String?
    var linkedInURL: String?
    var sortOrder: Int
    var boardYear: String
    var isCurrent: Bool

    enum CodingKeys: String, CodingKey {
        case id, name, role, domain, bio
        case headshotURL = "headshot_url"
        case githubURL = "github_url"
        case linkedInURL = "linkedin_url"
        case sortOrder = "sort_order"
        case boardYear = "board_year"
        case isCurrent = "is_current"
    }
}

struct LayoutConfig: Identifiable, Codable, Hashable {
    var id: UUID
    var brandTitle: String
    var logoURL: String?

    enum CodingKeys: String, CodingKey {
        case id
        case brandTitle = "brand_title"
        case logoURL = "logo_url"
    }
}

struct AppConfig: Codable {
    let id: String
    var aboutText: String

    enum CodingKeys: String, CodingKey {
        case id
        case aboutText = "about_text"
    }
}

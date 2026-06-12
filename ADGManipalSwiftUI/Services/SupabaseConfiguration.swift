import Foundation
import Supabase

enum SupabaseConfiguration {
    static let projectURL = URL(string: "https://wydmyxkwrjvmajmocbct.supabase.co")!
    static let anonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Ind5ZG15eGt3cmp2bWFqbW9jYmN0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODA3Mzc3MTAsImV4cCI6MjA5NjMxMzcxMH0.PFIUNWwh9t8Xp-WucSFuFt6a1d4aWt_1P1Q_lrL_t3g"
    static let assetBucket = "adg-assets"
}

enum SupabaseProvider {
    static let shared = SupabaseClient(
        supabaseURL: SupabaseConfiguration.projectURL,
        supabaseKey: SupabaseConfiguration.anonKey,
        // 👇 We pass the Auth configuration directly via the options block
        options: SupabaseClientOptions(
            auth: .init(
                emitLocalSessionAsInitialSession: true
            )
        )
    )
}

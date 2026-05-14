func validatedSelection<Tab: Hashable>(_ selection: Tab, in tabs: [Tab]) -> Tab? {
    guard !tabs.isEmpty else { return nil }
    return tabs.contains(selection) ? selection : tabs.first
}

func badgeTruncated(_ badge: String?) -> String? {
    guard let badge else { return nil }
    return badge.count > 3 ? String(badge.prefix(3)) : badge
}

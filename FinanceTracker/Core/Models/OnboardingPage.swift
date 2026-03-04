struct OnboardingPage: Identifiable {
    let id: String
    let imageName: String
    let title: String
    let description: String
}

extension OnboardingPage {
    static let pages: [OnboardingPage] = [
        OnboardingPage(
            id: "track_finances",
            imageName: "chart.pie.fill",
            title: "Track Your Finances",
            description: "Keep a clear record of all your income and expenses in one place."
        ),
        OnboardingPage(
            id: "income_expenses",
            imageName: "arrow.up.arrow.down.circle.fill",
            title: "Income & Expenses",
            description: "Categorize transactions and see where your money goes."
        ),
        OnboardingPage(
            id: "stay_budget",
            imageName: "target",
            title: "Stay on Budget",
            description: "Visualize your spending with beautiful charts and take control of your finances."
        )
    ]
}

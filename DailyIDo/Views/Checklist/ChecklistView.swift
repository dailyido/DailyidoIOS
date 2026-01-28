import SwiftUI

struct ChecklistView: View {
    @StateObject private var viewModel = ChecklistViewModel()
    @State private var showSettings = false

    init() {
        // Set navigation bar title color to dark blue and remove separator
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Color(hex: Constants.Colors.background))
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor(Color(hex: Constants.Colors.buttonPrimary))]
        appearance.titleTextAttributes = [.foregroundColor: UIColor(Color(hex: Constants.Colors.buttonPrimary))]
        appearance.shadowColor = .clear
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: Constants.Colors.background)
                    .ignoresSafeArea()

                if viewModel.isLoading {
                    LoadingSpinner()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 24, pinnedViews: .sectionHeaders) {
                            // Subtitle
                            Text("Your curated checklist from all of the important daily wedding tips!")
                                .font(.system(size: 15))
                                .foregroundColor(Color(hex: Constants.Colors.buttonPrimary))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 4)
                                .padding(.bottom, 8)

                            ForEach(viewModel.sortedCategories, id: \.self) { category in
                                let isLocked = viewModel.isCategoryLocked(category)
                                let isCollapsed = viewModel.isSectionCollapsed(category)

                                Section {
                                    if !isCollapsed {
                                        ChecklistGroupView(
                                            category: category,
                                            items: viewModel.checklistItems[category] ?? [],
                                            isLocked: isLocked,
                                            expandedItemId: $viewModel.expandedItemId,
                                            onToggle: { item in
                                                Task {
                                                    await viewModel.toggleItem(item)
                                                }
                                            },
                                            onExpand: { itemId in
                                                viewModel.toggleExpanded(itemId)
                                            },
                                            onAffiliateTap: { url in
                                                // Get the tip ID from the expanded item for analytics
                                                let tipId = viewModel.expandedItemId
                                                viewModel.openAffiliateLink(url, tipId: tipId)
                                            }
                                        )
                                    }
                                } header: {
                                    ChecklistSectionHeader(
                                        category: category,
                                        progress: viewModel.completionProgress(for: category),
                                        isLocked: isLocked,
                                        isCollapsed: isCollapsed,
                                        onTap: {
                                            viewModel.toggleSectionCollapsed(category)
                                        }
                                    )
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                        .padding(.bottom, 100)
                    }
                }
            }
            .navigationTitle("Wedding Checklist")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        HapticManager.shared.buttonTap()
                        showSettings = true
                    }) {
                        Image(systemName: "gearshape.fill")
                            .foregroundColor(Color(hex: Constants.Colors.secondaryText))
                    }
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView(onDone: {
                    showSettings = false
                })
            }
        }
        .task {
            await viewModel.loadData()
        }
    }
}

struct ChecklistSectionHeader: View {
    let category: String
    let progress: (completed: Int, total: Int)
    var isLocked: Bool = false
    var isCollapsed: Bool = false
    var onTap: (() -> Void)? = nil

    var body: some View {
        Button(action: {
            onTap?()
        }) {
            HStack {
                // Chevron indicator
                Image(systemName: isCollapsed ? "chevron.right" : "chevron.down")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color(hex: Constants.Colors.secondaryText))
                    .frame(width: 20)

                Text(category)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color(hex: Constants.Colors.buttonPrimary))
                    .opacity(isLocked ? 0.5 : 1.0)

                if isLocked {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: Constants.Colors.secondaryText))
                }

                Spacer()

                if !isLocked {
                    Text("\(progress.completed)/\(progress.total)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color(hex: Constants.Colors.secondaryText))
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.vertical, 12)
        .padding(.horizontal, 4)
        .background(Color(hex: Constants.Colors.background))
    }
}

#Preview {
    ChecklistView()
}

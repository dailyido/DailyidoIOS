import SwiftUI

enum ChecklistTab: String, CaseIterable {
    case checklist = "Checklist"
    case favorites = "Favorites"
}

struct ChecklistView: View {
    @StateObject private var viewModel = ChecklistViewModel()
    @StateObject private var favoritesService = FavoritesService.shared
    @State private var showSettings = false
    @State private var selectedFavoriteTip: Tip?
    @State private var selectedTab: ChecklistTab = .checklist

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
                    VStack(spacing: 0) {
                        // Title
                        Text("Checklist & Favorites")
                            .font(.system(size: 34, weight: .bold))
                            .foregroundColor(Color(hex: Constants.Colors.buttonPrimary))
                            .minimumScaleFactor(0.7)
                            .lineLimit(1)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 20)
                            .padding(.top, 8)

                        // Subtitle
                        Text("Here you will find your curated checklist from all of the important daily wedding tips as well as the tips you selected as your favorites!")
                            .font(.system(size: 15))
                            .foregroundColor(Color(hex: Constants.Colors.buttonPrimary))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 20)
                            .padding(.top, 4)
                            .padding(.bottom, 16)

                        // Tab Toggle
                        ChecklistTabToggle(selectedTab: $selectedTab)
                            .padding(.horizontal, 16)
                            .padding(.bottom, 16)
                            .onChange(of: selectedTab) { newTab in
                                if newTab == .favorites {
                                    Task {
                                        await viewModel.loadFavoriteTips()
                                    }
                                }
                            }

                        // Content based on selected tab
                        if selectedTab == .checklist {
                            checklistContent
                        } else {
                            favoritesContent
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    EmptyView()
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView(onDone: {
                    showSettings = false
                })
            }
            .sheet(item: $selectedFavoriteTip) { tip in
                FavoriteDetailView(tip: tip) {
                    Task {
                        await viewModel.removeFavorite(tipId: tip.id)
                    }
                }
            }
        }
        .task {
            await viewModel.loadData()
        }
    }

    // MARK: - Checklist Content

    private var checklistContent: some View {
        ScrollView {
            LazyVStack(spacing: 24, pinnedViews: .sectionHeaders) {
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
            .padding(.bottom, 100)
        }
    }

    // MARK: - Favorites Content

    private var favoritesContent: some View {
        ScrollView {
            if viewModel.favoriteTips.isEmpty && favoritesService.favoriteTipIds.isEmpty {
                // Empty state
                VStack(spacing: 16) {
                    Spacer()
                        .frame(height: 60)

                    Image(systemName: "heart")
                        .font(.system(size: 50))
                        .foregroundColor(Color(hex: Constants.Colors.accent).opacity(0.4))

                    Text("No favorites yet")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(Color(hex: Constants.Colors.primaryText))

                    Text("Double-tap tips on the calendar\nto save them here!")
                        .font(.system(size: 16))
                        .foregroundColor(Color(hex: Constants.Colors.secondaryText))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)

                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 24)
            } else {
                FavoritesGridView(tips: viewModel.favoriteTips) { tip in
                    selectedFavoriteTip = tip
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 100)
            }
        }
    }
}

// MARK: - Tab Toggle

struct ChecklistTabToggle: View {
    @Binding var selectedTab: ChecklistTab

    var body: some View {
        HStack(spacing: 0) {
            ForEach(ChecklistTab.allCases, id: \.self) { tab in
                Button(action: {
                    HapticManager.shared.buttonTap()
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedTab = tab
                    }
                }) {
                    Text(tab.rawValue)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(selectedTab == tab ? Color(hex: Constants.Colors.primaryText) : Color(hex: Constants.Colors.secondaryText))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(selectedTab == tab ? Color.white : Color.clear)
                                .shadow(color: selectedTab == tab ? .black.opacity(0.06) : .clear, radius: 4, x: 0, y: 2)
                        )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(hex: Constants.Colors.cardBackground))
        )
    }
}

// MARK: - Section Header

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

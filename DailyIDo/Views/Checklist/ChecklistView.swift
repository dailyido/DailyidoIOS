import SwiftUI

struct ChecklistView: View {
    @StateObject private var viewModel = ChecklistViewModel()
    @State private var showSettings = false

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
                            ForEach(viewModel.sortedCategories, id: \.self) { category in
                                Section {
                                    ChecklistGroupView(
                                        category: category,
                                        items: viewModel.checklistItems[category] ?? [],
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
                                            viewModel.openAffiliateLink(url)
                                        }
                                    )
                                } header: {
                                    ChecklistSectionHeader(
                                        category: category,
                                        progress: viewModel.completionProgress(for: category)
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

    var body: some View {
        HStack {
            Text(category)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(Color(hex: Constants.Colors.primaryText))

            Spacer()

            Text("\(progress.completed)/\(progress.total)")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color(hex: Constants.Colors.secondaryText))
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 4)
        .background(Color(hex: Constants.Colors.background))
    }
}

#Preview {
    ChecklistView()
}

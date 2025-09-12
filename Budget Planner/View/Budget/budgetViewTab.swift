//
//  budgetViewTab.swift
//  Budget Planner
//
//  Created by Assistant on 11/09/25.
//

import SwiftUI

struct budgetViewTab: View {
    @StateObject var budgetManager = BudgetManager()
    @StateObject var transactionManager = TransactionManager()
    @State private var showAddBudget = false
    @State private var selectedFilter: BudgetFilter = .active
    
    enum BudgetFilter: String, CaseIterable {
        case active = "Active"
        case expired = "Expired"
        case all = "All"
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Summary Header
                buildSummaryHeader()
                
                // Filter Section
                buildFilterSection()
                
                // Budgets List
                buildBudgetsList()
            }
            .navigationTitle("Budget Overview")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showAddBudget = true
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.primary)
                    }
                }
            }
            .sheet(isPresented: $showAddBudget) {
                AddBudgetView(
                    budgetManager: budgetManager,
                    transactionManager: transactionManager
                )
            }
        }
        .onAppear {
            budgetManager.loadData()
            transactionManager.loadData()
            syncBudgetSpending()
        }
    }
    
    // MARK: - View Builders
    
    @ViewBuilder
    private func buildSummaryHeader() -> some View {
        VStack(spacing: 16) {
            // Main stats
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Total Budget")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("₹\(formatAmount(budgetManager.totalBudgetAmount()))")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 8) {
                    Text("Spent")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("₹\(formatAmount(budgetManager.totalSpentAmount()))")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.red)
                }
                
                VStack(alignment: .trailing, spacing: 8) {
                    Text("Remaining")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("₹\(formatAmount(budgetManager.totalRemainingAmount()))")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            
            // Performance indicators
            let performance = budgetManager.budgetPerformanceData()
            if performance.onTrack + performance.warning + performance.overBudget > 0 {
                HStack(spacing: 20) {
                    performanceIndicator(
                        title: "On Track",
                        count: performance.onTrack,
                        color: .green
                    )
                    
                    performanceIndicator(
                        title: "Warning",
                        count: performance.warning,
                        color: .orange
                    )
                    
                    performanceIndicator(
                        title: "Over Budget",
                        count: performance.overBudget,
                        color: .red
                    )
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
            }
        }
        .background(Color(.systemGray6))
        .cornerRadius(16)
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }
    
    @ViewBuilder
    private func performanceIndicator(title: String, count: Int, color: Color) -> some View {
        VStack(spacing: 4) {
            Text("\(count)")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
    
    @ViewBuilder
    private func buildFilterSection() -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(BudgetFilter.allCases, id: \.self) { filter in
                    FilterChip(
                        title: filter.rawValue,
                        isSelected: selectedFilter == filter
                    ) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedFilter = filter
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
        }
        .padding(.vertical, 16)
    }
    
    @ViewBuilder
    private func buildBudgetsList() -> some View {
        let filteredBudgets = getFilteredBudgets()
        
        if filteredBudgets.isEmpty {
            buildEmptyState()
        } else {
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(filteredBudgets) { budget in
                        BudgetCard(
                            budget: budget,
                            onDelete: {
                                deleteBudget(budget)
                            }
                        )
                        .padding(.horizontal, 16)
                    }
                }
                .padding(.bottom, 100)
            }
        }
    }
    
    @ViewBuilder
    private func buildEmptyState() -> some View {
        VStack(spacing: 20) {
            Image(systemName: "chart.pie")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            
            VStack(spacing: 8) {
                Text("No Budgets")
                    .font(.title3)
                    .fontWeight(.semibold)
                
                Text("Create budgets to track your spending and stay on top of your finances")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Button("Create Budget") {
                showAddBudget = true
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding(40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Helper Methods
    
    private func getFilteredBudgets() -> [Budget] {
        switch selectedFilter {
        case .active:
            return budgetManager.activeBudgets().sorted { $0.daysRemaining < $1.daysRemaining }
        case .expired:
            return budgetManager.expiredBudgets().sorted { $0.endDate > $1.endDate }
        case .all:
            return budgetManager.budgets.sorted { budget1, budget2 in
                if budget1.isActive && !budget2.isActive {
                    return true
                } else if !budget1.isActive && budget2.isActive {
                    return false
                } else {
                    return budget1.daysRemaining < budget2.daysRemaining
                }
            }
        }
    }
    
    private func deleteBudget(_ budget: Budget) {
        withAnimation(.easeOut(duration: 0.3)) {
            budgetManager.deleteBudget(budget)
        }
    }
    
    private func formatAmount(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 0
        
        if let formattedNumber = formatter.string(from: NSNumber(value: abs(amount))) {
            return formattedNumber
        }
        return "\(Int(abs(amount)))"
    }
    
    // Sync budget spending with actual transactions
    private func syncBudgetSpending() {
        for budget in budgetManager.budgets {
            // Calculate actual spending for this category in the budget period
            let actualSpent = transactionManager.transactions
                .filter { transaction in
                    transaction.category.id == budget.category.id &&
                    transaction.type == .expense &&
                    transaction.date >= budget.startDate &&
                    transaction.date <= budget.endDate
                }
                .reduce(0) { $0 + $1.amount }
            
            // Update budget with actual spending
            var updatedBudget = budget
            updatedBudget.spentAmount = actualSpent
            budgetManager.updateBudget(updatedBudget)
        }
    }
}

// MARK: - Budget Card Component
struct BudgetCard: View {
    let budget: Budget
    let onDelete: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            // Header with category and amount
            HStack {
                HStack(spacing: 12) {
                    Text(budget.category.emoji)
                        .font(.title2)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(budget.category.name)
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                        
                        if !budget.description.isEmpty && budget.description != "Budget for \(budget.category.name)" {
                            Text(budget.description)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("₹\(Int(budget.remainingAmount))")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(budget.remainingAmount >= 0 ? .green : .red)
                    
                    Text("₹\(Int(budget.spentAmount)) / ₹\(Int(budget.budgetAmount))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Progress bar
            VStack(spacing: 8) {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Background
                        Rectangle()
                            .fill(Color(.systemGray5))
                            .frame(height: 8)
                            .cornerRadius(4)
                        
                        // Progress
                        Rectangle()
                            .fill(progressColor)
                            .frame(
                                width: min(
                                    geometry.size.width * CGFloat(budget.progressPercentage / 100),
                                    geometry.size.width
                                ),
                                height: 8
                            )
                            .cornerRadius(4)
                            .animation(.easeInOut(duration: 0.3), value: budget.progressPercentage)
                    }
                }
                .frame(height: 8)
                
                HStack {
                    Text("\(budget.daysRemaining) days left")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("\(Int(budget.progressPercentage))%")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(progressColor)
                }
            }
            
            // Status indicator
            HStack {
                StatusBadge(status: budget.budgetStatus)
                Spacer()
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        .contextMenu {
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Delete Budget", systemImage: "trash")
            }
        }
    }
    
    private var progressColor: Color {
        switch budget.budgetStatus {
        case .safe:
            return .green
        case .onTrack:
            return .blue
        case .warning:
            return .orange
        case .overBudget:
            return .red
        }
    }
}

// MARK: - Status Badge Component
struct StatusBadge: View {
    let status: BudgetStatus
    
    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(statusColor)
                .frame(width: 8, height: 8)
            
            Text(status.description)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(statusColor)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(statusColor.opacity(0.1))
        .cornerRadius(12)
    }
    
    private var statusColor: Color {
        switch status {
        case .safe:
            return .green
        case .onTrack:
            return .blue
        case .warning:
            return .orange
        case .overBudget:
            return .red
        }
    }
}

// MARK: - Filter Chip Component (reused from transaction view)
struct BudgetFilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.black : Color(.systemGray6))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview
struct budgetViewTab_Previews: PreviewProvider {
    static var previews: some View {
        budgetViewTab()
    }
}

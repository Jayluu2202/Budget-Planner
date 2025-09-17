//
//  transactionViewTab.swift
//  Budget Planner
//
//  Updated to pass TransactionManager to TransactionDetailsView for proper deletion
//

import SwiftUI
//change check
struct transactionViewTab: View {
    @StateObject var transactionManager = TransactionManager()
    @State private var showFilterSheet = false
    @State private var selectedFilter: FilterType = .all
    @Environment(\.dismiss) private var dismiss
    var isInsideTab : Bool = true
    // Make category an optional property
    let category: TransactionCategory?
    
    // Initializer to handle both cases
    init(category: TransactionCategory? = nil) {
        self.category = category
        _transactionManager = StateObject(wrappedValue: TransactionManager())
    }
    
    enum FilterType: String, CaseIterable {
        case all = "All Transactions"
        case recurring = "Recurring"
        case nonRecurring = "Non-Recurring"
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if category != nil {
                    buildCategoryHeader()
//                        .padding(.top, category == nil ? 0 : -50)
                }
                buildTransactionsList()
                    
            }
            .navigationBarBackButtonHidden(true)
            .navigationTitle(category == nil ? "Transactions" : "")
//            .edgesIgnoringSafeArea(category == nil ? [] : .top)
//            .padding(.top, category == nil ? 0 : -10)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    if category == nil {
                        Button {
                            showFilterSheet = true
                        } label: {
                            Image(systemName: "slider.horizontal.3")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.primary)
                        }
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            transactionManager.loadData()
        }
        .confirmationDialog("Filter Transactions", isPresented: $showFilterSheet, titleVisibility: .visible) {
            ForEach(FilterType.allCases, id: \.self) { filter in
                Button(filter.rawValue) {
                    selectedFilter = filter
                }
            }
            Button("Cancel", role: .cancel) { }
        }
    }
    
    private func buildCategoryHeader() -> some View {
        HStack {
            Button(action: {
                dismiss()
            }) {
                Image(systemName: "chevron.left")
                    .font(.title2)
                    .foregroundColor(.black)
            }
            
            Text(category?.emoji ?? "")
                .font(.title2)
            
            Text("Transactions")
                .font(.title2)
                .fontWeight(.semibold)
            
            Spacer()
        }
        .navigationBarBackButtonHidden(true)
        .edgesIgnoringSafeArea(category == nil ? [] : .top)
        .padding(.top, category == nil ? 0 : -100)
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color(.systemBackground))
    }
    
    // MARK: - View Builders
    
    @ViewBuilder
    private func buildTransactionsList() -> some View {
        if filteredTransactions.isEmpty {
            buildEmptyState()
        } else {
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(groupedTransactions.keys.sorted(by: >), id: \.self) { date in
                        Section {
                            ForEach(groupedTransactions[date] ?? []) { transaction in
                                // FIXED: Pass transactionManager to TransactionDetailsView
                                NavigationLink(destination: TransactionDetailsView(
                                    transaction: transaction,
                                    transactionManager: transactionManager
                                )) {
                                    TransactionRow(
                                        transaction: transaction,
                                        onDelete: {
                                            deleteTransaction(transaction)
                                        }
                                    )
                                    .padding(.horizontal)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        } header: {
                            buildDateHeader(date)
                        }
                    }
                }
                .padding(.bottom, 100) // Safe area for tab bar
            }
        }
    }
    
    @ViewBuilder
    private func buildDateHeader(_ date: Date) -> some View {
        HStack {
            Text(formatDateHeader(date))
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
    }
    
    @ViewBuilder
    private func buildEmptyState() -> some View {
        VStack(spacing: 20) {
            Image(systemName: "doc.text")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            
            VStack(spacing: 8) {
                Text("No Transactions")
                    .font(.title3)
                    .fontWeight(.semibold)
                
                Text("Start adding your income and expenses to track your finances")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Computed Properties
    
    private var filteredTransactions: [Transaction] {
        var transactions = transactionManager.transactions
        
        // Apply type filter based on recurring status
        switch selectedFilter {
        case .all:
            
            break
        case .recurring:
            transactions = transactions.filter { $0.isRecurring ?? false }
        case .nonRecurring:
            transactions = transactions.filter { !($0.isRecurring ?? false) }
        }
        
        // Sort by date (newest first)
        return transactions.sorted { $0.date > $1.date }
    }
    
    private var groupedTransactions: [Date: [Transaction]] {
        Dictionary(grouping: filteredTransactions) { transaction in
            Calendar.current.startOfDay(for: transaction.date)
        }
    }
    
    // MARK: - Helper Methods
    
    private func deleteTransaction(_ transaction: Transaction) {
        withAnimation(.easeOut(duration: 0.3)) {
            transactionManager.deleteTransaction(transaction)
        }
    }
    
    private func formatDateHeader(_ date: Date) -> String {
        let calendar = Calendar.current
        
        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE, MMMM d, yyyy"
            return formatter.string(from: date)
        }
    }
}

// MARK: - Filter Chip Component
struct FilterChip: View {
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

// MARK: - Transaction Row Component
struct TransactionRow: View {
    let transaction: Transaction
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            // Category emoji and icon background
            ZStack {
                Circle()
                    .fill(categoryBackgroundColor.opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Text(transaction.category.emoji)
                    .font(.title2)
            }
            
            // Transaction details
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(transaction.category.name)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text(amountText)
                        .font(.body)
                        .fontWeight(.semibold)
                        .foregroundColor(amountColor)
                }
                
                HStack {
                    HStack(spacing: 4) {
                        Text(transaction.account.emoji)
                            .font(.caption)
                        Text(transaction.account.name)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Text(formatTime(transaction.date))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if !transaction.description.isEmpty && transaction.description != "No description" {
                    Text(transaction.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            
            // Chevron arrow to indicate navigation
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
        .contextMenu {
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
    
    private var categoryBackgroundColor: Color {
        switch transaction.type {
        case .income:
            return .green
        case .expense:
            return .red
        case .transfer:
            return .blue
        }
    }
    
    private var amountText: String {
        let prefix = transaction.type == .income ? "+" : "-"
        return "\(prefix)₹\(Int(transaction.amount))"
    }
    
    private var amountColor: Color {
        switch transaction.type {
        case .income:
            return .green
        case .expense:
            return .red
        case .transfer:
            return .blue
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Preview
struct transactionViewTab_Previews: PreviewProvider {
    static var previews: some View {
        transactionViewTab()
    }
}

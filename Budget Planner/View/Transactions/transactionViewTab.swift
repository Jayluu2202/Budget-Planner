//
//  transactionViewTab.swift
//  Budget Planner
//
//  Created by mac on 03/09/25.
//

import SwiftUI

struct transactionViewTab: View {
    @StateObject var transactionManager = TransactionManager()
    @State private var showAddScreen = false
    @State private var selectedFilter: FilterType = .all
    @State private var searchText = ""
    
    enum FilterType: String, CaseIterable {
        case all = "All"
        case income = "Income"
        case expense = "Expense"
        case transfer = "Transfer"
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header with filter options
                buildHeaderSection()
                
                // Search bar
                buildSearchSection()
                
                // Filter chips
                buildFilterSection()
                
                // Transactions list
                buildTransactionsList()
            }
            .navigationTitle("Transactions")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showAddScreen = true
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.primary)
                    }
                }
            }
            .sheet(isPresented: $showAddScreen) {
                AddTransactionDetails(transactionManager: transactionManager)
            }
        }
        .onAppear {
            transactionManager.loadData()
        }
    }
    
    // MARK: - View Builders
    
    @ViewBuilder
    private func buildHeaderSection() -> some View {
        VStack(spacing: 8) {
            // Total balance summary
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Total Balance")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("₹\(formatAmount(totalBalance))")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(totalBalance >= 0 ? .green : .red)
                }
                
                Spacer()
                
                HStack(spacing: 20) {
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Income")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("₹\(formatAmount(totalIncome))")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.green)
                    }
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Expense")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("₹\(formatAmount(totalExpense))")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.red)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .padding(.horizontal)
        }
        .padding(.top, 8)
    }
    
    @ViewBuilder
    private func buildSearchSection() -> some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Search transactions", text: $searchText)
                .textFieldStyle(PlainTextFieldStyle())
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
        .cornerRadius(8)
        .padding(.horizontal)
        .padding(.top, 8)
    }
    
    @ViewBuilder
    private func buildFilterSection() -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(FilterType.allCases, id: \.self) { filter in
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
            .padding(.horizontal)
        }
        .padding(.top, 12)
    }
    
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
                                TransactionRow(
                                    transaction: transaction,
                                    onDelete: {
                                        deleteTransaction(transaction)
                                    }
                                )
                                .padding(.horizontal)
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
            
            Button("Add Transaction") {
                showAddScreen = true
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding(40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Computed Properties
    
    private var filteredTransactions: [Transaction] {
        var transactions = transactionManager.transactions
        
        // Apply type filter
        if selectedFilter != .all {
            transactions = transactions.filter {
                $0.type.rawValue.lowercased() == selectedFilter.rawValue.lowercased()
            }
        }
        
        // Apply search filter
        if !searchText.isEmpty {
            transactions = transactions.filter { transaction in
                transaction.description.localizedCaseInsensitiveContains(searchText) ||
                transaction.category.name.localizedCaseInsensitiveContains(searchText) ||
                transaction.account.name.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Sort by date (newest first)
        return transactions.sorted { $0.date > $1.date }
    }
    
    private var groupedTransactions: [Date: [Transaction]] {
        Dictionary(grouping: filteredTransactions) { transaction in
            Calendar.current.startOfDay(for: transaction.date)
        }
    }
    
    private var totalBalance: Double {
        return transactionManager.transactions.reduce(0) { total, transaction in
            switch transaction.type {
            case .income:
                return total + transaction.amount
            case .expense:
                return total - transaction.amount
            case .transfer:
                return total // Transfers don't affect overall balance
            }
        }
    }
    
    private var totalIncome: Double {
        return transactionManager.transactions
            .filter { $0.type == .income }
            .reduce(0) { $0 + $1.amount }
    }
    
    private var totalExpense: Double {
        return transactionManager.transactions
            .filter { $0.type == .expense }
            .reduce(0) { $0 + $1.amount }
    }
    
    // MARK: - Helper Methods
    
    private func deleteTransaction(_ transaction: Transaction) {
        withAnimation(.easeOut(duration: 0.3)) {
            transactionManager.deleteTransaction(transaction)
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

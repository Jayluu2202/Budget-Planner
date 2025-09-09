//
//  ExportDataView.swift
//  Budget Planner
//
//  Created by mac on 08/09/25.
//

import SwiftUI

struct ExportDataView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var fromDate = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
    @State private var toDate = Date()
    @State private var selectedDateRange = "Last 30 days"
    @State private var selectedFormat = "CSV File"
    @State private var includeCategories = true
    @State private var includeAccounts = true
    @State private var includeNotes = true
    @State private var includeRecurringInfo = true
    @State private var groupByMonth = false
    
    let dateRanges = ["Last 7 days", "Last 30 days", "Last 90 days", "This month", "Last month","This year"]
    let exportFormats = [
        ("CSV File", "Comma-separated values for Excel", "square.and.arrow.up.fill", Color.blue),
        ("Excel File", "Microsoft Excel format", "doc.fill", Color.green),
        ("PDF Report", "Formatted document with charts", Color.red)
    ] as [Any]
    
    var selectedOptionsCount: Int {
        var count = 0
        if includeCategories { count += 1 }
        if includeAccounts { count += 1 }
        if includeNotes { count += 1 }
        if includeRecurringInfo { count += 1 }
        if groupByMonth { count += 1 }
        return count
    }
    
    var dateRangeText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd"
        return "\(formatter.string(from: fromDate)) - \(formatter.string(from: toDate)), 2025"
    }
    
    var daysSelectedText: String {
        let days = Calendar.current.dateComponents([.day], from: fromDate, to: toDate).day ?? 0
        return "\(days) days selected"
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                // Date Range Section
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(.primary)
                            .font(.system(size: 18, weight: .medium))
                        Text("Date Range")
                            .font(.headline)
                            .fontWeight(.medium)
                    }
                    
                    // Date Range Buttons
                    ScrollView(.horizontal,showsIndicators: false){
                        HStack(spacing: 8) {
                            ForEach(dateRanges, id: \.self) { range in
                                Button(action: {
                                    selectedDateRange = range
                                    updateDatesForRange(range)
                                }) {
                                    Text(range)
                                        .font(.system(size: 13, weight: .medium))
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(selectedDateRange == range ? Color.blue : Color.gray.opacity(0.15))
                                        .foregroundColor(selectedDateRange == range ? .white : .primary)
                                        .cornerRadius(20)
                                }
                            }
                            Spacer()
                        }
                    }
                    
                    // Custom Date Pickers
                    VStack(spacing: 16) {
                        HStack {
                            Text("From")
                                .font(.subheadline)
                                .foregroundColor(.primary)
                                .fontWeight(.medium)
                            Spacer()
                            DatePicker("", selection: $fromDate, displayedComponents: .date)
                                .labelsHidden()
                                .scaleEffect(0.9)
                        }
                        
                        Divider()
                            .padding(.horizontal, -16)
                        
                        HStack {
                            Text("To")
                                .font(.subheadline)
                                .foregroundColor(.primary)
                                .fontWeight(.medium)
                            Spacer()
                            DatePicker("", selection: $toDate, displayedComponents: .date)
                                .labelsHidden()
                                .scaleEffect(0.9)
                        }
                    }
                    .padding(16)
                    .background(Color.gray.opacity(0.08))
                    .cornerRadius(12)
                    
                    Text(daysSelectedText)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 4)
                }
                .padding()
                
                Divider()
                    .padding(.horizontal)
                
                // Export Format Section
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: "folder.fill")
                            .foregroundColor(.primary)
                            .font(.system(size: 18, weight: .medium))
                        Text("Export Format")
                            .font(.headline)
                            .fontWeight(.medium)
                    }
                    
                    VStack(spacing: 12) {
                        // CSV File Option
                        Button(action: {
                            selectedFormat = "CSV File"
                        }) {
                            HStack(spacing: 12) {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.blue)
                                    .frame(width: 40, height: 40)
                                    .overlay(
                                        Text("CSV")
                                            .font(.system(size: 10, weight: .bold))
                                            .foregroundColor(.white)
                                    )
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("CSV File")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(.primary)
                                    Text("Comma-separated values for Excel")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Image(systemName: selectedFormat == "CSV File" ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(selectedFormat == "CSV File" ? .blue : .gray.opacity(0.5))
                                    .font(.system(size: 20))
                            }
                            .padding(16)
                            .background(Color.gray.opacity(0.05))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(selectedFormat == "CSV File" ? Color.blue : Color.clear, lineWidth: 2)
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        // Excel File Option
                        Button(action: {
                            selectedFormat = "Excel File"
                        }) {
                            HStack(spacing: 12) {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.green)
                                    .frame(width: 40, height: 40)
                                    .overlay(
                                        Text("XLS")
                                            .font(.system(size: 10, weight: .bold))
                                            .foregroundColor(.white)
                                    )
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Excel File")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(.primary)
                                    Text("Microsoft Excel format")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Image(systemName: selectedFormat == "Excel File" ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(selectedFormat == "Excel File" ? .blue : .gray.opacity(0.5))
                                    .font(.system(size: 20))
                            }
                            .padding(16)
                            .background(Color.gray.opacity(0.05))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(selectedFormat == "Excel File" ? Color.blue : Color.clear, lineWidth: 2)
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        // PDF Report Option
                        Button(action: {
                            selectedFormat = "PDF Report"
                        }) {
                            HStack(spacing: 12) {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.red)
                                    .frame(width: 40, height: 40)
                                    .overlay(
                                        Text("PDF")
                                            .font(.system(size: 10, weight: .bold))
                                            .foregroundColor(.white)
                                    )
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("PDF Report")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(.primary)
                                    Text("Formatted document with charts")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Image(systemName: selectedFormat == "PDF Report" ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(selectedFormat == "PDF Report" ? .blue : .gray.opacity(0.5))
                                    .font(.system(size: 20))
                            }
                            .padding(16)
                            .background(Color.gray.opacity(0.05))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(selectedFormat == "PDF Report" ? Color.blue : Color.clear, lineWidth: 2)
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding()
                
                Divider()
                    .padding(.horizontal)
                
                // Export Options Section
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: "gearshape.fill")
                            .foregroundColor(.primary)
                            .font(.system(size: 18, weight: .medium))
                        Text("Export Options")
                            .font(.headline)
                            .fontWeight(.medium)
                    }
                    
                    VStack(spacing: 0) {
                        // Include Categories
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Include Categories")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.primary)
                                Text("Export with category information")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Toggle("", isOn: $includeCategories)
                        }
                        .padding(.vertical, 12)
                        
                        Divider()
                        
                        // Include Accounts
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Include Accounts")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.primary)
                                Text("Show account details for each transaction")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Toggle("", isOn: $includeAccounts)
                        }
                        .padding(.vertical, 12)
                        
                        Divider()
                        
                        // Include Notes
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Include Notes")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.primary)
                                Text("Export transaction notes and descriptions")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Toggle("", isOn: $includeNotes)
                        }
                        .padding(.vertical, 12)
                        
                        Divider()
                        
                        // Include Recurring Info
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Include Recurring Info")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.primary)
                                Text("Show if transaction is recurring")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Toggle("", isOn: $includeRecurringInfo)
                        }
                        .padding(.vertical, 12)
                        
                        Divider()
                        
                        // Group by Month
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Group by Month")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.primary)
                                Text("Organize transactions by month")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Toggle("", isOn: $groupByMonth)
                        }
                        .padding(.vertical, 12)
                    }
                    .padding(16)
                    .background(Color.gray.opacity(0.05))
                    .cornerRadius(12)
                }
                .padding()
                
                // Export Summary Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Export Summary")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    VStack(spacing: 12) {
                        HStack {
                            Text("Date Range:")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(dateRangeText)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                        }
                        
                        HStack {
                            Text("Format:")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(selectedFormat)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                        }
                        
                        HStack {
                            Text("Options:")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("\(selectedOptionsCount) selected")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                        }
                    }
                    .padding(16)
                    .background(Color.gray.opacity(0.05))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                }
                .padding()
                
                // Export Button
                Button(action: {
                    exportData()
                }) {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Export Data")
                            .font(.headline)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.black)
                    .cornerRadius(12)
                }
                .padding()
                .padding(.bottom, 20)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    HStack(spacing: 20){
                        Image(systemName: "chevron.left")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundColor(.black)
                        
                        Text("Export Data")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                    }
                }
            }
        }
        
    }
    
    private func updateDatesForRange(_ range: String) {
        let calendar = Calendar.current
        let now = Date()
        
        switch range {
        case "Last 7 days":
            fromDate = calendar.date(byAdding: .day, value: -7, to: now) ?? now
        case "Last 30 days":
            fromDate = calendar.date(byAdding: .day, value: -30, to: now) ?? now
        case "Last 90 days":
            fromDate = calendar.date(byAdding: .day, value: -90, to: now) ?? now
        case "This month":
            fromDate = calendar.date(from: DateComponents(month: calendar.component(.month, from: now), day: 1)) ?? now
        case "This year":
            fromDate = calendar.date(from: DateComponents(year: calendar.component(.year, from: now), month: 1, day: 1)) ?? now
        default:
            break
        }
        toDate = now
    }
    
    private func exportData() {
        // Handle export functionality here
        print("Exporting \(selectedFormat) from \(fromDate) to \(toDate)")
        print("Include Categories: \(includeCategories)")
        print("Include Accounts: \(includeAccounts)")
        print("Include Notes: \(includeNotes)")
        print("Include Recurring Info: \(includeRecurringInfo)")
        print("Group by Month: \(groupByMonth)")
    }
}

struct ExportDataView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ExportDataView()
        }
    }
}

//
//  ExportDataView.swift
//  Budget Planner
//
//  Enhanced with actual file export functionality
//

import SwiftUI
import UniformTypeIdentifiers
import UIKit
struct ExportDataView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var transactionManager = TransactionManager()
    
    @State private var fromDate = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
    @State private var toDate = Date()
    @State private var selectedDateRange = "Last 30 days"
    @State private var selectedFormat = "CSV File"
    @State private var includeCategories = true
    @State private var includeAccounts = true
    @State private var includeNotes = true
    @State private var includeRecurringInfo = true
    @State private var groupByMonth = false
    
    // Export states
    @State private var isExporting = false
    @State private var showingExportSheet = false
    @State private var exportURL: URL?
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    let dateRanges = ["Last 7 days", "Last 30 days", "Last 90 days", "This month", "Last month","This year"]
    let exportFormats: [(title: String, description: String, icon: String, color: Color)] = [
        ("CSV File", "Comma-separated values for Excel", "square.and.arrow.up.fill", Color.blue),
        ("Excel File", "Microsoft Excel format", "doc.fill", Color.green),
        ("PDF Report", "Formatted document with charts","doc.richtext.fill", Color.red)
    ]
    
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
    
    var filteredTransactions: [Transaction] {
        return transactionManager.transactions.filter { transaction in
            transaction.date >= fromDate && transaction.date <= toDate
        }.sorted { $0.date > $1.date }
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                // Date Range Section
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image("calendar")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                            
                            
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
                                        .background(selectedDateRange == range ? Color.black : Color.gray.opacity(0.15))
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
                                .padding(EdgeInsets(top: 8, leading: 18, bottom: 8, trailing: 18))
                                .background(Color.white)
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.gray, lineWidth: 1)
                                )
                                
                        }
                        .padding(.horizontal)
                        
                                                
                        HStack {
                            Text("To")
                                .font(.subheadline)
                                .foregroundColor(.primary)
                                .fontWeight(.medium)
                            Spacer()
                            DatePicker("", selection: $toDate, displayedComponents: .date)
                                .labelsHidden()
                                .scaleEffect(0.9)
                                .padding(EdgeInsets(top: 8, leading: 18, bottom: 8, trailing: 18))
                                .background(Color.white)
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.gray, lineWidth: 1)
                                )
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical)
                    .background(Color.white)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.4), lineWidth: 2)
                    )
                    
                    Text("\(daysSelectedText)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 4)
                        .frame(maxWidth: .infinity ,alignment: .center)
                }
                .padding()
                
                // Export Format Section
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image("folder")
                            .resizable()
                            .scaledToFit()
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.primary)
                            .frame(width: 24, height: 24)
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
                                Image("csv")
                                    .resizable()
                                    .scaledToFit()
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundColor(.primary)
                                    .frame(width: 35, height: 35)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("CSV File")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(.black)
                                    Text("Comma-separated values for Excel")
                                        .font(.caption)
                                        .foregroundColor(Color.gray)
                                }
                                
                                Spacer()
                                
                                Image(systemName: selectedFormat == "CSV File" ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(selectedFormat == "CSV File" ? .blue : .gray.opacity(0.5))
                                    .font(.system(size: 20))
                            }
                            .padding(16)
                            .background(Color.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(selectedFormat == "CSV File" ? Color.black : Color.gray.opacity(0.4), lineWidth: 2)
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        // Excel File Option (Note: Basic CSV format, real Excel would need additional framework)
                        Button(action: {
                            selectedFormat = "Excel File"
                        }) {
                            HStack(spacing: 12) {
                                Image("xls")
                                    .resizable()
                                    .scaledToFit()
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundColor(.primary)
                                    .frame(width: 35, height: 35)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Excel File")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(.black)
                                    Text("Microsoft Excel format")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                
                                Spacer()
                                
                                Image(systemName: selectedFormat == "Excel File" ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(selectedFormat == "Excel File" ? .blue : .gray.opacity(0.5))
                                    .font(.system(size: 20))
                            }
                            .padding(16)
                            .background(Color.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(selectedFormat == "Excel File" ? Color.black : Color.gray
                                                .opacity(0.4), lineWidth: 2)
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        // PDF Report Option
                        Button(action: {
                            selectedFormat = "PDF Report"
                        }) {
                            HStack(spacing: 12) {
                                Image("pdf")
                                    .resizable()
                                    .scaledToFit()
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundColor(.primary)
                                    .frame(width: 35, height: 35)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("PDF Report")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(.black)
                                    Text("Formatted document with charts")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                
                                Spacer()
                                
                                Image(systemName: selectedFormat == "PDF Report" ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(selectedFormat == "PDF Report" ? .blue : .gray.opacity(0.5))
                                    .font(.system(size: 20))
                            }
                            .padding(16)
                            .background(Color.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(selectedFormat == "PDF Report" ? Color.black : Color.gray.opacity(0.4), lineWidth: 2)
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding()
                
                // Export Options Section
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image("options")
                            .resizable()
                            .scaledToFit()
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.primary)
                            .frame(width: 24, height: 24)
                        
                            
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
                        .padding(16)
                        
                        Divider()
                            .frame(height: 2)
                            .background(Color.gray.opacity(0.4))
                            
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
                        .padding(16)
                        
                        Divider()
                            .frame(height: 2)
                            .background(Color.gray.opacity(0.4))
                            
                        
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
                        .padding(16)
                        
                        Divider()
                            .frame(height: 2)
                            .background(Color.gray.opacity(0.4))
                        
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
                        .padding(16)
                        
                        Divider()
                            .frame(height: 2)
                            .background(Color.gray.opacity(0.4))
                        
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
                        .padding(16)
                    }
//                    .padding(5)
                    .background(Color.white)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.4), lineWidth: 2)
                    )
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
                    .background(Color.white)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.black, lineWidth: 1)
                    )
                }
                .padding()
                
                // Export Button
                Button(action: {
                    exportData()
                }) {
                    HStack {
                        if isExporting {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        Text(isExporting ? "Exporting..." : "Export Data")
                            .font(.headline)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(filteredTransactions.isEmpty ? Color.gray : Color.black)
                    .cornerRadius(12)
                }
                .disabled(isExporting || filteredTransactions.isEmpty)
                .padding()
                .padding(.bottom, 20)
            }
            .padding(.top, scaleH(110))
        }
        .onAppear{
            hideTabBarLegacy()
        }
        .onDisappear{
            showTabBarLegacy()
        }
        .ignoresSafeArea(edges: .top)
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                VStack{
                    Button(action: {
                        dismiss()
                    }) {
                        HStack(spacing: 10){
                            Image(systemName: "chevron.left")
                                .font(.system(size: 17, weight: .medium))
                                .foregroundColor(.black)
                                .frame(width: 20, height: 20)
                            
                            Text("Export Data")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.black)
                            
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.plain)
                    .padding(.bottom, 8)
                    
                    Divider()
//                        .frame(height: 2)
                        .background(.gray)
//                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, scaleW(-250))
                }
                .frame(maxWidth: .infinity)
            }
        }
        .onAppear {
            transactionManager.loadData()
        }
        .sheet(isPresented: $showingExportSheet) {
            if let url = exportURL {
                ActivityViewController(activityItems: [url])
            }
        }
        .alert("Export Status", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func scaleH(_ value: CGFloat) -> CGFloat {
        let deviceHeight = UIScreen.main.bounds.height
        let screenvalue = deviceHeight / 956
        return value * screenvalue
    }
    
    private func scaleW(_ value: CGFloat) -> CGFloat {
        let deviceWidth = UIScreen.main.bounds.width
        let screenValue = deviceWidth / 452
        return value * screenValue
    }
    
    // MARK: - Helper Methods
    
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
            fromDate = calendar.date(from: DateComponents(year: calendar.component(.year, from: now), month: calendar.component(.month, from: now), day: 1)) ?? now
        case "Last month":
            let lastMonth = calendar.date(byAdding: .month, value: -1, to: now) ?? now
            fromDate = calendar.date(from: DateComponents(year: calendar.component(.year, from: lastMonth), month: calendar.component(.month, from: lastMonth), day: 1)) ?? now
            toDate = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: fromDate) ?? now
        case "This year":
            fromDate = calendar.date(from: DateComponents(year: calendar.component(.year, from: now), month: 1, day: 1)) ?? now
        default:
            break
        }
        
        if range != "Last month" {
            toDate = now
        }
    }
    
    // MARK: - Export Functionality
    
    private func exportData() {
        guard !filteredTransactions.isEmpty else {
            alertMessage = "No transactions found for the selected date range."
            showingAlert = true
            return
        }
        
        isExporting = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let fileURL: URL
                
                switch selectedFormat {
                case "CSV File":
                    fileURL = try generateCSVFile()
                case "Excel File":
                    fileURL = try generateExcelFile()
                case "PDF Report":
                    fileURL = try generatePDFReport()
                default:
                    fileURL = try generateCSVFile()
                }
                
                DispatchQueue.main.async {
                    self.exportURL = fileURL
                    self.isExporting = false
                    self.showingExportSheet = true
                }
                
            } catch {
                DispatchQueue.main.async {
                    self.isExporting = false
                    self.alertMessage = "Export failed: \(error.localizedDescription)"
                    self.showingAlert = true
                }
            }
        }
    }
    
    
    
    private func generateCSVFile() throws -> URL {
        var csvContent = generateCSVHeader()
        
        if groupByMonth {
                        
            let groupedTransactions: [Date: [Transaction]] = Dictionary(grouping: filteredTransactions) { transaction in
                let components = Calendar.current.dateComponents([.year, .month], from: transaction.date)
                return Calendar.current.date(from: components)!
            }

            for month in groupedTransactions.keys.sorted() {
                let monthFormatter = DateFormatter()
                monthFormatter.dateFormat = "MMMM yyyy"
                csvContent += "\n\n\"\(monthFormatter.string(from: month))\"\n"
                
                if let transactions = groupedTransactions[month] {
                    for transaction in transactions.sorted(by: { $0.date > $1.date }) {
                        csvContent += generateCSVRow(for: transaction)
                    }
                }
            }
        } else {
            for transaction in filteredTransactions {
                csvContent += generateCSVRow(for: transaction)
            }
        }
        
        let fileName = "transactions_\(DateFormatter.fileNameFormatter.string(from: Date())).csv"

        let url = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        
        try csvContent.write(to: url, atomically: true, encoding: .utf8)
        return url
    }
    
    private func generateCSVHeader() -> String {
        var headers = ["Date", "Type", "Amount"]
        
        if includeAccounts {
            headers.append("Account")
        }
        
        if includeCategories {
            headers.append("Category")
        }
        
        if includeNotes {
            headers.append("Description")
        }
        
        if includeRecurringInfo {
            headers.append("Recurring")
        }
        
        return headers.map { "\"\($0)\"" }.joined(separator: ",")
    }
    
    private func generateCSVRow(for transaction: Transaction) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        var row = [
            dateFormatter.string(from: transaction.date),
            transaction.type.rawValue,
            String(format: "%.2f", transaction.amount)
        ]
        
        if includeAccounts {
            row.append("\(transaction.account.emoji) \(transaction.account.name)")
        }
        
        if includeCategories {
            row.append("\(transaction.category.emoji) \(transaction.category.name)")
        }
        
        if includeNotes {
            let description = transaction.description.isEmpty || transaction.description == "No description" ? "" : transaction.description
            row.append(description)
        }
        
        if includeRecurringInfo {
            row.append(transaction.isRecurring ? "Yes" : "No")
        }
        
        return "\n" + row.map { "\"\($0)\"" }.joined(separator: ",")
    }
    
    private func generateExcelFile() throws -> URL {
            // Generate Excel-compatible CSV content
            var csvContent = generateExcelCompatibleCSV()
            
            // For true Excel format, we'll create a properly formatted CSV that Excel can interpret
            let fileName = "transactions_\(DateFormatter.fileNameFormatter.string(from: Date())).xlsx"
            let url = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
            
            // Create a simple XML-based Excel file
            let excelContent = generateSimpleExcelXML()
            try excelContent.write(to: url, atomically: true, encoding: .utf8)
            
            return url
        }
    
    private func generateExcelCompatibleCSV() -> String {
            var csvContent = generateCSVHeader()
            
            if groupByMonth {
                let groupedTransactions: [Date: [Transaction]] = Dictionary(grouping: filteredTransactions) { transaction in
                    let components = Calendar.current.dateComponents([.year, .month], from: transaction.date)
                    return Calendar.current.date(from: components)!
                }

                for month in groupedTransactions.keys.sorted() {
                    let monthFormatter = DateFormatter()
                    monthFormatter.dateFormat = "MMMM yyyy"
                    csvContent += "\n\n\"\(monthFormatter.string(from: month))\"\n"
                    csvContent += generateCSVHeader() + "\n"
                    
                    if let transactions = groupedTransactions[month] {
                        for transaction in transactions.sorted(by: { $0.date > $1.date }) {
                            csvContent += generateCSVRow(for: transaction)
                        }
                    }
                }
            } else {
                for transaction in filteredTransactions {
                    csvContent += generateCSVRow(for: transaction)
                }
            }
            
            return csvContent
        }
    
    private func generateSimpleExcelXML() -> String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
            
            var xml = """
            <?xml version="1.0" encoding="UTF-8"?>
            <Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet"
             xmlns:o="urn:schemas-microsoft-com:office:office"
             xmlns:x="urn:schemas-microsoft-com:office:excel"
             xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet"
             xmlns:html="http://www.w3.org/TR/REC-html40">
             <DocumentProperties xmlns="urn:schemas-microsoft-com:office:office">
              <Title>Transaction Report</Title>
              <Created>\(ISO8601DateFormatter().string(from: Date()))</Created>
             </DocumentProperties>
             <Worksheet ss:Name="Transactions">
              <Table>
            """
            
            // Generate headers
            let headers = generateCSVHeader()
                .replacingOccurrences(of: "\"", with: "")
                .components(separatedBy: ",")
            
            xml += "<Row>"
            for header in headers {
                xml += "<Cell><Data ss:Type=\"String\">\(header.xmlEscaped)</Data></Cell>"
            }
            xml += "</Row>"
            
            // Generate data rows
            for transaction in filteredTransactions {
                xml += "<Row>"
                
                // Date
                xml += "<Cell><Data ss:Type=\"String\">\(dateFormatter.string(from: transaction.date).xmlEscaped)</Data></Cell>"
                
                // Type
                xml += "<Cell><Data ss:Type=\"String\">\(transaction.type.rawValue.xmlEscaped)</Data></Cell>"
                
                // Amount
                xml += "<Cell><Data ss:Type=\"Number\">\(transaction.amount)</Data></Cell>"
                
                // Additional fields based on options
                if includeAccounts {
                    let accountText = "\(transaction.account.emoji) \(transaction.account.name)"
                    xml += "<Cell><Data ss:Type=\"String\">\(accountText.xmlEscaped)</Data></Cell>"
                }
                
                if includeCategories {
                    let categoryText = "\(transaction.category.emoji) \(transaction.category.name)"
                    xml += "<Cell><Data ss:Type=\"String\">\(categoryText.xmlEscaped)</Data></Cell>"
                }
                
                if includeNotes {
                    let description = transaction.description.isEmpty || transaction.description == "No description" ? "" : transaction.description
                    xml += "<Cell><Data ss:Type=\"String\">\(description.xmlEscaped)</Data></Cell>"
                }
                
                if includeRecurringInfo {
                    xml += "<Cell><Data ss:Type=\"String\">\(transaction.isRecurring ? "Yes" : "No")</Data></Cell>"
                }
                
                xml += "</Row>"
            }
            
            xml += """
              </Table>
             </Worksheet>
            </Workbook>
            """
            
            return xml
        }
    
    private func generatePDFReport() throws -> URL {
        let fileName = "transaction_report_\(DateFormatter.fileNameFormatter.string(from: Date())).pdf"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        let actualCurrency = CurrencyManager().selectedCurrency.symbol
        // Build HTML content first (keep your old code here)
        var htmlContent = """
        <!DOCTYPE html>
        <html>
        <head>
            <title>Transaction Report</title>
            <style>
                body { font-family: Arial, sans-serif; margin: 20px; }
                .header { text-align: center; margin-bottom: 30px; }
                .summary { background-color: #f5f5f5; padding: 15px; border-radius: 5px; margin-bottom: 20px; }
                table { width: 100%; border-collapse: collapse; }
                th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
                th { background-color: #f2f2f2; }
                .income { color: green; }
                .expense { color: red; }
                .transfer { color: blue; }
            </style>
        </head>
        <body>
            <div class="header">
                <h1>Transaction Report</h1>
                <p>\(dateRangeText)</p>
            </div>
            
            <div class="summary">
                <h3>Summary</h3>
                <p>Total Transactions: \(filteredTransactions.count)</p>
                <p>Total Income: \(actualCurrency)\(String(format: "%.2f", filteredTransactions.filter { $0.type == .income }.reduce(0) { $0 + $1.amount }))</p>
                <p>Total Expenses: \(actualCurrency)\(String(format: "%.2f", filteredTransactions.filter { $0.type == .expense }.reduce(0) { $0 + $1.amount }))</p>
            </div>
            
            <table>
                <thead>
                    <tr>
                        <th>Date</th>
                        <th>Type</th>
                        <th>Amount</th>
        """

        if includeAccounts { htmlContent += "<th>Account</th>" }
        if includeCategories { htmlContent += "<th>Category</th>" }
        if includeNotes { htmlContent += "<th>Description</th>" }
        if includeRecurringInfo { htmlContent += "<th>Recurring</th>" }

        htmlContent += """
                    </tr>
                </thead>
                <tbody>
        """

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy HH:mm"

        for transaction in filteredTransactions {
            htmlContent += "<tr>"
            htmlContent += "<td>\(dateFormatter.string(from: transaction.date))</td>"
            htmlContent += "<td class=\"\(transaction.type.rawValue.lowercased())\">\(transaction.type.rawValue)</td>"
            htmlContent += "<td>\(actualCurrency)\(String(format: "%.2f", transaction.amount))</td>"
            
            if includeAccounts {
                htmlContent += "<td>\(transaction.account.emoji) \(transaction.account.name)</td>"
            }
            if includeCategories {
                htmlContent += "<td>\(transaction.category.emoji) \(transaction.category.name)</td>"
            }
            if includeNotes {
                let description = transaction.description.isEmpty || transaction.description == "No description" ? "-" : transaction.description
                htmlContent += "<td>\(description)</td>"
            }
            if includeRecurringInfo {
                htmlContent += "<td>\(transaction.isRecurring ? "Yes" : "No")</td>"
            }
            
            htmlContent += "</tr>"
        }

        htmlContent += """
                </tbody>
            </table>
        </body>
        </html>
        """

        // Create PDF renderer
        let format = UIGraphicsPDFRendererFormat()
        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: 612, height: 792), format: format) // A4 size
        
        try renderer.writePDF(to: url) { context in
            context.beginPage()
            
            // Convert HTML into an NSAttributedString
            if let data = htmlContent.data(using: .utf8),
               let attributedString = try? NSAttributedString(
                    data: data,
                    options: [
                        .documentType: NSAttributedString.DocumentType.html,
                        .characterEncoding: String.Encoding.utf8.rawValue
                    ],
                    documentAttributes: nil
               ) {
                
                attributedString.draw(in: CGRect(x: 20, y: 20, width: 572, height: 752))
            }
        }

        return url
    }

}

extension ExportDataView {
    // Updated method for hiding tab bar
    private func hideTabBarLegacy() {
        DispatchQueue.main.async {
            // Method 1: Using scene-based approach (iOS 13+)
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                if let tabBarController = window.rootViewController as? UITabBarController {
                    tabBarController.tabBar.isHidden = true
                } else {
                    // Method 2: Navigate through view hierarchy
                    findAndHideTabBar(in: window.rootViewController)
                }
            }
        }
    }
    
    private func showTabBarLegacy() {
        DispatchQueue.main.async {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                if let tabBarController = window.rootViewController as? UITabBarController {
                    tabBarController.tabBar.isHidden = false
                } else {
                    findAndShowTabBar(in: window.rootViewController)
                }
            }
        }
    }
    
    // Recursive method to find tab bar controller
    private func findAndHideTabBar(in viewController: UIViewController?) {
        guard let vc = viewController else { return }
        
        if let tabBarController = vc as? UITabBarController {
            tabBarController.tabBar.isHidden = true
        } else if let navigationController = vc as? UINavigationController {
            findAndHideTabBar(in: navigationController.topViewController)
        } else {
            for child in vc.children {
                findAndHideTabBar(in: child)
            }
        }
    }
    
    private func findAndShowTabBar(in viewController: UIViewController?) {
        guard let vc = viewController else { return }
        
        if let tabBarController = vc as? UITabBarController {
            tabBarController.tabBar.isHidden = false
        } else if let navigationController = vc as? UINavigationController {
            findAndShowTabBar(in: navigationController.topViewController)
        } else {
            for child in vc.children {
                findAndShowTabBar(in: child)
            }
        }
    }
}
// MARK: - Activity View Controller

struct ActivityViewController: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - DateFormatter Extension

extension DateFormatter {
    static let fileNameFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        return formatter
    }()
}

struct ExportDataView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ExportDataView()
        }
    }
}

extension String {
    var xmlEscaped: String {
        var escaped = self
        escaped = escaped.replacingOccurrences(of: "&", with: "&amp;")
        escaped = escaped.replacingOccurrences(of: "<", with: "&lt;")
        escaped = escaped.replacingOccurrences(of: ">", with: "&gt;")
        escaped = escaped.replacingOccurrences(of: "\"", with: "&quot;")
        escaped = escaped.replacingOccurrences(of: "'", with: "&apos;")
        return escaped
    }
}

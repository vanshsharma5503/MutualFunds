//
//  Fund Selection Screen.swift
//  MutualFundsApp
//
//  Created by Vansh Sharma on 20/08/25.
//
import SwiftUI
import Charts // Swift Charts for graph (iOS 16+)

// MARK: - Main Fund Selection Screen
struct Fund_Selection_Screen: View {
    @EnvironmentObject var userManager: UserManager
    @StateObject var viewModel = FundsListViewModel()
    
    @State private var searchText = ""
    @State private var showFilterSheet: Bool = false
    
    @State private var selectedAMC: String = "All"
    @State private var selectedCategory: String = "All"
    @State private var selectedType: String = "All"
    
    let categories = ["All", "Equity", "Debt"]
    let types = ["All", "Growth", "Dividend"]
    
    @State private var selectedFundDetail: Funds?
    
    // NEW: selection mode + comparison
    @State private var isSelectionMode = false
    @State private var comparisonFunds: [Funds] = []
    @State private var showComparison = false
    
    // MARK: - Filtered Funds
    var filteredFunds: [Funds] {
        viewModel.funds.filter { fund in
            let name = fund.schemeName.lowercased()
            let matchesSearch = searchText.isEmpty || name.contains(searchText.lowercased())
            let matchesAMC = (selectedAMC == "All") || name.contains(selectedAMC.lowercased())
            let matchesCategory = (selectedCategory == "All") || name.contains(selectedCategory.lowercased())
            let matchesType = (selectedType == "All") || name.contains(selectedType.lowercased())
            return matchesSearch && matchesAMC && matchesCategory && matchesType
        }
    }
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                LinearGradient(
                    colors: [.blue.opacity(0.3), .purple.opacity(0.3)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(alignment: .leading, spacing: 16) {
                    
                    // MARK: - Header
                    HStack {
                        Text("Explore")
                            .font(.system(size: 40, weight: .bold))
                            .padding(.horizontal)
                            .padding(.top)
                        
                        Spacer()
                        
                        // Filter button
                        Button {
                            showFilterSheet.toggle()
                        } label: {
                            Image(systemName: "line.3.horizontal.decrease.circle")
                                .font(.system(size: 26))
                                .padding(8)
                                .foregroundColor(.black)
                        }
                        
                        // Selection mode button
                        Button {
                            withAnimation {
                                isSelectionMode.toggle()
                                if !isSelectionMode {
                                    comparisonFunds.removeAll()
                                }
                            }
                        } label: {
                            Image(systemName: isSelectionMode ? "xmark.circle.fill" : "plus.circle")
                                .font(.system(size: 28))
                                .foregroundColor(.black)
                                .padding(8)
                        }
                    }
                    
                    // MARK: - Funds List
                    if viewModel.isLoading {
                        ProgressView("Loading funds...")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if let error = viewModel.errorMessage {
                        Text("Error: \(error)")
                            .foregroundColor(.red)
                            .padding()
                    } else {
                        VStack {
                            if isSelectionMode {
                                Text("Selected: \(comparisonFunds.count)/4")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(.black.opacity(0.7))
                                    .padding(.horizontal)
                            }
                            
                            List(filteredFunds, id: \.schemeCode) { fund in
                                HStack {
                                    Text(fund.schemeName)
                                        .font(.headline)
                                    Spacer()
                                    if isSelectionMode,
                                       comparisonFunds.contains(where: { $0.schemeCode == fund.schemeCode }) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.blue)
                                    }
                                }
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    if isSelectionMode {
                                        toggleComparisonFund(fund)
                                    } else {
                                        selectedFundDetail = fund
                                        userManager.savePastViewedFund(fund)
                                    }
                                }
                                .swipeActions(edge: .trailing) {
                                    if !isSelectionMode {
                                        Button {
                                            userManager.saveSelectedFund(fund)
                                        } label: {
                                            Label("Save", systemImage:
                                                  userManager.selectedFunds.contains(where: { $0.schemeCode == fund.schemeCode }) ?
                                                  "heart.fill" : "heart")
                                        }
                                        .tint(.pink)
                                    }
                                }
                            }
                            .listStyle(.insetGrouped)
                            .scrollContentBackground(.hidden)
                            .searchable(text: $searchText, prompt: "Search for funds...")
                            
                            // Compare button
                            if isSelectionMode {
                                Button(action: { showComparison = true }) {
                                    Text("Compare")
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(comparisonFunds.count >= 2 && comparisonFunds.count <= 4 ? Color.blue : Color.gray)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                }
                                .disabled(!(comparisonFunds.count >= 2 && comparisonFunds.count <= 4))
                                .padding(.horizontal)
                            }
                        }
                    }
                }
            }
            .task { await viewModel.getFunds() }
            .sheet(item: $selectedFundDetail) { fund in
                FundDetailView(fund: fund)
            }
            .sheet(isPresented: $showFilterSheet) {
                FilterSheetView(
                    amcs: viewModel.amcList,
                    categories: categories,
                    types: types,
                    selectedAMC: $selectedAMC,
                    selectedCategory: $selectedCategory,
                    selectedType: $selectedType
                )
            }
            .sheet(isPresented: $showComparison) {
                ComparisonView(funds: comparisonFunds)
            }
        }
    }
    
    // MARK: - Helpers
    private func toggleComparisonFund(_ fund: Funds) {
        if let idx = comparisonFunds.firstIndex(where: { $0.schemeCode == fund.schemeCode }) {
            comparisonFunds.remove(at: idx)
        } else if comparisonFunds.count < 4 {
            comparisonFunds.append(fund)
        }
    }
}

// MARK: - Fund Detail
struct FundDetailView: View {
    let fund: Funds
    @State private var navHistory: [NavData] = []
    @State private var isLoading = true
    
    var body: some View {
        VStack {
            Text(fund.schemeName)
                .font(.title2).bold()
                .padding()
            
            if isLoading {
                ProgressView("Loading NAV data...")
            } else {
                Chart(navHistory) { nav in
                    LineMark(
                        x: .value("Date", nav.date),
                        y: .value("NAV", nav.nav)
                    )
                }
                .frame(height: 300)
            }
            Spacer()
        }
        .task { await fetchNavHistory() }
    }
    
    private func fetchNavHistory() async {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        // Mock NAV data
        navHistory = [
            NavData(date: formatter.date(from: "2025-08-01")!, nav: 102.5),
            NavData(date: formatter.date(from: "2025-08-10")!, nav: 104.2),
            NavData(date: formatter.date(from: "2025-08-20")!, nav: 101.8)
        ]
        isLoading = false
    }
}

// MARK: - Comparison View
struct ComparisonView: View {
    let funds: [Funds]
    @State private var navHistories: [String: [NavData]] = [:]
    @State private var isLoading = true
    
    var body: some View {
        VStack {
            Text("Comparison")
                .font(.title)
                .bold()
            
            if isLoading {
                ProgressView("Loading NAVs...")
            } else {
                Chart {
                    ForEach(funds, id: \.schemeCode) { fund in
                        if let data = navHistories[String(fund.schemeCode)] {
                            ForEach(data) { nav in
                                LineMark(
                                    x: .value("Date", nav.date),
                                    y: .value("NAV", nav.nav),
                                    series: .value("Fund", fund.schemeName)
                                )
                                .foregroundStyle(by: .value("Fund", fund.schemeName))
                            }
                        }
                    }
                }
                .frame(height: 300)
            }
        }
        .padding()
        .task { await fetchComparisonData() }
    }
    
    private func fetchComparisonData() async {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        // Mock comparison data
        for fund in funds {
            navHistories[String(fund.schemeCode)] = [
                NavData(date: formatter.date(from: "2025-08-01")!, nav: 102.5),
                NavData(date: formatter.date(from: "2025-08-10")!, nav: 104.2),
                NavData(date: formatter.date(from: "2025-08-20")!, nav: 101.8)
            ]
        }
        isLoading = false
    }
}

// MARK: - Filter Sheet
// MARK: - Filter Sheet
struct FilterSheetView: View {
    let amcs: [String]
    let categories: [String]
    let types: [String]
    
    @Binding var selectedAMC: String
    @Binding var selectedCategory: String
    @Binding var selectedType: String
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                Text("Filters")
                    .font(.title2)
                    .bold()
                    .padding(.top)
                
                // AMC Filter
                Menu {
                    ForEach(["All"] + amcs, id: \.self) { amc in
                        Button(amc) { selectedAMC = amc }
                    }
                } label: {
                    Label("AMC: \(selectedAMC)", systemImage: "building.2")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                }
                
                // Category Filter
                Menu {
                    ForEach(categories, id: \.self) { category in
                        Button(category) { selectedCategory = category }
                    }
                } label: {
                    Label("Category: \(selectedCategory)", systemImage: "square.grid.2x2")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                }
                
                // Type Filter
                Menu {
                    ForEach(types, id: \.self) { type in
                        Button(type) { selectedType = type }
                    }
                } label: {
                    Label("Type: \(selectedType)", systemImage: "list.bullet")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                }
                
                Spacer()
                
                // 🔹 Reset Button
                Button {
                    selectedAMC = "All"
                    selectedCategory = "All"
                    selectedType = "All"
                } label: {
                    Text("Reset Filters")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.bottom, 20)
            }
            .padding()
        }
    }
}


// MARK: - NAV Data Model
struct NavData: Identifiable {
    let id = UUID()
    let date: Date
    let nav: Double
}

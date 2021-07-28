//
//  ChooseView.swift
//  Utai
//
//  Created by Toto Minai on 2021/06/12.
//

import SwiftUI

struct ChooseView: View {
    @EnvironmentObject var store: Store
    
    @Environment(\.openURL) var openURL
    @Environment(\.hostingWindow) var hostingWindow
    
    @State private var subWindow: NSWindow!
    
    @State private var response: SearchResponse!
    
    @State private var chosen: Int?
    
    @State private var yearGroup: [Int]?
    @State private var yearGroupChoice: Int?
    private var yearGroupChoiceMask: Binding<Int?> { Binding {
        yearGroupChoice
    } set: {
        yearGroupChoice = yearGroupChoice == $0 ? nil : $0
        
        updateDefaultChosen()
    }}
    
    @State private var formatGroup: [String]?
    @State private var formatGroupChoice: String?
    private var formatGroupChoiceMask: Binding<String?> { Binding {
        formatGroupChoice
    } set: {
        formatGroupChoice = formatGroupChoice == $0 ? nil : $0
        
        updateDefaultChosen()
    }}
    @AppStorage(Settings.preferCD) var preferCD: Bool = true
    private var preferCDMask: Binding<Bool> { Binding {
        preferCD
    } set: {
        preferCD = $0
        
        if preferCD && formatGroupChoice == nil {
            if let group = formatGroup {
                if group.contains(where: { $0 == "CD" }) {
                    formatGroupChoice = "CD"
                    
                    updateDefaultChosen()
                }
            }
        }
    }}
    
    @AppStorage(Settings.preferReleaseOnly) var preferReleaseOnly: Bool = true
    private var preferReleaseOnlyMask: Binding<Bool> { Binding {
        preferReleaseOnly
    } set: {
        preferReleaseOnly = $0
        
        if preferReleaseOnly {
            showMode = .release
            
            updateDefaultChosen()
        }
    }}
    
    @State private var labelGroup: [String]?
    @State private var labelGroupChoice: String?
    private var labelGroupChoiceMask: Binding<String?> { Binding {
        labelGroupChoice
    } set: {
        labelGroupChoice = labelGroupChoice == $0 ? nil : $0
        
        updateDefaultChosen()
    }}
    
    @State private var shouldScrollToChosen: Bool = false
    
    var header: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                if unit.album == nil {
                    Text("Music by ")
                        .foregroundColor(.secondary)
                        .fontWeight(.medium)
                        .textSelection(.disabled)
                }
                CustomText("\(artistRaw)")
                CustomText(unit.artist != nil &&
                     unit.album != nil ? " – " : "")
                CustomText("\(albumRaw)")
            }
            .textSelection(.enabled)
            .padding(.horizontal, Metrics.lilSpacing2x+Metrics.lilIconLength)
        }
    }
    
    @State var showMode: ShowMode = .both
    private var showModeMask: Binding<ShowMode> {
        Binding { showMode } set: {
            showMode = $0
            
            if showMode != .both && sortMode == .MR {
                sortMode = .none
            }
            
            if let first = resultsProcessed.first {
                chosen = first.id
            } else {
                chosen = nil
            }
        }
    }
    
    @State private var sortMode: SortMode = .none
    
    @FocusState private var isOptionsFocused: Bool
    
    var footer: some View {
        VStack {
            Spacer()
            
            HStack {
                Spacer()
                    
                Menu { extraMenu } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.system(size: 12))
                        .help("Options")
                        .padding(Metrics.lilSpacing)
                }
                .menuStyle(BorderlessButtonMenuStyle())
                .menuIndicator(.hidden)
                .help("Options (⌘ , )")
                .frame(width: Metrics.lilSpacing2x+Metrics.lilIconLength,
                       height: Metrics.lilSpacing2x+Metrics.lilIconLength)
                .offset(x: 2, y: -0.5)
                .focused($isOptionsFocused)
                .onReceive(NotificationCenter.default.publisher(for: Notification.Name("toggleOptions"))) { _ in
                    isOptionsFocused = true
                    
                    let source = CGEventSource(stateID: CGEventSourceStateID.hidSystemState)
                    let spaceKey: UInt16 = 49
                    
                    let spaceDown = CGEvent(keyboardEventSource: source, virtualKey: spaceKey, keyDown: true)
                    let spaceUp = CGEvent(keyboardEventSource: source, virtualKey: spaceKey, keyDown: false)
                    spaceDown?.flags = .maskNonCoalesced
                    spaceUp?.flags = .maskNonCoalesced
                    
                    let tap = CGEventTapLocation.cghidEventTap
                    spaceDown?.post(tap: tap)
                    spaceUp?.post(tap: tap)
                }
            }
        }
    }
    
    var extraMenu: some View {
        Group {
            Section {
                Picker("Show", selection: showModeMask) {
                    Text("Masters Only").tag(ShowMode.master)
                    Text("Releases Only").tag(ShowMode.release)
                    Divider()
                    Text("Both").tag(ShowMode.both)
                }
                
                Picker("Sort By", selection: $sortMode) {
                    if showMode == .both {
                        Text("Master, Release").tag(SortMode.MR)
                    }
                    Text("Year").tag(SortMode.year)
                    Divider()
                    Text("Default").tag(SortMode.none)
                }
            }
            
            Divider()
            
            Section("Filters") {
                Picker("Year", selection: yearGroupChoiceMask) {
                    if let group = yearGroup {
                        ForEach(group, id: \.self) { member in
                            if let choice = yearGroupChoice, choice == member {
                                Text(year2Text(member)).tag(member as Int?)
                            } else if !isResultsEmptyWhenYear(is: member) {
                                Text(year2Text(member)).tag(member as Int?)
                            }
                        }
                    }
                }
                
                Picker("Format", selection: formatGroupChoiceMask) {
                    if let group = formatGroup {
                        ForEach(group, id: \.self) { member in
                            if let choice = formatGroupChoice, choice == member {
                                Text(member).tag(member as String?)
                            } else if !isResultsEmptyWhenFormat(is: member) {
                                Text(member).tag(member as String?)
                            }
                        }
                    }
                }
                
                Picker("Label", selection: labelGroupChoiceMask) {
                    if let group = labelGroup {
                        ForEach(group, id: \.self) { member in
                            if let choice = labelGroupChoice, choice == member {
                                Text(member).tag(member as String?)
                            } else if !isResultsEmptyWhenLabel(is: member) {
                                Text(member).tag(member as String?)
                            }
                        }
                    }
                }
                
                Button("Clear All") {
                    yearGroupChoice = nil
                    formatGroupChoice = nil
                    labelGroupChoice = nil
                    
                    updateDefaultChosen()
                }
                .disabled(yearGroupChoice == nil &&
                          formatGroupChoice == nil &&
                          labelGroupChoice == nil)
                .keyboardShortcut(.delete, modifiers: [])
            }
            
            Divider()
            
            Section("Preferences") {
                Toggle("Show CDs if Available", isOn: preferCDMask)
                    
                Toggle("Prefer Releases", isOn: preferReleaseOnlyMask)
            }
        }
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            if store.page == 2 {
                Group {
                    Button("") { store.didReferencePicked(using: chosenResult.resourceURL) }
                        .keyboardShortcut(.return, modifiers: [])
                    
                    // ←
                    Button("") { toPrevious() }
                        .keyboardShortcut("h", modifiers: [])
                    Button("") { toPrevious() }
                        .keyboardShortcut("k", modifiers: [])
                    Button("") { toPrevious() }
                        .keyboardShortcut(.tab, modifiers: .shift)
                    
                    // →
                    Button("") { toNext() }
                        .keyboardShortcut("j", modifiers: [])
                    Button("") { toNext() }
                        .keyboardShortcut("l", modifiers: [])
                    Button("") { toNext() }
                        .keyboardShortcut(.tab, modifiers: [])
                }
                .hidden()
            }
            
            VStack(spacing: Metrics.lilSpacing2x) {
                if store.localUnit != nil { header }
                
                if response != nil && store.searchURL == nil {
                    if !results.isEmpty {
                        if !resultsProcessed.isEmpty {
                            Color.clear.frame(height: 80)
                            
                            if let chosen = chosen {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: Metrics.lilSpacing) {
                                        VStack(alignment: .trailing, spacing: 4) {
                                            Text("Versus")
                                                .fontWeight(.medium)
                                            Text("Released")
                                                .fontWeight(.medium)
                                                .opacity(chosenYearInCR != " " ? 1 : 0.3)
                                            Text("Format")
                                                .fontWeight(.medium)
                                                .opacity(chosenResult.format != nil ? 1 : 0.3)
                                            Text("Label")
                                                .fontWeight(.medium)
                                            
                                            Spacer()  // Keep 2 VStack aligned
                                        }
                                        .foregroundColor(.secondary)
                                        .animation(.easeOut, value: chosen)
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            CustomText("\(chosenTitleStyled)")
                                            CustomText("\(chosenYearInCR)")
                                            CustomText("\(chosenFormatStyled)")
                                            CustomText("\(chosenLabelStyled)")
                                            Button("**View on Discogs**") {
                                                openURL(URL(string: "https://discogs.com\(chosenResult.uri)")!)
                                            }
                                            .buttonStyle(.borderless)
                                            .foregroundColor(.secondary)
                                            .padding(.top, 2)
                                            .textSelection(.disabled)
                                            
                                            Spacer()
                                        }
                                        .animation(nil, value: chosen)
                                    }
                                    .padding(.horizontal, Metrics.lilSpacing2x+Metrics.lilIconLength)
                                }
                            }
                        } else { Text("No Album Under Such Condition").fontWeight(.bold) }
                    } else { Text("No Album Found").fontWeight(.bold) }
                } else { Text("Searching…").fontWeight(.bold) }
                
                Spacer()
            }
            .padding(.top, Metrics.lilSpacing2x+Metrics.lilIconLength)
            .contextMenu { if response != nil && store.searchURL == nil { extraMenu } }
                
            if store.page == 2 {
                if response != nil && store.searchURL == nil { footer }
                
                doWhenTurnToThisPage
                
                if store.searchURL != nil { doWhenNeededSearch }
            }
        }
        .frame(width: Metrics.unitLength, height: Metrics.unitLength)
        .onAppear {  // doWhenBuildiThisPage
            subWindow = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 352, height: 120),
                                 styleMask: [], backing: .buffered, defer: false)
            
            let rootView = ArtworkView(store: store, subWindow: $subWindow, response: $response, searchURL: $store.searchURL, chosen: $chosen, showMode: $showMode, sortMode: $sortMode, yearGroupChoice: $yearGroupChoice, formatGroupChoice: $formatGroupChoice, labelGroupChoice: $labelGroupChoice, shouldScrollToChosen: $shouldScrollToChosen)
            
            subWindow.titleVisibility = .hidden
            subWindow.backgroundColor = NSColor.clear
            subWindow.hasShadow = false
            
            subWindow.contentView = NSHostingView(rootView: rootView)
        }
    }
    
    var doWhenTurnToThisPage: some View {
        void.onAppear {
            if chosen == nil && response != nil {
                if let first = resultsProcessed.first {
                    chosen = first.id
                }
            }
            
            // SearchResponse do not need an update
            if store.searchURL == nil && response != nil {
                let frame = window.frame
                subWindow.setFrameOrigin(
                    NSPoint(x: frame.minX-20, y: frame.maxY-157))
                window.addChildWindow(subWindow, ordered: .above)
            }
        }
        .onDisappear {
            subWindow.orderOut(nil)
            if window != nil {
                window.removeChildWindow(subWindow)
            }
        }
    }
    
    var doWhenNeededSearch: some View {
        void.onAppear {
            response = nil
            
            sortMode = .none
            
            yearGroupChoice = nil
            formatGroupChoice = nil
            labelGroupChoice = nil
            
            Task {
                do { try await search() }
                catch { print(error) }
                
                parseForConditions()
                
                if let first = resultsProcessed.first {
                    chosen = first.id
                }
                
                if preferCD {
                    if let group = formatGroup {
                        if group.contains(where: { $0 == "CD" }) {
                            formatGroupChoice = "CD"
                            
                            updateDefaultChosen()
                            
                            if resultsProcessed.isEmpty {
                                formatGroupChoice = nil
                                
                                updateDefaultChosen()
                            }
                        }
                    }
                }
                
                if preferReleaseOnly {
                    showMode = .release
                    
                    updateDefaultChosen()
                }
                
                store.searchURL = nil
                
                let frame = window.frame
                subWindow.setFrameOrigin(
                    NSPoint(x: frame.minX-20, y: frame.maxY-157))
                window.addChildWindow(subWindow, ordered: .above)
            }
        }
    }
}

extension Array where Element == SearchResponse.Result {
    func processed(in mode: ShowMode) -> [Element]  {
        var processed = self
        
        switch mode {
        case .master:
            processed = processed.filter {
                $0.type == "master"
            }
        case .release:
            processed = processed.filter {
                $0.type == "release"
            }
        default: break
        }
        
        return processed
    }
    
    func processed(in mode: SortMode) -> [Element]  {
        var processed = self
        
        switch mode {
        case .MR:
            processed = processed.sorted {
                $1.type == "release" && $0.type == "master"
            }
        case .year:
            processed = processed.sorted { former, latter in
                let x = former.year != nil ? Int(former.year!) ?? Int.max : Int.max
                let y = latter.year != nil ? Int(latter.year!) ?? Int.max : Int.max
                
                return x < y
            }
        default: break
        }
        
        return processed
    }
    
    func filterd(year choice: Int?) -> [Element] {
        if let choice = choice {
            return self.filter {
                if let year = $0.year {
                    return Int(year)! / 10 == choice
                } else {
                    return choice == Int.max
                }
            }
        }
        
        return self
    }
    
    func filterd(format choice: String?) -> [Element] {
        if let choice = choice {
            return self.filter {
                if $0.type == "release" {
                    if let formats = $0.formats,
                        let first = formats.first {
                        return first.name == choice
                    }
                } else if $0.type == "master" {
                    if let format = $0.format,
                       let first = format.first {
                        return first == choice
                    }
                }
                
                return false
            }
        }
        
        return self
    }
    
    func filterd(label choice: String?) -> [Element] {
        if let choice = choice {
            return self.filter {
                if let label = $0.label,
                   let first = label.first {
                    return first == choice
                } else { return choice == "Unknown" }
            }
        }
        
        return self
    }
}

extension ChooseView {
    private var window: NSWindow! { self.hostingWindow() }
    
    private var unit: LocalUnit { store.localUnit! }
    private var albumRaw: String { unit.album ?? "" }
    private var artistRaw: String { unit.artist ?? "" }
    
    private var results: [SearchResponse.Result] {
        response.results
    }
    
    private var resultsInModes: [SearchResponse.Result] {
        results
            .processed(in: showMode)
            .processed(in: sortMode)
    }
    
    private var resultsProcessed: [SearchResponse.Result] {
        resultsInModes
            .filterd(year: yearGroupChoice)
            .filterd(format: formatGroupChoice)
            .filterd(label: labelGroupChoice)
    }
    
    private func isResultsEmptyWhenYear(is x: Int?) -> Bool {
        resultsInModes
            .filterd(year: x)
            .filterd(format: formatGroupChoice)
            .filterd(label: labelGroupChoice)
            .isEmpty
    }
    
    private func isResultsEmptyWhenFormat(is x: String?) -> Bool {
        resultsInModes
            .filterd(year: yearGroupChoice)
            .filterd(format: x)
            .filterd(label: labelGroupChoice)
            .isEmpty
    }
    
    private func isResultsEmptyWhenLabel(is x: String?) -> Bool {
        resultsInModes
            .filterd(year: yearGroupChoice)
            .filterd(format: formatGroupChoice)
            .filterd(label: x)
            .isEmpty
    }
    
    private var chosenResult: SearchResponse.Result {
        resultsProcessed.first { $0.id == chosen }!
    }
    
    private var chosenTitleStyled: String {
        if chosen != nil {
            return chosenResult.title
                .replacingOccurrences(of: " - ", with: " – ")
                .replacingOccurrences(of: "*", with: "†")
        } else { return "" }
    }
    
    private var chosenYearInCR: String {
        if chosen != nil {
            var processed = [chosenResult.year,
                             chosenResult.country]
            processed.removeAll { $0 == nil }
            
            return processed.map { $0!.replacingOccurrences(of: " & ", with: ", ") }
                            .joined(separator: ", ")
        } else { return " " }
    }
    
    private var chosenFormatStyled: String {
        if let _ = chosen {
            if chosenResult.type == "release" {
                if let formats = chosenResult.formats {
                    var styled = [String]()
                    
                    for format in formats {
                        let qty = Int(format.qty)!
                        
                        let filtered = format.descriptions ?? []
                        
                        let part = (qty > 1 ? "\(qty) × " : "") +
                        format.name +
                            (filtered.isEmpty ? "" : " (\(filtered.joined(separator: ", ")))")
                        
                        styled.append(part)
                    }
                    
                    return styled.joined(separator: " / ")
                }
            } else if chosenResult.type == "master" {
                if let format = chosenResult.format,
                   let first = format.first {
                    let formatLeft = format.dropFirst()
                    
                    return first + (formatLeft.isEmpty ?
                                    " " : " (\(formatLeft.joined(separator: ", ")))")
                }
            }
            
            return " "
        } else { return " " }
    }
    
    private var chosenLabelStyled: String {
        if let _ = chosen,
           let label = chosenResult.label,
           let first = label.first {
            return first
        } else { return " " }
    }
    
    enum SearchError: Error { case badURL }
    
    private func search() async throws {
        let (data, code) = try await URLSession.shared.data(from: store.searchURL!)
        guard (code as? HTTPURLResponse)?.statusCode == 200
        else { throw SearchError.badURL }
        
        do {
            let response = try JSONDecoder().decode(SearchResponse.self, from: data)
            withAnimation(.easeOut) { self.response = response }
        } catch { throw error }
    }
    
    private func parseForConditions() {
        var yearGroupSet = Set<Int>()
        var formatGroupSet = Set<String>()
        var labelGroupSet = Set<String>()
        var hasUnknown = false
        
        results.forEach {
            if $0.type == "release" {
                if let formats = $0.formats,
                   let first = formats.first {
                    formatGroupSet.insert(first.name)
                }
            } else if $0.type == "master" {
                if let format = $0.format,
                   let first = format.first {
                    formatGroupSet.insert(first)
                }
            }
            
            if let year = $0.year {
                yearGroupSet.insert(Int(year)! / 10)
            } else { yearGroupSet.insert(Int.max) }
            
            if let label = $0.label,
               let first = label.first {
                   labelGroupSet.insert(first)
            } else { hasUnknown = true }
        }
        
        self.yearGroup = yearGroupSet.sorted()
        self.formatGroup = formatGroupSet.sorted()
        
        var processed = labelGroupSet.sorted()
        if hasUnknown { processed.append("Unknown") }
        self.labelGroup = processed
    }
    
    private func updateDefaultChosen() {
        if let first = resultsProcessed.first {
            chosen = first.id
        } else {
            chosen = nil
        }
    }
    
    private func year2Text(_ x: Int) -> String {
        if x == Int.max { return "Unknown" }
        
        return String("\(x * 10)s")
    }
    
    private func toNext() {
        if let chosen = chosen {
            let count = resultsProcessed.count
            let index = resultsProcessed.firstIndex { $0.id == chosen }!
            self.chosen = resultsProcessed[min(count - 1, index+1)].id
            shouldScrollToChosen = true
        }
    }
    
    private func toPrevious() {
        if let chosen = chosen {
            let index = resultsProcessed.firstIndex { $0.id == chosen }!
            self.chosen = resultsProcessed[max(0, index-1)].id
            shouldScrollToChosen = true
        }
    }
}

struct ArtworkView: View {
    @ObservedObject var store: Store
    
    @Binding var subWindow: NSWindow?
    
    @Binding var response: SearchResponse?
    
    @Binding var searchURL: URL?
    
    @Binding var chosen: Int?
    @Binding var showMode: ShowMode
    @Binding var sortMode: SortMode
    
    @Binding var yearGroupChoice: Int?
    @Binding var formatGroupChoice: String?
    @Binding var labelGroupChoice: String?
    
    @Binding var shouldScrollToChosen: Bool
    
    
    var body: some View {
        ZStack {
            if response != nil && searchURL == nil && !results.isEmpty && !resultsProcessed.isEmpty {
                ScrollViewReader { proxy in
                    ScrollView(.horizontal, showsIndicators: false) {
                        ZStack {
                            Color.red.opacity(0.001)
                                .frame(height: 80)
                            
                            LazyHStack(alignment: .top, spacing: Metrics.lilSpacing) {
                                ForEach(resultsProcessed, id: \.id) { result in
                                    Artwork80x80(store: store, chosen: $chosen, result: result)
                                }
                            }
                            .padding(.horizontal, Metrics.lilSpacing2x+Metrics.lilIconLength+20)
                            .frame(height: 120)
                        }
                    }
                    .onChange(of: chosen) { newValue in
                        if shouldScrollToChosen {
                            proxy.scrollTo(chosen, anchor: .center)
                            shouldScrollToChosen = false
                        }
                    }
                }
                .mask {
                    HStack(spacing: 0) {
                        LinearGradient(colors: [Color.yellow.opacity(0), Color.yellow], startPoint: .leading, endPoint: .trailing)
                            .frame(width: 12)
                        
                        Rectangle()
                        
                        LinearGradient(colors: [Color.yellow.opacity(0), Color.yellow], startPoint: .trailing, endPoint: .leading)
                            .frame(width: 12)
                    }
                }
            }
        }
        .frame(width: 352, height: 120)
    }
}

extension ArtworkView {
    private var results: [SearchResponse.Result] {
        response!.results
    }
    
    private var resultsProcessed: [SearchResponse.Result] {
        return results
            .processed(in: showMode)
            .processed(in: sortMode)
            // Filters
            .filterd(year: yearGroupChoice)
            .filterd(format: formatGroupChoice)
            .filterd(label: labelGroupChoice)
    }
}

struct Artwork80x80: View {
    @ObservedObject var store: Store
    
    @Environment(\.openURL) var openURL
    
    let pasteboard = NSPasteboard.general
    
    @Binding var chosen: Int?
    
    let result: SearchResponse.Result
    
    var body: some View {
        ZStack {
            if let thumb = result.coverImage {
                AsyncImage(url: URL(string: thumb)!,
                           transaction: Transaction(animation: .easeOut)) { phase in
                    switch(phase) {
                    case .empty:
                        ZStack {
                            EffectView(material: .contentBackground,
                                       blendingMode: .behindWindow)
                            
                            ProgressView()
                        }.cornerRadius(8)
                    case .success(let image):
                        ZStack {
                            image.resizable().scaledToFill()
                                .frame(width: 80, height: 80)
                                .frame(height: 40, alignment: .bottom)
                                .cornerRadius(36)
                                .overlay(RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color.accentColor
                                        .opacity(
                                            (chosen != nil && chosen! == result.id) ?
                                            1 : 0.001), lineWidth: 2))
                                .blur(radius: 3.6)
                                .frame(width: 76, height: 120).clipped()
                                .offset(y: 2.4+20)
                            
                            image.resizable().scaledToFill()
                                .frame(width: 80, height: 80)
                                .cornerRadius(4)
                                .shadow(color: Color.black.opacity(0.54),
                                        radius: 3.6, x: 0, y: 2.4)
                        }
                    case .failure:
                        ZStack {
                            EffectView(material: .contentBackground,
                                       blendingMode: .behindWindow)
                        }.cornerRadius(8)
                    @unknown default:
                        EmptyView()
                    }
                }
                .id(result.id)
                .frame(width: 80, height: 80)
                .onTapGesture {
                    if chosen == result.id {
                        store.didReferencePicked(using: result.resourceURL)
                    } else { withAnimation(.easeOut) { chosen = result.id } }
                }
                .overlay(RoundedRectangle(cornerRadius: 4)
                    .stroke(Color.accentColor
                        .opacity(
                            (chosen != nil && chosen! == result.id) ?
                            1 : 0.001), lineWidth: 2))
            }
        }
        // Cancel shadow-clipping: 1. Positive padding
        .padding(.vertical, 20)
        .contextMenu {
            Button(action: { store.didReferencePicked(using: result.resourceURL) }) { Text("Pick Up") }
            Divider()
            Button(action: { openURL(URL(string: "https://discogs.com\(result.uri)")!) })
            { Text("View on Discogs") }
            Button(action: { openURL(URL(string: result.coverImage!)!) })
            { Text("Open Artwork in Browser") }
            Divider()
            Button("Copy Discogs ID") {
                pasteboard.declareTypes([.string], owner: nil)
                pasteboard.setString("\(result.id)", forType: .string)
            }
        }
    }
}

extension NSButton {
    open override var focusRingType: NSFocusRingType {
        get { .none }
        set {}
    }
}

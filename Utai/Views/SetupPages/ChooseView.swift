//
//  ChooseView.swift
//  Utai
//
//  Created by Toto Minai on 2021/06/12.
//

import SwiftUI

struct ArtworkView: View {
    @Binding var response: SearchResponse?
    
    @Binding var searchURL: URL?
    
    @Binding var chosen: Int?
    @Binding var showMode: ShowMode
    @Binding var sortMode: SortMode
    
    @Binding var yearGroupChoice: Int?
    @Binding var formatGroupChoice: String?
    @Binding var labelGroupChoice: String?
    
    @ObservedObject var store: Store
    
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
                    .onChange(of: showMode) { newValue in
                        withAnimation {
                            proxy.scrollTo(chosen, anchor: .top)
                        }
                    }
                    .onChange(of: sortMode) { newValue in
                        withAnimation {
                            proxy.scrollTo(chosen, anchor: .top)
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

struct ChooseView: View {
    @EnvironmentObject var store: Store
    
    @Environment(\.openURL) var openURL
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.hostingWindow) var hostingWindow
    
    @State private var subWindow: NSWindow!
    
    @State private var response: SearchResponse?
    
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
    @AppStorage(Settings.preferCD) var preferCD: Bool = false
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
    
    @AppStorage(Settings.preferReleaseOnly) var preferReleaseOnly: Bool = false
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
    
    var header: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                if album.title == nil {
                    Text("Music by ")
                        .foregroundColor(.secondary)
                        .fontWeight(.medium)
                        .textSelection(.disabled)
                }
                Text("\(artistsRaw)")
                    .fontWeight(.medium) +
                Text(album.artists != nil &&
                     album.title != nil ? " – " : "")
                    .fontWeight(.medium) +
                Text("\(titleRaw)")
                    .fontWeight(.medium)
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
    
    var footer: some View {
        VStack {
            Spacer()
            
            HStack {
                Spacer()
                
                Menu { extraMenu } label: {
                    ButtonMini(alwaysHover: true,
                               systemName: "ellipsis.circle",
                               helpText: "Options")
                        .padding(Metrics.lilSpacing)
                }
                .menuStyle(BorderlessButtonMenuStyle())
                .menuIndicator(.hidden)
                .frame(width: Metrics.lilSpacing2x+Metrics.lilIconLength,
                       height: Metrics.lilSpacing2x+Metrics.lilIconLength)
                .offset(x: 2, y: -0.5)
            }
        }
    }
    
    // Bug: Contextual menu sometimes do not show properly
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
                            } else if !isResultsEmptyWhenYear(equals: member) {
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
                            } else if !isResultsEmptyWhenFormat(equals: member) {
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
                            } else if !isResultsEmptyWhenLabel(equals: member) {
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
            }
            
            Divider()
            
            Section {
                Menu("Options") {
                    Toggle("Auto Show CD if Available", isOn: preferCDMask)
                    
                    Toggle("Prefer Releases Only", isOn: preferReleaseOnlyMask)
                }
            }
        }
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            VStack(spacing: Metrics.lilSpacing2x) {
                if store.album != nil { header }
                
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
                                                .opacity(chosenYearCR != " " ? 1 : 0.3)
                                            Text("Format")
                                                .fontWeight(.medium)
                                                .opacity(chosenResult.format != nil ? 1 : 0.3)
                                            Text("Labal")
                                                .fontWeight(.medium)
                                            
                                            Spacer()  // Keep 2 VStack aligned
                                        }
                                        .foregroundColor(.secondary)
                                        .animation(.easeOut, value: chosen)
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("\(chosenInfoRaw)")
                                                .fontWeight(.medium)
                                            Text("\(chosenYearCR)")
                                                .fontWeight(.medium)
                                            Text("\(chosenFormatStyled)")
                                                .fontWeight(.medium)
                                            Text("\(chosenLabelStyled)")
                                                .fontWeight(.medium)
                                            Button("**View on Discogs**") {
                                                openURL(URL(string: "https://discogs.com\(chosenResult.uri)")!)
                                            }
                                            .buttonStyle(.borderless)
                                            .foregroundColor(.secondary)
                                            .padding(.top, 2)
                                            .textSelection(.disabled)
                                            
                                            Spacer()
                                        }
                                        .textSelection(.enabled)
                                        .animation(nil, value: chosen)
                                    }
                                    .padding(.horizontal, Metrics.lilSpacing2x+Metrics.lilIconLength)
                                }
                            }
                        } else { Text("No Album Under Such Condition") }
                    } else { Text("No Album Found") }
                } else { Text("Searching...") }
                
                Spacer()
            }
            .padding(.top, Metrics.lilSpacing2x+Metrics.lilIconLength)
            .contextMenu { if response != nil && store.searchURL == nil { extraMenu } }
            
            if response != nil && store.searchURL == nil { footer }
                
            if store.page == 2 {
                doWhenTurnToThisPage
                
                if store.searchURL != nil { doWhenNeededSearch }
            }
        }
        .frame(width: Metrics.unitLength, height: Metrics.unitLength)
        .onAppear {  // doWhenBuildiThisPage
            let frame = window.frame
            subWindow = NSWindow(contentRect: NSRect(x: frame.minX-20, y: frame.maxY-157, width: 352, height: 120),
                                 styleMask: [], backing: .buffered, defer: false)
            
            let rootView = ArtworkView(response: $response, searchURL: $store.searchURL, chosen: $chosen, showMode: $showMode, sortMode: $sortMode, yearGroupChoice: $yearGroupChoice, formatGroupChoice: $formatGroupChoice, labelGroupChoice: $labelGroupChoice, store: store)
            subWindow.setFrameAutosaveName("Sub Window")
            
            subWindow.titleVisibility = .hidden
            subWindow.backgroundColor = NSColor.clear
            subWindow.hasShadow = false
            
            subWindow.contentView = NSHostingView(rootView: rootView)
            
            window.addChildWindow(subWindow, ordered: .above)
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
            window.removeChildWindow(subWindow)
        }
    }
    
    var doWhenNeededSearch: some View {
        void.onAppear {
            response = nil
            
            sortMode = .none
            
            yearGroupChoice = nil
            formatGroupChoice = nil
            labelGroupChoice = nil
            
            async {
                do { try await search() }
                catch { print(error) }
                
                parse()
                
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
    var window: NSWindow { self.hostingWindow()! }
    
    private var album: Album { store.album! }
    private var titleRaw: String { album.title ?? "" }
    private var artistsRaw: String { album.artists ?? "" }
    
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
    
    private func isResultsEmptyWhenYear(equals x: Int?) -> Bool {
        return results
            .processed(in: showMode)
            .processed(in: sortMode)
            // Filters
            .filterd(year: x)
            .filterd(format: formatGroupChoice)
            .filterd(label: labelGroupChoice)
            .isEmpty
    }
    
    private func isResultsEmptyWhenFormat(equals x: String?) -> Bool {
        return results
            .processed(in: showMode)
            .processed(in: sortMode)
            // Filters
            .filterd(year: yearGroupChoice)
            .filterd(format: x)
            .filterd(label: labelGroupChoice)
            .isEmpty
    }
    
    private func isResultsEmptyWhenLabel(equals x: String?) -> Bool {
        return results
            .processed(in: showMode)
            .processed(in: sortMode)
            // Filters
            .filterd(year: yearGroupChoice)
            .filterd(format: formatGroupChoice)
            .filterd(label: x)
            .isEmpty
    }
    
    private var chosenResult: SearchResponse.Result { resultsProcessed.first { $0.id == chosen }! }
    
    private var chosenInfoRaw: String {
        if chosen != nil {
            return chosenResult.title
                .replacingOccurrences(of: " - ", with: " – ")
                .replacingOccurrences(of: "*", with: "†")
        } else { return "" }
    }
    
    private var chosenYearCR: String {
        if chosen != nil {
            var processed = [chosenResult.year,
                             chosenResult.country]
            processed.removeAll { $0 == nil }
            
            return processed.map { $0!.replacingOccurrences(of: " & ", with: ", ") }.joined(separator: ", ")
        } else { return " " }
    }
    
    private var chosenFormatStyled: String {
        if let _ = chosen {
            if chosenResult.type == "release" {
                if let formats = chosenResult.formats,
                   let first = formats.first {
                    let filtered = first.descriptions ?? []
                    
                    return first.name + (filtered.isEmpty ?
                                    " " : " (\(filtered.joined(separator: ", ")))")
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
    
    private func parse() {
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
}

struct Artwork80x80: View {
    @ObservedObject var store: Store
    
    @Environment(\.openURL) var openURL
    
    @Binding var chosen: Int?
    
    let result: SearchResponse.Result
    
    var body: some View {
        ZStack {
            if let thumb = result.coverImage {
                AsyncImage(url: URL(string: thumb)!) { image in
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
                            .overlay(RoundedRectangle(cornerRadius: 4)
                                .stroke(Color.accentColor
                                    .opacity(
                                        (chosen != nil && chosen! == result.id) ?
                                        1 : 0.001), lineWidth: 2))
                            .onTapGesture {
                                if chosen == result.id { store.didReferencePicked(using: result.resourceURL) }
                                else { withAnimation(.easeOut) { chosen = result.id } }
                            }
                    }
                    .id(result.id)
                } placeholder: { ProgressView() }
                .frame(width: 80, height: 80)
            } else { Color.red.frame(width: 80, height: 80) }
        }
        // Cancel shadow-clipping: 1. Positive padding
        .padding(.vertical, 20)
        .contextMenu {
            Button(action: { store.didReferencePicked(using: result.resourceURL) }) { Text("Pick Up") }
            Divider()
            Button(action: { openURL(URL(string: "https://discogs.com\(result.uri)")!) })
            { Text("View on Discogs") }
            Button(action: { openURL(URL(string: result.coverImage!)!) })
            { Text("Open Artwork in Broswer") }
        }
    }
}

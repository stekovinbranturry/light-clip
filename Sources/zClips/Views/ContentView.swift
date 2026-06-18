import AppKit
import SwiftUI

struct ContentView: View {
    @ObservedObject var store: ClipboardStore
    @State private var filter: ClipboardFilter = .all
    @State private var searchText = ""
    @FocusState private var isSearchFocused: Bool

    private var visibleItems: [ClipboardItem] {
        let filteredByTab: [ClipboardItem]
        switch filter {
        case .all:
            filteredByTab = store.items
        case .text:
            filteredByTab = store.items.filter { $0.kind == .text }
        case .image:
            filteredByTab = store.items.filter { $0.kind == .image }
        case .file:
            filteredByTab = store.items.filter { $0.kind == .file }
        case .favorite:
            filteredByTab = store.items.filter(\.isFavorite)
        }

        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return filteredByTab }
        return filteredByTab.filter { $0.matchesSearch(query) }
    }

    var body: some View {
        VStack(spacing: 0) {
            ClipboardFilterBar(
                filter: $filter,
                searchText: $searchText,
                isSearchFocused: $isSearchFocused,
                favoriteCount: store.items.filter(\.isFavorite).count
            )

            Rectangle()
                .fill(Color.black.opacity(0.12))
                .frame(height: 1)

            if visibleItems.isEmpty {
                EmptyHistoryView(filter: filter)
            } else {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(Array(visibleItems.enumerated()), id: \.element.id) { index, item in
                                ClipboardListItem(
                                    item: item,
                                    number: index + 1,
                                    isSelected: store.selectedItemID == item.id,
                                    onSelect: {
                                        store.selectedItemID = item.id
                                    },
                                    onCopy: {
                                        store.selectedItemID = item.id
                                        store.copyToPasteboard(item)
                                    },
                                    onPreview: {
                                        store.selectedItemID = item.id
                                        store.previewImage(item)
                                    },
                                    onToggleFavorite: {
                                        store.toggleFavorite(item)
                                    },
                                    onDelete: {
                                        store.delete(item)
                                    }
                                )
                                .id(item.id)
                            }
                        }
                    }
                    .background(Color.white)
                    .onAppear {
                        showLatestItem(using: proxy)
                    }
                    .onChange(of: store.items.first?.id) { _ in
                        showLatestItem(using: proxy)
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 10)
        .background(Color.white)
        .onReceive(NotificationCenter.default.publisher(for: .focusClipboardSearch)) { _ in
            isSearchFocused = true
        }
    }

    private func showLatestItem(using proxy: ScrollViewProxy) {
        guard searchText.isEmpty else { return }
        filter = .all
        store.selectLatestItem()

        guard let latestID = store.items.first?.id else { return }
        DispatchQueue.main.async {
            proxy.scrollTo(latestID, anchor: .top)
        }
    }
}

private enum ClipboardFilter: String, CaseIterable, Identifiable {
    case all
    case text
    case image
    case file
    case favorite

    var id: String { rawValue }

    var title: String {
        switch self {
        case .all: return "全部"
        case .text: return "文本"
        case .image: return "图像"
        case .file: return "文件"
        case .favorite: return "收藏"
        }
    }

    var systemImage: String {
        switch self {
        case .all: return "doc.on.clipboard"
        case .text: return "text.alignleft"
        case .image: return "photo"
        case .file: return "paperclip"
        case .favorite: return "star.fill"
        }
    }
}

private struct ClipboardFilterBar: View {
    @Binding var filter: ClipboardFilter
    @Binding var searchText: String
    var isSearchFocused: FocusState<Bool>.Binding
    let favoriteCount: Int

    var body: some View {
        VStack(spacing: 6) {
            HStack(spacing: 18) {
                ForEach(ClipboardFilter.allCases) { option in
                    Button {
                        filter = option
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: option.systemImage)
                                .font(.system(size: 13, weight: .semibold))
                            Text(option == .favorite ? "\(option.title)（\(favoriteCount)）" : option.title)
                                .font(.system(size: 13, weight: .semibold))
                        }
                        .foregroundStyle(filter == option ? Color.black : Color.black.opacity(0.58))
                        .frame(minWidth: 86, minHeight: 34)
                        .background {
                            if filter == option {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.black.opacity(0.045))
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }

                Spacer()

                Button {
                    filter = .all
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .frame(width: 24, height: 24)
                }
                .buttonStyle(.plain)
                .help("刷新")
            }

            HStack(spacing: 5) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(Color.black.opacity(0.42))

                TextField("搜索", text: $searchText)
                    .textFieldStyle(.plain)
                    .font(.system(size: 12))
                    .focused(isSearchFocused)

                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 11))
                            .foregroundStyle(Color.black.opacity(0.34))
                    }
                    .buttonStyle(.plain)
                    .help("清空搜索")
                }
            }
            .padding(.horizontal, 8)
            .frame(maxWidth: .infinity, minHeight: 24)
            .background(Color.black.opacity(0.045), in: RoundedRectangle(cornerRadius: 6))
        }
        .foregroundStyle(Color.black.opacity(0.58))
        .padding(.top, 2)
        .padding(.bottom, 8)
        .background(Color.white)
    }
}

private struct ClipboardListItem: View {
    let item: ClipboardItem
    let number: Int
    let isSelected: Bool
    let onSelect: () -> Void
    let onCopy: () -> Void
    let onPreview: () -> Void
    let onToggleFavorite: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(alignment: .bottom, spacing: 12) {
            itemBody

            Spacer(minLength: 12)

            VStack(alignment: .trailing, spacing: 8) {
                Text(item.metricText)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(Color.black.opacity(0.48))
                Text("\(number)")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(Color.black.opacity(0.48))
            }
            .frame(width: 86, alignment: .trailing)

            Button(action: onToggleFavorite) {
                Image(systemName: item.isFavorite ? "star.fill" : "star")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(item.isFavorite ? Color.orange : Color.black.opacity(0.42))
                    .frame(width: 24, height: 24)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .help(item.isFavorite ? "取消收藏" : "收藏")

            Button(action: onCopy) {
                Image(systemName: "doc.on.doc")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color.black.opacity(0.54))
                    .frame(width: 24, height: 24)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .help("复制")
        }
        .padding(.horizontal, 18)
        .padding(.vertical, item.kind == .image ? 8 : 9)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            if isSelected {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color(red: 0.94, green: 0.96, blue: 1.0))
                    .overlay {
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color(red: 0.34, green: 0.42, blue: 1.0), lineWidth: 2)
                    }
                    .padding(.horizontal, 2)
                    .padding(.vertical, 3)
            } else {
                Color.white
            }
        }
        .contentShape(Rectangle())
        .onTapGesture(perform: onSelect)
        .contextMenu {
            Button("Copy") {
                onCopy()
            }
            if item.kind == .image {
                Button("Preview") {
                    onPreview()
                }
            }
            Button(item.isFavorite ? "Unfavorite" : "Favorite") {
                onToggleFavorite()
            }
            Button("Delete", role: .destructive) {
                onDelete()
            }
        }

        Divider()
            .overlay(Color.black.opacity(0.11))
            .padding(.leading, 18)
            .padding(.trailing, 8)
    }

    @ViewBuilder
    private var itemBody: some View {
        switch item.kind {
        case .text:
            VStack(alignment: .leading, spacing: 4) {
                Text(item.textPreview)
                    .font(.system(size: 13))
                    .foregroundStyle(Color.black.opacity(0.88))
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                Text(item.createdAt.relativeString)
                    .font(.system(size: 11))
                    .foregroundStyle(Color.black.opacity(0.46))
            }
        case .image:
            HStack(alignment: .bottom, spacing: 12) {
                Text(item.createdAt.relativeString)
                    .font(.system(size: 11))
                    .foregroundStyle(Color.black.opacity(0.46))
                    .frame(width: 62, alignment: .leading)

                if let image = item.nsImage {
                    Button(action: onPreview) {
                        Image(nsImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 260, maxHeight: 118)
                            .padding(4)
                            .background(Color.black.opacity(0.035), in: RoundedRectangle(cornerRadius: 6))
                            .shadow(color: .black.opacity(0.08), radius: 6, y: 2)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .help("预览")
                }
            }
        case .file:
            HStack(spacing: 10) {
                Image(systemName: item.filePaths.count > 1 ? "doc.on.doc" : "doc")
                    .font(.system(size: 18))
                    .foregroundStyle(Color.black.opacity(0.56))
                    .frame(width: 26)

                VStack(alignment: .leading, spacing: 4) {
                    Text(item.fileDisplayName)
                        .font(.system(size: 13))
                        .foregroundStyle(Color.black.opacity(0.88))
                        .lineLimit(1)
                    Text(item.createdAt.relativeString)
                        .font(.system(size: 11))
                        .foregroundStyle(Color.black.opacity(0.46))
                }
            }
        }
    }
}

private struct EmptyHistoryView: View {
    let filter: ClipboardFilter

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: filter.systemImage)
                .font(.system(size: 30))
                .foregroundStyle(Color.black.opacity(0.32))
            Text("暂无\(filter.title)")
                .font(.system(size: 14))
                .fontWeight(.semibold)
                .foregroundStyle(Color.black.opacity(0.86))
            Text("复制文字或图片后会直接出现在这里。")
                .font(.system(size: 12))
                .foregroundStyle(Color.black.opacity(0.48))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
    }
}

private extension ClipboardItem {
    var nsImage: NSImage? {
        guard let imageData else { return nil }
        return NSImage(data: imageData)
    }

    var textPreview: String {
        let raw = text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return raw.isEmpty ? "Empty text" : raw
    }

    var metricText: String {
        switch kind {
        case .text:
            return "\(text?.count ?? 0) 字符"
        case .image:
            guard let image = nsImage,
                  let representation = image.representations.first else {
                return "图像"
            }
            return "\(representation.pixelsWide) x \(representation.pixelsHigh)"
        case .file:
            return filePaths.count == 1 ? "1 个文件" : "\(filePaths.count) 个文件"
        }
    }

    var fileDisplayName: String {
        guard let firstPath = filePaths.first else { return "文件" }
        let firstName = URL(fileURLWithPath: firstPath).lastPathComponent
        if filePaths.count == 1 {
            return firstName
        }
        return "\(firstName) 等 \(filePaths.count) 个文件"
    }

    func matchesSearch(_ query: String) -> Bool {
        let tokens = [
            title,
            text ?? "",
            filePaths.joined(separator: " "),
            filePaths.map { URL(fileURLWithPath: $0).lastPathComponent }.joined(separator: " "),
            metricText,
            kind.rawValue
        ]

        return tokens.contains { token in
            token.localizedCaseInsensitiveContains(query)
        }
    }
}

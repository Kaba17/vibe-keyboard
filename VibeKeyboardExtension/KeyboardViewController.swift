import UIKit
import SwiftUI

// MARK: - GIF Model
struct GifResult: Codable, Identifiable {
    let id: String
    let url: String
    let previewUrl: String
    let title: String
    let width: Int
    let height: Int
}

// MARK: - Giphy Service
actor GiphyService {
    static let shared = GiphyService()
    private let tenorKey = "AIzaSyAyimkuYQYF_FXVALexPuGQctUWRURdCYQ"

    private let vibeMap: [String: [String]] = [
        "laugh":      ["laughing", "hilarious", "funny"],
        "hilarious":  ["hilarious", "laughing", "lol"],
        "funny":      ["funny", "lol", "laughing"],
        "lol":        ["lol", "laughing", "funny"],
        "haha":       ["haha", "laughing", "lol"],
        "happy":      ["happy", "excited", "yay"],
        "excited":    ["excited", "hype", "yay"],
        "love":       ["love", "heart", "affection"],
        "yes":        ["yes", "agree", "nodding"],
        "no":         ["no", "nope", "reject"],
        "wow":        ["wow", "amazed", "shocked"],
        "amazing":    ["amazing", "wow", "impressive"],
        "great":      ["great", "awesome", "thumbs up"],
        "awesome":    ["awesome", "amazing", "cool"],
        "sad":        ["sad", "crying", "disappointed"],
        "cry":        ["crying", "sad", "tears"],
        "angry":      ["angry", "mad", "furious"],
        "omg":        ["omg", "shocked", "oh my god"],
        "surprised":  ["surprised", "shocked", "omg"],
        "bored":      ["bored", "whatever", "meh"],
        "tired":      ["tired", "sleepy", "exhausted"],
        "bye":        ["bye", "goodbye", "wave"],
        "hi":         ["hi", "hello", "wave"],
        "hello":      ["hello", "hi", "greetings"],
        "thanks":     ["thank you", "grateful", "appreciate"],
        "thank":      ["thank you", "grateful", "appreciate"],
        "sorry":      ["sorry", "apology", "oops"],
        "cute":       ["cute", "adorable", "sweet"],
        "fire":       ["fire", "hot", "lit"],
        "cool":       ["cool", "awesome", "swag"],
        "dance":      ["dancing", "party", "celebrate"],
        "party":      ["party", "celebrate", "dancing"],
        "win":        ["win", "victory", "champion"],
        "yay":        ["yay", "excited", "celebration"],
        "clap":       ["clapping", "applause", "well done"],
        "facepalm":   ["facepalm", "embarrassed", "oh no"],
        "ok":         ["okay", "alright", "thumbs up"],
        "sure":       ["sure", "okay", "alright"],
        "really":     ["really", "seriously", "disbelief"],
        "seriously":  ["seriously", "really", "unbelievable"],
        "bruh":       ["bruh", "seriously", "facepalm"],
        "wait":       ["wait", "hold on", "pause"],
        "crying":     ["crying laughing", "hilarious", "lol"],
        "perfect":    ["perfect", "flawless", "nailed it"],
        "same":       ["same", "relatable", "mood"],
        "mood":       ["mood", "relatable", "same"],
        "goals":      ["goals", "amazing", "impressed"],
        "sus":        ["suspicious", "side eye", "hmm"],
        "rip":        ["rip", "dead", "done"],
        "facts":      ["facts", "truth", "absolutely"],
        "cap":        ["lying", "cap", "no way"],
        "slay":       ["slay", "yasss", "werk"],
    ]

    func extractKeyword(from text: String) -> String? {
        let words = text.lowercased()
            .components(separatedBy: .whitespacesAndNewlines)
            .map { $0.filter(\.isLetter) }
            .filter { !$0.isEmpty }

        for word in words.reversed() {
            if let terms = vibeMap[word], let pick = terms.randomElement() {
                return pick
            }
        }

        // fallback: use last few words as phrase
        let lastWords = words.suffix(3).joined(separator: " ")
        return lastWords.isEmpty ? nil : lastWords
    }

    func search(query: String, limit: Int = 6) async throws -> [GifResult] {
        var components = URLComponents(string: "https://tenor.googleapis.com/v2/search")!
        components.queryItems = [
            URLQueryItem(name: "key", value: tenorKey),
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "limit", value: "\(limit)"),
            URLQueryItem(name: "media_filter", value: "gif,tinygif,nanogif"),
            URLQueryItem(name: "contentfilter", value: "medium"),
        ]
        let (data, _) = try await URLSession.shared.data(from: components.url!)
        let response = try JSONDecoder().decode(TenorResponse.self, from: data)
        return response.results.compactMap { item in
            guard let full = item.mediaFormats["tinygif"] ?? item.mediaFormats["gif"],
                  !full.url.isEmpty else { return nil }
            let preview = item.mediaFormats["nanogif"] ?? item.mediaFormats["tinygif"] ?? full
            return GifResult(
                id: item.id,
                url: full.url,
                previewUrl: preview.url,
                title: item.contentDescription,
                width: full.dims.first ?? 200,
                height: full.dims.last ?? 150
            )
        }
    }
}

// MARK: - Tenor Decodable Models
struct TenorResponse: Decodable { let results: [TenorItem] }
struct TenorItem: Decodable {
    let id: String
    let contentDescription: String
    let mediaFormats: [String: TenorFormat]
    enum CodingKeys: String, CodingKey {
        case id
        case contentDescription = "content_description"
        case mediaFormats = "media_formats"
    }
}
struct TenorFormat: Decodable {
    let url: String
    let dims: [Int]
}

// MARK: - Keyboard View Model
@MainActor
class KeyboardViewModel: ObservableObject {
    @Published var gifs: [GifResult] = []
    @Published var isLoading = false
    @Published var currentKeyword: String?

    private var debounceTask: Task<Void, Never>?
    private var lastQuery = ""

    func analyzeText(_ text: String) {
        debounceTask?.cancel()

        guard !text.trimmingCharacters(in: .whitespaces).isEmpty,
              text.count >= 2 else {
            gifs = []
            currentKeyword = nil
            lastQuery = ""
            return
        }

        debounceTask = Task {
            try? await Task.sleep(nanoseconds: 400_000_000)
            guard !Task.isCancelled else { return }
            await fetchGifs(for: text)
        }
    }

    private func fetchGifs(for text: String) async {
        guard let keyword = await GiphyService.shared.extractKeyword(from: text) else { return }
        guard keyword != lastQuery else { return }
        lastQuery = keyword
        currentKeyword = keyword
        isLoading = true
        do {
            gifs = try await GiphyService.shared.search(query: keyword)
        } catch {
            gifs = []
        }
        isLoading = false
    }
}

// MARK: - SwiftUI Vibe Bar
struct VibeBarView: View {
    @ObservedObject var viewModel: KeyboardViewModel
    var onSelectGif: (GifResult) -> Void
    var hasText: Bool

    var body: some View {
        ZStack {
            Color(red: 0.067, green: 0.051, blue: 0.141)

            if !hasText {
                HStack(spacing: 6) {
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 11))
                        .foregroundStyle(Color(red: 0.608, green: 0.231, blue: 0.929))
                    Text("Start typing to see Vibe GIFs...")
                        .font(.system(size: 13))
                        .foregroundStyle(Color.gray)
                    Spacer()
                }
                .padding(.horizontal, 14)
            } else if viewModel.isLoading {
                HStack(spacing: 6) {
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 11))
                        .foregroundStyle(Color(red: 0.608, green: 0.231, blue: 0.929))
                    Text("Vibing...")
                        .font(.system(size: 13))
                        .foregroundStyle(Color(red: 0.608, green: 0.231, blue: 0.929))
                    Spacer()
                    ProgressView()
                        .scaleEffect(0.7)
                        .tint(.white)
                }
                .padding(.horizontal, 14)
            } else if viewModel.gifs.isEmpty {
                HStack(spacing: 6) {
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 11))
                        .foregroundStyle(Color.gray)
                    Text("Keep typing...")
                        .font(.system(size: 13))
                        .foregroundStyle(Color.gray)
                    Spacer()
                }
                .padding(.horizontal, 14)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        if let kw = viewModel.currentKeyword {
                            HStack(spacing: 4) {
                                Image(systemName: "bolt.fill")
                                    .font(.system(size: 9))
                                    .foregroundStyle(Color(red: 0.608, green: 0.231, blue: 0.929))
                                Text(kw)
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundStyle(Color(red: 0.608, green: 0.231, blue: 0.929))
                                    .textCase(.lowercase)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Color(red: 0.608, green: 0.231, blue: 0.929).opacity(0.15))
                            .clipShape(Capsule())
                        }
                        ForEach(viewModel.gifs) { gif in
                            GifThumbnail(gif: gif, onTap: { onSelectGif(gif) })
                        }
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                }
            }
        }
        .frame(height: 80)
    }
}

struct GifThumbnail: View {
    let gif: GifResult
    var onTap: () -> Void
    @State private var image: UIImage?
    @State private var isPressed = false

    var body: some View {
        Button(action: {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            onTap()
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(red: 0.18, green: 0.13, blue: 0.37))
                if let img = image {
                    Image(uiImage: img)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 90, height: 68)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                } else {
                    ProgressView()
                        .scaleEffect(0.6)
                        .tint(Color(red: 0.608, green: 0.231, blue: 0.929))
                }
            }
            .frame(width: 90, height: 68)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(Color(red: 0.18, green: 0.13, blue: 0.37), lineWidth: 1.5)
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .buttonStyle(.plain)
        .onAppear { loadImage() }
    }

    func loadImage() {
        guard let url = URL(string: gif.previewUrl.isEmpty ? gif.url : gif.previewUrl) else { return }
        Task {
            if let (data, _) = try? await URLSession.shared.data(from: url) {
                await MainActor.run {
                    image = UIImage(data: data)
                }
            }
        }
    }
}

// MARK: - Main Keyboard SwiftUI View
struct KeyboardView: View {
    @ObservedObject var viewModel: KeyboardViewModel
    var onInsertGif: (GifResult) -> Void
    var onKeyPress: (String) -> Void
    var onBackspace: () -> Void
    var onReturn: () -> Void
    var onNextKeyboard: () -> Void
    var currentText: String

    @State private var isCaps = false
    @State private var isShifted = false

    let rows: [[String]] = [
        ["q","w","e","r","t","y","u","i","o","p"],
        ["a","s","d","f","g","h","j","k","l"],
        ["z","x","c","v","b","n","m"],
    ]

    var body: some View {
        VStack(spacing: 0) {
            VibeBarView(viewModel: viewModel, onSelectGif: onInsertGif, hasText: !currentText.isEmpty)

            Divider()
                .background(Color(red: 0.18, green: 0.13, blue: 0.37))

            VStack(spacing: 8) {
                ForEach(rows.indices, id: \.self) { rowIndex in
                    HStack(spacing: 5) {
                        if rowIndex == 2 {
                            // Shift key
                            KeyButton(label: nil, systemImage: isShifted || isCaps ? "shift.fill" : "shift",
                                      isSpecial: true, width: 40) {
                                if isCaps { isCaps = false; isShifted = false }
                                else if isShifted { isCaps = true }
                                else { isShifted = true }
                            }
                        }
                        ForEach(rows[rowIndex], id: \.self) { key in
                            let display = (isShifted || isCaps) ? key.uppercased() : key
                            KeyButton(label: display, systemImage: nil, isSpecial: false, width: nil) {
                                onKeyPress(display)
                                if isShifted && !isCaps { isShifted = false }
                            }
                        }
                        if rowIndex == 2 {
                            // Backspace
                            KeyButton(label: nil, systemImage: "delete.left", isSpecial: true, width: 40) {
                                onBackspace()
                            }
                        }
                    }
                }

                // Bottom row
                HStack(spacing: 5) {
                    KeyButton(label: nil, systemImage: "globe", isSpecial: true, width: 40) {
                        onNextKeyboard()
                    }
                    KeyButton(label: "123", systemImage: nil, isSpecial: true, width: 40) {
                        // Number row (basic stub)
                    }
                    KeyButton(label: " ", systemImage: nil, isSpecial: false, width: nil) {
                        onKeyPress(" ")
                    }
                    KeyButton(label: "return", systemImage: nil, isSpecial: true, width: 80) {
                        onReturn()
                    }
                }
            }
            .padding(.horizontal, 4)
            .padding(.top, 8)
            .padding(.bottom, 4)
            .background(Color(UIColor.systemGray5))
        }
    }
}

struct KeyButton: View {
    let label: String?
    let systemImage: String?
    let isSpecial: Bool
    let width: CGFloat?
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            action()
        }) {
            Group {
                if let img = systemImage {
                    Image(systemName: img)
                        .font(.system(size: 16, weight: .medium))
                } else if let lbl = label {
                    Text(lbl)
                        .font(.system(size: lbl == " " ? 14 : (lbl == "return" || lbl == "123" ? 15 : 17), weight: .regular))
                }
            }
            .frame(maxWidth: width == nil ? .infinity : nil)
            .frame(width: width, height: 42)
            .background(isSpecial ? Color(UIColor.systemGray3) : .white)
            .foregroundStyle(isSpecial ? Color.primary : Color.primary)
            .clipShape(RoundedRectangle(cornerRadius: 5))
            .shadow(color: .black.opacity(0.2), radius: 0, x: 0, y: 1)
            .scaleEffect(isPressed ? 0.93 : 1.0)
        }
        .buttonStyle(.plain)
        ._onButtonGesture(pressing: { p in
            withAnimation(.easeInOut(duration: 0.08)) { isPressed = p }
        }, perform: {})
    }
}

// MARK: - UIInputViewController
class KeyboardViewController: UIInputViewController {

    private var viewModel = KeyboardViewModel()
    private var currentText = ""
    private var hostingController: UIHostingController<KeyboardView>?
    private var observerToken: NSObjectProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupKeyboardView()
        observeTextChanges()
    }

    private func setupKeyboardView() {
        let keyboardView = KeyboardView(
            viewModel: viewModel,
            onInsertGif: { [weak self] gif in self?.insertGif(gif) },
            onKeyPress: { [weak self] key in self?.insertKey(key) },
            onBackspace: { [weak self] in self?.deleteBackward() },
            onReturn: { [weak self] in self?.insertKey("\n") },
            onNextKeyboard: { [weak self] in self?.advanceToNextInputMode() },
            currentText: currentText
        )
        let hc = UIHostingController(rootView: keyboardView)
        hostingController = hc

        addChild(hc)
        view.addSubview(hc.view)
        hc.didMove(toParent: self)
        hc.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hc.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hc.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hc.view.topAnchor.constraint(equalTo: view.topAnchor),
            hc.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    private func observeTextChanges() {
        observerToken = NotificationCenter.default.addObserver(
            forName: UITextInputMode.currentInputModeDidChangeNotification,
            object: nil, queue: .main
        ) { [weak self] _ in
            self?.updateCurrentText()
        }
    }

    private func updateCurrentText() {
        let before = textDocumentProxy.documentContextBeforeInput ?? ""
        currentText = before
        viewModel.analyzeText(before)
        updateHostingView()
    }

    private func updateHostingView() {
        hostingController?.rootView = KeyboardView(
            viewModel: viewModel,
            onInsertGif: { [weak self] gif in self?.insertGif(gif) },
            onKeyPress: { [weak self] key in self?.insertKey(key) },
            onBackspace: { [weak self] in self?.deleteBackward() },
            onReturn: { [weak self] in self?.insertKey("\n") },
            onNextKeyboard: { [weak self] in self?.advanceToNextInputMode() },
            currentText: currentText
        )
    }

    private func insertKey(_ key: String) {
        textDocumentProxy.insertText(key)
        let before = textDocumentProxy.documentContextBeforeInput ?? ""
        currentText = before
        viewModel.analyzeText(before)
        updateHostingView()
    }

    private func deleteBackward() {
        textDocumentProxy.deleteBackward()
        let before = textDocumentProxy.documentContextBeforeInput ?? ""
        currentText = before
        viewModel.analyzeText(before)
        updateHostingView()
    }

    private func insertGif(_ gif: GifResult) {
        // For GIFs, we insert the URL as text (in a real app you'd use a share extension or pasteboard)
        UIPasteboard.general.string = gif.url
        // Insert a placeholder emoji + note
        textDocumentProxy.insertText("🎞️ [GIF copied - paste it]")
        currentText = textDocumentProxy.documentContextBeforeInput ?? ""
        viewModel.gifs = []
        viewModel.currentKeyword = nil
        updateHostingView()
    }

    override func textDidChange(_ textInput: UITextInput?) {
        let before = textDocumentProxy.documentContextBeforeInput ?? ""
        currentText = before
        viewModel.analyzeText(before)
        updateHostingView()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }

    deinit {
        if let token = observerToken {
            NotificationCenter.default.removeObserver(token)
        }
    }
}

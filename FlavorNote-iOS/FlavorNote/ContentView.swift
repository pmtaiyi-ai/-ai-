import AVFoundation
import PhotosUI
import SwiftUI
import UIKit

struct ContentView: View {
    @EnvironmentObject private var store: DrinkStore

    var body: some View {
        TabView {
            HomeView()
                .tabItem { Label("Home", systemImage: "cup.and.saucer.fill") }

            AnalysisView()
                .tabItem { Label("Analysis", systemImage: "chart.pie.fill") }

            RecordListView(title: "History", records: store.records)
                .tabItem { Label("History", systemImage: "clock.fill") }

            RecordListView(title: "Favorites", records: store.favorites)
                .tabItem { Label("Favorites", systemImage: "heart.fill") }

            ProfileView()
                .tabItem { Label("Me", systemImage: "person.crop.circle.fill") }
        }
        .tint(.flavorBerry)
    }
}

struct HomeView: View {
    @EnvironmentObject private var store: DrinkStore
    @State private var drinkName = "Milk Tea"
    @State private var sweet = 70.0
    @State private var rich = 60.0
    @State private var selectedTags: Set<String> = ["Creamy", "Strong"]
    @State private var photoItem: PhotosPickerItem?
    @State private var imageData: Data?
    @State private var isCameraOpen = false
    @State private var voiceNote = ""
    @State private var showSaved = false

    private let tags = ["Creamy", "Fresh", "Strong", "Fruity", "Floral", "Iced"]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    header
                    drinkCard
                    tastePanel
                    insightPanel
                    actionPanel
                    quickStats
                }
                .padding(20)
            }
            .background(FlavorBackground())
            .navigationBarHidden(true)
            .sheet(isPresented: $isCameraOpen) {
                CameraPicker(imageData: $imageData)
                    .ignoresSafeArea()
            }
            .alert("Saved", isPresented: $showSaved) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Your drink note has been added to history.")
            }
            .onChange(of: photoItem) { _, newItem in
                Task {
                    imageData = try? await newItem?.loadTransferable(type: Data.self)
                }
            }
        }
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Today’s Drink")
                    .eyebrowStyle()
                Text(Date.now.formatted(date: .omitted, time: .shortened))
                    .font(.system(size: 48, weight: .black, design: .rounded))
            }
            Spacer()
            Text("Taste profile live")
                .pillStyle(foreground: .flavorMint, background: .flavorMint.opacity(0.12))
        }
    }

    private var drinkCard: some View {
        VStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(LinearGradient(colors: [.flavorCoffee, .flavorBerry.opacity(0.76)], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(height: 300)

                if let imageData, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 300)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                } else {
                    VStack(spacing: 16) {
                        Image(systemName: "takeoutbag.and.cup.and.straw.fill")
                            .font(.system(size: 84, weight: .bold))
                            .foregroundStyle(.white)
                        Text("Milk Tea · Sweet")
                            .foregroundStyle(.white.opacity(0.86))
                            .font(.headline)
                    }
                }
            }

            VStack(alignment: .leading, spacing: 10) {
                Text("Drink name")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.secondary)
                TextField("Drink name", text: $drinkName)
                    .font(.system(size: 38, weight: .black, design: .rounded))
                    .textFieldStyle(.plain)
                Text("\(drinkName) · \(sweetLabel)")
                    .pillStyle(foreground: .flavorCoffee, background: .flavorGold.opacity(0.18))
                Text("Capture what you drink, tune the flavor, and let FlavorNote learn your personal taste.")
                    .foregroundStyle(.secondary)
            }
        }
        .cardStyle()
    }

    private var tastePanel: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Taste Control")
                .eyebrowStyle()
            Text("Mark the flavor")
                .font(.title.bold())

            TasteSlider(left: "Sweet", right: "Bitter", valueLabel: "\(sweetLabel) \(Int(sweet))%", value: $sweet)
            TasteSlider(left: "Light", right: "Rich", valueLabel: "\(richLabel) \(Int(rich))%", value: $rich)

            FlowLayout(items: tags) { tag in
                Button {
                    if selectedTags.contains(tag) {
                        selectedTags.remove(tag)
                    } else {
                        selectedTags.insert(tag)
                    }
                } label: {
                    Text(tag)
                        .pillStyle(
                            foreground: selectedTags.contains(tag) ? .white : .secondary,
                            background: selectedTags.contains(tag) ? .flavorCoffee : .white.opacity(0.72)
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .cardStyle()
    }

    private var insightPanel: some View {
        VStack(spacing: 12) {
            InfoTile(title: "Preference Insight", value: sweet >= 60 ? "You prefer sweet drinks" : "You prefer crisp drinks", note: rich >= 55 ? "You often choose milk-based drinks" : "You often choose refreshing drinks")
            VStack(alignment: .leading, spacing: 12) {
                Text("Based on your taste")
                    .eyebrowStyle()
                HStack {
                    ForEach(recommendations, id: \.self) { item in
                        Text(item)
                            .pillStyle(foreground: item == recommendations.first ? .white : .secondary, background: item == recommendations.first ? .flavorCoffee : .white.opacity(0.72))
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .cardStyle()
        }
    }

    private var actionPanel: some View {
        HStack(spacing: 10) {
            Button("Take Photo") {
                AVCaptureDevice.requestAccess(for: .video) { granted in
                    if granted {
                        DispatchQueue.main.async { isCameraOpen = true }
                    }
                }
            }
            .buttonStyle(PrimaryActionStyle(isPrimary: false))

            PhotosPicker(selection: $photoItem, matching: .images) {
                Text("Album")
            }
            .buttonStyle(PrimaryActionStyle(isPrimary: false))

            Button(voiceNote.isEmpty ? "Voice Note" : "Voice Added") {
                AVAudioSession.sharedInstance().requestRecordPermission { granted in
                    DispatchQueue.main.async {
                        voiceNote = granted ? "Voice note captured" : "Microphone permission needed"
                    }
                }
            }
            .buttonStyle(PrimaryActionStyle(isPrimary: false))

            Button("Save", action: saveDrink)
                .buttonStyle(PrimaryActionStyle(isPrimary: true))
        }
    }

    private var quickStats: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            InfoTile(title: "Last drink", value: store.records.first?.name ?? "No drinks yet", note: "Saved recently")
            InfoTile(title: "Drinks this week", value: "\(store.records.count)", note: "Light habit tracking")
            InfoTile(title: "Most common", value: store.commonType.rawValue, note: "Personal favorite pattern")
            InfoTile(title: "Favorites", value: "\(store.favorites.count)", note: "Loved drinks")
        }
    }

    private var sweetLabel: String {
        sweet >= 60 ? "Sweet" : sweet <= 35 ? "Bitter" : "Balanced"
    }

    private var richLabel: String {
        rich >= 60 ? "Rich" : rich <= 35 ? "Light" : "Smooth"
    }

    private var recommendations: [String] {
        if rich >= 60 { return ["Latte", "Milk Tea", "Mocha"] }
        if sweet >= 60 { return ["Fruit Tea", "Honey Lemon", "Yakult Tea"] }
        return ["Cold Brew", "Oolong Tea", "Americano"]
    }

    private func saveDrink() {
        let type = inferType(drinkName)
        let record = DrinkRecord(
            name: drinkName.isEmpty ? "Today’s Drink" : drinkName,
            sweet: sweet,
            rich: rich,
            tags: Array(selectedTags).sorted(),
            type: type,
            isFavorite: false,
            createdAt: .now,
            imageData: imageData,
            voiceNote: voiceNote.isEmpty ? nil : voiceNote
        )
        store.add(record)
        imageData = nil
        photoItem = nil
        voiceNote = ""
        showSaved = true
    }

    private func inferType(_ name: String) -> DrinkType {
        let lower = name.lowercased()
        if lower.contains("latte") || lower.contains("coffee") || lower.contains("brew") { return .coffee }
        if lower.contains("milk") { return .milkTea }
        if lower.contains("tea") { return .tea }
        if lower.contains("juice") || lower.contains("fruit") { return .juice }
        return .other
    }
}

struct AnalysisView: View {
    @EnvironmentObject private var store: DrinkStore

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    Text("Preference Analysis")
                        .eyebrowStyle()
                    Text("Your taste map")
                        .font(.system(size: 44, weight: .black, design: .rounded))

                    DonutChart(distribution: store.typeDistribution)
                        .frame(height: 300)
                        .cardStyle()

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        InfoTile(title: "Sweetness preference", value: "\(store.averageSweet)%", note: "Average sweetness")
                        InfoTile(title: "Richness preference", value: "\(store.averageRich)%", note: "Average body")
                        InfoTile(title: "Common category", value: store.commonType.rawValue, note: "Most frequent type")
                        InfoTile(title: "Drink types", value: "\(store.typeDistribution.count)", note: "Recorded categories")
                    }
                }
                .padding(20)
            }
            .background(FlavorBackground())
        }
    }
}

struct RecordListView: View {
    @EnvironmentObject private var store: DrinkStore
    let title: String
    let records: [DrinkRecord]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    Text(title == "History" ? "History" : "Favorites")
                        .eyebrowStyle()
                    Text(title == "History" ? "Drink timeline" : "Loved drinks")
                        .font(.system(size: 44, weight: .black, design: .rounded))

                    if records.isEmpty {
                        Text("No drinks yet.")
                            .foregroundStyle(.secondary)
                            .cardStyle()
                    } else {
                        ForEach(records) { record in
                            DrinkRow(record: record) {
                                store.toggleFavorite(record)
                            }
                        }
                    }
                }
                .padding(20)
            }
            .background(FlavorBackground())
        }
    }
}

struct ProfileView: View {
    @EnvironmentObject private var store: DrinkStore

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    Text("Me")
                        .eyebrowStyle()
                    Text("Flavor identity")
                        .font(.system(size: 44, weight: .black, design: .rounded))

                    HStack(spacing: 16) {
                        Text("FN")
                            .font(.title.bold())
                            .foregroundStyle(.white)
                            .frame(width: 82, height: 82)
                            .background(LinearGradient(colors: [.flavorCoffee, .flavorBerry], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Daily drink explorer")
                                .font(.title2.bold())
                            Text("You prefer \(store.averageSweet >= 60 ? "sweet" : "balanced"), \(store.averageRich >= 60 ? "rich" : "light"), \(store.commonType.rawValue.lowercased()) drinks.")
                                .foregroundStyle(.secondary)
                        }
                    }
                    .cardStyle()

                    LazyVGrid(columns: [GridItem(.flexible())], spacing: 12) {
                        PremiumTile(title: "Record Plus", detail: "Expand drink record capacity for long-term tracking.")
                        PremiumTile(title: "Insight Pro", detail: "Unlock enhanced preference analysis and weekly patterns.")
                        PremiumTile(title: "Voice Plus", detail: "Turn voice notes into structured taste memories.")
                    }
                }
                .padding(20)
            }
            .background(FlavorBackground())
        }
    }
}

struct DrinkRow: View {
    let record: DrinkRecord
    let onFavorite: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(LinearGradient(colors: [.flavorGold.opacity(0.62), .flavorMint.opacity(0.7)], startPoint: .topLeading, endPoint: .bottomTrailing))
                if let data = record.imageData, let image = UIImage(data: data) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                } else {
                    Image(systemName: "cup.and.saucer.fill")
                        .font(.largeTitle)
                        .foregroundStyle(.white)
                }
            }
            .frame(width: 90, height: 90)
            .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 8) {
                Text(record.name)
                    .font(.headline)
                Text("\(record.type.rawValue) · Sweet \(Int(record.sweet))% · Rich \(Int(record.rich))%")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                FlowLayout(items: record.tags) { tag in
                    Text(tag)
                        .font(.caption.bold())
                        .pillStyle(foreground: .flavorCoffee, background: .flavorGold.opacity(0.16))
                }
            }

            Spacer()

            Button(action: onFavorite) {
                Image(systemName: record.isFavorite ? "heart.fill" : "heart")
                    .foregroundStyle(Color.flavorBerry)
                    .font(.title3)
            }
            .buttonStyle(.plain)
        }
        .cardStyle()
    }
}

struct TasteSlider: View {
    let left: String
    let right: String
    let valueLabel: String
    @Binding var value: Double

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text(left)
                Spacer()
                Text(valueLabel)
                    .foregroundStyle(Color.flavorBerry)
                    .fontWeight(.black)
                Spacer()
                Text(right)
            }
            .font(.caption.weight(.bold))
            .foregroundStyle(.secondary)
            Slider(value: $value, in: 0...100)
        }
    }
}

struct InfoTile: View {
    let title: String
    let value: String
    let note: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .eyebrowStyle()
            Text(value)
                .font(.title2.bold())
            Text(note)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardStyle()
    }
}

struct PremiumTile: View {
    let title: String
    let detail: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            Text(detail)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardStyle()
    }
}

struct DonutChart: View {
    let distribution: [(DrinkType, Double)]

    private let colors: [Color] = [.flavorBerry, .flavorMint, .flavorGold, .flavorCoffee, .gray]

    var body: some View {
        VStack(spacing: 18) {
            ZStack {
                Circle()
                    .trim(from: 0, to: 1)
                    .stroke(Color.flavorGold.opacity(0.24), style: StrokeStyle(lineWidth: 42, lineCap: .round))

                ForEach(Array(segments.enumerated()), id: \.offset) { index, segment in
                    Circle()
                        .trim(from: segment.start, to: segment.end)
                        .stroke(colors[index % colors.count], style: StrokeStyle(lineWidth: 42, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                }

                VStack {
                    Text("Drink")
                        .font(.caption.bold())
                        .foregroundStyle(.secondary)
                    Text("Types %")
                        .font(.title3.bold())
                }
            }
            .frame(width: 210, height: 210)

            FlowLayout(items: distribution.map { "\($0.0.rawValue) \(Int($0.1 * 100))%" }) { label in
                Text(label)
                    .pillStyle(foreground: .secondary, background: .white.opacity(0.72))
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var segments: [(start: Double, end: Double)] {
        var cursor = 0.0
        return distribution.map { item in
            let start = cursor
            cursor += item.1
            return (start, cursor)
        }
    }
}

struct FlowLayout<Data: RandomAccessCollection, Content: View>: View where Data.Element: Hashable {
    let items: Data
    let content: (Data.Element) -> Content

    init(items: Data, @ViewBuilder content: @escaping (Data.Element) -> Content) {
        self.items = items
        self.content = content
    }

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 88), spacing: 8)], alignment: .leading, spacing: 8) {
            ForEach(Array(items), id: \.self) { item in
                content(item)
            }
        }
    }
}

struct CameraPicker: UIViewControllerRepresentable {
    @Binding var imageData: Data?
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = UIImagePickerController.isSourceTypeAvailable(.camera) ? .camera : .photoLibrary
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraPicker

        init(_ parent: CameraPicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.imageData = image.jpegData(compressionQuality: 0.78)
            }
            parent.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

struct FlavorBackground: View {
    var body: some View {
        LinearGradient(colors: [Color.flavorCream, Color.flavorSoft], startPoint: .topLeading, endPoint: .bottomTrailing)
            .ignoresSafeArea()
    }
}

struct PrimaryActionStyle: ButtonStyle {
    let isPrimary: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .foregroundStyle(isPrimary ? .white : .flavorCoffee)
            .background(isPrimary ? Color.flavorBerry : Color.white.opacity(0.82))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.black.opacity(0.08)))
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
    }
}

extension View {
    func cardStyle() -> some View {
        self
            .padding(18)
            .background(Color.white.opacity(0.76), in: RoundedRectangle(cornerRadius: 8))
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.black.opacity(0.08)))
            .shadow(color: Color.black.opacity(0.08), radius: 24, x: 0, y: 14)
    }

    func eyebrowStyle() -> some View {
        self
            .font(.caption.weight(.black))
            .textCase(.uppercase)
            .foregroundStyle(Color.flavorBerry)
    }

    func pillStyle(foreground: Color, background: Color) -> some View {
        self
            .font(.caption.weight(.black))
            .foregroundStyle(foreground)
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(background, in: RoundedRectangle(cornerRadius: 8))
    }
}

extension Color {
    static let flavorCoffee = Color(red: 0.33, green: 0.22, blue: 0.17)
    static let flavorBerry = Color(red: 0.74, green: 0.25, blue: 0.34)
    static let flavorMint = Color(red: 0.18, green: 0.55, blue: 0.46)
    static let flavorGold = Color(red: 0.82, green: 0.60, blue: 0.27)
    static let flavorCream = Color(red: 1.00, green: 0.97, blue: 0.92)
    static let flavorSoft = Color(red: 0.95, green: 0.91, blue: 0.86)
}

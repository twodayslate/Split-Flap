import SwiftUI
import UIKit

struct FontPickerView: View {
    @Binding var fontData: Data

    private let familyNames = UIFont.familyNames.sorted()

    private var currentFamily: String {
        FontArchive.fontFamily(from: fontData)
    }

    var body: some View {
        List {
            ForEach(familyNames, id: \.self) { family in
                Button {
                    fontData = FontArchive.encode(fontFamily: family, size: Preferences.defaultFontSize)
                } label: {
                    HStack {
                        Text(family)
                            .font(previewFont(for: family))
                        Spacer()
                        if currentFamily == family {
                            Image(systemName: "checkmark")
                                .foregroundStyle(.tint)
                        }
                    }
                }
                .foregroundStyle(.primary)
            }
        }
        .navigationTitle("Font")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Reset") {
                    fontData = Preferences.defaultFontData
                }
            }
        }
    }

    private func previewFont(for family: String) -> Font {
        if let uiFont = UIFont(name: family, size: 17) {
            return Font(uiFont)
        }
        return .system(size: 17)
    }
}

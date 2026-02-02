import Foundation

extension Calendar {
    var is24Hour: Bool {
        guard let locale else {
            return false
        }
        guard let format = DateFormatter.dateFormat(fromTemplate: "j", options: 0, locale: locale) else {
            return false
        }
        return !format.contains("a")
    }
}

enum TimeFormatter {
    static func string(for date: Date, showSeconds: Bool) -> String {
        let formatter = DateFormatter()
        let calendar = Calendar.current
        formatter.timeZone = calendar.timeZone
        formatter.locale = calendar.locale

        let template: String
        if calendar.is24Hour {
            template = showSeconds ? "HH:mm:ss" : "HH:mm"
        } else {
            template = showSeconds ? "h:mm:ss a" : "h:mm a"
        }
        formatter.setLocalizedDateFormatFromTemplate(template)
        return formatter.string(from: date)
    }
}

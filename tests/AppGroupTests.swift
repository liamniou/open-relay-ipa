import Foundation

@main
struct AppGroupTests {
    static func main() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        defer {
            do { try FileManager.default.removeItem(at: root) }
            catch { fatalError("Could not clean up App Group fixtures: \(error)") }
        }

        let original = "group.com.openui.openui"
        let renamed = original + ".TEAM123456"
        let cases: [([String]?, String)] = [
            (nil, original),
            ([original], original),
            ([renamed], renamed),
            (["group.unrelated", renamed], renamed),
            ([original + "other.TEAM123456", renamed], renamed),
            ([], original),
            (["group.unrelated"], original)
        ]
        for (index, testCase) in cases.enumerated() {
            let (groups, expected) = testCase
            let directory = root.appendingPathComponent("Fixture\(index).bundle")
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
            var info: [String: Any] = [
                "CFBundleIdentifier": "com.openui.fixture\(index)",
                "CFBundleName": "Fixture\(index)"
            ]
            if let groups { info["ALTAppGroups"] = groups }
            let plist = try PropertyListSerialization.data(fromPropertyList: info, format: .xml, options: 0)
            try plist.write(to: directory.appendingPathComponent("Info.plist"))
            guard let bundle = Bundle(url: directory) else {
                fatalError("Could not load App Group fixture \(index)")
            }
            let actual = AppGroup.identifier(in: bundle)
            precondition(actual == expected, "Fixture \(index): expected \(expected), got \(actual)")
        }
        print("Passed \(cases.count) App Group resolution tests.")
    }
}

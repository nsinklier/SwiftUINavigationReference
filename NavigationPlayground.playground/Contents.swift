import SwiftUI
//:# SwiftUI Navigation
/*:
 -------------------------------------------------------------------
 ## Navigation Stack
 */
struct MyNavStackView: View {
    var body: some View {
        NavigationStack {
            VStack {
                NavigationLink("Go to Details", value: "SomeValue")
            }
            .navigationDestination(for: String.self) { value in
                Text("You navigated to: \(value)")
            }
        }
    }
}
/*:
 -------------------------------------------------------------------
 ## Programmatic Navigation (State-Based)
 */
struct NavPathView: View {
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            VStack {
                Button("Go to View A") {
                    path.append("ViewA")
                }
            }
            .navigationDestination(for: String.self) { value in
                Text("Navigated to: \(value)")
            }
        }
    }
}
/*:
 -------------------------------------------------------------------
 ## Classic (deprecated as of 16.0) NavigationLink (Selection-Based)
 */
struct ClassicNavView: View {
    @State private var isActive = false

    var body: some View {
        NavigationView {
            VStack {
                NavigationLink(destination: Text("Details"), isActive: $isActive) {
                    Text("Go")
                }
                Button("Navigate") {
                    isActive = true
                }
            }
        }
    }
}
/*:
 -------------------------------------------------------------------
 ## Router-Based Navigation (Bare-Bones)
 _*Note: You'd need something like this to support any type of deep/universal link-based navigation_
 */
//: ### The Map
protocol Navigator { func navigate(to key: String) throws -> AnyView }
protocol NavigationRegistrar { func registerDestination(key: String, viewProvider: @escaping () -> AnyView) throws }
class NavRouter: Navigator, NavigationRegistrar {
    private var destinations = [String: () -> AnyView]()
    
    enum NavError: Error {
        case destinationNotFound
        case destinationAlreadyExists
    }
    
    func registerDestination(key: String, viewProvider: @escaping () -> AnyView) throws {
        guard destinations[key] == nil else { throw NavError.destinationAlreadyExists }
        destinations[key] = viewProvider
    }
    
    func navigate(to key: String) throws -> AnyView {
        guard let viewProvider = destinations[key] else { throw NavError.destinationNotFound }
        return viewProvider()
    }
}
//: ### The View
struct RouterView: View {
    @Environment var navigator: Navigator
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            VStack {
                Button("Go to a registered view") {
                    path.append("MyRegisteredView")
                }
            }
            .navigationDestination(for: String.self) { key in
                try? navigator.navigate(to: key)
            }
        }
    }
}
/*:
 -------------------------------------------------------------------
 ## PopToRoot
 */
var path = NavigationPath([""])
//: ### Back
path.removeLast()
//: ### PopToRoot
path.removeLast(path.count)
/*:
 -------------------------------------------------------------------
 ## Modal
 */
//: ### Sheet
struct NavToSheetView: View {
    @State var isPresented = false
    var body: some View {
        Button("Current View") {
            isPresented = true
        }
        .sheet(isPresented: $isPresented) { // Also .popover for regular size class, functions as sheet in compact
            Text("Modal View, (can swipe down to dismiss)")
        }
    }
}
//: ### Full Screen
struct NavToFullScreenView: View {
    @State var isPresented = false
    var body: some View {
        Button("Current View") {
            isPresented = true
        }
        .fullScreenCover(isPresented: $isPresented) {
            Text("Full-Screen Modal View (will need dismissButton)")
        }
    }
}
/*:
 -------------------------------------------------------------------
 ## Animated
 */
struct AnimatedNavPathView: View {
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            VStack {
                Button("Go to View A") {
                    withAnimation {
                        path.append("ViewA")
                    }
                }
            }
            .navigationDestination(for: String.self) { value in
                Text("Navigated to: \(value)")
            }
        }
    }
}

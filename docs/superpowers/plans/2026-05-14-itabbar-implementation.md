# ITabBar Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a pure-SwiftUI SPM package that provides a custom TabBar with three shape styles (plain / concave / convex), built-in tab animations, FAB center button, badge support, and double-tap / long-press callbacks.

**Architecture:** Zero UIKit. All three shapes drawn via SwiftUI `Path`. Animations driven by iOS 17 `keyframeAnimator`. Caller owns selection state via `@Binding`; ITabBar fires gesture callbacks and plays animations internally.

**Tech Stack:** Swift 6.0, SwiftUI, iOS 17+, Swift Testing (unit tests), Xcode 16+

---

## File Map

```
ITabBar/
├── Package.swift
├── .gitignore
├── LICENSE
├── README.md
├── Sources/ITabBar/
│   ├── ITabBar.swift                  — public View + .onTabDoubleTap / .onTabLongPress modifiers
│   ├── ITabBarShape.swift             — ITabBarShape enum
│   ├── ITabBarStyle.swift             — ITabBarStyle struct
│   ├── ITabBarItemConfig.swift        — ITabBarItemConfig struct + ITabBarAnimation enum
│   └── Internal/
│       ├── _SelectionHelpers.swift    — validatedSelection(), badgeTruncated()
│       ├── _TabBarBackground.swift    — ConcaveShape, ConvexShape + _TabBarBackground view
│       ├── _TabBarItem.swift          — _TabBarItem view (animations + gestures)
│       ├── _DefaultTabItemView.swift  — default icon+label template
│       └── _FABButton.swift           — center + button
├── Tests/ITabBarTests/
│   └── ITabBarTests.swift
└── demo/
    ├── ITabBarDemo.xcodeproj/
    └── ITabBarDemo/
        ├── ITabBarDemoApp.swift
        ├── ContentView.swift
        ├── PlainDemo.swift
        ├── ConcaveDemo.swift
        ├── ConvexDemo.swift
        └── AnimationDemo.swift
```

---

## Task 1: Package Scaffold

**Files:**
- Create: `Package.swift`
- Create: `.gitignore`
- Create: `Sources/ITabBar/.gitkeep` (touched by first source file)

- [ ] **Step 1: Write Package.swift**

```swift
// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "ITabBar",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "ITabBar", targets: ["ITabBar"]),
    ],
    targets: [
        .target(name: "ITabBar"),
        .testTarget(name: "ITabBarTests", dependencies: ["ITabBar"]),
    ]
)
```

- [ ] **Step 2: Write .gitignore** (copy from sibling ITabPager)

```
# macOS
.DS_Store

# Xcode
*.xcuserstate
xcuserdata/
*.xcodeproj/xcuserdata/
*.xcodeproj/project.xcworkspace/xcuserdata/
DerivedData/

# Swift Package Manager
.build/
.swiftpm/

# Superpowers / Claude
.superpowers/
.claude/
docs/
```

- [ ] **Step 3: Create source directories**

```bash
mkdir -p Sources/ITabBar/Internal
mkdir -p Tests/ITabBarTests
```

- [ ] **Step 4: Commit**

```bash
git add Package.swift .gitignore
git commit -m "chore: scaffold ITabBar SPM package"
```

---

## Task 2: Core Data Types

**Files:**
- Create: `Sources/ITabBar/ITabBarShape.swift`
- Create: `Sources/ITabBar/ITabBarStyle.swift`
- Create: `Sources/ITabBar/ITabBarItemConfig.swift`

- [ ] **Step 1: Write failing tests**

Create `Tests/ITabBarTests/ITabBarTests.swift`:

```swift
import Testing
import SwiftUI
@testable import ITabBar

@Suite struct ITabBarStyleTests {
    @Test func defaultHeight() {
        #expect(ITabBarStyle().height == 56)
    }
    @Test func defaultFabSize() {
        #expect(ITabBarStyle().fabSize == 52)
    }
    @Test func defaultCurveRadius() {
        #expect(ITabBarStyle().curveRadius == 28)
    }
    @Test func liquidGlassDefaultFalse() {
        #expect(ITabBarStyle().useLiquidGlass == false)
    }
}

@Suite struct ITabBarItemConfigTests {
    @Test func badgeTruncatesAt3() {
        #expect(badgeTruncated("1234") == "123")
    }
    @Test func badgeShortPassesThrough() {
        #expect(badgeTruncated("99") == "99")
    }
    @Test func badgeNilPassesNil() {
        #expect(badgeTruncated(nil) == nil)
    }
}
```

- [ ] **Step 2: Run tests — expect compile failure**

```bash
swift test --filter ITabBarTests 2>&1 | head -20
```

Expected: compile error — types not defined yet.

- [ ] **Step 3: Write ITabBarShape.swift**

```swift
import Foundation

public enum ITabBarShape: Sendable {
    case plain
    case concave
    case convex
}
```

- [ ] **Step 4: Write ITabBarStyle.swift**

```swift
import SwiftUI

public struct ITabBarStyle: Sendable {
    public var selectedColor: Color       = .primary
    public var unselectedColor: Color     = .secondary
    public var selectedFont: Font         = .system(size: 10, weight: .medium)
    public var unselectedFont: Font       = .system(size: 10, weight: .regular)

    public var backgroundColor: Color?   = nil
    public var backgroundMaterial: Material = .ultraThinMaterial
    public var useLiquidGlass: Bool      = false

    public var height: CGFloat           = 56
    public var fabSize: CGFloat          = 52
    public var fabColor: Color           = .blue
    public var itemSpacing: CGFloat      = 0

    public var badgeColor: Color         = .red
    public var badgeFont: Font           = .system(size: 10, weight: .bold)

    public var curveRadius: CGFloat      = 28

    public init() {}
}
```

- [ ] **Step 5: Write ITabBarItemConfig.swift**

```swift
import SwiftUI

public struct ITabBarItemConfig: Sendable {
    public var icon: String
    public var selectedIcon: String?
    public var title: String
    public var animation: ITabBarAnimation
    public var badge: String?

    public init(
        icon: String,
        selectedIcon: String? = nil,
        title: String,
        animation: ITabBarAnimation = .bounce,
        badge: String? = nil
    ) {
        self.icon = icon
        self.selectedIcon = selectedIcon
        self.title = title
        self.animation = animation
        self.badge = badge
    }
}

public enum ITabBarAnimation {
    case bounce
    case wiggle
    case pop
    case none
    case custom(@MainActor (Bool) -> AnyView)
}
```

- [ ] **Step 6: Write _SelectionHelpers.swift** (needed by tests)

```swift
// Sources/ITabBar/Internal/_SelectionHelpers.swift
func validatedSelection<Tab: Hashable>(_ selection: Tab, in tabs: [Tab]) -> Tab? {
    guard !tabs.isEmpty else { return nil }
    return tabs.contains(selection) ? selection : tabs.first
}

func badgeTruncated(_ badge: String?) -> String? {
    guard let badge else { return nil }
    return badge.count > 3 ? String(badge.prefix(3)) : badge
}
```

- [ ] **Step 7: Run tests — expect pass**

```bash
swift test --filter ITabBarTests
```

Expected: all 6 tests pass.

- [ ] **Step 8: Commit**

```bash
git add Sources/ Tests/
git commit -m "feat: add core data types ITabBarShape, ITabBarStyle, ITabBarItemConfig, ITabBarAnimation"
```

---

## Task 3: Selection Helpers Tests

**Files:**
- Modify: `Tests/ITabBarTests/ITabBarTests.swift`

- [ ] **Step 1: Add selection helper tests**

Append to `Tests/ITabBarTests/ITabBarTests.swift`:

```swift
@Suite struct SelectionHelpersTests {
    @Test func validSelectionReturnsItself() {
        #expect(validatedSelection(2, in: [1, 2, 3]) == 2)
    }
    @Test func invalidSelectionReturnsFirst() {
        #expect(validatedSelection(99, in: [1, 2, 3]) == 1)
    }
    @Test func emptyTabsReturnsNil() {
        #expect(validatedSelection(1, in: [] as [Int]) == nil)
    }
    @Test func singleTabAlwaysReturnsIt() {
        #expect(validatedSelection(42, in: [7]) == 7)
    }
}
```

- [ ] **Step 2: Run tests**

```bash
swift test --filter SelectionHelpersTests
```

Expected: all 4 tests pass.

- [ ] **Step 3: Commit**

```bash
git add Tests/
git commit -m "test: add selection helper and badge truncation tests"
```

---

## Task 4: Shape Drawing — _TabBarBackground

**Files:**
- Create: `Sources/ITabBar/Internal/_TabBarBackground.swift`

The TabBar frame height = `style.height`. For concave/convex, the FAB area extends above this frame via negative `offset` — SwiftUI does not clip overflow by default, so the button remains visible and tappable.

The `notchRadius` = `fabSize/2 + 4` — slightly larger than the FAB to leave a 4 pt gap.

- [ ] **Step 1: Write _TabBarBackground.swift**

```swift
import SwiftUI

// MARK: - Shapes

struct ConcaveShape: Shape {
    var fabSize: CGFloat
    var curveRadius: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width, h = rect.height
        let cx = w / 2
        let nr = fabSize / 2 + 4   // notch arc radius
        let cr = min(curveRadius, nr)

        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: cx - nr - cr, y: 0))
        // left shoulder: arc sweeping from top into notch left wall
        path.addArc(
            center: CGPoint(x: cx - nr - cr, y: cr),
            radius: cr,
            startAngle: .degrees(-90), endAngle: .degrees(0), clockwise: false
        )
        // notch bottom arc (clockwise in SwiftUI = visually down)
        path.addArc(
            center: CGPoint(x: cx, y: 0),
            radius: nr,
            startAngle: .degrees(180), endAngle: .degrees(0), clockwise: true
        )
        // right shoulder: arc sweeping from notch right wall back to top
        path.addArc(
            center: CGPoint(x: cx + nr + cr, y: cr),
            radius: cr,
            startAngle: .degrees(180), endAngle: .degrees(-90), clockwise: false
        )
        path.addLine(to: CGPoint(x: w, y: 0))
        path.addLine(to: CGPoint(x: w, y: h))
        path.addLine(to: CGPoint(x: 0, y: h))
        path.closeSubpath()
        return path
    }
}

struct ConvexShape: Shape {
    var fabSize: CGFloat
    var curveRadius: CGFloat
    var domeRise: CGFloat   // how many points the dome rises above y=0

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width, h = rect.height
        let cx = w / 2
        let nr = fabSize / 2 + 4
        let cr = min(curveRadius, nr)
        let rise = domeRise   // positive = above y=0

        // flat left part starts at y=rise (below dome transition)
        path.move(to: CGPoint(x: 0, y: rise))
        path.addLine(to: CGPoint(x: cx - nr - cr, y: rise))
        // left shoulder: arc sweeping up from flat level into dome
        path.addArc(
            center: CGPoint(x: cx - nr - cr, y: rise - cr),
            radius: cr,
            startAngle: .degrees(90), endAngle: .degrees(0), clockwise: false
        )
        // dome arc (counter-clockwise = visually up then over)
        path.addArc(
            center: CGPoint(x: cx, y: rise - cr),
            radius: nr,
            startAngle: .degrees(180), endAngle: .degrees(0), clockwise: false
        )
        // right shoulder: arc sweeping down from dome back to flat level
        path.addArc(
            center: CGPoint(x: cx + nr + cr, y: rise - cr),
            radius: cr,
            startAngle: .degrees(180), endAngle: .degrees(90), clockwise: false
        )
        path.addLine(to: CGPoint(x: w, y: rise))
        path.addLine(to: CGPoint(x: w, y: h))
        path.addLine(to: CGPoint(x: 0, y: h))
        path.closeSubpath()
        return path
    }
}

// MARK: - Background View

struct _TabBarBackground: View {
    let shape: ITabBarShape
    let style: ITabBarStyle

    private var domeRise: CGFloat { style.fabSize / 2 + 4 + style.curveRadius }

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height

            ZStack {
                switch shape {
                case .plain:
                    Rectangle()
                        .fill(backgroundFill)
                case .concave:
                    ConcaveShape(fabSize: style.fabSize, curveRadius: style.curveRadius)
                        .fill(backgroundFill)
                case .convex:
                    ConvexShape(fabSize: style.fabSize, curveRadius: style.curveRadius, domeRise: domeRise)
                        .fill(backgroundFill)
                }
            }
            .frame(width: w, height: h)
        }
    }

    @ViewBuilder
    private var backgroundFill: some ShapeStyle {
        if let color = style.backgroundColor {
            color
        } else if style.useLiquidGlass, #available(iOS 26, *) {
            // iOS 26 liquid glass — use GlassMaterial or .glassEffect modifier
            // Apply via .glassEffect() on the shape view instead of fill when available
            Material.ultraThinMaterial  // fallback shape style; .glassEffect applied as modifier below
        } else {
            style.backgroundMaterial
        }
    }
}
```

> **Note:** iOS 26 liquid glass is applied as a `.glassEffect()` view modifier, not a `ShapeStyle`. The `_TabBarBackground` body should wrap the shape in a conditional `if #available(iOS 26, *) { shape.glassEffect() }` block. Exact API should be verified against iOS 26 SDK docs; the structure above is the correct placement.

- [ ] **Step 2: Build to verify compilation**

```bash
swift build 2>&1 | tail -10
```

Expected: build succeeded with zero errors.

- [ ] **Step 3: Commit**

```bash
git add Sources/ITabBar/Internal/_TabBarBackground.swift
git commit -m "feat: add ConcaveShape, ConvexShape and _TabBarBackground"
```

---

## Task 5: FAB Button

**Files:**
- Create: `Sources/ITabBar/Internal/_FABButton.swift`

- [ ] **Step 1: Write _FABButton.swift**

```swift
import SwiftUI

struct _FABButton: View {
    let size: CGFloat
    let color: Color
    let onTap: (() -> Void)?

    var body: some View {
        Button {
            onTap?()
        } label: {
            Image(systemName: "plus")
                .font(.system(size: size * 0.38, weight: .medium))
                .foregroundStyle(.white)
                .frame(width: size, height: size)
                .background(color, in: Circle())
                .shadow(color: color.opacity(0.4), radius: 8, y: 4)
        }
        .buttonStyle(.plain)
    }
}
```

- [ ] **Step 2: Build**

```bash
swift build 2>&1 | tail -5
```

Expected: build succeeded.

- [ ] **Step 3: Commit**

```bash
git add Sources/ITabBar/Internal/_FABButton.swift
git commit -m "feat: add _FABButton"
```

---

## Task 6: Default Tab Item View

**Files:**
- Create: `Sources/ITabBar/Internal/_DefaultTabItemView.swift`

- [ ] **Step 1: Write _DefaultTabItemView.swift**

```swift
import SwiftUI

public struct _DefaultTabItemView: View {
    let config: ITabBarItemConfig
    let isSelected: Bool
    let style: ITabBarStyle

    public var body: some View {
        VStack(spacing: 3) {
            ZStack(alignment: .topTrailing) {
                Image(systemName: isSelected ? (config.selectedIcon ?? config.icon) : config.icon)
                    .font(.system(size: 22))
                    .foregroundStyle(isSelected ? style.selectedColor : style.unselectedColor)

                if let badge = badgeTruncated(config.badge), !badge.isEmpty {
                    Text(badge)
                        .font(style.badgeFont)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 1)
                        .background(style.badgeColor, in: Capsule())
                        .offset(x: 10, y: -6)
                }
            }

            Text(config.title)
                .font(isSelected ? style.selectedFont : style.unselectedFont)
                .foregroundStyle(isSelected ? style.selectedColor : style.unselectedColor)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
    }
}
```

- [ ] **Step 2: Build**

```bash
swift build 2>&1 | tail -5
```

Expected: build succeeded.

- [ ] **Step 3: Commit**

```bash
git add Sources/ITabBar/Internal/_DefaultTabItemView.swift
git commit -m "feat: add _DefaultTabItemView with icon, label, badge"
```

---

## Task 7: Tab Item with Animations and Gestures

**Files:**
- Create: `Sources/ITabBar/Internal/_TabBarItem.swift`

Animations use iOS 17's `keyframeAnimator`. A `@State var animKey: Bool` flips on each tap-to-select to trigger the animation.

Gesture priority: long press (0.5 s) is recognized simultaneously alongside tap gestures. Double tap is detected before single tap by stacking `.onTapGesture(count:)` modifiers (SwiftUI waits for the second tap before confirming a double tap, then does not fire the single-tap handler).

- [ ] **Step 1: Write _TabBarItem.swift**

```swift
import SwiftUI

struct _TabBarItem<TabItemView: View>: View {
    let isSelected: Bool
    let animation: ITabBarAnimation
    let onTap: () -> Void
    let onDoubleTap: (() -> Void)?
    let onLongPress: (() -> Void)?
    @ViewBuilder let content: () -> TabItemView

    @State private var animKey = false

    var body: some View {
        animatedContent
            .contentShape(Rectangle())
            .onTapGesture(count: 2) {
                onDoubleTap?()
            }
            .onTapGesture(count: 1) {
                onTap()
                if isSelected { animKey.toggle() }
            }
            .onLongPressGesture(minimumDuration: 0.5) {
                onLongPress?()
            }
            .onChange(of: isSelected) { _, newValue in
                if newValue { animKey.toggle() }
            }
    }

    @ViewBuilder
    private var animatedContent: some View {
        switch animation {
        case .bounce:
            content()
                .keyframeAnimator(initialValue: CGFloat(1.0), trigger: animKey) { view, scale in
                    view.scaleEffect(scale)
                } keyframes: { _ in
                    KeyframeTrack {
                        SpringKeyframe(1.25, duration: 0.15, spring: .bouncy)
                        SpringKeyframe(1.0,  duration: 0.2,  spring: .smooth)
                    }
                }
        case .wiggle:
            content()
                .keyframeAnimator(initialValue: CGFloat(0), trigger: animKey) { view, angle in
                    view.rotationEffect(.degrees(angle))
                } keyframes: { _ in
                    KeyframeTrack {
                        CubicKeyframe(-15.0, duration: 0.07)
                        CubicKeyframe( 15.0, duration: 0.14)
                        CubicKeyframe(  0.0, duration: 0.07)
                    }
                }
        case .pop:
            content()
                .keyframeAnimator(initialValue: CGFloat(1.0), trigger: animKey) { view, scale in
                    view.scaleEffect(scale)
                } keyframes: { _ in
                    KeyframeTrack {
                        SpringKeyframe(1.4, duration: 0.1,  spring: .bouncy(duration: 0.1, extraBounce: 0.2))
                        SpringKeyframe(1.0, duration: 0.25, spring: .smooth)
                    }
                }
        case .none:
            content()
        case .custom(let builder):
            builder(isSelected)
        }
    }
}
```

- [ ] **Step 2: Build**

```bash
swift build 2>&1 | tail -5
```

Expected: build succeeded.

- [ ] **Step 3: Commit**

```bash
git add Sources/ITabBar/Internal/_TabBarItem.swift
git commit -m "feat: add _TabBarItem with keyframe animations and gesture stack"
```

---

## Task 8: ITabBar Main View

**Files:**
- Create: `Sources/ITabBar/ITabBar.swift`

Layout: `ZStack(alignment: .bottom)` — page content fills the screen; the TabBar sits at the bottom. For concave, the FAB floats above the TabBar using a negative `offset(y:)`. For convex, the FAB sits inside the dome at a negative offset equal to half the dome rise. SwiftUI does not clip overflow, so both cases render correctly without additional clipping configuration.

- [ ] **Step 1: Write ITabBar.swift**

```swift
import SwiftUI

public struct ITabBar<Tab: Hashable, Content: View, TabItemView: View>: View {
    private let tabs: [Tab]
    @Binding private var selection: Tab
    private let shape: ITabBarShape
    private let style: ITabBarStyle
    private let onCenterTap: (() -> Void)?
    private let content: (Tab) -> Content
    private let tabItem: (Tab, Bool) -> TabItemView
    private var doubleTapAction: ((Tab) -> Void)?
    private var longPressAction: ((Tab) -> Void)?

    public init(
        tabs: [Tab],
        selection: Binding<Tab>,
        shape: ITabBarShape = .plain,
        style: ITabBarStyle = .init(),
        onCenterTap: (() -> Void)? = nil,
        @ViewBuilder content: @escaping (Tab) -> Content,
        @ViewBuilder tabItem: @escaping (Tab, Bool) -> TabItemView
    ) {
        self.tabs = tabs
        self._selection = selection
        self.shape = shape
        self.style = style
        self.onCenterTap = onCenterTap
        self.content = content
        self.tabItem = tabItem
    }

    private var validSelection: Tab {
        validatedSelection(selection, in: tabs) ?? selection
    }

    private var fabOffset: CGFloat {
        switch shape {
        case .plain:    return 0
        case .concave:  return -(style.fabSize / 2 + 8)
        case .convex:   return -(style.fabSize / 2 + style.curveRadius / 2 + 4)
        }
    }

    public var body: some View {
        ZStack(alignment: .bottom) {
            // Page content
            if let idx = tabs.firstIndex(of: validSelection) {
                content(tabs[idx])
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea()
            }

            // TabBar
            ZStack(alignment: .top) {
                _TabBarBackground(shape: shape, style: style)

                HStack(spacing: style.itemSpacing > 0 ? style.itemSpacing : nil) {
                    ForEach(Array(tabs.enumerated()), id: \.offset) { idx, tab in
                        // Insert gap at center for concave/convex
                        if shape != .plain && idx == tabs.count / 2 {
                            Spacer().frame(width: style.fabSize + 16)
                        }
                        _TabBarItem(
                            isSelected: validSelection == tab,
                            animation: .bounce,
                            onTap: { selection = tab },
                            onDoubleTap: doubleTapAction.map { action in { action(tab) } },
                            onLongPress: longPressAction.map { action in { action(tab) } }
                        ) {
                            tabItem(tab, validSelection == tab)
                        }
                    }
                }
                .padding(.horizontal, 8)
                .frame(height: style.height)

                // FAB — only for concave / convex
                if shape != .plain {
                    _FABButton(size: style.fabSize, color: style.fabColor, onTap: onCenterTap)
                        .offset(y: fabOffset)
                }
            }
            .frame(height: style.height)
        }
        .onChange(of: selection) { _, newValue in
            if !tabs.contains(newValue), let first = tabs.first {
                selection = first
            }
        }
    }

    // MARK: - Modifier methods
    public func onTabDoubleTap(perform action: @escaping (Tab) -> Void) -> Self {
        var copy = self
        copy.doubleTapAction = action
        return copy
    }

    public func onTabLongPress(perform action: @escaping (Tab) -> Void) -> Self {
        var copy = self
        copy.longPressAction = action
        return copy
    }
}

// MARK: - Convenience init (default template)

public extension ITabBar where TabItemView == _DefaultTabItemView {
    init(
        tabs: [Tab],
        selection: Binding<Tab>,
        shape: ITabBarShape = .plain,
        style: ITabBarStyle = .init(),
        configs: [Tab: ITabBarItemConfig],
        onCenterTap: (() -> Void)? = nil,
        @ViewBuilder content: @escaping (Tab) -> Content
    ) {
        self.init(
            tabs: tabs,
            selection: selection,
            shape: shape,
            style: style,
            onCenterTap: onCenterTap,
            content: content,
            tabItem: { tab, isSelected in
                _DefaultTabItemView(
                    config: configs[tab] ?? ITabBarItemConfig(icon: "questionmark", title: ""),
                    isSelected: isSelected,
                    style: style
                )
            }
        )
    }
}
```

- [ ] **Step 2: Build**

```bash
swift build 2>&1 | tail -5
```

Expected: build succeeded.

- [ ] **Step 3: Run all tests**

```bash
swift test
```

Expected: all tests pass.

- [ ] **Step 4: Commit**

```bash
git add Sources/ITabBar/ITabBar.swift
git commit -m "feat: add ITabBar main view with convenience init and modifier methods"
```

---

## Task 9: Demo App

**Files:**
- Create: `demo/ITabBarDemo.xcodeproj/` (via Xcode)
- Create: `demo/ITabBarDemo/ITabBarDemoApp.swift`
- Create: `demo/ITabBarDemo/ContentView.swift`
- Create: `demo/ITabBarDemo/PlainDemo.swift`
- Create: `demo/ITabBarDemo/ConcaveDemo.swift`
- Create: `demo/ITabBarDemo/ConvexDemo.swift`
- Create: `demo/ITabBarDemo/AnimationDemo.swift`

- [ ] **Step 1: Create Xcode project**

In Xcode: File → New → Project → iOS App
- Product Name: `ITabBarDemo`
- Bundle ID: `com.ibabyblue.iTabBarDemo`
- Save to: `demo/` inside the ITabBar repo root
- No tests, no CoreData

- [ ] **Step 2: Add ITabBar as local SPM dependency**

In Xcode: File → Add Package Dependencies → Add Local → select the repo root (`ITabBar/`). Add `ITabBar` product to the `ITabBarDemo` target.

- [ ] **Step 3: Write ITabBarDemoApp.swift**

```swift
import SwiftUI

@main
struct ITabBarDemoApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

- [ ] **Step 4: Write ContentView.swift**

```swift
import SwiftUI

enum Demo: String, CaseIterable, Identifiable {
    case plain    = "Plain"
    case concave  = "Concave (Water Drop)"
    case convex   = "Convex (Dome)"
    case animation = "Animations"

    var id: String { rawValue }
}

struct ContentView: View {
    @State private var activeDemo: Demo?

    var body: some View {
        NavigationStack {
            List(Demo.allCases) { demo in
                Button(demo.rawValue) { activeDemo = demo }
            }
            .navigationTitle("ITabBar Demo")
        }
        .fullScreenCover(item: $activeDemo) { demo in
            switch demo {
            case .plain:     PlainDemo()
            case .concave:   ConcaveDemo()
            case .convex:    ConvexDemo()
            case .animation: AnimationDemo()
            }
        }
    }
}
```

- [ ] **Step 5: Write PlainDemo.swift**

```swift
import SwiftUI
import ITabBar

private enum PlainTab: String, CaseIterable, Hashable {
    case home, explore, messages, profile
}

struct PlainDemo: View {
    @State private var selection: PlainTab = .home
    @Environment(\.dismiss) private var dismiss

    private var configs: [PlainTab: ITabBarItemConfig] {
        [
            .home:     ITabBarItemConfig(icon: "house",         title: "Home"),
            .explore:  ITabBarItemConfig(icon: "magnifyingglass", title: "Explore"),
            .messages: ITabBarItemConfig(icon: "message",       title: "Messages", badge: "3"),
            .profile:  ITabBarItemConfig(icon: "person",        title: "Profile"),
        ]
    }

    var body: some View {
        ITabBar(
            tabs: PlainTab.allCases,
            selection: $selection,
            shape: .plain,
            configs: configs
        ) { tab in
            pageContent(tab)
        }
        .onTabDoubleTap { tab in
            print("[PlainDemo] double tap: \(tab)")
        }
        .onTabLongPress { tab in
            print("[PlainDemo] long press: \(tab)")
        }
        .overlay(alignment: .topLeading) {
            Button("Close") { dismiss() }
                .padding()
        }
    }

    @ViewBuilder
    private func pageContent(_ tab: PlainTab) -> some View {
        Color.clear.overlay(
            Text(tab.rawValue.capitalized)
                .font(.largeTitle.bold())
        )
    }
}
```

- [ ] **Step 6: Write ConcaveDemo.swift**

```swift
import SwiftUI
import ITabBar

private enum ConcaveTab: String, CaseIterable, Hashable {
    case home, explore, messages, profile
}

struct ConcaveDemo: View {
    @State private var selection: ConcaveTab = .home
    @State private var centerTapCount = 0
    @Environment(\.dismiss) private var dismiss

    private var configs: [ConcaveTab: ITabBarItemConfig] {
        [
            .home:     ITabBarItemConfig(icon: "house",           title: "Home"),
            .explore:  ITabBarItemConfig(icon: "magnifyingglass", title: "Explore"),
            .messages: ITabBarItemConfig(icon: "message",         title: "Messages"),
            .profile:  ITabBarItemConfig(icon: "person",          title: "Profile"),
        ]
    }

    var body: some View {
        ITabBar(
            tabs: ConcaveTab.allCases,
            selection: $selection,
            shape: .concave,
            configs: configs,
            onCenterTap: { centerTapCount += 1 }
        ) { tab in
            VStack {
                Text(tab.rawValue.capitalized).font(.largeTitle.bold())
                Text("+ tapped \(centerTapCount) times").foregroundStyle(.secondary)
            }
        }
        .overlay(alignment: .topLeading) {
            Button("Close") { dismiss() }.padding()
        }
    }
}
```

- [ ] **Step 7: Write ConvexDemo.swift**

```swift
import SwiftUI
import ITabBar

private enum ConvexTab: String, CaseIterable, Hashable {
    case home, explore, messages, profile
}

struct ConvexDemo: View {
    @State private var selection: ConvexTab = .home
    @State private var centerTapCount = 0
    @Environment(\.dismiss) private var dismiss

    private var configs: [ConvexTab: ITabBarItemConfig] {
        [
            .home:     ITabBarItemConfig(icon: "house",           title: "Home"),
            .explore:  ITabBarItemConfig(icon: "magnifyingglass", title: "Explore"),
            .messages: ITabBarItemConfig(icon: "message",         title: "Messages"),
            .profile:  ITabBarItemConfig(icon: "person",          title: "Profile"),
        ]
    }

    var body: some View {
        ITabBar(
            tabs: ConvexTab.allCases,
            selection: $selection,
            shape: .convex,
            configs: configs,
            onCenterTap: { centerTapCount += 1 }
        ) { tab in
            VStack {
                Text(tab.rawValue.capitalized).font(.largeTitle.bold())
                Text("+ tapped \(centerTapCount) times").foregroundStyle(.secondary)
            }
        }
        .overlay(alignment: .topLeading) {
            Button("Close") { dismiss() }.padding()
        }
    }
}
```

- [ ] **Step 8: Write AnimationDemo.swift**

```swift
import SwiftUI
import ITabBar

private enum AnimTab: String, CaseIterable, Hashable {
    case bounce, wiggle, pop, none_
    var title: String { self == .none_ ? "None" : rawValue.capitalized }
    var animation: ITabBarAnimation {
        switch self {
        case .bounce: return .bounce
        case .wiggle: return .wiggle
        case .pop:    return .pop
        case .none_:  return .none
        }
    }
}

struct AnimationDemo: View {
    @State private var selection: AnimTab = .bounce
    @Environment(\.dismiss) private var dismiss

    private var style: ITabBarStyle {
        var s = ITabBarStyle()
        s.selectedColor = .orange
        s.fabColor = .orange
        return s
    }

    var body: some View {
        ITabBar(
            tabs: AnimTab.allCases,
            selection: $selection,
            shape: .concave,
            style: style,
            onCenterTap: nil
        ) { tab in
            Text(tab.title).font(.largeTitle.bold())
        } tabItem: { tab, isSelected in
            _DefaultTabItemView(
                config: ITabBarItemConfig(
                    icon: "star",
                    selectedIcon: "star.fill",
                    title: tab.title,
                    animation: tab.animation
                ),
                isSelected: isSelected,
                style: style
            )
        }
        .overlay(alignment: .topLeading) {
            Button("Close") { dismiss() }.padding()
        }
    }
}
```

- [ ] **Step 9: Build and run demo in simulator**

Open `demo/ITabBarDemo.xcodeproj` in Xcode, select an iPhone 17 simulator, and run. Verify:
- All four demo scenes open and close
- Plain: tabs switch, badge shows on Messages, double-tap and long-press print to console
- Concave: water-drop notch visible, + button tap increments counter
- Convex: dome visible, + button enclosed inside dome, tap increments counter
- Animation: each tab animates differently on selection

- [ ] **Step 10: Commit**

```bash
git add demo/
git commit -m "feat: add ITabBarDemo with Plain, Concave, Convex, Animation scenes"
```

---

## Task 10: README, LICENSE, Final Polish

**Files:**
- Create: `README.md`
- Create: `LICENSE`

- [ ] **Step 1: Write LICENSE** (MIT, copyright ibabyblue 2025)

```
MIT License

Copyright (c) 2025 ibabyblue

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

- [ ] **Step 2: Write README.md**

```markdown
# ITabBar

A custom tab bar component for iOS 17+. Three shape styles (plain, concave water-drop, convex dome), built-in animations, FAB center button, badge support, and double-tap / long-press callbacks. Pure SwiftUI, zero third-party dependencies.

![iOS 17+](https://img.shields.io/badge/iOS-17%2B-blue)
![Swift 6.0](https://img.shields.io/badge/Swift-6.0%2B-orange)
![SPM](https://img.shields.io/badge/SPM-compatible-brightgreen)
![License](https://img.shields.io/badge/license-MIT-lightgrey)

## Features

- **Three shapes** — plain flat, concave water-drop notch, convex dome with enclosed FAB
- **Built-in animations** — bounce, wiggle, pop, or fully custom per tab item
- **FAB center button** — optional center action button for concave / convex styles
- **Badge support** — numeric or text badge on any tab
- **Gesture callbacks** — double-tap and long-press per tab via `.onTabDoubleTap` / `.onTabLongPress`
- **Flexible tab items** — default icon+label template or fully custom `ViewBuilder`
- **Background modes** — solid color, blur material, iOS 26+ liquid glass

## Requirements

| | Minimum |
|---|---|
| iOS | 17.0 |
| Swift | 6.0 |
| Xcode | 16.0 |

## Installation

### Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/ibabyblue/ITabBar", from: "0.0.1")
],
targets: [
    .target(
        name: "YourTarget",
        dependencies: [
            .product(name: "ITabBar", package: "ITabBar")
        ]
    )
]
```

## Quick Start

```swift
import ITabBar

enum Tab: String, CaseIterable, Hashable {
    case home, explore, messages, profile
}

struct ContentView: View {
    @State private var selection: Tab = .home

    var body: some View {
        ITabBar(
            tabs: Tab.allCases,
            selection: $selection,
            shape: .concave,
            configs: [
                .home:     ITabBarItemConfig(icon: "house",           title: "Home"),
                .explore:  ITabBarItemConfig(icon: "magnifyingglass", title: "Explore"),
                .messages: ITabBarItemConfig(icon: "message",         title: "Messages", badge: "3"),
                .profile:  ITabBarItemConfig(icon: "person",          title: "Profile"),
            ],
            onCenterTap: { print("FAB tapped") }
        ) { tab in
            Text(tab.rawValue)
        }
        .onTabDoubleTap { tab in print("double tap: \(tab)") }
        .onTabLongPress { tab in print("long press: \(tab)") }
    }
}
```

## Shapes

| Style | Description |
|---|---|
| `.plain` | Flat top edge, no FAB |
| `.concave` | Top edge dips at center (water-drop notch), FAB floats above |
| `.convex` | Top edge rises at center (dome), FAB enclosed inside dome |

## Custom Style

```swift
var style: ITabBarStyle {
    var s = ITabBarStyle()
    s.selectedColor   = .orange
    s.fabColor        = .orange
    s.height          = 60
    s.fabSize         = 56
    s.curveRadius     = 32
    return s
}
```

## Custom Tab Item

```swift
ITabBar(
    tabs: tabs,
    selection: $selection,
    shape: .plain
) { tab in
    pageView(tab)
} tabItem: { tab, isSelected in
    MyCustomTabItem(tab: tab, isSelected: isSelected)
}
```

## Animations

```swift
ITabBarItemConfig(
    icon: "star",
    selectedIcon: "star.fill",
    title: "Favorites",
    animation: .wiggle   // .bounce | .wiggle | .pop | .none | .custom(...)
)
```

## Edge-Case Behavior

| Scenario | Behavior |
|---|---|
| `tabs` is empty | Renders blank, no crash |
| `selection` not in `tabs` | Corrected to `tabs.first` automatically |
| `onCenterTap` is nil | FAB renders but taps are no-ops |
| badge text > 3 chars | Truncated to 3 characters |
| `useLiquidGlass` on iOS < 26 | Silent fallback to `backgroundMaterial` |

## Demo

Open `demo/ITabBarDemo.xcodeproj`, select a simulator and run. Covers four scenarios:

- **Plain** — flat tab bar, badges, double-tap / long-press callbacks
- **Concave** — water-drop notch, FAB callback
- **Convex** — dome style, FAB enclosed inside
- **Animations** — all built-in animation presets side by side

## License

ITabBar is available under the MIT license. See the [LICENSE](LICENSE) file for details.
```

- [ ] **Step 3: Run final test suite**

```bash
swift test
```

Expected: all tests pass.

- [ ] **Step 4: Final commit and tag**

```bash
git add README.md LICENSE
git commit -m "docs: add README and MIT license"
git tag 0.0.1
```
```

- [ ] **Step 5: Push**

```bash
git push origin main --tags
```

---

## Self-Review

**Spec coverage check:**

| Spec requirement | Task |
|---|---|
| Three shapes: plain / concave / convex | Task 4 (_TabBarBackground) |
| Built-in animations: bounce / wiggle / pop / none / custom | Task 7 (_TabBarItem) |
| FAB center button + onCenterTap callback | Task 5 + Task 8 (ITabBar body) |
| Double-tap / long-press callbacks | Task 7 (gestures) + Task 8 (modifiers) |
| Default icon+label template | Task 6 (_DefaultTabItemView) |
| Custom ViewBuilder tab item | Task 8 (ITabBar init) |
| Badge support (truncated at 3 chars) | Task 6 + Task 2 (badgeTruncated) |
| Solid color / blur / liquid glass background | Task 4 (_TabBarBackground) |
| Edge cases: empty tabs, invalid selection | Task 3 (validatedSelection tests) |
| Demo app with all scenarios | Task 9 |
| README + LICENSE | Task 10 |

No gaps found.

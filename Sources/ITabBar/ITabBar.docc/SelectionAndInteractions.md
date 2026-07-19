# Selection and Interactions

Understand how tab identity, selection correction, and gesture callbacks compose.

## Keep Selection Valid

Both components validate selection whenever `tabs` or the selection binding changes:

- A valid identity remains selected through reordering.
- Removing the selected identity writes `tabs.first` into the binding.
- An initially invalid selection is corrected to the first tab.
- An empty tab collection leaves the binding unchanged and presents no selected content.

Use unique stable identities. The package does not deduplicate repeated identifiers.

## Handle Standard Item Gestures

```swift
ITabBar(/* ... */)
    .onTabDoubleTap { tab in
        scrollToTop(tab)
    }
    .onTabLongPress { tab in
        showContextActions(for: tab)
    }
```

A single tap selects immediately. When double-tap handling is installed, a second tap on the same item within 0.3 seconds invokes the double-tap callback without delaying or repeating the first selection action. Tapping the selected item also replays its configured animation.

A long press is recognized after 0.5 seconds and invokes its callback only when the item was already selected. Long-pressing an unselected item does not select it. A recognized long press clears pending double-tap timing.

The native component supports same-tab double taps but intentionally omits long presses because `UITabBarItem` has no public per-item long-press target API.

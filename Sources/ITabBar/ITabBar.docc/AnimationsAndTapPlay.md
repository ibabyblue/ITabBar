# Animations and Tap Playback

Apply built-in item motion or build replayable custom content from interaction context.

## Choose a Built-in Animation

``ITabBarAnimation`` provides bounce, wiggle, pop, none, and custom options. Built-in motion replays when an item becomes selected, when the selected item is tapped again, and when a recognized double tap completes.

## Build Custom Animated Content

The custom builder receives ``ITabBarAnimationContext/isSelected`` and ``ITabBarAnimationContext/tapTrigger``. The trigger flips whenever playback should restart.

```swift
ITabBarItemConfig(
    icon: "heart",
    title: "Favorites",
    animation: .custom { context in
        AnyView(
            Image(systemName: context.isSelected ? "heart.fill" : "heart")
                .symbolEffect(.bounce, value: context.tapTrigger)
        )
    }
)
```

Custom builders run on the main actor.

## Swap Resting and Active Views

Use ``ITabBarTapPlayView`` for one-shot content such as Lottie, a video-frame sequence, or a custom SwiftUI animation:

```swift
animation: .custom { context in
    AnyView(
        ITabBarTapPlayView(context: context, duration: 1.2) {
            Image(systemName: "heart")
        } active: {
            AnimatedHeartView()
        }
    )
}
```

Each replay remounts the active hierarchy with a new SwiftUI identity. Switching away cancels pending restoration and immediately returns to resting content. The container adds a small grace interval after the requested duration so one-shot content can render its final frame. Obsolete reset tasks are cancelled on replay or deselection.

ITabBar does not depend on an animation framework. Any third-party renderer remains an application or Example dependency.

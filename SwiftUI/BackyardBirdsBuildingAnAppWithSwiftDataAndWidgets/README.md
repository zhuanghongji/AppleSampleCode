# Backyard Birds: Building an app with SwiftData and widgets

Create an app with persistent data, interactive widgets, and an all new in-app purchase experience.

## Overview

Backyard Birds offers a rich environment in which you can watch the birds that visit your backyard garden. 
You can monitor their water and food supply to ensure they always have fresh water and plenty to eat, 
or upgrade the game using an in-app purchase to provide tastier food for the birds to eat.

 The sample implements its data model using [SwiftData](https://developer.apple.com/documentation/swiftdata) 
 for persistence, and integrates seamlessly with SwiftUI using the [`Observable`](https://developer.apple.com/documentation/observation) protocol. 
 The game's widgets implement [App Intents](https://developer.apple.com/documentation/AppIntents) for interactive and configurable widgets. The in-app purchase experience uses the [`ProductView`](https://developer.apple.com/documentation/storekit/productview) 
 and [`SubscriptionStoreView`](https://developer.apple.com/documentation/storekit/subscriptionstoreview) from StoreKit.

You can access the source code for this sample
on [GitHub](https://github.com/apple/sample-backyard-birds).

- Note: This sample code project is associated with WWDC23 session 102:
[State of the Union](https://developer.apple.com/wwdc23/102/).

## Configure the sample code project

To configure the Backyard Birds app to run on your devices, follow these steps:

1. Open the project in Xcode 15 or later.
2. Edit the multiplatform target's scheme, and on the Options tab, choose the `Store.storekit` file for StoreKit configuration.
3. Repeat the previous step for the watchOS target's scheme.
4. Select the top-level Backyard Birds project.
5. For all targets, choose your team from the Team menu in the Signing & Capabilities pane so Xcode can automatically manage your provisioning profile.

## Create a data-driven app

The app defines its data model by conforming the model objects to [`PersistentModel`](https://developer.apple.com/documentation/swiftdata/persistentmodel) 
using the [`Model`](https://developer.apple.com/documentation/swiftdata/model()) macro. 
Using the [`Attribute`](https://developer.apple.com/documentation/swiftdata/attribute(_:originalName:hashModifier:)) macro 
with the [`unique`](https://developer.apple.com/documentation/swiftdata/schema/attribute/option/unique) 
option ensures that the `id` property is unique.

``` swift
@Model public class BirdSpecies {
    @Attribute(.unique) public var id: String
    public var naturalScale: Double
    public var isEarlyAccess: Bool
    public var parts: [BirdPart]
    
    @Relationship(deleteRule: .cascade, inverse: \Bird.species)
    public var birds: [Bird] = []
    
    public var info: BirdSpeciesInfo { BirdSpeciesInfo(rawValue: id) }
    
    public init(info: BirdSpeciesInfo, naturalScale: Double = 1, isEarlyAccess: Bool = false, parts: [BirdPart]) {
        self.id = info.rawValue
        self.naturalScale = naturalScale
        self.isEarlyAccess = isEarlyAccess
        self.parts = parts
    }
}
```

## Construct interactive widgets

Backyard Birds displays interactive widgets by presenting a ``Button`` to refill a backyard's supplies 
when the water and food are running low. The app does this by placing a `Button` in the widget's view, 
and passing a `ResupplyBackyardIntent` instance to the
 [`init(intent:label:)`](https://developer.apple.com/documentation/swiftui/button/init(intent:label:)) initializer:

``` swift
Button(intent: ResupplyBackyardIntent(backyard: BackyardEntity(from: snapshot.backyard))) {
    Label("Refill Water", systemImage: "arrow.clockwise")
        .foregroundStyle(.secondary)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(.quaternary, in: .containerRelative)
}
```

The app allows for configuration of the widget by implementing the 
 [`WidgetConfigurationIntent`](https://developer.apple.com/documentation/appintents/widgetconfigurationintent)
  protocol:

``` swift
struct BackyardWidgetIntent: WidgetConfigurationIntent {
    static let title: LocalizedStringResource = "Backyard"
    static let description = IntentDescription("Keep track of your backyards.")
    
    @Parameter(title: "Backyards", default: BackyardWidgetContent.all)
    var backyards: BackyardWidgetContent
    
    @Parameter(title: "Backyard")
    var specificBackyard: BackyardEntity?
    
    init(backyards: BackyardWidgetContent = .all, specificBackyard: BackyardEntity? = nil) {
        self.backyards = backyards
        self.specificBackyard = specificBackyard
    }
    
    init() {
    }
    
    static var parameterSummary: some ParameterSummary {
        When(\.$backyards, .equalTo, BackyardWidgetContent.specific) {
            Summary {
                \.$backyards
                \.$specificBackyard
            }
        } otherwise: {
            Summary {
                \.$backyards
            }
        }
    }
}
```

## Provide a new in-app purchase experience

The sample app uses [`ProductView`](https://developer.apple.com/documentation/storekit/productview) to display several different bird food upgrades available for purchase on a store shelf. 
To prominently feature an in-app purchase item, the app uses the
 [`.productViewStyle(.large)`](https://developer.apple.com/documentation/storekit/productview/4202371-productviewstyle) modifier:

``` swift
ProductView(id: product.id) {
    BirdFoodProductIcon(birdFood: birdFood, quantity: product.quantity)
        .bestBirdFoodValueBadge()
}
.padding(.vertical)
.background(.background.secondary, in: .rect(cornerRadius: 20))
.productViewStyle(.large)
```

The Backyard Birds Pass page displays renewable subscriptions using the
 [`SubscriptionStoreView`](https://developer.apple.com/documentation/storekit/subscriptionstoreview) view. 
 The app uses the `PassMarketingContent` view as the content of the `SubscriptionStoreView`:

``` swift
SubscriptionStoreView(
    groupID: passGroupID,
    visibleRelationships: showPremiumUpgrade ? .upgrade : .all
) {
    PassMarketingContent(showPremiumUpgrade: showPremiumUpgrade)
        #if !os(watchOS)
        .containerBackground(for: .subscriptionStoreFullHeight) {
            SkyBackground()
        }
        #endif
}
```

## Screenshots

![1](https://github.com/zhuanghongji/AppleSampleCode/assets/11421799/2a6567ae-4ef8-4b25-9910-5384f99edfb3)

![2](https://github.com/zhuanghongji/AppleSampleCode/assets/11421799/24bcf985-13e7-446c-a295-1b83d4d033ab)

![3](https://github.com/zhuanghongji/AppleSampleCode/assets/11421799/099dc647-9675-46ed-b1b8-69b62898fc11)

![4](https://github.com/zhuanghongji/AppleSampleCode/assets/11421799/e554275f-81a4-484e-91f7-ab80de5e8eb5)

![5](https://github.com/zhuanghongji/AppleSampleCode/assets/11421799/aa39b705-0b6a-4bb9-83e5-653e483a5a3e)

![6](https://github.com/zhuanghongji/AppleSampleCode/assets/11421799/c9ca5fce-82de-4b4b-8f21-ae013c6e372e)

![7](https://github.com/zhuanghongji/AppleSampleCode/assets/11421799/4772b9dd-319e-473b-a772-0bc7e3114eb7)

![8](https://github.com/zhuanghongji/AppleSampleCode/assets/11421799/b663033b-f8b1-425d-a519-d94a386d6640)

![9](https://github.com/zhuanghongji/AppleSampleCode/assets/11421799/dd4fdf95-852c-4411-b1d3-3fa73bdcdf6d)

![10](https://github.com/zhuanghongji/AppleSampleCode/assets/11421799/9a2c6aca-feed-447e-b9ba-c4f1890a707c)

![11](https://github.com/zhuanghongji/AppleSampleCode/assets/11421799/82ce5279-10c1-4e70-a29c-b9850bf770b5)

![12](https://github.com/zhuanghongji/AppleSampleCode/assets/11421799/f7ebbaf9-da8e-44d5-b0b4-a7a1e919ed9d)

![13](https://github.com/zhuanghongji/AppleSampleCode/assets/11421799/6511d923-773b-4df1-813f-a5b722964ce4)

![14](https://github.com/zhuanghongji/AppleSampleCode/assets/11421799/751b34f6-206f-434f-8fef-4562eac81897)

![15](https://github.com/zhuanghongji/AppleSampleCode/assets/11421799/a323c749-5095-4839-840f-64dda23ac5be)

![16](https://github.com/zhuanghongji/AppleSampleCode/assets/11421799/a62e135a-ba41-43c0-b325-6f0fcd1562d5)

![17](https://github.com/zhuanghongji/AppleSampleCode/assets/11421799/92ebf169-cda9-4554-b310-98c8726df4c4)
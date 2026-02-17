// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Domain
import SwiftUI

/// A reusable form component that contains an intro section and a content section.
///
/// This component provides a consistent layout for form sections across the settings views,
/// with a centered icon, title, and descriptive subtitle.
struct IntroForm<Content: View, HeaderContent: View>: View {
    /// The style of the form intro section.
    ///
    /// - intro: The intro section is displayed with a centered icon, title, and subtitle.
    /// - compact: The intro section is displayed with a compact layout.
    enum Style {
        case intro
        case compact
    }

    /// The title of the navigation bar.
    let navigationTitle: String

    /// The style of the form intro section.
    let style: Style

    /// The icon to display in the intro section.
    let icon: AnyView

    /// The title of the form.
    let title: String

    /// The subtitle of the form.
    let subtitle: String

    /// The content of the form.
    let content: () -> Content

    /// Additional content to append to the header section.
    let appendToHeader: (() -> HeaderContent)?

    init(
        navigationTitle: String,
        style: Style,
        icon: some View,
        title: String,
        subtitle: String,
        @ViewBuilder content: @escaping () -> Content
    ) where HeaderContent == EmptyView {
        self.navigationTitle = navigationTitle
        self.style = style
        self.icon = AnyView(icon)
        self.title = title
        self.subtitle = subtitle
        self.content = content
        appendToHeader = nil
    }

    init(
        navigationTitle: String,
        style: Style,
        icon: some View,
        title: String,
        subtitle: String,
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder appendToHeader: @escaping () -> HeaderContent
    ) {
        self.navigationTitle = navigationTitle
        self.style = style
        self.icon = AnyView(icon)
        self.title = title
        self.subtitle = subtitle
        self.content = content
        self.appendToHeader = appendToHeader
    }

    init(
        navigationPage: some NavigationPage,
        style: Style,
        @ViewBuilder content: @escaping () -> Content
    ) where HeaderContent == EmptyView {
        navigationTitle = navigationPage.name
        self.style = style
        icon = navigationPage.icon
        title = navigationPage.name
        subtitle = navigationPage.description
        self.content = content
        appendToHeader = nil
    }

    init(
        navigationPage: some NavigationPage,
        style: Style,
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder appendToHeader: @escaping () -> HeaderContent
    ) {
        navigationTitle = navigationPage.name
        self.style = style
        icon = navigationPage.icon
        title = navigationPage.name
        subtitle = navigationPage.description
        self.content = content
        self.appendToHeader = appendToHeader
    }

    var body: some View {
        Form {
            Section {
                switch style {
                case .intro:
                    VStack {
                        HStack {
                            Spacer()

                            icon
                                .frame(width: 64, height: 64)
                                .tag("intro-form-icon")

                            Spacer()
                        }

                        Spacer(minLength: 4)

                        Text(title)
                            .font(.title)
                            .bold()
                            .tag("intro-form-title")

                        Text(subtitle)
                            .multilineTextAlignment(.center)
                            .font(.callout)
                            .foregroundStyle(.secondary)
                            .tag("intro-form-subtitle")

                        Spacer()
                    }
                    .padding(8)
                    .tag("intro-form-intro-section")

                case .compact:
                    HStack(alignment: .top) {
                        icon
                            .scaleEffect(18.0 / ConfigurationDefaults.settingsIconSmallSize)
                            .padding(5)
                            .tag("intro-form-compact-icon")

                        VStack(alignment: .leading) {
                            Text(title)
                                .font(.none)
                                .tag("intro-form-compact-title")

                            Text(subtitle)
                                .multilineTextAlignment(.leading)
                                .secondaryText()
                                .tag("intro-form-compact-subtitle")
                        }
                    }
                    .tag("intro-form-compact-section")
                }

                appendToHeader?()
            }

            content()
        }
        .settingsFormStyle()
        .navigationTitle(
            style == .intro ? "" : navigationTitle
        )
        .tag("intro-form")
    }
}

#Preview {
    IntroForm(
        navigationTitle: "General Settings",
        style: .intro,
        icon: AnyView(Image(nsImage: NSApplication.shared.applicationIconImage)
            .resizable()
        ),
        title: "General Settings",
        subtitle: "Manage your overall setup and preferences for AeroSpaceBar, " +
            "such as AeroSpace path and Appearance settings."
    ) { }

    IntroForm(
        navigationTitle: "Some Other Settings",
        style: .compact,
        icon: AnyView(Image(systemName: "star")
            .resizable()
        ),
        title: "General Settings",
        subtitle: "Manage your overall setup and preferences for AeroSpaceBar, " +
            "such as AeroSpace path and Appearance settings."
    ) { }

    IntroForm(
        navigationTitle: "Some More Settings",
        style: .compact,
        icon: AnyView(Image(systemName: "hammer")
            .resizable()
        ),
        title: "Non General Settings",
        subtitle: "Manage your overall setup and preferences for AeroSpaceBar, " +
            "such as AeroSpace path and Appearance settings."
    ) {
        Button("hello") {
            print("world")
        }
    } appendToHeader: {
        Text("again")
    }
}

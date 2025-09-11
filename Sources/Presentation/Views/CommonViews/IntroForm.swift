// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import SwiftUI

/// A reusable form component that contains an intro section and a content section.
///
/// This component provides a consistent layout for form sections across the settings views,
/// with a centered icon, title, and descriptive subtitle.
struct IntroForm<Content, HeaderContent>: View where Content: View, HeaderContent: View {
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

    /// The image to display in the intro section.
    let image: Image

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
        style: Style = .intro,
        image: Image,
        title: String,
        subtitle: String,
        @ViewBuilder content: @escaping () -> Content
    ) where HeaderContent == EmptyView {
        self.navigationTitle = navigationTitle
        self.style = style
        self.image = image
        self.title = title
        self.subtitle = subtitle
        self.content = content
        appendToHeader = nil
    }

    init(
        navigationTitle: String,
        style: Style = .intro,
        image: Image,
        title: String,
        subtitle: String,
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder appendToHeader: @escaping () -> HeaderContent
    ) {
        self.navigationTitle = navigationTitle
        self.style = style
        self.image = image
        self.title = title
        self.subtitle = subtitle
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

                            image
                                .resizable()
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
                            .font(.system(size: 12))
                            .foregroundStyle(.secondary)
                            .tag("intro-form-subtitle")

                        Spacer()
                    }
                    .padding(8)
                    .tag("intro-form-intro-section")

                case .compact:
                    HStack(alignment: .top) {
                        let displayImage = image
                            .resizable()
                            .frame(width: 18, height: 18)
                            .padding(4)
                            .background(.white.opacity(0.1), in: .rect)
                            .tag("intro-form-compact-icon")

                        if #available(macOS 26.0, *) {
                            displayImage
                                .glassEffect(.clear, in: .rect)
                                .cornerRadius(8)
                        } else {
                            displayImage
                                .cornerRadius(8)
                        }

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
        .formStyle(.grouped)
        .padding(.top, -20)
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
        image: Image(nsImage: NSApplication.shared.applicationIconImage),
        title: "General Settings",
        subtitle: "Manage your overall setup and preferences for AeroSpaceBar, " +
            "such as AeroSpace path and Appearance settings."
    ) { }

    IntroForm(
        navigationTitle: "Some Other Settings",
        style: .compact,
        image: Image(systemName: "star"),
        title: "General Settings",
        subtitle: "Manage your overall setup and preferences for AeroSpaceBar, " +
            "such as AeroSpace path and Appearance settings."
    ) { }

    IntroForm(
        navigationTitle: "Some More Settings",
        style: .compact,
        image: Image(systemName: "hammer"),
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

// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Domain
import SwiftUI

/// A generic view for configuring visual settings of container entities.
///
/// This view provides a reusable interface for managing visual appearance configurations
/// for different types of container entities (Groups, Spaces) with their respective
/// appearance modes and CRUD capabilities.
struct VisualSettingsContainerView<Entity: VisualContainer, PrependContent: View, AppendContent: View>: View {
    // MARK: - Properties

    /// The navigation page for this container view.
    let navigationPage: RootNavigationPage

    /// Whether the feature is enabled.
    @OptionalBinding var isFeatureEnabled: Bool?

    /// The available appearance modes (optional - defaults to all cases).
    @OptionalBinding var availableAppearanceModes: [Entity.AppearanceMode]?

    /// The current appearance mode.
    @Binding var appearanceMode: Entity.AppearanceMode

    /// The list of entities.
    @Binding var entities: [Entity]

    /// The global color properties.
    @Binding var globalColorProperties: ColorProperties

    /// The global geometric properties.
    @Binding var globalGeometricProperties: GeometricProperties

    /// The global effect properties.
    @Binding var globalEffectProperties: EffectProperties

    /// The current theme preset.
    @Binding var themePresetColorProperties: ThemePresetColorProperties

    /// The theme preset geometry properties.
    @OptionalBinding var themePresetGeometricProperties: GeometricProperties?

    /// The theme preset effect properties.
    @OptionalBinding var themePresetEffectProperties: EffectProperties?

    /// Whether to show the reset confirmation dialog.
    @State private var showingResetConfirmation = false

    /// The current theme mode.
    let themeMode: ThemeMode

    // MARK: - Callbacks

    /// Callback to create a navigation page for an entity.
    let createNavigationPage: (Entity) -> AnyNavigationPage

    /// Callback to register a dynamic sub page.
    let onRegisterDynamicSubPage: @MainActor (AnyNavigationPage) -> Void

    /// Callback to navigate to a page.
    let onNavigateTo: @MainActor (AnyNavigationPage) -> Void

    /// Callback to add a new entity.
    let onAddEntity: (() -> Void)?

    /// Callback to delete an entity.
    let onDeleteEntity: ((Entity) -> Void)?

    /// Callback to reset all entities.
    let onResetEntities: () -> Void

    /// Callback to check if more entities can be added.
    let canAddMoreEntities: (() -> Bool)?

    /// Callback to remove navigation pages when feature is disabled.
    let onFeatureDisabled: (() -> Void)?

    /// Optional callback to determine if the entities list should be shown.
    /// If nil, defaults to metadata.canAddEntities || metadata.canDeleteEntities.
    let shouldShowEntitiesList: (() -> Bool)?

    // MARK: - Content

    /// Content to display before the main visual settings.
    let prepend: () -> PrependContent

    /// Content to display after the main visual settings.
    let append: () -> AppendContent

    // MARK: - Initializer

    /// Initializes a VisualSettingsContainerView with required and optional parameters.
    ///
    /// - Parameters:
    ///   - navigationPage: The navigation page for this container view
    ///   - isFeatureEnabled: Whether the feature is enabled
    ///   - appearanceMode: The current appearance mode
    ///   - entities: The list of entities
    ///   - globalColorProperties: The global color properties
    ///   - globalGeometricProperties: The global geometric properties
    ///   - themeMode: The current theme mode
    ///   - themePresetColorProperties: The current theme preset
    ///   - themePresetGeometricProperties: The current theme preset geometric properties
    ///   - themePresetEffectProperties: The current theme preset effect properties
    ///   - createNavigationPage: Callback to create a navigation page for an entity
    ///   - onRegisterDynamicSubPage: Callback to register a dynamic sub page
    ///   - onNavigateTo: Callback to navigate to a page
    ///   - onAddEntity: Optional callback to add a new entity (default: nil)
    ///   - onDeleteEntity: Optional callback to delete an entity (default: nil)
    ///   - onResetEntities: Optional callback to reset all entities (default: nil)
    ///   - canAddMoreEntities: Optional callback to check if more entities can be added (default: nil)
    ///   - onFeatureDisabled: Optional callback to remove navigation pages when feature is disabled (default: nil)
    ///   - shouldShowEntitiesList: Optional callback to determine if entities list should be shown (default: nil)
    ///   - prepend: Content to display before the main visual settings
    ///   - append: Content to display after the main visual settings
    init(
        navigationPage: RootNavigationPage,
        isFeatureEnabled: Binding<Bool>? = nil,
        appearanceMode: Binding<Entity.AppearanceMode>,
        availableAppearanceModes: Binding<[Entity.AppearanceMode]>? = nil,
        entities: Binding<[Entity]>,
        globalColorProperties: Binding<ColorProperties>,
        globalGeometricProperties: Binding<GeometricProperties>,
        globalEffectProperties: Binding<EffectProperties>,
        themeMode: ThemeMode,
        themePresetColorProperties: Binding<ThemePresetColorProperties>,
        themePresetGeometricProperties: Binding<GeometricProperties>? = nil,
        themePresetEffectProperties: Binding<EffectProperties>? = nil,
        createNavigationPage: @escaping (Entity) -> AnyNavigationPage,
        onRegisterDynamicSubPage: @escaping @MainActor (AnyNavigationPage) -> Void,
        onNavigateTo: @escaping @MainActor (AnyNavigationPage) -> Void,
        onAddEntity: (() -> Void)? = nil,
        onDeleteEntity: ((Entity) -> Void)? = nil,
        onResetEntities: @escaping () -> Void,
        canAddMoreEntities: (() -> Bool)? = nil,
        onFeatureDisabled: (() -> Void)? = nil,
        shouldShowEntitiesList: (() -> Bool)? = nil,
        @ViewBuilder prepend: @escaping () -> PrependContent,
        @ViewBuilder append: @escaping () -> AppendContent
    ) {
        self.navigationPage = navigationPage

        _isFeatureEnabled = OptionalBinding(isFeatureEnabled)
        _availableAppearanceModes = OptionalBinding(availableAppearanceModes)
        _appearanceMode = appearanceMode
        _entities = entities
        _globalColorProperties = globalColorProperties
        _globalGeometricProperties = globalGeometricProperties
        _globalEffectProperties = globalEffectProperties
        _themePresetColorProperties = themePresetColorProperties
        _themePresetGeometricProperties = OptionalBinding(themePresetGeometricProperties)
        _themePresetEffectProperties = OptionalBinding(themePresetEffectProperties)

        self.themeMode = themeMode
        self.createNavigationPage = createNavigationPage
        self.onRegisterDynamicSubPage = onRegisterDynamicSubPage
        self.onNavigateTo = onNavigateTo
        self.onAddEntity = onAddEntity
        self.onDeleteEntity = onDeleteEntity
        self.onResetEntities = onResetEntities
        self.canAddMoreEntities = canAddMoreEntities
        self.onFeatureDisabled = onFeatureDisabled
        self.shouldShowEntitiesList = shouldShowEntitiesList
        self.prepend = prepend
        self.append = append
    }

    // MARK: - Body

    var body: some View {
        let metadata = Entity.metadata

        IntroForm(
            navigationPage: navigationPage,
            style: .compact
        ) {
            // Prepend content
            prepend()

            if isFeatureEnabled != false {
                appearanceModeSection

                let isPresetModeController = themePresetGeometricProperties != nil &&
                    themePresetEffectProperties != nil &&
                    !themeMode.isColorCustomizable

                if appearanceMode.shouldShowGlobalConfig || isPresetModeController {
                    visualSettingsSection
                }

                if shouldShowEntitiesList?() != false {
                    entitiesListSection

                    if !entities.isEmpty {
                        resetSection
                    }
                }
            }

            // Append content
            append()
        } appendToHeader: {
            // Only show toggle if isFeatureEnabled binding is provided
            if isFeatureEnabled != nil {
                Toggle(isOn: $isFeatureEnabled) {
                    Text(LocalizedStringResource(stringLiteral: metadata.entityNamePlural))
                }
                .toggleStyle(.switch)
                .tag("\(metadata.tagPrefix)-show-\(metadata.tagPrefix)-toggle")
            }
        }
        .animation(.themeEaseInOutFast, value: isFeatureEnabled)
        .animation(.themeEaseInOutFast, value: entities.isEmpty)
        .animation(.themeEaseInOutFast, value: appearanceMode)
        .animation(.themeEaseInOutFast, value: entities)
        .animation(.themeEaseInOutFast, value: themeMode)
        .onChange(of: isFeatureEnabled) { _, newValue in
            if newValue == false {
                handleFeatureDisabled()
            }
        }
        .alert(
            metadata.resetAlertTitle,
            isPresented: $showingResetConfirmation
        ) {
            Button(LocalizedStringResource("Cancel"), role: .cancel) { }
            Button(LocalizedStringResource("Reset"), role: .destructive) {
                onResetEntities()
            }
        } message: {
            Text(LocalizedStringResource(stringLiteral: metadata.resetAlertMessage))
        }
    }

    // MARK: - Private Views

    /// Appearance mode picker section.
    private var appearanceModeSection: some View {
        let metadata = Entity.metadata

        return Section {
            let appearanceModeCases = availableAppearanceModes ?? Array(Entity.AppearanceMode.allCases)

            Picker(
                LocalizedStringResource("Mode"),
                selection: $appearanceMode
            ) {
                ForEach(appearanceModeCases, id: \.self) { mode in
                    Text(mode.displayName).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .disabled(!themeMode.isColorCustomizable)
        } header: {
            Text(LocalizedStringResource("Appearance"))
        } footer: {
            if themeMode.isColorCustomizable {
                Text(appearanceMode.description)
            } else {
                Text(
                    LocalizedStringResource(
                        """
                        Appearance mode is set to \(themePresetColorProperties.displayName) and can be modified \
                        in the General settings when Theme Mode is set to Custom.
                        """
                    )
                )
            }
        }
        .padding(.top, 4)
        .tag("\(metadata.tagPrefix)-appearance-mode-section")
    }

    /// Global color properties section.
    private var visualSettingsSection: some View {
        VisualSettingsView(
            metadata: Entity.metadata,
            themeMode: themeMode,
            colorProperties: Binding<ColorProperties>(
                get: {
                    if themeMode.isColorCustomizable {
                        globalColorProperties
                    } else {
                        themePresetColorProperties.colorProperties
                    }
                },
                set: { newValue in
                    if themeMode.isColorCustomizable {
                        globalColorProperties = newValue
                    }
                }
            ),
            geometricProperties: Binding<GeometricProperties>(
                get: {
                    if
                        !themeMode.isColorCustomizable,
                        let geometry = themePresetGeometricProperties
                    {
                        geometry
                    } else {
                        globalGeometricProperties
                    }
                },
                set: { newValue in
                    if themeMode.isColorCustomizable {
                        globalGeometricProperties = newValue
                    } else {
                        themePresetGeometricProperties = newValue
                    }
                }
            ),
            effectProperties: Binding<EffectProperties>(
                get: {
                    if
                        !themeMode.isColorCustomizable,
                        let effect = themePresetEffectProperties
                    {
                        effect
                    } else {
                        globalEffectProperties
                    }
                },
                set: { newValue in
                    if themeMode.isColorCustomizable {
                        globalEffectProperties = newValue
                    } else {
                        themePresetEffectProperties = newValue
                    }
                }
            )
        )
    }

    /// Entities list section.
    private var entitiesListSection: some View {
        let metadata = Entity.metadata

        return Section {
            LazyVStackList {
                ForEach(entities) { entity in
                    entityRowItem(for: entity)
                }
            }
        } header: {
            HStack {
                Text(LocalizedStringResource(stringLiteral: metadata.entityNamePlural))
                Spacer()
                if metadata.canAddEntities, let addEntity = onAddEntity {
                    Button {
                        addEntity()
                    } label: {
                        Image(systemName: "plus.circle")
                    }
                    .buttonStyle(.plain)
                    .disabled(!(canAddMoreEntities?() ?? false))
                }
            }
        } footer: {
            if !metadata.footerText.isEmpty {
                Text(LocalizedStringResource(stringLiteral: metadata.footerText))
            }
        }
    }

    /// Creates a row item for the given entity.
    /// - Parameter entity: The entity to create a row item for
    /// - Returns: A configured LazyVStackListRowItem
    @ViewBuilder
    private func entityRowItem(for entity: Entity) -> some View {
        let metadata = Entity.metadata
        let deleteCallback: ((AnyNavigationPage) -> Void)? = metadata
            .canDeleteEntities && onDeleteEntity != nil ? { page in
                // Find the entity that matches this page ID
                if
                    let matchingEntity = entities.first(where: { entity in
                        AnyHashable(page.id) == getEntityId(entity)
                    }),
                    let deleteEntity = onDeleteEntity
                {
                    deleteEntity(matchingEntity)
                }
            } : nil

        LazyVStackListRowItem(
            item: entity,
            allItems: entities,
            content: { entity in
                Text(LocalizedStringResource(stringLiteral: "\(metadata.entityName) \(getEntityDisplayId(entity))"))
            },
            createPage: createNavigationPage,
            onRegisterDynamicSubPage: onRegisterDynamicSubPage,
            onNavigateTo: onNavigateTo,
            onDelete: deleteCallback,
            shouldShowDeleteAction: metadata.canDeleteEntities ? metadata.canDeleteEntity : nil
        )
    }

    /// Reset section.
    private var resetSection: some View {
        let metadata = Entity.metadata

        return Section(LocalizedStringResource("Reset")) {
            SettingsDestructiveButton(
                title: LocalizedStringResource(stringLiteral: metadata.resetButtonTitle),
                description: LocalizedStringResource(stringLiteral: metadata.resetButtonDescription),
                action: { showingResetConfirmation = true }
            )
            .tag("\(metadata.tagPrefix)-reset-button")
        }
        .tag("\(metadata.tagPrefix)-reset-section")
    }

    // MARK: - Private Methods

    /// Handles when the feature is disabled.
    private func handleFeatureDisabled() {
        onFeatureDisabled?()
    }

    /// Gets the display ID for an entity.
    /// - Parameter entity: The entity to get the display ID for
    /// - Returns: The display ID string
    private func getEntityDisplayId(_ entity: Entity) -> String {
        if let group = entity as? Domain.Group {
            return String(group.id + 1)
        } else if let space = entity as? Domain.Space {
            return space.id
        }
        return String(describing: entity.id)
    }

    /// Gets the ID for an entity (used for matching with page IDs).
    /// - Parameter entity: The entity to get the ID for
    /// - Returns: The entity ID
    private func getEntityId(_ entity: Entity) -> AnyHashable {
        if let group = entity as? Domain.Group {
            return group.id
        } else if let space = entity as? Domain.Space {
            return space.id
        }
        return entity.id
    }
}

// MARK: - Convenience Extensions

extension VisualSettingsContainerView where AppendContent == EmptyView {
    /// Initializes a VisualSettingsContainerView with only prepend content.
    ///
    /// - Parameters:
    ///   - navigationPage: The navigation page for this container view
    ///   - isFeatureEnabled: Whether the feature is enabled
    ///   - appearanceMode: The current appearance mode
    ///   - entities: The list of entities
    ///   - globalColorProperties: The global color properties
    ///   - globalGeometricProperties: The global geometric properties
    ///   - themeMode: The current theme mode
    ///   - themePresetColorProperties: The current theme preset
    ///   - themePresetGeometricProperties: The current theme preset geometric properties
    ///   - themePresetEffectProperties: The current theme preset effect properties
    ///   - createNavigationPage: Callback to create a navigation page for an entity
    ///   - onRegisterDynamicSubPage: Callback to register a dynamic sub page
    ///   - onNavigateTo: Callback to navigate to a page
    ///   - onAddEntity: Optional callback to add a new entity (default: nil)
    ///   - onDeleteEntity: Optional callback to delete an entity (default: nil)
    ///   - onResetEntities: Optional callback to reset all entities (default: nil)
    ///   - canAddMoreEntities: Optional callback to check if more entities can be added (default: nil)
    ///   - onFeatureDisabled: Optional callback to remove navigation pages when feature is disabled (default: nil)
    ///   - shouldShowEntitiesList: Optional callback to determine if entities list should be shown (default: nil)
    ///   - prepend: Content to display before the main visual settings
    init(
        navigationPage: RootNavigationPage,
        isFeatureEnabled: Binding<Bool>? = nil,
        appearanceMode: Binding<Entity.AppearanceMode>,
        availableAppearanceModes: Binding<[Entity.AppearanceMode]>? = nil,
        entities: Binding<[Entity]>,
        globalColorProperties: Binding<ColorProperties>,
        globalGeometricProperties: Binding<GeometricProperties>,
        globalEffectProperties: Binding<EffectProperties>,
        themeMode: ThemeMode,
        themePresetColorProperties: Binding<ThemePresetColorProperties>,
        themePresetGeometricProperties: Binding<GeometricProperties>? = nil,
        themePresetEffectProperties: Binding<EffectProperties>? = nil,
        createNavigationPage: @escaping (Entity) -> AnyNavigationPage,
        onRegisterDynamicSubPage: @escaping @MainActor (AnyNavigationPage) -> Void,
        onNavigateTo: @escaping @MainActor (AnyNavigationPage) -> Void,
        onAddEntity: (() -> Void)? = nil,
        onDeleteEntity: ((Entity) -> Void)? = nil,
        onResetEntities: @escaping () -> Void,
        canAddMoreEntities: (() -> Bool)? = nil,
        onFeatureDisabled: (() -> Void)? = nil,
        shouldShowEntitiesList: (() -> Bool)? = nil,
        @ViewBuilder prepend: @escaping () -> PrependContent
    ) {
        self.init(
            navigationPage: navigationPage,
            isFeatureEnabled: isFeatureEnabled,
            appearanceMode: appearanceMode,
            availableAppearanceModes: availableAppearanceModes,
            entities: entities,
            globalColorProperties: globalColorProperties,
            globalGeometricProperties: globalGeometricProperties,
            globalEffectProperties: globalEffectProperties,
            themeMode: themeMode,
            themePresetColorProperties: themePresetColorProperties,
            themePresetGeometricProperties: themePresetGeometricProperties,
            themePresetEffectProperties: themePresetEffectProperties,
            createNavigationPage: createNavigationPage,
            onRegisterDynamicSubPage: onRegisterDynamicSubPage,
            onNavigateTo: onNavigateTo,
            onAddEntity: onAddEntity,
            onDeleteEntity: onDeleteEntity,
            onResetEntities: onResetEntities,
            canAddMoreEntities: canAddMoreEntities,
            onFeatureDisabled: onFeatureDisabled,
            shouldShowEntitiesList: shouldShowEntitiesList,
            prepend: prepend,
            append: { EmptyView() }
        )
    }
}

extension VisualSettingsContainerView where PrependContent == EmptyView {
    /// Initializes a VisualSettingsContainerView with only append content.
    ///
    /// - Parameters:
    ///   - navigationPage: The navigation page for this container view
    ///   - isFeatureEnabled: Whether the feature is enabled
    ///   - appearanceMode: The current appearance mode
    ///   - entities: The list of entities
    ///   - globalColorProperties: The global color properties
    ///   - globalGeometricProperties: The global geometric properties
    ///   - themeMode: The current theme mode
    ///   - themePresetColorProperties: The current theme preset
    ///   - themePresetGeometricProperties: The current theme preset geometric properties
    ///   - themePresetEffectProperties: The current theme preset effect properties
    ///   - createNavigationPage: Callback to create a navigation page for an entity
    ///   - onRegisterDynamicSubPage: Callback to register a dynamic sub page
    ///   - onNavigateTo: Callback to navigate to a page
    ///   - onAddEntity: Optional callback to add a new entity (default: nil)
    ///   - onDeleteEntity: Optional callback to delete an entity (default: nil)
    ///   - onResetEntities: Optional callback to reset all entities (default: nil)
    ///   - canAddMoreEntities: Optional callback to check if more entities can be added (default: nil)
    ///   - onFeatureDisabled: Optional callback to remove navigation pages when feature is disabled (default: nil)
    ///   - shouldShowEntitiesList: Optional callback to determine if entities list should be shown (default: nil)
    ///   - append: Content to display after the main visual settings
    init(
        navigationPage: RootNavigationPage,
        isFeatureEnabled: Binding<Bool>? = nil,
        appearanceMode: Binding<Entity.AppearanceMode>,
        availableAppearanceModes: Binding<[Entity.AppearanceMode]>? = nil,
        entities: Binding<[Entity]>,
        globalColorProperties: Binding<ColorProperties>,
        globalGeometricProperties: Binding<GeometricProperties>,
        globalEffectProperties: Binding<EffectProperties>,
        themeMode: ThemeMode,
        themePresetColorProperties: Binding<ThemePresetColorProperties>,
        themePresetGeometricProperties: Binding<GeometricProperties>? = nil,
        themePresetEffectProperties: Binding<EffectProperties>? = nil,
        createNavigationPage: @escaping (Entity) -> AnyNavigationPage,
        onRegisterDynamicSubPage: @escaping @MainActor (AnyNavigationPage) -> Void,
        onNavigateTo: @escaping @MainActor (AnyNavigationPage) -> Void,
        onAddEntity: (() -> Void)? = nil,
        onDeleteEntity: ((Entity) -> Void)? = nil,
        onResetEntities: @escaping () -> Void,
        canAddMoreEntities: (() -> Bool)? = nil,
        onFeatureDisabled: (() -> Void)? = nil,
        shouldShowEntitiesList: (() -> Bool)? = nil,
        @ViewBuilder append: @escaping () -> AppendContent
    ) {
        self.init(
            navigationPage: navigationPage,
            isFeatureEnabled: isFeatureEnabled,
            appearanceMode: appearanceMode,
            availableAppearanceModes: availableAppearanceModes,
            entities: entities,
            globalColorProperties: globalColorProperties,
            globalGeometricProperties: globalGeometricProperties,
            globalEffectProperties: globalEffectProperties,
            themeMode: themeMode,
            themePresetColorProperties: themePresetColorProperties,
            themePresetGeometricProperties: themePresetGeometricProperties,
            themePresetEffectProperties: themePresetEffectProperties,
            createNavigationPage: createNavigationPage,
            onRegisterDynamicSubPage: onRegisterDynamicSubPage,
            onNavigateTo: onNavigateTo,
            onAddEntity: onAddEntity,
            onDeleteEntity: onDeleteEntity,
            onResetEntities: onResetEntities,
            canAddMoreEntities: canAddMoreEntities,
            onFeatureDisabled: onFeatureDisabled,
            shouldShowEntitiesList: shouldShowEntitiesList,
            prepend: { EmptyView() },
            append: append
        )
    }
}

extension VisualSettingsContainerView where PrependContent == EmptyView, AppendContent == EmptyView {
    /// Initializes a VisualSettingsContainerView with no custom content.
    ///
    /// - Parameters:
    ///   - navigationPage: The navigation page for this container view
    ///   - isFeatureEnabled: Whether the feature is enabled
    ///   - appearanceMode: The current appearance mode
    ///   - entities: The list of entities
    ///   - globalColorProperties: The global color properties
    ///   - globalGeometricProperties: The global geometric properties
    ///   - themeMode: The current theme mode
    ///   - themePresetColorProperties: The current theme preset
    ///   - themePresetGeometricProperties: The current theme preset geometric properties
    ///   - themePresetEffectProperties: The current theme preset effect properties
    ///   - createNavigationPage: Callback to create a navigation page for an entity
    ///   - onRegisterDynamicSubPage: Callback to register a dynamic sub page
    ///   - onNavigateTo: Callback to navigate to a page
    ///   - onAddEntity: Optional callback to add a new entity (default: nil)
    ///   - onDeleteEntity: Optional callback to delete an entity (default: nil)
    ///   - onResetEntities: Optional callback to reset all entities (default: nil)
    ///   - canAddMoreEntities: Optional callback to check if more entities can be added (default: nil)
    ///   - onFeatureDisabled: Optional callback to remove navigation pages when feature is disabled (default: nil)
    ///   - shouldShowEntitiesList: Optional callback to determine if entities list should be shown (default: nil)
    init(
        navigationPage: RootNavigationPage,
        isFeatureEnabled: Binding<Bool>? = nil,
        appearanceMode: Binding<Entity.AppearanceMode>,
        availableAppearanceModes: Binding<[Entity.AppearanceMode]>? = nil,
        entities: Binding<[Entity]>,
        globalColorProperties: Binding<ColorProperties>,
        globalGeometricProperties: Binding<GeometricProperties>,
        globalEffectProperties: Binding<EffectProperties>,
        themeMode: ThemeMode,
        themePresetColorProperties: Binding<ThemePresetColorProperties>,
        themePresetGeometricProperties: Binding<GeometricProperties>? = nil,
        themePresetEffectProperties: Binding<EffectProperties>? = nil,
        createNavigationPage: @escaping (Entity) -> AnyNavigationPage,
        onRegisterDynamicSubPage: @escaping @MainActor (AnyNavigationPage) -> Void,
        onNavigateTo: @escaping @MainActor (AnyNavigationPage) -> Void,
        onAddEntity: (() -> Void)? = nil,
        onDeleteEntity: ((Entity) -> Void)? = nil,
        onResetEntities: @escaping () -> Void,
        canAddMoreEntities: (() -> Bool)? = nil,
        onFeatureDisabled: (() -> Void)? = nil,
        shouldShowEntitiesList: (() -> Bool)? = nil
    ) {
        self.init(
            navigationPage: navigationPage,
            isFeatureEnabled: isFeatureEnabled,
            appearanceMode: appearanceMode,
            availableAppearanceModes: availableAppearanceModes,
            entities: entities,
            globalColorProperties: globalColorProperties,
            globalGeometricProperties: globalGeometricProperties,
            globalEffectProperties: globalEffectProperties,
            themeMode: themeMode,
            themePresetColorProperties: themePresetColorProperties,
            themePresetGeometricProperties: themePresetGeometricProperties,
            themePresetEffectProperties: themePresetEffectProperties,
            createNavigationPage: createNavigationPage,
            onRegisterDynamicSubPage: onRegisterDynamicSubPage,
            onNavigateTo: onNavigateTo,
            onAddEntity: onAddEntity,
            onDeleteEntity: onDeleteEntity,
            onResetEntities: onResetEntities,
            canAddMoreEntities: canAddMoreEntities,
            onFeatureDisabled: onFeatureDisabled,
            shouldShowEntitiesList: shouldShowEntitiesList,
            prepend: { EmptyView() },
            append: { EmptyView() }
        )
    }
}

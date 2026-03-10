// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import AppKit
import Domain
import SwiftUI

/// A view that allows the user to select a modifier key for the Quick Hide feature.
///
/// When clicked, the view enters a "recording" mode that captures the next modifier
/// key press and updates the binding. Pressing Escape cancels the recording mode.
struct TriggerKeyRecorderView: View {
    /// The currently selected trigger key.
    @Binding var triggerKey: QuickHideTriggerKey

    /// Whether the view is currently recording a key press.
    @State private var isRecording = false

    /// Controls the blinking border opacity during recording mode.
    @State private var blinkOpacity: Double = 1.0

    /// The task responsible for running the blink animation loop.
    @State private var blinkTask: Task<Void, Never>?

    /// Local event monitor for capturing key events during recording.
    @State private var localMonitor: Any?

    /// Global event monitor for capturing key events during recording.
    @State private var globalMonitor: Any?

    var body: some View {
        HStack {
            Text(LocalizedStringResource("Trigger Key"))

            Spacer()

            Button {
                startRecording()
            } label: {
                HStack(spacing: 6) {
                    if isRecording {
                        Text(LocalizedStringResource("Press a modifier key\u{2026}"))
                            .foregroundStyle(.secondary)
                    } else {
                        Image(systemName: triggerKey.systemImageName)
                        Text(triggerKey.displayName)
                    }
                }
                .frame(minWidth: 140)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
            }
            .buttonStyle(.bordered)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(Color.accentColor, lineWidth: 2)
                    .opacity(isRecording ? blinkOpacity : 0)
            )
        }
        .onChange(of: isRecording) { _, newValue in
            if newValue {
                startBlinking()
            } else {
                stopBlinking()
            }
        }
        .onDisappear {
            stopRecording()
        }
    }

    // MARK: - Private Methods

    /// Begins recording mode to capture the next modifier key press.
    private func startRecording() {
        isRecording = true

        // Monitor for flagsChanged events to detect modifier key presses
        localMonitor = NSEvent.addLocalMonitorForEvents(matching: [.flagsChanged, .keyDown]) { event in
            if event.type == .keyDown, event.keyCode == 53 {
                // Escape key pressed — cancel recording
                stopRecording()
                return nil
            }

            if event.type == .flagsChanged {
                if let key = mapModifierFlags(event.modifierFlags) {
                    triggerKey = key
                    stopRecording()
                    return nil
                }
            }

            return event
        }

        globalMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.flagsChanged]) { event in
            if let key = mapModifierFlags(event.modifierFlags) {
                Task { @MainActor in
                    triggerKey = key
                    stopRecording()
                }
            }
        }
    }

    /// Stops recording mode and removes event monitors.
    private func stopRecording() {
        isRecording = false

        if let localMonitor {
            NSEvent.removeMonitor(localMonitor)
            self.localMonitor = nil
        }

        if let globalMonitor {
            NSEvent.removeMonitor(globalMonitor)
            self.globalMonitor = nil
        }
    }

    /// Maps NSEvent modifier flags to a QuickHideTriggerKey.
    ///
    /// Returns the corresponding trigger key for the first recognized modifier flag
    /// detected in the event, or nil if no recognized modifier is pressed.
    /// - Parameter flags: The modifier flags from the NSEvent
    /// - Returns: The matching QuickHideTriggerKey, or nil if no match
    private func mapModifierFlags(_ flags: NSEvent.ModifierFlags) -> QuickHideTriggerKey? {
        // Check each modifier flag in order of specificity
        if flags.contains(.function) { return .fn }
        if flags.contains(.control) { return .control }
        if flags.contains(.option) { return .option }
        if flags.contains(.command) { return .command }
        if flags.contains(.shift) { return .shift }
        return nil
    }

    /// Starts the blinking animation loop for the recording border.
    private func startBlinking() {
        blinkOpacity = 1.0
        blinkTask = Task { @MainActor in
            while !Task.isCancelled {
                withAnimation(.easeInOut(duration: 0.5)) {
                    blinkOpacity = 0.0
                }
                try? await Task.sleep(for: .milliseconds(500))
                guard !Task.isCancelled else { break }

                withAnimation(.easeInOut(duration: 0.5)) {
                    blinkOpacity = 1.0
                }
                try? await Task.sleep(for: .milliseconds(500))
            }
        }
    }

    /// Stops the blinking animation loop and resets the border opacity.
    private func stopBlinking() {
        blinkTask?.cancel()
        blinkTask = nil
        withAnimation(.easeInOut(duration: 0.2)) {
            blinkOpacity = 0.0
        }
    }
}

// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Foundation
import PackagePlugin

/// Build Tool Plugin for generating Secrets.swift from environment variables or .env file.
///
/// This plugin generates the Secrets.swift file during the build process by:
/// 1. Creating a Swift script that reads LEMONSQUEEZY_API_KEY from environment or .env file
/// 2. Running the script using /usr/bin/swift (system Swift interpreter)
/// 3. Declaring the output file so SPM includes it in compilation
/// 4. Failing the build if no API key is found
///
/// The .env file is expected to be in the Data package directory (Packages/Data/.env).
/// The generated file contains sensitive API keys and is created before the Data target compilation begins.
@main
struct SecretGeneratorPlugin: BuildToolPlugin {
    /// Creates build commands to run during the build.
    ///
    /// - Parameters:
    ///   - context: The plugin context providing access to the package and build environment
    ///   - target: The target being built
    /// - Returns: Array of prebuild commands that generate Secrets.swift
    func createBuildCommands(context: PluginContext, target: Target) throws -> [Command] {
        // Only run for the Data target
        guard target.name == "Data" else {
            return []
        }

        // Get directories
        let workDirectory = context.pluginWorkDirectoryURL
        let outputDirectory = workDirectory.appending(path: "GeneratedSources")
        let scriptsDirectory = workDirectory.appending(path: "Scripts")
        let secretsFilePath = outputDirectory.appending(path: "Secrets.swift")
        let scriptPath = scriptsDirectory.appending(path: "generate-secrets-script.swift")

        // Get the Data package directory (where .env file is located)
        let packageDirectory = context.package.directoryURL

        // Create the Swift script that will generate Secrets.swift
        let scriptContent = """
        #!/usr/bin/env swift

        import Foundation

        // MARK: - Error Types

        enum SecretGeneratorError: Error, CustomStringConvertible {
            case missingAPIKey
            case invalidEnvFile(String)
            case writeFailure(Error)

            var description: String {
                switch self {
                case .missingAPIKey:
                    return \"\"\"
                    ❌ LEMONSQUEEZY_API_KEY not found

                    The API key must be provided via:
                    1. Environment variable: LEMONSQUEEZY_API_KEY
                    2. .env file in Data package directory (Packages/Data/.env)
                       with: LEMONSQUEEZY_API_KEY="your-key-here"

                    Build cannot proceed without the API key.
                    \"\"\"

                case .invalidEnvFile(let path):
                    return "❌ .env file exists at \\(path) but does not contain LEMONSQUEEZY_API_KEY"

                case .writeFailure(let error):
                    return "❌ Failed to write Secrets.swift: \\(error.localizedDescription)"
                }
            }
        }

        // MARK: - Main Logic

        func getAPIKey(packageDirectory: String) throws -> String {
            // First, check environment variables
            if let apiKey = ProcessInfo.processInfo.environment["LEMONSQUEEZY_API_KEY"],
               !apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            {
                print("✅ Found LEMONSQUEEZY_API_KEY in environment variables")
                return apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
            }

            print("⚠️  LEMONSQUEEZY_API_KEY not in environment, checking .env file...")

            // Try to read from .env file
            let envFilePath = "\\(packageDirectory)/.env"

            guard FileManager.default.fileExists(atPath: envFilePath) else {
                print("❌ .env file not found at: \\(envFilePath)")
                throw SecretGeneratorError.missingAPIKey
            }

            print("📄 Found .env file at: \\(envFilePath)")

            // Read and parse .env file
            guard let envContents = try? String(contentsOfFile: envFilePath, encoding: .utf8) else {
                print("❌ Failed to read .env file")
                throw SecretGeneratorError.missingAPIKey
            }

            // Parse .env file for LEMONSQUEEZY_API_KEY
            let lines = envContents.components(separatedBy: .newlines)
            for line in lines {
                let trimmedLine = line.trimmingCharacters(in: .whitespaces)

                // Skip empty lines and comments
                guard !trimmedLine.isEmpty, !trimmedLine.hasPrefix("#") else {
                    continue
                }

                // Parse KEY=VALUE or KEY="VALUE"
                if let equalIndex = trimmedLine.firstIndex(of: "=") {
                    let key = trimmedLine[..<equalIndex].trimmingCharacters(in: .whitespaces)

                    if key == "LEMONSQUEEZY_API_KEY" {
                        var value = String(trimmedLine[trimmedLine.index(after: equalIndex)...])
                            .trimmingCharacters(in: .whitespaces)

                        // Remove quotes if present
                        if value.hasPrefix("\\""), value.hasSuffix("\\"") {
                            value = String(value.dropFirst().dropLast())
                        } else if value.hasPrefix("'"), value.hasSuffix("'") {
                            value = String(value.dropFirst().dropLast())
                        }

                        if !value.isEmpty {
                            print("✅ Found LEMONSQUEEZY_API_KEY in .env file")
                            return value
                        }
                    }
                }
            }

            // API key not found in .env file
            throw SecretGeneratorError.invalidEnvFile(envFilePath)
        }

        func generateSecrets(packageDirectory: String, outputPath: String) throws {
            // Get API key
            let apiKey = try getAPIKey(packageDirectory: packageDirectory)

            // Generate Secrets.swift content
            let secretsContent = \"\"\"
            // Copyright (c) 2025 AeroSpaceBar by Ronen Druker.
            //
            // ⚠️ AUTO-GENERATED FILE - DO NOT EDIT
            // This file is generated by SecretGeneratorPlugin during the build process
            // It contains sensitive API keys that should never be committed to version control

            import Foundation

            /// Contains sensitive secrets baked into the application at build time.
            public enum Secrets {
                /// LemonSqueezy API key for license management.
                public static let lemonSqueezyAPIKey = "\\(apiKey)"
            }

            \"\"\"

            // Write Secrets.swift file
            do {
                try secretsContent.write(toFile: outputPath, atomically: true, encoding: .utf8)
                print("✅ SecretGeneratorPlugin: Secrets.swift generated successfully")
                print("   Output: \\(outputPath)")
            } catch {
                throw SecretGeneratorError.writeFailure(error)
            }
        }

        // MARK: - Entry Point

        // Check command line arguments
        guard CommandLine.arguments.count == 3 else {
            print("Usage: generate-secrets-script.swift <package-directory> <output-path>")
            exit(1)
        }

        let packageDirectory = CommandLine.arguments[1]
        let outputPath = CommandLine.arguments[2]

        do {
            try generateSecrets(packageDirectory: packageDirectory, outputPath: outputPath)
            exit(0)
        } catch {
            print("\\(error)")
            exit(1)
        }
        """

        // Create directories
        try FileManager.default.createDirectory(
            at: scriptsDirectory,
            withIntermediateDirectories: true
        )
        try FileManager.default.createDirectory(
            at: outputDirectory,
            withIntermediateDirectories: true
        )

        // Write the script file
        try scriptContent.write(to: scriptPath, atomically: true, encoding: .utf8)

        // Make the script executable
        var permissions = try FileManager.default.attributesOfItem(atPath: scriptPath.path())
        permissions[.posixPermissions] = 0o755
        try FileManager.default.setAttributes(permissions, ofItemAtPath: scriptPath.path())

        // Return prebuild command that runs the Swift script
        // outputFilesDirectory points to GeneratedSources, not Scripts, so only Secrets.swift is compiled
        return [
            .prebuildCommand(
                displayName: "Generate Secrets.swift",
                executable: URL(fileURLWithPath: "/usr/bin/swift"),
                arguments: [
                    scriptPath.path(),
                    packageDirectory.path(),
                    secretsFilePath.path()
                ],
                outputFilesDirectory: outputDirectory
            )
        ]
    }
}

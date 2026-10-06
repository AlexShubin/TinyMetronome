import ProjectDescription

let appVersion = "1.0.0"
let buildNumber = "2"

let project = Project(
    name: "TinyMetronome",
    options: .options(automaticSchemesOptions: .enabled(codeCoverageEnabled: true)),
    settings: .settings(
        base: [
            "SWIFT_VERSION": "6.0",
            "SWIFT_APPROACHABLE_CONCURRENCY": "YES",
            "ENABLE_USER_SCRIPT_SANDBOXING": "YES",
            "CODE_SIGN_STYLE": "Automatic",
            "DEVELOPMENT_TEAM": "RBNKHS73S3",
        ],
        configurations: [
            .debug(name: "Debug"),
            .release(name: "Release"),
        ]
    ),
    targets: [
        .target(
            name: "TinyMetronome",
            destinations: .macOS,
            product: .app,
            bundleId: "com.alexshubin.TinyMetronome",
            deploymentTargets: .macOS("26.0"),
            infoPlist: .extendingDefault(with: [
                "CFBundleIconName": "AppIcon",
                "CFBundleDisplayName": "Tiny Metronome",
                "CFBundleName": "Tiny Metronome",
                "CFBundleShortVersionString": .string(appVersion),
                "CFBundleVersion": .string(buildNumber),
                "LSApplicationCategoryType": "public.app-category.music",
                "ITSAppUsesNonExemptEncryption": false,
            ]),
            buildableFolders: [
                "Sources",
                "Resources",
            ],
            entitlements: .file(path: "Resources/TinyMetronome.entitlements"),
            settings: .settings(
                base: [
                    "ASSETCATALOG_COMPILER_APPICON_NAME": "AppIcon",
                    "CODE_SIGN_IDENTITY": "Apple Development",
                    "ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS": "YES",
                    "ENABLE_APP_SANDBOX": "YES",
                    "ENABLE_HARDENED_RUNTIME": "YES",
                    "PRODUCT_NAME": "Tiny Metronome",
                    "PRODUCT_MODULE_NAME": "TinyMetronome",
                    "MARKETING_VERSION": .string(appVersion),
                    "CURRENT_PROJECT_VERSION": .string(buildNumber),
                ]
            )
        ),
        .target(
            name: "TinyMetronomeTests",
            destinations: .macOS,
            product: .unitTests,
            bundleId: "com.alexshubin.TinyMetronome.TinyMetronomeTests",
            deploymentTargets: .macOS("26.0"),
            buildableFolders: [
                "Tests",
            ],
            dependencies: [
                .target(name: "TinyMetronome"),
            ],
            settings: .settings(
                base: [
                    "TEST_HOST": "$(BUILT_PRODUCTS_DIR)/Tiny Metronome.app/Contents/MacOS/Tiny Metronome",
                    "BUNDLE_LOADER": "$(TEST_HOST)",
                ]
            )
        ),
    ]
)

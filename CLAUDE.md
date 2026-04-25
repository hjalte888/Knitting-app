# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

iOS knitting app (App Store, one-time purchase). SwiftUI + SwiftData, iOS 17+. No backend — all data is local.

## Setup

```bash
brew install xcodegen
xcodegen generate          # generates KnittingApp.xcodeproj from project.yml
open KnittingApp.xcodeproj
```

Edit `project.yml` to set `DEVELOPMENT_TEAM` and `PRODUCT_BUNDLE_IDENTIFIER` before building for a device.

## Build & Run

Build and run only through Xcode (no CLI build target). Simulator works without a paid developer account.

## Architecture

**Navigation:** `TabView` in `ContentView.swift` with 5 tabs: Projects · Patterns · Tools · Yarn Stash · Yarn Finder.

**Persistence:** SwiftData `ModelContainer` configured in `KnittingApp.swift`. Models: `Project`, `Pattern`, `YarnStash`, `Needle`. All `@Query` usage is in views, `@Environment(\.modelContext)` for writes.

**Gauge adjustment** (`Services/GaugeParser.swift`): Pure regex-based, no AI. Parses Danish + English knitting text to find stitch counts, row counts, and measurements, then applies the ratio `myGauge / patternGauge`. Entry point: `GaugeAdjusterView` in `Features/GaugeAdjuster/`.

**Yarn finder** (`Services/YarnDatabase.swift`): Loads `Resources/yarns.json` at init. `findAlternatives(for:tolerance:)` scores candidates by gauge distance. Add new yarns directly to `yarns.json` — the format is documented at the top of that file.

## Key files

| File | Purpose |
|---|---|
| `project.yml` | xcodegen config — source of truth for Xcode project settings |
| `Services/GaugeParser.swift` | Regex patterns + adjustment logic |
| `Services/YarnDatabase.swift` | Yarn search and alternative matching |
| `Resources/yarns.json` | Bundled yarn database (~44 yarns, expand as needed) |
| `Models/YarnStash.swift` | `YarnWeight` enum with gauge ranges per category |

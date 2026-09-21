# Apple UX Swarm

```
========================================================================
  SOVEREIGN LEVIATHAN NODE LICENSE
  License-ID: SL-AGPL3-001 | Covenant-Version: 1.0
  Copyright (C) 2026 SnapKittyWest. Ahmad Ali Parr,
  Bel Esprit D'Accord Irrevocable Trust.
  Licensed under: MPL-2.0 OR GPL-3.0-or-later
  Commercial repository.
  "Hark, though this node be but a spark,
   Its covenant endureth through the dark."
========================================================================
```

<p align="center">
  <video src="https://github.com/SNAPKITTYWEST/apple-ux-swarm/releases/download/v1.0.0/clear.mp4"
         autoplay muted loop playsinline
         width="680"
         style="border-radius:16px">
  </video>
</p>

---

## Overview

**BEAM OTP coordinator · Dylan CRC frames · Metal avatars · SwiftUI HIG shell · JWT+SAML auth**

A complete multi-agent orchestration system with an Apple HIG-compliant frontend, formally verified BEAM mesh, and Metal-accelerated avatar rendering.

---

## Architecture

```
+------------------------------------------------------------------+
|  SwiftUI HIG Shell (Visual Workplace)                            |
|  frontend/visual-workplace.html                                  |
|  - macOS-style desktop, menubar, dock                            |
|  - Xcode-style editor + file tree + console                      |
|  - Canvas 2D avatar presence tile (browser fallback)             |
|  - Metal avatar shader (Apple hardware)                          |
+------------------------+-----------------------------------------+
                         |
                         | JWT + SAML auth
                         v
+------------------------------------------------------------------+
|  BEAM OTP Coordinator (Elixir)                                   |
|  beam/lib/swarm/                                                  |
|  - 10,000-agent fan-out in 32-42 ms                              |
|  - Dylan CRC32 framing                                           |
|  - TCP listener + backpressure                                    |
+------------------------+-----------------------------------------+
                         |
                         | Dylan frames
                         v
+------------------------------------------------------------------+
|  Metal Avatars + SwiftUI Bridge (Swift 6)                        |
|  metal/Sources/AgentUX/                                          |
|  - AvatarShaders.metal                                           |
|  - AppleRecreationView.swift                                     |
|  - DylanClient.swift                                             |
+------------------------------------------------------------------+
```

---

## Repository Structure

```
apple-ux-swarm/
├── frontend/
│   ├── visual-workplace.html    # Full macOS-style workspace UI
│   ├── assets/
│   │   └── clear.mp4            # Demo video
│   └── auth/
│       ├── auth-guard.js
│       ├── jwt.js
│       └── saml.js
├── beam/
│   └── lib/swarm/
│       ├── agent_supervisor.ex
│       ├── application.ex
│       ├── backpressure.ex
│       ├── dylan_codec.ex
│       ├── tcp_listener.ex
│       └── auth/
│           ├── jwt_verifier.ex
│           └── saml_handler.ex
├── metal/Sources/AgentUX/
│   ├── AgentUIState.swift
│   ├── AppleRecreationView.swift
│   ├── AssemblyBridge.swift
│   ├── DylanClient.swift
│   ├── DylanFrame.swift
│   └── Shaders/AvatarShaders.metal
├── asm/
│   └── crc32_dylan.S            # CRC32 hand-rolled assembly
├── canvas-templates/            # XML/XSLT canvas pipeline
└── backend/
    ├── coordinator.py
    └── test_session.sh
```

---

## Live Demo

**GitHub Pages**: https://snapkittywest.github.io/apple-ux-swarm/

The canvas auto-opens on load showing the animated avatar presence tile.

---

## Verification

| Component | Result |
|-----------|--------|
| BEAM mesh | 14/14 tests passed · 10,000-agent fan-out 32-42 ms |
| AppleUXBridge | Clean Swift 6 build · 5/5 tests passed |
| Dylan frames | CRC32-IEEE verified · tampered frames rejected |
| Canvas 2D | Animated presence tile · browser fallback |
| Metal shaders | Requires Apple hardware |

---

## Build

```bash
# BEAM coordinator (Elixir)
cd beam
mix deps.get
mix test

# SwiftUI + Metal (Xcode / Swift CLI)
cd metal
swift build
swift test

# Frontend — open directly in browser
open frontend/visual-workplace.html
```

---

## License

```
MPL-2.0 OR GPL-3.0-or-later
Commercial repository.
```

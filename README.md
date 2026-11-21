# Maharaja Institute of Technology Mysore — Offline Examination Management System (EMS)

An integrated, secure, multi-tier examination platform supporting the complete institutional lifecycle: Question Bank authoring and blueprinting, COE scheduling and version shuffling, air-gapped laboratory examination delivery, automated local evaluation, cryptographic result signing, and administrative analytics.

---

## Architecture Overview

```
                                      +---------------------------------------------+
                                      |           PostgreSQL Database               |
                                      |              campusexam_test                |
                                      +----------------------+----------------------+
                                                             |
                                      +----------------------+----------------------+
                                      |       Central Java Backend (Port 8081)       |
                                      |        State Authority & Core Logic         |
                                      +---------+-------------------+---------------+
                                                |                   |
            +-----------------------------------+----+         +----+------------------------------------+
            |                                        |         |                                         |
+-----------v------------+               +-----------v---------v--+                          +-----------v------------+
|  Admin / HOD Portal    |               |       COE Portal       |                          |  Independent Lab Server|
|      (Port 3000)       |               |      (Port 3001)       |                          |       (Port 8082)      |
|  - Class Management    |               |  - Exam Scheduling     |                          |  - Local Air-Gapped Hub|
|  - Student Lists       |               |  - Sitting Allocation  |                          |  - Package Verification|
|  - QB Authoring & Sets |               |  - Shuffled Versions   |                          |  - Auto-Evaluation     |
|  - Result Analytics    |               |  - Result Approval     |                          +------------+-----------+
+------------------------+               +------------------------+                                       |
                                                                                                          |
                                                                                             +------------v-----------+
                                                                                             |     Student Portal     |
                                                                                             |      (Port 3002)       |
                                                                                             |  - Air-gapped delivery |
                                                                                             |  - Authoritative timer |
                                                                                             |  - Auto-submission     |
                                                                                             +------------------------+
```

---

## Service Matrix & Port Allocations

| Service | Technology | Port | Database / Environment | Purpose |
| :--- | :--- | :--- | :--- | :--- |
| **Central Backend** | Java 17+ HTTP Server | `8081` | `campusexam_test` | State authority, REST APIs, Cryptographic Signer |
| **Independent Lab Server** | Java 17+ HTTP Server | `8082` | In-memory / Air-Gapped | Secure local examination node, verification, timer |
| **Admin / HOD Portal** | React / Vite / TypeScript | `3000` | Central API (`:8081`) | Principal & HOD controls, Question Converter, Analytics |
| **COE Portal** | React / Vite / TypeScript | `3001` | Central API (`:8081`) | Scheduling, Sitting Allocations, Version A-D Shuffling |
| **Student Portal** | React / Vite / TypeScript | `3002` | Lab Server API (`:8082`) | Secure workstation delivery, auto-save, timer |

---

## Prerequisites

1. **Java Development Kit (JDK)**: Java 17 or higher (`java -version`, `javac -version`).
2. **Node.js**: v18.x or higher (`node -v`, `npm -v`).
3. **PostgreSQL**: PostgreSQL 16+ on port `5432` with user `campusexam`, password `password`, and database `campusexam_test`.

---

## Quick Start (Start All Services)

To launch all five services simultaneously with health checks and port verification:

```powershell
# From the repository root
.\start_all.ps1
```

Or on Windows Command Prompt:
```cmd
start_all.bat
```

To stop all background services cleanly:
```powershell
.\stop_all.ps1
```

---

## Directory Structure

```
OFFLINE-EXAM/
├── CampusExam/                   # Central Java Backend & Independent Lab Server
│   ├── CampusExam.java           # Central authority server & API endpoints
│   ├── LabServer.java            # Air-gapped Lab Server & local runtime
│   ├── lib/postgresql.jar        # PostgreSQL JDBC driver
│   ├── keys/                     # Central authority RSA keypair
│   ├── lab_server_keys/          # Laboratory node RSA keypair
│   ├── migrations/               # PostgreSQL schema migrations
│   └── schema.sql                # Complete relational schema
├── admin-portal (7)/             # Principal / HOD Examination Portal
│   ├── src/pages/                # Class setup, Document Converter, Results
│   └── package.json
├── coe-portal (7)/               # Controller of Examinations Portal
│   ├── src/pages/                # Scheduling, Package Export, Result Approval
│   └── package.json
├── student-portal (Final)/       # Air-gapped Student Examination Interface
│   └── student-portal (Final)/
│       └── student-portal/       # Examination screen, countdown timer, question palette
├── INTEGRATION/                  # Acceptance reports, verification matrices
├── start_all.ps1                 # Unified 5-service development launcher
├── stop_all.ps1                  # Unified process shutdown script
└── README.md
```

---

## Key Features

1. **Question Set Lifecycle & Availability**:
   - Numbered question sets published by HOD transition through `AVAILABLE -> RESERVED -> SCHEDULED -> CONSUMED`.
   - Committed sets disappear automatically from available COE selection feeds and cannot be reused across sittings or exams.
   - Transactional conflict protection returns `HTTP 409 Conflict` on concurrent scheduling attempts.

2. **Custom Examination Duration**:
   - Fully customizable exam duration in minutes (e.g., 20, 35, 50, 60, 75, 90, 120 mins) with independent configurations for Morning and Afternoon sittings.
   - Propagated end-to-end to encrypted packages, Lab Server timers, and Student Portal countdown displays.

3. **Air-Gapped Cryptographic Security**:
   - AES-GCM-256 package encryption with RSA-4096 digital signatures.
   - Offline verification by Lab Server without requiring active Internet connectivity.
   - Tamper-proof, signed result files for post-exam COE verification and import.

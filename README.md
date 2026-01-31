# csci499-capstone

## Requirements (Windows)

- **CMake** (3.21 or newer)
- **VS Code**
- VS Code extensions:
  - **CMake Tools** (Microsoft)
  - **C/C++** (Microsoft)

---

## Repository Structure

```
.
├─ CMakeLists.txt
├─ external/
│  └─ raylib/        (git submodule)
├─ src/
│  ├─ main.cpp
│  └─ resource_dir.h
├─ assets/
│  └─ gatito.png
├─ .vscode/          (committed)
├─ build/            (generated, NOT committed)
└─ README.md
```

---

## Cloning the Repository

Because raylib is a submodule, you must clone recursively:

```bash
git clone --recurse-submodules https://github.com/jerichom08/csci499-capstone
```

If you already cloned without submodules:

```bash
git submodule update --init --recursive
```

---

## Running from the Command Line

From the project root:

### Configure

```bash
cmake -S . -B build
```

### Build (Debug)

```bash
cmake --build build
```

### Run

```bash
./build/Debug/csci499-capstone.exe
```

### For Release builds:

```bash
cmake --build build --config Release
./build/Release/csci499-capstone.exe
```

---

## Running from VS Code (Recommended)

### 1. Open the Project

```bash
code .
```

### 2. Let CMake Configure Automatically

When the folder opens:
- CMake Tools will configure the project automatically
- raylib will be built automatically
- You may be prompted to select a compiler — choose **MSVC**

### 3. Build

Use any of the following:
- **Ctrl + Shift + B**
- CMake "Build" button in the status bar

### 4. Run

Press:
- **F5**

or use the Run panel and select **"Run game"**.

The executable will launch automatically.

---

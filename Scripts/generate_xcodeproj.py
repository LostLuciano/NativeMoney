#!/usr/bin/env python3
"""
generate_xcodeproj.py  –  MonassistNative Xcode Project Generator
Generates a valid project.pbxproj + xcscheme for Xcode 26 / iOS 26 target.
Run from the repo root:  python3 Scripts/generate_xcodeproj.py
"""

import os
import sys
import uuid

# ─── Deterministic UUID generation ───────────────────────────────────────────
NS = uuid.UUID("12345678-1234-5678-1234-567812345678")

def gid(name: str) -> str:
    return uuid.uuid5(NS, name).hex[:24].upper()

# ─── File classification ──────────────────────────────────────────────────────
SWIFT_EXTS   = {".swift"}
ASSET_EXTS   = {".png", ".jpg", ".jpeg", ".gif", ".webp", ".pdf",
                ".glb", ".usdz", ".obj", ".scn",
                ".json", ".lottie", ".strings", ".stringsdict"}
PLIST_EXTS   = {".plist"}
XCASSETS_EXT = ".xcassets"

def file_type(ext: str) -> str:
    m = {
        ".swift":    "sourcecode.swift",
        ".m":        "sourcecode.c.objc",
        ".mm":       "sourcecode.cpp.objcpp",
        ".c":        "sourcecode.c.c",
        ".cpp":      "sourcecode.cpp.cpp",
        ".h":        "sourcecode.c.h",
        ".png":      "image.png",
        ".jpg":      "image.jpeg",
        ".jpeg":     "image.jpeg",
        ".gif":      "image.gif",
        ".pdf":      "image.pdf",
        ".json":     "text.json",
        ".glb":      "file",
        ".usdz":     "file",
        ".obj":      "file",
        ".scn":      "file",
        ".plist":    "text.plist.xml",
        ".strings":  "text.plist.strings",
        ".xcassets": "folder.assetcatalog",
        ".storyboard": "file.storyboard",
        ".xib":      "file.xib",
    }
    return m.get(ext.lower(), "text")

# ─── Project scaffold ─────────────────────────────────────────────────────────
def create_xcodeproj(project_root: str):
    app_dir     = os.path.join(project_root, "MonassistNative")
    xcodeproj   = os.path.join(project_root, "MonassistNative.xcodeproj")
    pbxproj     = os.path.join(xcodeproj,    "project.pbxproj")
    schemes_dir = os.path.join(xcodeproj,    "xcshareddata", "xcschemes")

    os.makedirs(xcodeproj,   exist_ok=True)
    os.makedirs(schemes_dir, exist_ok=True)

    # ── Collect source files ──────────────────────────────────────────────────
    swift_files    = []  # compile sources
    resource_files = []  # copy resources
    xcassets_dirs  = []  # opaque folder references
    plist_file     = None

    # First, collect .xcassets directories at the top level (opaque folder refs)
    for entry in os.listdir(app_dir):
        full = os.path.join(app_dir, entry)
        if entry.endswith(".xcassets") and os.path.isdir(full):
            xcassets_dirs.append(entry)  # just the folder name, e.g. "Assets.xcassets"

    for root, dirs, files in os.walk(app_dir):
        # Skip Xcode build artefacts AND asset catalogs (treat as opaque)
        dirs[:] = [d for d in dirs if d not in
                   {"DerivedData", "build", ".build", ".git", "__pycache__",
                    "MonassistNative.xcodeproj"}
                   and not d.endswith(".xcassets")]

        rel_root = os.path.relpath(root, app_dir)

        for f in files:
            rel = os.path.join(rel_root, f).replace("\\", "/")
            rel = rel.lstrip("./").lstrip("/")
            ext = os.path.splitext(f)[1].lower()

            if f == "Info.plist" and rel_root == ".":  # top-level only
                plist_file = rel
            elif ext in SWIFT_EXTS:
                swift_files.append(rel)
            elif ext in ASSET_EXTS:
                resource_files.append(rel)

    print(f"Swift sources : {len(swift_files)}")
    print(f"Resources     : {len(resource_files)}")
    print(f"Info.plist    : {plist_file}")

    # ── Fixed GIDs ───────────────────────────────────────────────────────────
    PROJ_ID    = gid("PROJECT_MONASSIST")
    TGT_ID     = gid("TARGET_APP_MONASSIST")
    PROD_ID    = gid("PROD_APP_MONASSIST")
    MAIN_GRP   = gid("GROUP_MAIN")
    SRC_GRP    = gid("GROUP_SRC")
    PROD_GRP   = gid("GROUP_PRODUCTS")

    SOURCES_PHASE    = gid("PHASE_SOURCES")
    FRAMEWORKS_PHASE = gid("PHASE_FRAMEWORKS")
    RESOURCES_PHASE  = gid("PHASE_RESOURCES")

    PROJ_CFG_LIST = gid("CFGLIST_PROJ")
    APP_CFG_LIST  = gid("CFGLIST_APP")
    PROJ_DEBUG    = gid("CFG_PROJ_DEBUG")
    PROJ_REL      = gid("CFG_PROJ_RELEASE")
    APP_DEBUG     = gid("CFG_APP_DEBUG")
    APP_REL       = gid("CFG_APP_RELEASE")

    # ── System frameworks ─────────────────────────────────────────────────────
    SYS_FW = ["Foundation", "UIKit", "SwiftUI",
              "CoreData", "Combine", "Observation"]

    fw_refs = {}   # name → (ref_id, bf_id)
    for fw in SYS_FW:
        fw_refs[fw] = (gid(f"REF_FW_{fw}"), gid(f"BF_FW_{fw}"))

    # ── Source file refs ──────────────────────────────────────────────────────
    src_refs = {}   # rel_path → (ref_id, bf_id)
    for f in swift_files + resource_files:
        src_refs[f] = (gid(f"REF_{f}"), gid(f"BF_{f}"))

    # .xcassets get separate folder-reference entries
    xca_refs = {}  # folder_name → (ref_id, bf_id)
    for xca in xcassets_dirs:
        xca_refs[xca] = (gid(f"REF_XCA_{xca}"), gid(f"BF_XCA_{xca}"))

    prod_ref = gid("REF_PROD")
    plist_ref = gid(f"REF_{plist_file}") if plist_file else gid("REF_INFOPLIST_MISSING")

    # ═════════════════════════════════════════════════════════════════════════
    # Write project.pbxproj
    # ═════════════════════════════════════════════════════════════════════════
    with open(pbxproj, "w", encoding="utf-8") as f:

        def w(line=""): f.write(line + "\n")

        w("// !$*UTF8*$!")
        w("{")
        w("\tarchiveVersion = 1;")
        w("\tclasses = { };")
        w("\tobjectVersion = 56;")
        w("\tobjects = {")
        w()

        # ── PBXBuildFile ─────────────────────────────────────────────────────
        w("/* Begin PBXBuildFile section */")
        for fw, (ref_id, bf_id) in fw_refs.items():
            w(f"\t\t{bf_id} /* {fw}.framework in Frameworks */ = {{isa = PBXBuildFile; fileRef = {ref_id}; }};")
        for rel, (ref_id, bf_id) in src_refs.items():
            ext = os.path.splitext(rel)[1].lower()
            if ext in SWIFT_EXTS:
                w(f"\t\t{bf_id} /* {os.path.basename(rel)} in Sources */ = {{isa = PBXBuildFile; fileRef = {ref_id}; }};")
            else:
                w(f"\t\t{bf_id} /* {os.path.basename(rel)} in Resources */ = {{isa = PBXBuildFile; fileRef = {ref_id}; }};")
        for xca, (ref_id, bf_id) in xca_refs.items():
            w(f"\t\t{bf_id} /* {xca} in Resources */ = {{isa = PBXBuildFile; fileRef = {ref_id}; }};")
        w("/* End PBXBuildFile section */")
        w()

        # ── PBXFileReference ──────────────────────────────────────────────────
        w("/* Begin PBXFileReference section */")
        # Product
        w(f"\t\t{prod_ref} /* MonassistNative.app */ = {{isa = PBXFileReference; "
          f"explicitFileType = wrapper.application; "
          f"path = MonassistNative.app; sourceTree = BUILT_PRODUCTS_DIR; }};")
        # System frameworks
        for fw, (ref_id, _) in fw_refs.items():
            w(f"\t\t{ref_id} /* {fw}.framework */ = {{isa = PBXFileReference; "
              f"lastKnownFileType = wrapper.framework; "
              f"name = {fw}.framework; "
              f"path = System/Library/Frameworks/{fw}.framework; "
              f"sourceTree = SDKROOT; }};")
        # Source files
        for rel, (ref_id, _) in src_refs.items():
            base  = os.path.basename(rel)
            ext   = os.path.splitext(rel)[1].lower()
            ftype = file_type(ext) if ext else "file"
            w(f"\t\t{ref_id} /* {base} */ = {{isa = PBXFileReference; "
              f"lastKnownFileType = {ftype}; "
              f"path = \"{rel}\"; "
              f"sourceTree = \"<group>\"; }};")
        # .xcassets folder references
        for xca, (ref_id, _) in xca_refs.items():
            w(f"\t\t{ref_id} /* {xca} */ = {{isa = PBXFileReference; "
              f"lastKnownFileType = folder.assetcatalog; "
              f"path = \"{xca}\"; "
              f"sourceTree = \"<group>\"; }};")
        # Info.plist
        if plist_file and plist_file not in src_refs:
            w(f"\t\t{plist_ref} /* Info.plist */ = {{isa = PBXFileReference; "
              f"lastKnownFileType = text.plist.xml; "
              f"path = Info.plist; sourceTree = \"<group>\"; }};")
        w("/* End PBXFileReference section */")
        w()

        # ── PBXFrameworksBuildPhase ───────────────────────────────────────────
        w("/* Begin PBXFrameworksBuildPhase section */")
        w(f"\t\t{FRAMEWORKS_PHASE} /* Frameworks */ = {{")
        w("\t\t\tisa = PBXFrameworksBuildPhase;")
        w("\t\t\tbuildActionMask = 2147483647;")
        w("\t\t\tfiles = (")
        for fw, (_, bf_id) in fw_refs.items():
            w(f"\t\t\t\t{bf_id} /* {fw}.framework in Frameworks */,")
        w("\t\t\t);")
        w("\t\t\trunOnlyForDeploymentPostprocessing = 0;")
        w("\t\t};")
        w("/* End PBXFrameworksBuildPhase section */")
        w()

        # ── PBXGroup ──────────────────────────────────────────────────────────
        w("/* Begin PBXGroup section */")

        # Main group
        w(f"\t\t{MAIN_GRP} = {{")
        w("\t\t\tisa = PBXGroup;")
        w("\t\t\tchildren = (")
        w(f"\t\t\t\t{SRC_GRP} /* MonassistNative */,")
        w(f"\t\t\t\t{PROD_GRP} /* Products */,")
        w("\t\t\t);")
        w('\t\t\tsourceTree = "<group>";')
        w("\t\t};")

        # Products group
        w(f"\t\t{PROD_GRP} /* Products */ = {{")
        w("\t\t\tisa = PBXGroup;")
        w("\t\t\tchildren = (")
        w(f"\t\t\t\t{prod_ref} /* MonassistNative.app */,")
        w("\t\t\t);")
        w('\t\t\tname = Products;')
        w('\t\t\tsourceTree = "<group>";')
        w("\t\t};")

        # App source group (flat list of all files)
        w(f"\t\t{SRC_GRP} /* MonassistNative */ = {{")
        w("\t\t\tisa = PBXGroup;")
        w("\t\t\tchildren = (")
        for rel, (ref_id, _) in src_refs.items():
            w(f"\t\t\t\t{ref_id} /* {os.path.basename(rel)} */,")
        for xca, (ref_id, _) in xca_refs.items():
            w(f"\t\t\t\t{ref_id} /* {xca} */,")
        if plist_file and plist_file not in src_refs:
            w(f"\t\t\t\t{plist_ref} /* Info.plist */,")
        w("\t\t\t);")
        w('\t\t\tname = MonassistNative;')
        w('\t\t\tpath = MonassistNative;')
        w('\t\t\tsourceTree = "<group>";')
        w("\t\t};")
        w("/* End PBXGroup section */")
        w()

        # ── PBXNativeTarget ───────────────────────────────────────────────────
        w("/* Begin PBXNativeTarget section */")
        w(f"\t\t{TGT_ID} /* MonassistNative */ = {{")
        w("\t\t\tisa = PBXNativeTarget;")
        w(f"\t\t\tbuildConfigurationList = {APP_CFG_LIST};")
        w("\t\t\tbuildPhases = (")
        w(f"\t\t\t\t{SOURCES_PHASE} /* Sources */,")
        w(f"\t\t\t\t{FRAMEWORKS_PHASE} /* Frameworks */,")
        w(f"\t\t\t\t{RESOURCES_PHASE} /* Resources */,")
        w("\t\t\t);")
        w("\t\t\tbuildRules = ( );")
        w("\t\t\tdependencies = ( );")
        w('\t\t\tname = MonassistNative;')
        w('\t\t\tproductName = MonassistNative;')
        w(f"\t\t\tproductReference = {prod_ref} /* MonassistNative.app */;")
        w('\t\t\tproductType = "com.apple.product-type.application";')
        w("\t\t};")
        w("/* End PBXNativeTarget section */")
        w()

        # ── PBXProject ────────────────────────────────────────────────────────
        w("/* Begin PBXProject section */")
        w(f"\t\t{PROJ_ID} /* Project object */ = {{")
        w("\t\t\tisa = PBXProject;")
        w("\t\t\tattributes = {")
        w("\t\t\t\tLastSwiftUpdateCheck = 1600;")
        w("\t\t\t\tTargetAttributes = {")
        w(f"\t\t\t\t\t{TGT_ID} = {{ CreatedOnToolsVersion = 16.0; }};")
        w("\t\t\t\t};")
        w("\t\t\t};")
        w(f"\t\t\tbuildConfigurationList = {PROJ_CFG_LIST};")
        w('\t\t\tcompatibilityVersion = "Xcode 15.0";')
        w('\t\t\tdevelopmentRegion = id;')
        w('\t\t\thasScannedForEncodings = 0;')
        w('\t\t\tknownRegions = ( en, id, Base, );')
        w(f"\t\t\tmainGroup = {MAIN_GRP};")
        w(f"\t\t\tproductRefGroup = {PROD_GRP} /* Products */;")
        w('\t\t\tprojectDirPath = "";')
        w('\t\t\tprojectRoot = "";')
        w("\t\t\ttargets = (")
        w(f"\t\t\t\t{TGT_ID} /* MonassistNative */,")
        w("\t\t\t);")
        w("\t\t};")
        w("/* End PBXProject section */")
        w()

        # ── PBXResourcesBuildPhase ────────────────────────────────────────────
        w("/* Begin PBXResourcesBuildPhase section */")
        w(f"\t\t{RESOURCES_PHASE} /* Resources */ = {{")
        w("\t\t\tisa = PBXResourcesBuildPhase;")
        w("\t\t\tbuildActionMask = 2147483647;")
        w("\t\t\tfiles = (")
        for rel, (_, bf_id) in src_refs.items():
            ext = os.path.splitext(rel)[1].lower()
            if ext not in SWIFT_EXTS:
                w(f"\t\t\t\t{bf_id} /* {os.path.basename(rel)} in Resources */,")
        for xca, (_, bf_id) in xca_refs.items():
            w(f"\t\t\t\t{bf_id} /* {xca} in Resources */,")
        w("\t\t\t);")
        w("\t\t\trunOnlyForDeploymentPostprocessing = 0;")
        w("\t\t};")
        w("/* End PBXResourcesBuildPhase section */")
        w()

        # ── PBXSourcesBuildPhase ──────────────────────────────────────────────
        w("/* Begin PBXSourcesBuildPhase section */")
        w(f"\t\t{SOURCES_PHASE} /* Sources */ = {{")
        w("\t\t\tisa = PBXSourcesBuildPhase;")
        w("\t\t\tbuildActionMask = 2147483647;")
        w("\t\t\tfiles = (")
        for rel, (_, bf_id) in src_refs.items():
            ext = os.path.splitext(rel)[1].lower()
            if ext in SWIFT_EXTS:
                w(f"\t\t\t\t{bf_id} /* {os.path.basename(rel)} in Sources */,")
        w("\t\t\t);")
        w("\t\t\trunOnlyForDeploymentPostprocessing = 0;")
        w("\t\t};")
        w("/* End PBXSourcesBuildPhase section */")
        w()

        # ── XCBuildConfiguration ──────────────────────────────────────────────
        COMMON = {
            "ALWAYS_SEARCH_USER_PATHS": "NO",
            "CLANG_ANALYZER_NONNULL": "YES",
            "CLANG_ENABLE_MODULES": "YES",
            "CLANG_ENABLE_OBJC_ARC": "YES",
            "COPY_PHASE_STRIP": "NO",
            "ENABLE_STRICT_OBJC_MSGSEND": "YES",
            "GCC_C_LANGUAGE_STANDARD": "gnu11",
            "IPHONEOS_DEPLOYMENT_TARGET": "18.0",
            "SDKROOT": "iphoneos",
            "SWIFT_VERSION": "5.0",
            "TARGETED_DEVICE_FAMILY": '"1,2"',
        }

        # INFOPLIST_FILE path is relative to the .xcodeproj dir (i.e. project root)
        plist_path = f"MonassistNative/{plist_file}" if plist_file else "MonassistNative/Info.plist"

        APP_COMMON = {
            **COMMON,
            "ASSETCATALOG_COMPILER_APPICON_NAME": "AppIcon",
            "CODE_SIGN_STYLE": "Automatic",
            "INFOPLIST_FILE": f"\"{plist_path}\"",
            "LD_RUNPATH_SEARCH_PATHS": '( "$(inherited)", "@executable_path/Frameworks", )',
            "PRODUCT_BUNDLE_IDENTIFIER": "\"com.monassist.native\"",
            "PRODUCT_NAME": '"$(TARGET_NAME)"',
            "DEVELOPMENT_TEAM": "XY12345678",
            "CODE_SIGN_IDENTITY": "\"\"",
            "CODE_SIGNING_REQUIRED": "NO",
            "CODE_SIGNING_ALLOWED": "NO",
            "ENABLE_PREVIEWS": "YES",
        }

        w("/* Begin XCBuildConfiguration section */")

        def write_cfg(cfg_id: str, name: str, settings: dict, extra: dict = {}):
            merged = {**settings, **extra}
            w(f"\t\t{cfg_id} /* {name} */ = {{")
            w("\t\t\tisa = XCBuildConfiguration;")
            w("\t\t\tbuildSettings = {")
            for k, v in sorted(merged.items()):
                w(f"\t\t\t\t{k} = {v};")
            w("\t\t\t};")
            w(f'\t\t\tname = {name};')
            w("\t\t};")

        write_cfg(PROJ_DEBUG, "Debug", COMMON, {
            "DEBUG_INFORMATION_FORMAT": "dwarf",
            "GCC_DYNAMIC_NO_PIC": "NO",
            "GCC_OPTIMIZATION_LEVEL": "0",
            "GCC_PREPROCESSOR_DEFINITIONS": '( "DEBUG=1", "$(inherited)", )',
            "MTL_ENABLE_DEBUG_INFO": "INCLUDE_SOURCE",
            "ONLY_ACTIVE_ARCH": "YES",
        })
        write_cfg(PROJ_REL, "Release", COMMON, {
            "DEBUG_INFORMATION_FORMAT": '"dwarf-with-dsym"',
            "ENABLE_NS_ASSERTIONS": "NO",
            "MTL_ENABLE_DEBUG_INFO": "NO",
            "VALIDATE_PRODUCT": "YES",
        })
        write_cfg(APP_DEBUG, "Debug", APP_COMMON, {
            "DEBUG_INFORMATION_FORMAT": "dwarf",
            "SWIFT_OPTIMIZATION_LEVEL": '"-Onone"',
            "SWIFT_ACTIVE_COMPILATION_CONDITIONS": "DEBUG",
        })
        write_cfg(APP_REL, "Release", APP_COMMON, {
            "SWIFT_OPTIMIZATION_LEVEL": '"-Owholemodule"',
            "DEBUG_INFORMATION_FORMAT": '"dwarf-with-dsym"',
            "VALIDATE_PRODUCT": "YES",
        })
        w("/* End XCBuildConfiguration section */")
        w()

        # ── XCConfigurationList ───────────────────────────────────────────────
        w("/* Begin XCConfigurationList section */")
        w(f"\t\t{PROJ_CFG_LIST} /* Build configuration list for PBXProject */ = {{")
        w("\t\t\tisa = XCConfigurationList;")
        w("\t\t\tbuildConfigurations = (")
        w(f"\t\t\t\t{PROJ_DEBUG} /* Debug */,")
        w(f"\t\t\t\t{PROJ_REL} /* Release */,")
        w("\t\t\t);")
        w("\t\t\tdefaultConfigurationIsVisible = 0;")
        w('\t\t\tdefaultConfigurationName = Release;')
        w("\t\t};")
        w(f"\t\t{APP_CFG_LIST} /* Build configuration list for PBXNativeTarget MonassistNative */ = {{")
        w("\t\t\tisa = XCConfigurationList;")
        w("\t\t\tbuildConfigurations = (")
        w(f"\t\t\t\t{APP_DEBUG} /* Debug */,")
        w(f"\t\t\t\t{APP_REL} /* Release */,")
        w("\t\t\t);")
        w("\t\t\tdefaultConfigurationIsVisible = 0;")
        w('\t\t\tdefaultConfigurationName = Release;')
        w("\t\t};")
        w("/* End XCConfigurationList section */")
        w()

        w("\t};")
        w(f"\trootObject = {PROJ_ID} /* Project object */;")
        w("}")

    print(f"\n[OK] project.pbxproj -> {pbxproj}")

    # ═════════════════════════════════════════════════════════════════════════
    # Write xcscheme
    # ═════════════════════════════════════════════════════════════════════════
    scheme_path = os.path.join(schemes_dir, "MonassistNative.xcscheme")
    with open(scheme_path, "w", encoding="utf-8") as f:
        f.write(f'''<?xml version="1.0" encoding="UTF-8"?>
<Scheme LastUpgradeVersion="1600" version="1.7">
   <BuildAction parallelizeBuildables="YES" buildImplicitDependencies="YES">
      <BuildActionEntries>
         <BuildActionEntry buildForTesting="YES" buildForRunning="YES" buildForProfiling="YES" buildForArchiving="YES" buildForAnalyzing="YES">
            <BuildableReference
               BuildableIdentifier = "primary"
               BlueprintIdentifier = "{TGT_ID}"
               BuildableName = "MonassistNative.app"
               BlueprintName = "MonassistNative"
               ReferencedContainer = "container:MonassistNative.xcodeproj">
            </BuildableReference>
         </BuildActionEntry>
      </BuildActionEntries>
   </BuildAction>
   <TestAction buildConfiguration="Debug" selectedDebuggerIdentifier="Xcode.DebuggerFoundation.Debugger.LLDB" selectedLauncherIdentifier="Xcode.DebuggerFoundation.Launcher.LLDB" shouldUseLaunchSchemeArgsEnv="YES">
      <Testables></Testables>
   </TestAction>
   <LaunchAction buildConfiguration="Debug" selectedDebuggerIdentifier="Xcode.DebuggerFoundation.Debugger.LLDB" selectedLauncherIdentifier="Xcode.DebuggerFoundation.Launcher.LLDB" launchStyle="0" useCustomWorkingDirectory="NO" ignoresPersistentStateOnLaunch="NO" debugDocumentVersioning="YES" debugServiceExtension="internal" allowLocationSimulation="YES">
      <BuildableProductRunnable runnableDebuggingMode="0">
         <BuildableReference
            BuildableIdentifier = "primary"
            BlueprintIdentifier = "{TGT_ID}"
            BuildableName = "MonassistNative.app"
            BlueprintName = "MonassistNative"
            ReferencedContainer = "container:MonassistNative.xcodeproj">
         </BuildableReference>
      </BuildableProductRunnable>
   </LaunchAction>
   <ProfileAction buildConfiguration="Release" shouldUseLaunchSchemeArgsEnv="YES" useCustomWorkingDirectory="NO" ignoresPersistentStateOnLaunch="NO" debugDocumentVersioning="YES">
      <BuildableProductRunnable runnableDebuggingMode="0">
         <BuildableReference
            BuildableIdentifier = "primary"
            BlueprintIdentifier = "{TGT_ID}"
            BuildableName = "MonassistNative.app"
            BlueprintName = "MonassistNative"
            ReferencedContainer = "container:MonassistNative.xcodeproj">
         </BuildableReference>
      </BuildableProductRunnable>
   </ProfileAction>
   <AnalyzeAction buildConfiguration="Debug"></AnalyzeAction>
   <ArchiveAction buildConfiguration="Release" revealArchiveInOrganizer="YES"></ArchiveAction>
</Scheme>
''')
    print(f"[OK] xcscheme        -> {scheme_path}")

# ─── Entry point ──────────────────────────────────────────────────────────────
if __name__ == "__main__":
    root = sys.argv[1] if len(sys.argv) > 1 else os.path.dirname(os.path.abspath(__file__))
    # If run from Scripts/, step up one level
    if os.path.basename(root).lower() == "scripts":
        root = os.path.dirname(root)
    print(f"Project root: {root}")
    create_xcodeproj(root)
    print("\nDone! Open MonassistNative.xcodeproj in Xcode 26 to build.\n")

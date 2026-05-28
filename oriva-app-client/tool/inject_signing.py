#!/usr/bin/env python3
"""Inject the release signing config into the Flutter-generated Android build.

The android/ folder is NOT committed to this repo; it is generated fresh in CI
by `flutter create`. So we cannot keep a hand-edited build.gradle.kts under
version control. Instead this script runs in CI, AFTER `flutter create`, and
patches the generated android/app/build.gradle.kts.

Behaviour:
  * Reads android/key.properties at Gradle eval time (created in CI from secrets).
  * If key.properties exists  -> release build is signed with the upload key.
  * If it does NOT exist       -> release build falls back to debug signing, so
                                  local/dev builds keep working without the key.

Idempotent: running it twice is a no-op.
"""
import sys
from pathlib import Path

GRADLE = Path("android/app/build.gradle.kts")

PROPS_BLOCK = """import java.util.Properties
import java.io.FileInputStream

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

"""

SIGNING_BLOCK = """
    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties.getProperty("keyAlias")
            keyPassword = keystoreProperties.getProperty("keyPassword")
            storeFile = keystoreProperties.getProperty("storeFile")?.let { file(it) }
            storePassword = keystoreProperties.getProperty("storePassword")
        }
    }
"""

RELEASE_DEBUG = 'signingConfig = signingConfigs.getByName("debug")'
RELEASE_COND = (
    "signingConfig = if (keystorePropertiesFile.exists()) "
    'signingConfigs.getByName("release") else signingConfigs.getByName("debug")'
)


def main() -> None:
    if not GRADLE.exists():
        sys.exit(f"ERROR: {GRADLE} not found. Run `flutter create` first.")

    text = GRADLE.read_text()

    if "keystoreProperties" in text:
        print("Signing config already present; nothing to do.")
        return

    # 1. Prepend keystore loading (Kotlin imports must be at the top of the file).
    text = PROPS_BLOCK + text

    # 2. Insert the signingConfigs block right after the `android {` opener.
    marker = "\nandroid {\n"
    idx = text.find(marker)
    if idx == -1:
        sys.exit("ERROR: could not find `android {` block in build.gradle.kts")
    insert_at = idx + len(marker)
    text = text[:insert_at] + SIGNING_BLOCK + text[insert_at:]

    # 3. Point the release buildType at the release signing config (with fallback).
    if RELEASE_DEBUG in text:
        text = text.replace(RELEASE_DEBUG, RELEASE_COND, 1)
    else:
        print(
            "WARNING: default `release -> debug` signingConfig line not found; "
            "release buildType left unchanged."
        )

    GRADLE.write_text(text)
    print(f"Injected release signing config into {GRADLE}")


if __name__ == "__main__":
    main()

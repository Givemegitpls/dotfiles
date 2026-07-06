---
name: minecraft-plugin-build
description: "Use when building, compiling, or troubleshooting Minecraft Paper/Spigot/Purpur plugins. Covers Gradle builds, Java toolchain setup, Paper API, plugin.yml, JAR assembly, and common build failures."
---

# Minecraft Plugin Build Guide

## When to use

Building or fixing compilation of Paper/Spigot/Purpur plugins written in Java/Kotlin with Gradle.

## Technology Stack

- **Platform**: Paper API (`api-version: '1.21'` compatible with all 1.21.x builds)
- **Build Tool**: Gradle (Kotlin DSL preferred) with wrapper
- **JVM**: Java 21 for Paper 1.21+
- **Dependencies**: `io.papermc.paper:paper-api:1.21.4-R0.1-SNAPSHOT` (compile-only)

## Project Structure

```
project/
├── build.gradle.kts          # Build script
├── settings.gradle.kts       # Project name
├── gradle/                   # Wrapper files (copy from existing project)
├── gradlew / gradlew.bat     # Wrapper scripts (copy from existing project)
└── src/
    └── main/
        ├── java/.../           # Plugin classes
        └── resources/
            ├── plugin.yml      # Plugin metadata
            └── config.yml      # Default config
```

## Minimal build.gradle.kts

```kotlin
plugins {
    java
}

group = "com.example.mymcplugin"
version = "1.0.0"

java {
    toolchain {
        languageVersion.set(JavaLanguageVersion.of(21))
    }
}

repositories {
    mavenCentral()
    maven("https://repo.papermc.io/repository/maven-public/")
}

dependencies {
    compileOnly("io.papermc.paper:paper-api:1.21.4-R0.1-SNAPSHOT")
}

tasks {
    processResources {
        filesMatching("plugin.yml") {
            expand(project.properties)
        }
    }
    compileJava {
        options.encoding = "UTF-8"
    }
    jar {
        archiveBaseName.set("MyPlugin")
    }
}
```

## plugin.yml template

```yaml
name: MyPlugin
version: ${version}
main: com.example.mymcplugin.MyPlugin
api-version: '1.21'
description: Plugin description
softdepend: [WorldGuard, Vault]
commands:
  mycmd:
    description: My command
    usage: /mycmd
    permission: myplugin.use
permissions:
  myplugin.use:
    default: op
```

## Build commands

```bash
export JAVA_HOME=/usr/lib/jvm/java-21-openjdk
./gradlew build
```

Output: `build/libs/MyPlugin-1.0.0.jar`

### Useful Gradle tasks

| Task | Purpose |
|------|---------|
| `./gradlew build` | Full build (compile + test + jar) |
| `./gradlew compileJava` | Compile only |
| `./gradlew jar` | Assemble JAR only |
| `./gradlew clean` | Clean build outputs |
| `./gradlew clean build` | Clean rebuild |

## Troubleshooting

### Gradle daemon JVM mismatch

**Symptom**: Gradle complains about incompatible daemon running Java 8 while project needs Java 21.

**Fix**: Stop the daemon and retry:

```bash
./gradlew --stop
export JAVA_HOME=/usr/lib/jvm/java-21-openjdk
./gradlew build
```

### Missing javac

**Symptom**: `javac: command not found`

**Fix**: Ensure JDK (not just JRE) is installed:

```bash
# Find installed JDKs
ls /usr/lib/jvm/
# Use correct JAVA_HOME with bin/javac present
export JAVA_HOME=/usr/lib/jvm/java-21-openjdk
```

### EngineHub (WorldGuard/WorldEdit) repo timeout

**Symptom**: Downloads from `maven.enginehub.org` time out.

**Fix**: Use **reflection-based integration** instead of compile-time dependency.

1. Remove WorldGuard from `dependencies`:
   ```kotlin
   // compileOnly("com.sk89q.worldguard:worldguard-bukkit:7.0.9")  // REMOVE
   ```

2. Detect and interact via reflection:
   ```java
   Plugin wg = Bukkit.getPluginManager().getPlugin("WorldGuard");
   if (wg != null && wg.isEnabled()) {
       Class<?> wgClass = Class.forName("com.sk89q.worldguard.WorldGuard");
       Object instance = wgClass.getMethod("getInstance").invoke(null);
       // ... further reflection calls
   }
   ```

3. Remove EngineHub repository:
   ```kotlin
   repositories {
       mavenCentral()
       maven("https://repo.papermc.io/repository/maven-public/")
       // NO maven("https://maven.enginehub.org/repo/")
   }
   ```

### JAR verification

If `jar` command is unavailable, use `7z`:

```bash
# List JAR contents
7z l build/libs/MyPlugin-1.0.0.jar

# Verify plugin.yml is present
7z l build/libs/MyPlugin-1.0.0.jar | grep plugin.yml
```

## Generating Gradle wrapper from scratch

If a project lacks `gradlew`, either copy from an existing project **or generate** via Gradle binary from the cache:

```bash
# Find cached Gradle
ls ~/.gradle/wrapper/dists/
# Generate wrapper (adjust version to match project needs)
JAVA_HOME=/usr/lib/jvm/java-21-openjdk \
  ~/.gradle/wrapper/dists/gradle-8.10.1-bin/e90i968nv55tch01zkse4avv3/gradle-8.10.1/bin/gradle \
  wrapper --gradle-version=8.8
```

This creates `gradlew`, `gradlew.bat`, and `gradle/` directory.

## Setting JDK for Gradle

**Primary method** — `gradle.properties` in project root:

```properties
org.gradle.java.home=/usr/lib/jvm/java-21-openjdk
```

**Alternative** — `JAVA_HOME` env var before every command:

```bash
export JAVA_HOME=/usr/lib/jvm/java-21-openjdk
./gradlew build
```

`gradle.properties` is preferred — persistent, works in IDE, doesn't require remembering to export.

## Java version compatibility

| Paper version | Java required |
|---------------|---------------|
| 1.20.5+ | Java 21 |
| 1.18 - 1.20.4 | Java 17 |
| 1.17 | Java 16 |
| 1.16 | Java 11 |

Always set `api-version` in `plugin.yml` to match target Minecraft major version.

## Soft-dependency pattern

For optional integrations (WorldGuard, Vault, etc.):

```java
public class HookManager {
    private boolean enabled = false;
    
    public HookManager(Plugin plugin) {
        Plugin dep = plugin.getServer().getPluginManager().getPlugin("WorldGuard");
        if (dep != null && dep.isEnabled()) {
            enabled = true;
        }
    }
    
    public boolean isAllowed(Location loc) {
        if (!enabled) return true;
        // reflection-based check
    }
}
```

Mark as `softdepend` in `plugin.yml` — plugin loads even if dependency is absent.

## Key files to inspect

| File | Purpose |
|------|---------|
| `build.gradle.kts` | Dependencies, repos, JVM version |
| `src/main/resources/plugin.yml` | Plugin metadata, commands, permissions |
| `src/main/resources/config.yml` | Default configuration shipped in JAR |
| `gradle/wrapper/gradle-wrapper.properties` | Gradle version |

## Common patterns

- **Data persistence**: Use Bukkit's `YamlConfiguration` for server-side data (not NBT or external DB for simple plugins)
- **Async tasks**: Use `BukkitRunnable().runTaskTimer(plugin, delay, period)` for tick-based logic
- **Event listeners**: Implement `Listener`, register via `pluginManager.registerEvents(listener, plugin)`
- **Commands**: Implement `CommandExecutor`, register in `plugin.yml` and `onEnable()`

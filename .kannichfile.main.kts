@file:DependsOn("dev.kannich:kannich-stdlib:0.10.0")
@file:DependsOn("dev.kannich:kannich-tools:0.10.0")
@file:DependsOn("dev.kannich:kannich-ggg:0.1.0")

import dev.kannich.stdlib.*
import dev.kannich.tools.*
import dev.kannich.ggg.*

pipeline {

    /**
     * Install dependencies for Godot.
     */
    suspend fun prepareDependencies() {
        Apt.install(
            "libx11-6",
            "libxcursor1",
            "libxinerama1",
            "libxi6",
            "libxrandr2",
            "libglu1-mesa",
            "libasound2t64",
            "libpulse0",
            "libudev1",
            "libwayland-client0",
            "libwayland-cursor0",
            "libwayland-egl1",
            "libxkbcommon0",
            "libfontconfig1",
            "libdbus-1-3",
            "xvfb"
        )
    }

    /**
     * Run GGG in XVFB using ggg.
     */
    suspend fun JobScope.ggg(vararg args: String) {
        val ggg = Ggg("0.4.0")
        withTools(ggg) {
            Shell.exec(
                "xvfb-run", "-a", "-s", "-screen 0 1280x720x24", "ggg", "run", "--audio-driver", "Dummy",
                "--display-driver", "x11",
                "--rendering-driver", "opengl3",
                "--single-window", *args
            )
        }
    }

    execution("test") {
        job {
            artifacts(On.SUCCESS_OR_FAILURE) {
                includes("reports/**")
            }

            prepareDependencies()
            ggg("run", "-s", "res://addons/gdUnit4/bin/GdUnitCmdTool.gd","--continue", "-a", "tests")
        }
    }
}

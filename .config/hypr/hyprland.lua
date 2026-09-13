-- Converted from hyprland.conf for Hyprland 0.55+.
-- Hyprland's current configuration API uses Lua.
-- See: https://wiki.hypr.land/Configuring/

local terminal = "kitty"
local fileManager = "dolphin"
local menu = "hyprlauncher"
local mainMod = "SUPER"

-- ============================================================
-- MONITORS
-- ============================================================

hl.monitor({
    output = "DP-1",
    mode = "highrr",
    position = "0x0",
    scale = 1,
})

hl.monitor({
    output = "eDP-1",
    mode = "highrr",
    position = "auto",
    scale = 1.333,
})

-- Fallback
hl.monitor({
    output = "",
    mode = "preferred",
    position = "auto",
    scale = 1,
})

-- ============================================================
-- ENVIRONMENT
-- ============================================================

-- Hyprcursor
hl.env("HYPRCURSOR_THEME", "VivianBLZ")
hl.env("HYPRCURSOR_SIZE", "40")

-- VPN / Clash Verge
hl.env("http_proxy", "http://127.0.0.1:7897")
hl.env("https_proxy", "http://127.0.0.1:7897")
hl.env("all_proxy", "socks5://127.0.0.1:7897")

hl.env("HTTP_PROXY", "http://127.0.0.1:7897")
hl.env("HTTPS_PROXY", "http://127.0.0.1:7897")
hl.env("ALL_PROXY", "socks5://127.0.0.1:7897")

hl.env("no_proxy", "localhost,127.0.0.1,::1")
hl.env("NO_PROXY", "localhost,127.0.0.1,::1")

-- XCursor / NVIDIA / Wayland
hl.env("XCURSOR_THEME", "VivianBLZ")
hl.env("XCURSOR_SIZE", "40")
hl.env("LIBVA_DRIVER_NAME", "nvidia")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("GBM_BACKEND", "nvidia-drm")
hl.env("_GLX_VENDOR_LIBRARY_NAME", "nvidia")
hl.env("WLR_NO_HARDWARE_CURSORS", "1")

-- Input method / toolkit variables
hl.env("QT_IM_MODULE", "fcitx")
hl.env("GTK_IM_MODULE", "fcitx")
hl.env("XMODIFIERS", "@im=fcitx")
hl.env("SDL_IM_MODULE", "fcitx")
hl.env("GLFW_IM_MODULE", "ibus")
hl.env("GDK_BACKEND", "wayland,x11")

-- ============================================================
-- LOOK AND FEEL
-- ============================================================

hl.config({
    general = {
        gaps_in = 5,
        gaps_out = 10,
        border_size = 2,
        col = {
            active_border = {
                colors = { "rgba(33ccffee)", "rgba(00ff99ee)" },
                angle = 45,
            },
            inactive_border = "rgba(595959aa)",
        },
        resize_on_border = false,
        allow_tearing = false,
        layout = "dwindle",
    },

    decoration = {
        rounding = 10,
        rounding_power = 2,
        active_opacity = 1,
        inactive_opacity = 1,

        shadow = {
            enabled = true,
            range = 4,
            render_power = 3,
            color = "rgba(1a1a1aee)",
        },

        blur = {
            enabled = true,
            size = 8,
            passes = 1,
            vibrancy = 0.1696,
            new_optimizations = true,
        },
    },

    master = {
        new_status = "master",
    },

    misc = {
        force_default_wallpaper = -1,
        disable_hyprland_logo = false,
    },

    input = {
        kb_layout = "us",
        kb_variant = "",
        kb_model = "",
        kb_options = "",
        kb_rules = "",
        follow_mouse = 1,
        sensitivity = 0,

        touchpad = {
            natural_scroll = false,
        },
    },

    xwayland = {
        force_zero_scaling = true,
    },
})

-- ============================================================
-- INPUT / GESTURES
-- ============================================================

hl.gesture({
    fingers = 3,
    direction = "horizontal",
    action = "workspace",
})

hl.device({
    name = "epic-mouse-v1",
    sensitivity = -0.5,
})

-- ============================================================
-- ANIMATIONS
-- ============================================================

hl.curve("easeOutQuint", {
    type = "bezier",
    points = {
        { 0.23, 1 },
        { 0.32, 1 },
    },
})

hl.curve("easeInOutCubic", {
    type = "bezier",
    points = {
        { 0.65, 0.05 },
        { 0.36, 1 },
    },
})

hl.curve("linear", {
    type = "bezier",
    points = {
        { 0, 0 },
        { 1, 1 },
    },
})

hl.curve("almostLinear", {
    type = "bezier",
    points = {
        { 0.5, 0.5 },
        { 0.75, 1 },
    },
})

hl.curve("quick", {
    type = "bezier",
    points = {
        { 0.15, 0 },
        { 0.1, 1 },
    },
})

hl.animation({ leaf = "global", enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "border", enabled = true, speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows", enabled = true, speed = 4.79, bezier = "easeOutQuint" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 4.1, bezier = "easeOutQuint", style = "popin 87%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 1.49, bezier = "linear", style = "popin 87%" })
hl.animation({ leaf = "fadeIn", enabled = true, speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade", enabled = true, speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers", enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 4, bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 1.5, bezier = "linear", style = "fade" })
hl.animation({ leaf = "fadeLayersIn", enabled = true, speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesIn", enabled = true, speed = 1.21, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "zoomFactor", enabled = true, speed = 7, bezier = "quick" })

-- ============================================================
-- AUTOSTART
-- ============================================================

hl.on("hyprland.start", function()
    hl.exec_cmd("waybar")
    hl.exec_cmd("swww init")
    hl.exec_cmd("fcitx5 -d")
    hl.exec_cmd("nm-applet --indicator")
    hl.exec_cmd("/usr/lib/polkit-kde-authentication-agent-1")

    -- Disabled in the original config:
    -- glava --desktop
    -- vesktop
end)

-- ============================================================
-- KEYBINDINGS
-- ============================================================

local function bindExec(keys, cmd, flags)
    hl.bind(keys, hl.dsp.exec_cmd(cmd), flags)
end

local function bindWindow(keys, dispatcher, flags)
    hl.bind(keys, dispatcher, flags)
end

-- Programs
bindExec(mainMod .. " + Q", terminal)
bindWindow(mainMod .. " + C", hl.dsp.window.close())
bindExec(mainMod .. " + SHIFT + C", "hyprctl activewindow -j | jq '.pid' | xargs kill")
bindExec(mainMod .. " + SHIFT + M", "hyprshutdown || hyprctl dispatch exit")
bindExec(mainMod .. " + E", fileManager)
bindWindow(mainMod .. " + SPACE", hl.dsp.window.float())
bindExec(mainMod .. " + R", "rofi -show drun")
bindWindow(mainMod .. " + P", hl.dsp.window.pseudo())
bindWindow(mainMod .. " + J", hl.dsp.layout("togglesplit"))

-- Focus
for key, direction in pairs({
    LEFT = "l",
    RIGHT = "r",
    UP = "u",
    DOWN = "d",
}) do
    bindWindow(
        mainMod .. " + " .. key,
        hl.dsp.focus({ direction = direction })
    )
end

-- Move focused window
for key, direction in pairs({
    LEFT = "l",
    RIGHT = "r",
    UP = "u",
    DOWN = "d",
}) do
    bindWindow(
        mainMod .. " + SHIFT + " .. key,
        hl.dsp.window.move({ direction = direction })
    )
end

-- Workspaces
for i = 1, 9 do
    bindWindow(
        mainMod .. " + " .. i,
        hl.dsp.focus({ workspace = tostring(i) })
    )
    bindWindow(
        mainMod .. " + SHIFT + " .. i,
        hl.dsp.window.move({ workspace = tostring(i) })
    )
end

bindWindow(mainMod .. " + 0", hl.dsp.focus({ workspace = "10" }))
bindWindow(mainMod .. " + SHIFT + 0", hl.dsp.window.move({ workspace = "10" }))

-- Mouse movement
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Fullscreen
bindWindow(mainMod .. " + F", hl.dsp.window.fullscreen({ mode = "fullscreen" }))
bindWindow(mainMod .. " + SHIFT + F", hl.dsp.window.fullscreen({ mode = "maximized" }))

-- Audio / brightness
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), {
    repeating = true,
    locked = true,
})
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), {
    repeating = true,
    locked = true,
})
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -s set +5%"), { repeating = true, locked = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -s set 5%-"), { repeating = true, locked = true })

-- Media controls
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

-- Screenshot
bindExec(mainMod .. " + SHIFT + S", "screenshot.sh")

-- MangaOCR
bindExec(
    mainMod .. " + T",
    "grim -g \"$(slurp)\" ~/.cache/screenshots/mangaOCR/capture_$(date +'%s%N').png"
)
bindExec(mainMod .. " + X", "kitty --class manga-ocr -e manga_ocr ~/.cache/screenshots/mangaOCR/")
bindExec(mainMod .. " + SHIFT + X", "pkill manga_ocr")

-- Zoom
bindExec(mainMod .. " + mouse_down", "woomer")

-- Audiobar
bindExec(mainMod .. " + K", "glava")
bindExec(mainMod .. " + K", "conky")
bindExec(mainMod .. " + SHIFT + K", "pkill glava; pkill conky; pkill waybar; waybar")

-- Music
bindExec(mainMod .. " + M", "sh -c \"mpd; mpc update; kitty -e rmpc\"")

-- Wallpaper
bindExec(mainMod .. " + SHIFT + W", "killall mpvpaper")
bindExec(mainMod .. " + SHIFT + W", "killall linux-wallpaperengine")
bindExec(
    mainMod .. " + W",
    "killall mpvpaper; mpvpaper -o \"--no-audio --loop\" DP-1 '/home/xinuwu/.local/share/Steam/steamapps/workshop/content/431960/2680392402/HuTao-Genshin Impact.mp4'"
)
bindExec(
    mainMod .. " + W",
    "killall linux-wallpaperengine; linux-wallpaperengine --screen-root eDP-1 --bg ~/.local/share/Steam/steamapps/workshop/content/431960/3439550988"
)

-- Power / lock
bindExec(mainMod .. " + SHIFT + P", "systemctl poweroff")
bindExec(mainMod .. " + SHIFT + L", "hyprlock")
bindExec(mainMod .. " + SHIFT + Q", "hyprlock")
bindExec(mainMod .. " + SHIFT + Q", "systemctl hibernate")

-- Lid switch
hl.bind("switch:on:Lid Switch", hl.dsp.exec_cmd("hyprlock"), { locked = true })
hl.bind("switch:on:Lid Switch", hl.dsp.exec_cmd("systemctl hibernate"), { locked = true })

-- ============================================================
-- WINDOW RULES
-- ============================================================

hl.window_rule({
    name = "suppress-maximize-events",
    match = {
        class = ".*",
    },
    suppress_event = "maximize",
})

hl.window_rule({
    name = "fix-xwayland-drags",
    match = {
        class = "^$",
        title = "^$",
        xwayland = true,
        float = true,
        fullscreen = false,
        pin = false,
    },
    no_focus = true,
})

hl.window_rule({
    name = "move-hyprland-run",
    match = {
        class = "hyprland-run",
    },
    move = { "20", "monitor_h-120" },
    float = true,
})

hl.window_rule({
    name = "glava",
    match = {
        class = "^(GLava)$",
    },
    float = true,
    move = { "monitor_w*0.5-window_w*0.5", "monitor_h*0.5-window_h*0.5" },
    size = { "monitor_w", "monitor_h" },
    no_blur = true,
    no_focus = true,
    border_size = 0,
    no_shadow = true,
    monitor = "eDP-1",
})

hl.window_rule({
    name = "conky",
    match = {
        class = "^(conky)$",
    },
    float = true,
    size = { 360, 630 },
    fullscreen = true,
    no_focus = false,
    border_size = 0,
    no_shadow = true,
})

hl.window_rule({
    name = "manga-ocr",
    match = {
        class = "^(manga-ocr)$",
    },
    workspace = "10 silent",
})

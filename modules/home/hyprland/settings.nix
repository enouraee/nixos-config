# modules/home/hyprland/settings.nix
# Hyprland general settings (input, decoration, animations)
{ ... }:
{
  wayland.windowManager.hyprland.settings = {
    # Modifier key
    "$mod" = "SUPER";

    # ====== INPUT ======
    input = {
      # Keyboard layouts: English + Persian
      # Switch with Alt+Caps Lock
      kb_layout = "us,fa";
      kb_options = "grp:alt_caps_toggle";

      repeat_delay = 300;
      numlock_by_default = true;

      # Mouse behavior
      follow_mouse = 1;
      mouse_refocus = 0;
      float_switch_override_focus = 0;

      # Touchpad settings
      touchpad = {
        disable_while_typing = false;
        natural_scroll = true;
      };
    };

    # ====== GENERAL ======
    general = {
      layout = "dwindle";

      gaps_in = 6;
      gaps_out = 12;
      border_size = 2;

      # Border colors (customize to your theme)
      "col.active_border" = "rgb(8aadf4) rgb(c6a0f6) 45deg";   # Blue to mauve gradient
      "col.inactive_border" = "0x00000000";
    };

    # ====== MISC ======
    misc = {
      disable_hyprland_logo = true;
      disable_splash_rendering = true;
      focus_on_activate = true;
      middle_click_paste = false;
      disable_autoreload = false;
    };

    # ====== LAYOUT ======
    dwindle = {
      force_split = 2;
      preserve_split = true;
      use_active_for_splits = true;
    };

    master = {
      new_status = "master";
    };

    # ====== DECORATION ======
    decoration = {
      rounding = 8;

      blur = {
        enabled = true;
        size = 3;
        noise = 0;
        passes = 2;
        contrast = 1.4;
        brightness = 1;
        xray = true;
      };

      shadow = {
        enabled = true;
        range = 20;
        render_power = 3;
        offset = "0 2";
        color = "rgba(00000055)";
      };
    };

    # ====== ANIMATIONS ======
    animations = {
      enabled = true;

      bezier = [
        "fluent_decel, 0, 0.2, 0.4, 1"
        "easeOutCirc, 0, 0.55, 0.45, 1"
        "easeOutCubic, 0.33, 1, 0.68, 1"
        "fade_curve, 0, 0.55, 0.45, 1"
      ];

      animation = [
        # Windows
        "windowsIn,   0, 4, easeOutCubic,  popin 20%"
        "windowsOut,  0, 4, fluent_decel,  popin 80%"
        "windowsMove, 1, 2, fluent_decel, slide"

        # Fade
        "fadeIn,      1, 3, fade_curve"
        "fadeOut,     1, 3, fade_curve"
        "fadeSwitch,  1, 3, fade_curve"
        "fadeShadow,  1, 3, fade_curve"
        "fadeDim,     1, 3, fade_curve"

        # Border
        "border,     1, 2, fluent_decel"
        "borderangle, 1, 30, fluent_decel, once"

        # Workspaces
        "workspaces, 1, 4, easeOutCubic, slide"
      ];
    };
  };
}

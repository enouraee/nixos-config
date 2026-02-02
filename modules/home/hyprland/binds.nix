# modules/home/hyprland/binds.nix
# Hyprland keybindings
{ ... }:
{
  wayland.windowManager.hyprland.settings = {
    binds = {
      scroll_event_delay = 100;
      movefocus_cycles_fullscreen = true;
    };

    bind = [
      # ====== APPLICATIONS ======
      "$mod, Return, exec, kitty"                          # Terminal
      "ALT, Return, exec, [float; size 1111 700] kitty"    # Floating terminal
      "$mod SHIFT, Return, exec, [fullscreen] kitty"       # Fullscreen terminal
      "$mod, D, exec, wofi --show drun"                    # App launcher
      "$mod, E, exec, nautilus"                            # File manager
      "$mod, Q, killactive,"                               # Close window

      # ====== WINDOW MANAGEMENT ======
      "$mod, F, fullscreen, 0"                             # Fullscreen
      "$mod SHIFT, F, fullscreen, 1"                       # Maximize
      "$mod, Space, togglefloating,"                       # Toggle float
      "$mod, P, pseudo,"                                   # Dwindle pseudo
      "$mod, X, togglesplit,"                              # Toggle split direction

      # ====== SESSION ======
      "$mod, Escape, exec, swaylock"                       # Lock screen
      "$mod SHIFT, Escape, exec, wlogout"                  # Power menu

      # ====== SCREENSHOT ======
      ", Print, exec, grimblast --notify copy area"        # Area screenshot to clipboard
      "$mod, Print, exec, grimblast --notify copysave area ~/Pictures/Screenshots/$(date +%Y-%m-%d_%H-%M-%S).png"  # Save screenshot
      "SHIFT, Print, exec, grimblast --notify copy screen" # Full screen to clipboard

      # ====== CLIPBOARD ======
      "$mod, V, exec, cliphist list | wofi --dmenu | cliphist decode | wl-copy"

      # ====== FOCUS (vim-style + arrows) ======
      "$mod, left,  movefocus, l"
      "$mod, right, movefocus, r"
      "$mod, up,    movefocus, u"
      "$mod, down,  movefocus, d"
      "$mod, h, movefocus, l"
      "$mod, j, movefocus, d"
      "$mod, k, movefocus, u"
      "$mod, l, movefocus, r"

      # ====== WORKSPACES ======
      "$mod, 1, workspace, 1"
      "$mod, 2, workspace, 2"
      "$mod, 3, workspace, 3"
      "$mod, 4, workspace, 4"
      "$mod, 5, workspace, 5"
      "$mod, 6, workspace, 6"
      "$mod, 7, workspace, 7"
      "$mod, 8, workspace, 8"
      "$mod, 9, workspace, 9"
      "$mod, 0, workspace, 10"

      # ====== MOVE TO WORKSPACE ======
      "$mod SHIFT, 1, movetoworkspacesilent, 1"
      "$mod SHIFT, 2, movetoworkspacesilent, 2"
      "$mod SHIFT, 3, movetoworkspacesilent, 3"
      "$mod SHIFT, 4, movetoworkspacesilent, 4"
      "$mod SHIFT, 5, movetoworkspacesilent, 5"
      "$mod SHIFT, 6, movetoworkspacesilent, 6"
      "$mod SHIFT, 7, movetoworkspacesilent, 7"
      "$mod SHIFT, 8, movetoworkspacesilent, 8"
      "$mod SHIFT, 9, movetoworkspacesilent, 9"
      "$mod SHIFT, 0, movetoworkspacesilent, 10"
      "$mod CTRL, c, movetoworkspace, empty"

      # ====== MOVE WINDOWS ======
      "$mod SHIFT, left, movewindow, l"
      "$mod SHIFT, right, movewindow, r"
      "$mod SHIFT, up, movewindow, u"
      "$mod SHIFT, down, movewindow, d"
      "$mod SHIFT, h, movewindow, l"
      "$mod SHIFT, j, movewindow, d"
      "$mod SHIFT, k, movewindow, u"
      "$mod SHIFT, l, movewindow, r"

      # ====== RESIZE WINDOWS ======
      "$mod CTRL, left, resizeactive, -80 0"
      "$mod CTRL, right, resizeactive, 80 0"
      "$mod CTRL, up, resizeactive, 0 -80"
      "$mod CTRL, down, resizeactive, 0 80"
      "$mod CTRL, h, resizeactive, -80 0"
      "$mod CTRL, j, resizeactive, 0 80"
      "$mod CTRL, k, resizeactive, 0 -80"
      "$mod CTRL, l, resizeactive, 80 0"

      # ====== MEDIA CONTROLS ======
      ",XF86AudioPlay, exec, playerctl play-pause"
      ",XF86AudioNext, exec, playerctl next"
      ",XF86AudioPrev, exec, playerctl previous"
      ",XF86AudioStop, exec, playerctl stop"

      # ====== SCROLL THROUGH WORKSPACES ======
      "$mod, mouse_down, workspace, e-1"
      "$mod, mouse_up, workspace, e+1"
    ];

    # ====== HELD KEYS ======
    binde = [
      # Volume control
      ",XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
      ",XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
      ",XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"

      # Brightness control
      ",XF86MonBrightnessUp, exec, brightnessctl set +5%"
      ",XF86MonBrightnessDown, exec, brightnessctl set 5%-"
    ];

    # ====== MOUSE BINDINGS ======
    bindm = [
      "$mod, mouse:272, movewindow"
      "$mod, mouse:273, resizewindow"
    ];
  };
}

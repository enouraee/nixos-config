# NixOS Configuration

A minimal, clean NixOS configuration with Hyprland window manager.

## Features

- 🪟 **Hyprland** - Modern Wayland compositor with animations
- 🔐 **LUKS encryption** - Full disk encryption using LUKS2 + argon2id
- 🐚 **Zsh + Oh-My-Zsh** - Feature-rich shell with plugins
- ⌨️ **Dual keyboard layouts** - English (US) + Persian (IR), switch with `Alt+Shift`
- 🔊 **PipeWire audio** - Modern audio stack with PulseAudio compatibility
- 📦 **Flakes** - Reproducible configuration with Nix flakes

## ⚠️ CRITICAL WARNINGS

1. **BACKUP YOUR LUKS PASSWORD** - Store it in a password manager or write it down physically.
   If you forget it, your data is **PERMANENTLY UNRECOVERABLE**. There is no backdoor.

2. **VERIFY TARGET DISK** - The install script shows disk info. **Triple-check** you're not 
   wiping your main drive! The script will ask for confirmation.

3. **AMD CPUs** - After install, edit `hosts/expertbook/hardware-configuration.nix`:
   ```nix
   # Change this line:
   hardware.cpu.intel.updateMicrocode = ...
   # To:
   hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
   
   # Also change:
   boot.kernelModules = [ "kvm-intel" ];
   # To:
   boot.kernelModules = [ "kvm-amd" ];
   ```

4. **NVIDIA GPUs** - Uncomment the NVIDIA section in `modules/home/hyprland/variables.nix`
   and consider adding `hardware.nvidia` options in your host config.

## Quick Start

### Fresh Installation

1. Boot from NixOS live USB
2. Connect to internet (use `nmtui` for WiFi)
3. Clone this repo:
   ```bash
   nix-shell -p git
   git clone https://github.com/YOUR_USER/nixos-config.git
   cd nixos-config
   ```
4. **Set your username** in `flake.nix`:
   ```nix
   username = "yourname";  # Change from "nixuser" to your preferred username
   ```
5. Run the installer:
   ```bash
   sudo ./install.sh /dev/sdX    # Replace with your target disk
   ```
6. The installer will prompt for passwords automatically
7. Reboot and enjoy!

### Install Script Options

The install script includes preflight checks and safety guards:

```bash
# Standard install (with all safety checks)
sudo ./install.sh /dev/sdX

# Skip build test (faster but less safe)
SKIP_BUILD_TEST=1 sudo ./install.sh /dev/sdX

# Force reformat existing partitions (DANGER!)
FORCE=1 sudo ./install.sh /dev/sdX
```

**Preflight checks performed:**
- ✅ `flake.lock` exists (reproducibility)
- ✅ Network connectivity to cache.nixos.org
- ✅ Flake metadata validation
- ✅ Host exists in flake
- ✅ Build test (dry-run)
- ✅ Required tools available

### Rebuilding After Changes

```bash
cd /etc/nixos
sudo nixos-rebuild switch --flake .#expertbook
```

Or use the alias (after first boot):
```bash
rebuild    # Defined in zsh aliases
```

## Directory Structure

```
nixos-config/
├── flake.nix                 # Main flake entry point
├── install.sh                # Installation script
├── README.md
│
├── hosts/                    # Host-specific configurations
│   └── expertbook/           # Your laptop
│       ├── default.nix       # Host config (power management, etc.)
│       └── hardware-configuration.nix  # Auto-generated hardware config
│
└── modules/
    ├── common/               # Shared system modules (all hosts import this)
    │   ├── default.nix       # Entry point
    │   ├── audio.nix         # PipeWire audio
    │   ├── bootloader.nix    # systemd-boot
    │   ├── fonts.nix         # System fonts
    │   ├── hardware.nix      # GPU, Bluetooth, etc.
    │   ├── network.nix       # NetworkManager
    │   ├── security.nix      # sudo, PAM, polkit
    │   ├── services.nix      # System services
    │   ├── system.nix        # Nix settings, locale, timezone
    │   ├── user.nix          # User creation + home-manager
    │   ├── wayland.nix       # Hyprland + XDG portals
    │   └── xserver.nix       # X11 support + display manager
    │
    └── home/                 # Home Manager modules (user config)
        ├── default.nix       # Entry point
        ├── git.nix           # Git config
        ├── gtk.nix           # GTK theming
        ├── kitty.nix         # Terminal emulator
        ├── packages.nix      # User packages (ADD YOUR APPS HERE)
        ├── xdg.nix           # XDG directories + default apps
        ├── zsh.nix           # Zsh + Oh-My-Zsh
        │
        └── hyprland/         # Hyprland window manager config
            ├── default.nix
            ├── binds.nix     # Keybindings
            ├── exec-once.nix # Startup apps
            ├── hyprland.nix  # Core Hyprland setup
            ├── monitors.nix  # Monitor config
            ├── settings.nix  # Input, decorations, animations
            ├── variables.nix # Environment variables
            └── windowrules.nix
```

## Common Tasks

### Setting Your Username

The username is configured in one place: `flake.nix`

```nix
# In flake.nix, find this line and change it:
username = "nixuser";  # <-- Change to your username
```

After changing, rebuild:
```bash
sudo nixos-rebuild switch --flake .#expertbook
```

### Setting Git Identity

Edit `modules/home/git.nix`:
```nix
userName = "Your Name";
userEmail = "you@example.com";
```

### Adding Packages

**System packages** (available to all users):
Edit `modules/common/system.nix`

**User packages** (home-manager):
Edit `modules/home/packages.nix` - this is where most apps should go.

### Adding a New Host

1. Create `hosts/newhost/default.nix`:
   ```nix
   { ... }:
   {
     imports = [
       ./hardware-configuration.nix
       ./../../modules/common
     ];
     # Host-specific settings here
   }
   ```

2. Add to `flake.nix`:
   ```nix
   nixosConfigurations = {
     # existing...
     newhost = nixpkgs.lib.nixosSystem {
       inherit system;
       modules = [ ./hosts/newhost ];
       specialArgs = {
         host = "newhost";
         inherit self inputs username;
       };
     };
   };
   ```

3. Generate hardware config:
   ```bash
   sudo nixos-generate-config --show-hardware-config > hosts/newhost/hardware-configuration.nix
   ```

### Hyprland Configuration

All Hyprland config lives in `modules/home/hyprland/`:

- **Keybindings**: [binds.nix](modules/home/hyprland/binds.nix)
- **Startup apps**: [exec-once.nix](modules/home/hyprland/exec-once.nix)
- **Appearance**: [settings.nix](modules/home/hyprland/settings.nix)
- **Window rules**: [windowrules.nix](modules/home/hyprland/windowrules.nix)

For custom monitor setup, create `~/.config/hypr/monitors.conf`:
```
monitor=eDP-1,1920x1080@60,0x0,1
monitor=HDMI-A-1,2560x1440@144,1920x0,1
```

### Useful Keybindings

| Key | Action |
|-----|--------|
| `Super + Return` | Open terminal (kitty) |
| `Super + D` | App launcher (wofi) |
| `Super + Q` | Close window |
| `Super + F` | Fullscreen |
| `Super + Space` | Toggle floating |
| `Super + 1-9` | Switch workspace |
| `Super + Shift + 1-9` | Move window to workspace |
| `Super + h/j/k/l` | Focus window (vim-style) |
| `Super + Shift + h/j/k/l` | Move window |
| `Super + V` | Clipboard history |
| `Print` | Screenshot area |
| `Alt + Shift` | Switch keyboard layout (EN/IR) |

### Switching Keyboard Layout

The keyboard is configured with:
- **Primary**: English (US)
- **Secondary**: Persian (IR)
- **Switch key**: `Alt + Shift`

You can see the current layout in waybar or use `hyprctl getoption input:kb_layout` (or `localectl status`) to check.

## Health Check

After installation, run the built-in health check to verify everything is working:

```bash
health-check
```

This checks:
- Core system (NixOS version, hostname)
- Network (routes, DNS, NetworkManager)
- Time/timezone (should be Asia/Tehran)
- Disk (mounts, LUKS encryption, disk space)
- User/shell (zsh, oh-my-zsh)
- Desktop (Hyprland, portals, D-Bus)
- Audio (PipeWire, WirePlumber)
-- Keyboard (Persian layout)
- Systemd (failed units)
- Boot log errors

See [scripts/health-check.md](scripts/health-check.md) for detailed documentation.

## Troubleshooting

### No display after boot
- Try switching to TTY: `Ctrl + Alt + F2`
- Check Hyprland logs: `cat ~/.local/share/hyprland/hyprland.log`

### Audio not working
```bash
# Check PipeWire status
systemctl --user status pipewire

# Restart audio
systemctl --user restart pipewire pipewire-pulse
```

### Rebuild fails
```bash
# Check for errors
sudo nixos-rebuild switch --flake .#expertbook 2>&1 | less

# Update flake inputs
./scripts/flake-update.sh
```

### narHash mismatch error

If you see an error like "mismatch in field 'narHash'", your flake.lock is inconsistent:

```bash
# Fix it with:
./scripts/flake-lock-refresh.sh

# Or manually:
nix flake lock --refresh

# Or delete flake.lock and regenerate:
rm flake.lock && nix flake lock
```

## Helper Scripts

The repository includes helper scripts for common operations:

| Script | Purpose |
|--------|---------|
| `./scripts/flake-check.sh` | Run flake checks to validate configuration |
| `./scripts/flake-build-expertbook.sh` | Build the expertbook configuration |
| `./scripts/flake-lock-refresh.sh` | Refresh flake.lock (fixes narHash mismatches) |
| `./scripts/flake-update.sh` | Update all flake inputs to latest versions |

All scripts automatically enable flakes (work in NixOS live/installer environments).

## Customization Ideas

- [ ] Add a theme (Catppuccin, Gruvbox, etc.)
- [ ] Configure waybar layout
- [ ] Add screen locker (swaylock-effects)
- [ ] Setup development environments
- [ ] Add gaming support (Steam, Lutris)

## Credits

Structure inspired by [FrostPhoenix's nixos-config](https://github.com/Frost-Phoenix/nixos-config).

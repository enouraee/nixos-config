# Health Check Script

A post-install diagnostic tool to verify your NixOS system is working correctly.

## Usage

```bash
health-check
```

Or directly:
```bash
/etc/nixos/scripts/health-check.sh
```

## What It Checks

### Core System
| Check | Description |
|-------|-------------|
| NixOS version | Reads `/etc/os-release` |
| Hostname | Verifies hostname is set |

### Network
| Check | Description |
|-------|-------------|
| Default route | Checks `ip route` for gateway |
| DNS resolution | Tests resolving `nixos.org` |
| NetworkManager | Verifies service is running |

### Time & Locale
| Check | Description |
|-------|-------------|
| Timezone | Should be `Asia/Tehran` |
| NTP sync | Time synchronization status |
| System time | Current date/time |

### Disk & Encryption
| Check | Description |
|-------|-------------|
| Root mount | `/` is mounted |
| Boot mount | `/boot` is mounted |
| LUKS encryption | Detects `crypt` devices in `lsblk` |
| udisks2 | Automount service for USB drives |
| Disk usage | Warns if root > 80% full |

### User & Shell
| Check | Description |
|-------|-------------|
| Current user | Who you're logged in as |
| Default shell | Should be `zsh` |
| Oh-My-Zsh | Checks for `~/.oh-my-zsh` or config |

### Desktop / Hyprland
| Check | Description |
|-------|-------------|
| Hyprland installed | Binary exists |
| Hyprland running | Process active (if in graphical session) |
| xdg-desktop-portal | Portal service running |
| Hyprland portal | `xdg-desktop-portal-hyprland` running |
| D-Bus session | User session bus available |

### Audio
| Check | Description |
|-------|-------------|
| PipeWire | Audio server running |
| WirePlumber | Session manager running |
| PipeWire-pulse | PulseAudio compatibility layer |
| pactl info | Audio server responding |

### Input / Keyboard
| Check | Description |
|-------|-------------|
| Persian layout | Checks Hyprland config or `hyprctl` |
| X11 layout | Checks `setxkbmap -query` |

### Systemd Health
| Check | Description |
|-------|-------------|
| Failed units | `systemctl --failed` |
| User failed units | `systemctl --user --failed` |

### Journal Errors
| Check | Description |
|-------|-------------|
| Boot errors | `journalctl -b -p err..alert` (top 15) |

## Output Symbols

| Symbol | Meaning |
|--------|---------|
| ✅ | Check passed |
| ❌ | Check failed (needs attention) |
| ⚠️ | Warning (review recommended) |

## Exit Codes

| Code | Meaning |
|------|---------|
| 0 | All checks passed |
| 1 | One or more checks failed |
| 2 | Script error |

## Example Output

```
╔══════════════════════════════════════╗
║     NixOS Health Check               ║
╚══════════════════════════════════════╝

Running checks... (2026-02-02 15:30:00)

[Core System]
  ✅ NixOS version: 24.11 (Vicuna)
  ✅ Hostname: expertbook

[Network]
  ✅ Default route exists (gateway: 192.168.1.1)
  ✅ DNS resolution working
  ✅ NetworkManager running

...

══════════════════════════════════════
             SUMMARY                  
══════════════════════════════════════

  ✅ Passed:   25
  ❌ Failed:   0
  ⚠️  Warnings: 2
  📊 Total:    27 checks

WARNINGS (review recommended):
  • Time not NTP synchronized: Run: timedatectl set-ntp true
  • Oh-My-Zsh not detected: May be managed by home-manager differently

🎉 System is healthy!
   (2 warning(s) - review above)
```

## Troubleshooting Common Failures

### PipeWire not running
```bash
systemctl --user start pipewire pipewire-pulse wireplumber
systemctl --user enable pipewire pipewire-pulse wireplumber
```

### Failed systemd units
```bash
systemctl --failed
systemctl restart <failed-unit>
journalctl -u <failed-unit> -e
```

### Hyprland portal not running
```bash
systemctl --user restart xdg-desktop-portal-hyprland
```

### Disk space issues
```bash
sudo nix-collect-garbage -d
sudo nix-store --gc
```

## Notes

- Run this **after first boot** to verify installation
- Run from **within Hyprland session** for full desktop checks
- Does **not require root** for most checks
- **Network offline** = warnings, not failures (except DNS)

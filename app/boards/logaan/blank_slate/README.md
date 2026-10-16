# Blank Slate

Logaan's in-tree definition for the LP Galaxy Blank Slate, using only the
**4x12 ortholinear, 48-key all-1U layout**. No shield or external Blank Slate
module is needed.

The hardware definition is based on Pete Johanson's MIT-licensed
[Blank Slate module](https://github.com/petejohanson/blank-slate-zmk-module)
(`706ebcb`) and the stock QWERTY keymap from the
[original config](https://github.com/petejohanson/blank-slate-zmk-config).
The MIT/single-2U, dual-2U, and alternative base keymap options are intentionally
not included.

## Hardware

- nRF52840 QIAA, USB and Bluetooth LE.
- Six electrical columns and eight folded switch rows; the right half of each
  physical row is wired in reverse order. A ninth electrical row carries the
  dedicated power button at matrix position `(8, 0)`.
- Original column/row GPIO assignments and 1 ms press / 5 ms release debounce.
- Battery measurement through the nRF52840's VDDH input; blue LED on P0.16.
- DC/DC enabled using devicetree, not the deprecated `SOC_DCDC_NRF52X` setting.
- Original UF2 flash layout: application at `0x1000`, 128 KiB settings storage at
  `0xd4000`, bootloader at `0xf4000`.
- Deep sleep and soft off enabled. Hold the dedicated power button for more than
  one second, then release, to turn off. Press it to wake from soft off. Ordinary
  keys can wake the keyboard from automatic deep sleep.

The board uses Zephyr's hardware model v2 (`board.yml`, `Kconfig.blank_slate`,
and the `zmk` variant), with target **`blank_slate//zmk`** (fully qualified:
`blank_slate/nrf52840/zmk`). The selected physical layout uses ZMK's shared
`ortho_4x12/all1u.dtsi`, including the key positions required by Studio. Its
matrix transform and scan driver are attached to the physical layout; there is
no legacy `zmk,matrix-transform` chosen property.

The GPIO matrix scan uses ZMK's sideband driver to keep the dedicated power
button separate from the editable keymap. This currently produces an expected
Zephyr 4.1 deprecation warning for `KSCAN`.

## Build with ZMK Studio

With the [ZMK build environment](https://zmk.dev/docs/development/local-toolchain/setup)
installed, run these commands from the repository root:

```sh
# First-time workspace setup (skip init if already initialized).
west init -l app
west update
west zephyr-export

west build -s app -d build/blank_slate -b blank_slate//zmk \
  -S studio-rpc-usb-uart -- -DCONFIG_ZMK_STUDIO=y
```

Studio is enabled at build time, as with other in-tree Studio-capable keyboards.
The USB snippet supplies the CDC ACM RPC interface and keeps standard behaviors
available for assignment in Studio. BLE Studio transport is also enabled by ZMK
when Studio and Bluetooth are enabled; use a supported native app/client for BLE.
Studio locking remains enabled.

Flash `build/blank_slate/zephyr/zmk.uf2` using the keyboard's existing UF2
bootloader. With the default keymap, hold **Sym** (bottom row, second key from
the left) and press **Backspace** (top-right) to enter the bootloader, then copy
the UF2 onto its USB drive.

## Default keymap and Studio access

The four stock layers are **Base (QWERTY)**, **Nav**, **Num**, and **Sym**; each
contains exactly 48 bindings.

- **Nav:** hold the fifth key on the bottom row.
- **Num:** hold the eighth key on the bottom row.
- **Sym:** hold the second key on the bottom row.
- **Select USB output:** hold Nav and press Q. Select BLE output with Nav + W.
- **Select Bluetooth profile 0–4:** hold Nav and press Z, X, C, V, or B.
- **Clear the active Bluetooth profile:** Nav + Esc.
- **Unlock Studio:** hold Sym and press P (top row, second key from the right).
- **Enter UF2 bootloader:** Sym + Backspace.

To edit over USB, connect the keyboard, select USB output, open
[ZMK Studio](https://zmk.studio/), connect to the keyboard, and use the unlock
binding. Studio changes are saved in the settings partition. Once saved, they
override the compiled keymap until **Restore Stock Settings** is used in Studio.
Keep an accessible Studio unlock binding when editing the keymap.

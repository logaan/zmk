# SPDX-License-Identifier: MIT

# Nordic peripherals share unit addresses when only one instance is enabled.
list(APPEND EXTRA_DTC_FLAGS "-Wno-unique_unit_address_if_enabled")

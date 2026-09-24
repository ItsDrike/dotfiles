# Intel GPU driver: VA-API video acceleration + Vulkan
#
# Covers any Intel GPU: integrated (all Broadwell-and-newer iGPUs) and discrete
# (Arc). Intel doesn't split its userspace drivers by iGPU vs dGPU: the same
# intel-media-driver and vulkan-intel packages support both. The kernel driver
# (i915 vs the newer xe) is chosen automatically by PCI ID, not something to
# select here.

###############################################################################
## VA-API (hardware video decode)
###############################################################################

# Installs the modern iHD VA-API backend, used by browsers and media players
# for hardware video decode. libva selects a driver by PCI vendor
# automatically, so this becomes the default for the Intel device without
# needing a LIBVA_DRIVER_NAME override.
#
# On hybrid machines with nvidia, we deliberately still use the intel backend,
# instead of installing an NVIDIA VA-API driver or forcing
# LIBVA_DRIVER_NAME=nvidia globally. This is because if we have both GPUs,
# using the dGPU for decoding means powering it on for something that Intel
# Quick Sync can already do at a fraction of the power draw. If a specific
# application ever needs NVDEC decode, scope LIBVA_DRIVER_NAME=nvidia to that
# one command instead of setting it globally.
#
# Verify what's actually active with `vainfo`, or in Firefox's about:support,
# under Media > HARDWARE_VIDEO_DECODING.
AddPackage intel-media-driver
AddPackage libva-utils # vainfo and other VA-API inspection/debugging tools

###############################################################################
## OpenGL and EGL
###############################################################################

# Mesa provides the Iris OpenGL/EGL driver used by the Intel GPU.
#
# We install the 32-bit variant too, for Steam + Proton/Wine.
AddPackage mesa
AddPackage lib32-mesa

###############################################################################
## Vulkan
###############################################################################

# Unlike VA-API, Vulkan ICDs don't have a "default driver" conflict: the Vulkan
# loader enumerates every installed ICD as its own VkPhysicalDevice, so having
# both vulkan-intel and other bundled ICD (say from nvidia-utils) installed
# just gives a Vulkan app two GPUs to pick from, not a clash to resolve. Safe
# to install unconditionally alongside any other vendor.
#
# The 32-bit Vulkan ICD supports Proton/Wine games.
AddPackage vulkan-intel
AddPackage lib32-vulkan-intel

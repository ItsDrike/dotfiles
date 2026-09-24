# NVIDIA PRIME render offload (hybrid iGPU + NVIDIA dGPU)
#
# For hosts with no hardware MUX switch, where an integrated GPU always
# drives the display and the NVIDIA dGPU is only woken up on demand to
# render specific applications ("Optimus"/PRIME render offload). Requires
# nvidia.sh for the base driver.
AddPackage nvidia-prime

###############################################################################
## nvidia-launch
###############################################################################

# prime-run, plus a performance power profile and a sleep/idle inhibitor for
# the duration of the wrapped command.
CopyFile /usr/local/bin/nvidia-launch 755

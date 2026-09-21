AddPackage linux-cachyos-nvidia-open # nvidia open modules of 615.71.09 driver for the linux-cachyos kernel
AddPackage nvidia-open # NVIDIA open kernel modules
AddPackage nvidia-prime # NVIDIA Prime Render Offload configuration and utilities
AddPackage lib32-nvidia-utils # NVIDIA drivers utilities (32-bit)

CreateLink \
    /etc/systemd/system/multi-user.target.wants/nvidia-powerd.service \
    /usr/lib/systemd/system/nvidia-powerd.service

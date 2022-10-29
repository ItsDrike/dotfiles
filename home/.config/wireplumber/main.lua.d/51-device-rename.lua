
table.insert(
  alsa_monitor.rules,
  {
    matches = {
      {
        { "node.name", "equals", "alsa_output.pci-0000_05_00.6.analog-stereo" },
      },
    },
    apply_properties = {
      ["node.description"] = "Laptop-output",
    },
  }
)

table.insert(
  alsa_monitor.rules,
  {
    matches = {
      {
        { "node.name", "equals", "alsa_input.pci-0000_05_00.6.analog-stereo" },
      },
    },
    apply_properties = {
      ["node.description"] = "Laptop-input",
    },
  }
)


table.insert(
  alsa_monitor.rules,
  {
    matches = {
      {
        { "node.name", "equals", "alsa_input.usb-C-Media_Electronics_Inc._Bloody_Gaming_Audio_Device-00.analog-stereo" },
      },
    },
    apply_properties = {
      ["node.description"] = "Bloody_Gaming_Headphones-input",
    },
  }
)


table.insert(
  alsa_monitor.rules,
  {
    matches = {
      {
        { "node.name", "equals", "alsa_output.usb-C-Media_Electronics_Inc._Bloody_Gaming_Audio_Device-00.analog-stereo" },
      },
    },
    apply_properties = {
      ["node.description"] = "Bloody_Gaming_Headphones-output",
    },
  }
)


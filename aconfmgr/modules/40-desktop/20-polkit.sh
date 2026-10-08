# Graphical authentication agent for Polkit authorization requests.
AddPackage polkit-gnome

# Include and enable a global user systemd service which auto-starts the gnome
# polkit agent after reaching graphical-session.target
CopyFile /etc/systemd/user/polkit-gnome-agent.service
CreateLink \
  /etc/systemd/user/graphical-session.target.wants/polkit-gnome-agent.service \
  /etc/systemd/user/polkit-gnome-agent.service

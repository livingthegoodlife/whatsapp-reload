#!/bin/bash

echo "📦 Installiere WhatsApp Web Auto-Restart Setup..."

# 1. Script-Datei erstellen
cat << 'EOF' > /home/$USER/whatsapp-reloader.sh
#!/bin/bash

while true; do
    pkill chromium
    sleep 2
    DISPLAY=:10 chromium --no-sandbox --new-window "https://web.whatsapp.com" &
    sleep 7200
done
EOF

chmod +x /home/$USER/whatsapp-reloader.sh

# 2. systemd user service einrichten
mkdir -p /home/$USER/.config/systemd/user

cat << EOF > /home/$USER/.config/systemd/user/whatsapp.service
[Unit]
Description=WhatsApp Web Auto-Restarter
After=default.target

[Service]
ExecStart=/home/$USER/whatsapp-reloader.sh
Restart=always
Environment=DISPLAY=:10
Environment=XDG_RUNTIME_DIR=/run/user/$(id -u)

[Install]
WantedBy=default.target
EOF

# 3. systemd Dienst aktivieren
loginctl enable-linger $USER
sudo -u $USER systemctl --user daemon-reload
sudo -u $USER systemctl --user enable whatsapp.service
sudo -u $USER systemctl --user start whatsapp.service

# 4. Desktop-Verknüpfung erstellen
mkdir -p /home/$USER/Desktop

cat << EOF > /home/$USER/Desktop/WhatsAppStarter.desktop
[Desktop Entry]
Type=Application
Name=WhatsApp Auto-Start
Comment=Startet den WhatsApp-Neulade-Service im Hintergrund
Exec=systemctl --user restart whatsapp.service
Icon=chromium
Terminal=false
Categories=Utility;
EOF

chmod +x /home/$USER/Desktop/WhatsAppStarter.desktop

echo "✅ Installation abgeschlossen! Du findest das Icon auf deinem Desktop."

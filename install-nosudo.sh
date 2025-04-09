#!/bin/bash

echo "📦 Installiere WhatsApp Web Auto-Restart Setup (ohne sudo)..."

# 1. Script-Datei erstellen
cat << 'EOF' > /home/tomasz/whatsapp-reloader.sh
#!/bin/bash

while true; do
    pkill chromium
    sleep 2
    DISPLAY=:10 chromium --no-sandbox --new-window "https://web.whatsapp.com" &
    sleep 7200
done
EOF

chmod +x /home/tomasz/whatsapp-reloader.sh
chown tomasz:tomasz /home/tomasz/whatsapp-reloader.sh

# 2. systemd user service einrichten
mkdir -p /home/tomasz/.config/systemd/user
chown -R tomasz:tomasz /home/tomasz/.config

cat << EOF > /home/tomasz/.config/systemd/user/whatsapp.service
[Unit]
Description=WhatsApp Web Auto-Restarter
After=default.target

[Service]
ExecStart=/home/tomasz/whatsapp-reloader.sh
Restart=always
Environment=DISPLAY=:10
Environment=XDG_RUNTIME_DIR=/run/user/$(id -u)

[Install]
WantedBy=default.target
EOF

chown tomasz:tomasz /home/tomasz/.config/systemd/user/whatsapp.service

# 3. systemd Dienst aktivieren (als root)
loginctl enable-linger tomasz
runuser -l tomasz -c "systemctl --user daemon-reexec"
runuser -l tomasz -c "systemctl --user daemon-reload"
runuser -l tomasz -c "systemctl --user enable whatsapp.service"
runuser -l tomasz -c "systemctl --user start whatsapp.service"

# 4. Desktop-Verknüpfung erstellen
mkdir -p /home/tomasz/Desktop

cat << EOF > /home/tomasz/Desktop/WhatsAppStarter.desktop
[Desktop Entry]
Type=Application
Name=WhatsApp Auto-Start
Comment=Startet den WhatsApp-Neulade-Service im Hintergrund
Exec=systemctl --user restart whatsapp.service
Icon=chromium
Terminal=false
Categories=Utility;
EOF

chmod +x /home/tomasz/Desktop/WhatsAppStarter.desktop
chown tomasz:tomasz /home/tomasz/Desktop/WhatsAppStarter.desktop

echo "✅ Installation abgeschlossen! Icon befindet sich auf dem Desktop von tomasz."

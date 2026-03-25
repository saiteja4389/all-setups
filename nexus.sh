# Update system
sudo yum update -y

# Install required tools
sudo yum install -y wget tar

# Install Java 17 (correct package)
sudo yum install -y java-17-amazon-corretto

# Verify Java
java -version

# Create directory
sudo mkdir -p /app
cd /app

# Download Nexus
sudo wget https://download.sonatype.com/nexus/3/nexus-3.90.2-06-linux-x86_64.tar.gz

# Extract
sudo tar -xvzf nexus-3.90.2-06-linux-x86_64.tar.gz

# Rename for consistency
sudo mv nexus-3.90.2-06 nexus

# Create nexus user (if not exists)
id nexus || sudo useradd nexus

# Set ownership
sudo chown -R nexus:nexus /app/nexus
sudo chown -R nexus:nexus /app/sonatype-work

# Configure Nexus to run as nexus user (FIXED sed command)
sudo sed -i 's/#run_as_user=""/run_as_user="nexus"/' /app/nexus/bin/nexus

# Create systemd service
sudo tee /etc/systemd/system/nexus.service > /dev/null << 'EOF'
[Unit]
Description=Nexus Repository Manager
After=network.target

[Service]
Type=forking
LimitNOFILE=65536
User=nexus
Group=nexus
ExecStart=/app/nexus/bin/nexus start
ExecStop=/app/nexus/bin/nexus stop
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd
sudo systemctl daemon-reload

# Enable and start Nexus
sudo systemctl enable nexus
sudo systemctl start nexus

# Check status
sudo systemctl status nexus

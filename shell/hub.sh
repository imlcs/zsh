#########################################################################
# File Name: hub.sh
# Author: Charles
# Created Time: 2024-11-08 22:42:15
#########################################################################

sudo tee /etc/docker/daemon.json <<-'EOF'
{
    "registry-mirrors": [
    "https://docker.rainbond.cc",
    "https://docker.1panel.live",
    "https://docker.cloudmessage.top"
  ]
}
EOF
sudo systemctl daemon-reload
sudo systemctl restart docker

#########################################################################
# File Name: hub.sh
# Author: Charles
# Created Time: 2024-11-08 22:42:15
#########################################################################

sudo tee /etc/docker/daemon.json <<-'EOF'
{
  "log-level": "info",
  "log-opts": {
    "max-size": "200m",
    "max-file": "5"
  },
  "registry-mirrors": [
    "https://docker.1ms.run",
    "https://proxy.1panel.live",
    "https://docker.ketches.cn"
  ]
}
EOF
sudo systemctl daemon-reload
sudo systemctl restart docker

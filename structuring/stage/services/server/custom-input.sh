#!/bin/bash
# "sudo apt update",
#       "sudo apt install -y nginx",
#       "sudo systemctl start nginx"

sudo apt update
sudo apt install -y nginx

echo "<html>
<head>
  <title>Test Server</title>
</head>
<body>
  <h1>Hello, World!</h1>
  <p>Public ip: ${publicIp}.</p>
  <p>Nic id: ${nicId}.</p>
</body>
</html>" | sudo tee /var/www/html/index.html

sudo systemctl start nginx
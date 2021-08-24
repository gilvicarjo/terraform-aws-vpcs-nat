#! /bin/bash
sudo apt-get update
sudo apt-get install -y apache2
sudo systemctl start apache2
sudo systemctl enable apache2
sudo mkdir /var/www/html/
echo "<h1>Hello World</h1>" | sudo tee /var/www/html/index.html
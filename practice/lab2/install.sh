      #!/bin/bash
      #Update OS
      sudo yum update -y

      #Instal HTTPD
      sudo yum install httpd -y

      #Modify below file:
      sudo touch /var/www/html/index.html
      sudo chmod u+rwx,o+rxw  /var/www/html/index.html
      #Add some html code:
      sudo echo "<h1>Welcome to Udemy</h1>" >> /var/www/html/index.html
      sudo echo "<h2>AWS Cloud for beginner. Please like, subscribe and share !!!!</h2>" >> /var/www/html/index.html
      #Enable httpd
      sudo systemctl enable httpd #moi khi server khoi dong service se khoi dong theo 
      sudo service httpd start
      service httpd status
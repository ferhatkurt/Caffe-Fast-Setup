
sudo echo "
server {
    location / {
        proxy_pass http://localhost:5000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
    location /statical {
        alias  /home/www/flask_project/static/;
    }
}" >> /etc/nginx/sites-available/web_demo

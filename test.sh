echo "
server {
    location / {
        proxy_pass http://localhost:5000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
    location /armut {
        alias  /home/www/flask_project/static/;
    }
}" | sudo tee -a /etc/nginx/sites-available/web_demo

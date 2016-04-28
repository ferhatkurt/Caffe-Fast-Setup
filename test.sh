# cd /etc/nginx/sites-available
# echo "
# server {
#     location / {
#         proxy_pass http://localhost:5000;
#         proxy_set_header Host $host;
#         proxy_set_header X-Real-IP $remote_addr;
#     }
#     location /elma {
#         alias  /home/www/flask_project/static/;
#     }
# }" >> web_demo

echo 'text' | sudo tee -a /etc/nginx/sites-available

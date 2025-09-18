#!/bin/bash

# Prepares then runs the server

echo ">>> Setting up the db for Django"
python manage.py migrate

echo ">>> Creating superuser if not exists"
python manage.py shell << EOF
from django.contrib.auth.models import User
if not User.objects.filter(username='admin').exists():
    User.objects.create_superuser('admin', 'admin@example.com', 'admin123')
    print('Superuser created: admin/admin123')
else:
    print('Superuser already exists')
EOF

echo ">>> Starting local server"
exec python manage.py runserver 0.0.0.0:3030

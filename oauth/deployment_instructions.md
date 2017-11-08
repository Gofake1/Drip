# Deployment Instructions

### CPanel
* Add subdomain
* Setup Python app
    - Python version: 2.7
    - App directory: drip
    - App domain/URI: drip.gofake1.net
    - Setup
* Edit existing application
    - WGI file location: drip.py
        + Displays as drip.py:application when you update the application
    - Add modules:
        + Flask
    - Update

### Configuration
* ID: 24dad3650cf344ab8eca674697394dd2
* Secret: a50ef2eab25a4e8cb85bc4eee3311f88
* Auth URL: https://api.instagram.com/oauth/authorize/?client_id=24dad3650cf344ab8eca674697394dd2&redirect_uri=https%3A%2F%2Fdrip.gofake1.net/auth&response_type=code&scope=basic+public_content+follower_list+comments+relationships+likes

### Structure
* drip/
    - passenger_wsgi.py - auto-generated
    - drip.py
    - public/ - auto-generated
    - tmp/ - auto-generated

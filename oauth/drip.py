from flask import Flask, redirect, render_template, request
import requests

ACCESS_TOKEN_URL = 'https://api.instagram.com/oauth/access_token'
CLIENT_ID = '24dad3650cf344ab8eca674697394dd2'
CLIENT_SECRET = 'a50ef2eab25a4e8cb85bc4eee3311f88'
REDIRECT_URI = 'https://drip.gofake1.net/auth'

app = Flask(__name__)
application = app # wsgi.application in passenger_wsgi.py

@app.route('/')
def index():
    return redirect('https://gofake1.net/projects/drip.html')

@app.route('/auth')
def auth():
    if request.args.has_key('code'):
        code = request.args.get('code')
        return render_template('auth_code.html', code=code)
    elif request.args.has_key('error'):
        error = request.args.get('error')
        if request.args.has_key('error_reason'):
            reason = request.args.get('error_reason')
        else:
            reason = 'No reason provided'
        if request.args.has_key('error_description'):
            description = request.args.get('error_description')
        else:
            description = 'No description provided'
        return render_template(
            'auth_error.html', 
            error=error, 
            reason=reason, 
            description=description)
    else:
        return redirect('https://gofake1.net/projects/drip.html')

@app.route('/auth/code/<string:code>')
def auth_code(code):
    form = {
        'client_id':CLIENT_ID,
        'client_secret':CLIENT_SECRET,
        'grant_type':'authorization_code',
        'redirect_uri':REDIRECT_URI,
        'code':code
    }
    r = requests.post(ACCESS_TOKEN_URL, data=form)
    return r.text

if __name__ == '__main__':
    app.run()

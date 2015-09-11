from demo.server import app
import os

# bind=os.environ['BIND']
bind=os.getenv('BIND','0.0.0.0')
port=os.getenv('PORT','5000')

app.run(host=str(bind), port=int(port), debug=True)

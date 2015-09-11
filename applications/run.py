from demo.server import app
import os

# bind=os.environ['BIND']
bind='0.0.0.0'
port=os.environ['PORT']

app.run(host=str(bind), port=int(port), debug=True)

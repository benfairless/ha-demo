import os
import multiprocessing

bind = ['0.0.0.0:5000']
workers = multiprocessing.cpu_count() * 2 + 1
threads = multiprocessing.cpu_count() * 2

chdir = os.path.dirname(os.path.realpath(__file__))
pidfile = '/tmp/ha-demo.pid'

accesslog = '/vagrant/tmp/access.log'
access_log_format = '%(h)s %(l)s %(s)s %(l)s %(r)s'

loglevel = 'info'
errorlog = '/vagrant/tmp/error.log'

raw_env = [ 'BACKEND_HOST=backend-00', 'BACKEND_PORT=80' ]

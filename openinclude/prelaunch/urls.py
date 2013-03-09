'''
Add all url patterns needed in Prelaunch app
'''
from django.conf.urls.defaults import (patterns, url)
from django.contrib.auth import views as auth_views

# Import our local imports here
from django.conf import settings

from views import *

urlpatterns = patterns('',
    url(r'^email/$', email, name="prelaunch-email"),
)
'''
Create your models here.
'''
from django.db import models
from djangosphinx import SphinxSearch

# import our local imports here
from member.models import Member

class UserSnippet(models.Model):
    member = models.ForeignKey(Member, related_name="UserSnippetMember")
    title = models.CharField(max_length=100)
    profile_url = models.URLField(verbose_name='Profile Url',
                             help_text='(Please provide your LinedIn profile url or Github url. Example: https://github.com/XXXX)')
    code_block = models.TextField()
    license_url = models.URLField(verbose_name='License Url')
    approved = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    
    
    def __unicode__(self):
        return u'%s - %s' % (self.member.github_username,
                                self.profile_url) 
    def get_absolute_url(self):
        from django.core.urlresolvers import reverse
        return reverse('view_snippet', kwargs={"snippet_id" : self.id })
    
    search = SphinxSearch(
           index ='snippets', 
           weights = { 
               'member': 100,
               'title': 80,
               'profile_url': 70,
               'code_block': 50,
               'license_url': 20,
           }
       )
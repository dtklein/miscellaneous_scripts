#!/usr/bin/env python

from bs4 import BeautifulSoup
from urlparse import *
import requests
import sys
import pdfkit
import re

#url = 'https://www.craigslist.org/about/best/bos/5237173491.html'
if (len(sys.argv) > 1):
    url = sys.argv[1]
else:
    url = input("Enter Craigslist article URL") 
url_bits = urlsplit(url)
if "craigslist" not in url_bits.netloc :
    sys.stderr.write("This only supports articles on craigslist at this time")
    sys.exit(1)
outstring = ''
soup = BeautifulSoup(requests.get(url).text)
title = soup.title.string.encode('utf-8')
print('Original Title: %s\n' % (title))
title = title.replace('best of craigslist: ','')
print('Title Minus \"Best of\": %s\n' % (title))
title = re.sub(' [-] ([mwt]+4[mwt]+)$',
    '',
    title
)
print('Title Minus Looking-for: %s\n' % (title))
title = re.sub('[ \t\n]',
    '_',
    title
)
print('Title: %s\n' % (title))
outstring = '%s<html><head><title>%s</title></head><body>' % (outstring,title)
article = soup.find("section", {"id": "postingbody"})
print('Article: %s\n' % (article))
first_line = re.compile('^([^.?!]+)[.?!]').match(article)
print('First Line: %s\n' % (first_line))
article = re.sub(r'^([^.?!\n]+[\.\?\!])\b', r'<span font-style: italic>\1</span>', article, 1)
outstring = '%s%s<div>Original source: <a href="%s">%s</a></div></body></html>' % (outstring,article,url,url)
pdfkit.from_string(BeautifulSoup(outstring, 'html.parser').prettify(), '%s.PDF' % (str.upper(title)))

print("finished converting %s\n" % (title))

#!/usr/bin/env python

from bs4 import BeautifulSoup
from urlparse import *
import requests
import sys
import pdfkit

url_list = []

outstring = "" 
if (len(sys.argv) > 1):
    url = sys.argv[1]
else:
    url = input("Enter Linux Journal article URL") 
url_bits = urlsplit(url)
if url_bits.netloc != "www.linuxjournal.com" and url_bits.netloc != "linuxjournal.com":
    sys.stderr.write("This only supports articles on www.linuxjournal.com at this time")
    sys.exit(1)
url_list.append(url)
soup = BeautifulSoup(requests.get(url).text)
title = soup.title.string.encode('utf-8')
outcss = ""
for CSS in soup.find_all("style"):
    outcss = "%s%s" % (outcss, CSS.prettify().encode('utf-8'))

outstring = '%s<html><head><title>%s</title>%s</head><body><h1>%s</h1>' % (outstring,title,outcss,title)

for page in soup.find("ul", {"class": "pager"}).find_all("li", {"class": "pager-item"}):
    found_url = page.find("a").get("href")
    fixed_url = urlunsplit([url_bits.scheme, url_bits.netloc, found_url,"",""])
    url_list.append(fixed_url)

for this_url in url_list:
    soup = BeautifulSoup(requests.get(this_url).text)
    for trash in soup.find_all("h1", {"class": "title"}):
        trash.decompose()
    for trash in soup.find_all("div", {"class": "facebook-like"}):
        trash.decompose()
    for trash in soup.find_all("div", {"class": "user-signature clear-block"}):
        trash.decompose()
    for trash in soup.find_all("ul", {"class": "links inline"}):
        trash.decompose()
    for trash in soup.find_all("ul", {"class": "pager"}):
        trash.decompose()
    for trash in soup.find_all("div", {"class": "terms terms-inline"}):
        trash.decompose()
    for trash in soup.find_all("div", {"class": "g-plusone-wrapper"}):
        trash.decompose()
    outstring = '%s%s' % (outstring, soup.find("div", {"id": "content"}).prettify().encode('utf-8'))

outstring = '%s</body></html>' % (outstring)
pdfkit.from_string(BeautifulSoup(outstring, 'html.parser').prettify(), '%s.PDF' % (title))

print "finished\n"

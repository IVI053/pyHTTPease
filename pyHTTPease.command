#!/usr/bin/python
import os
import posixpath #mm# only needed for parent back link
import BaseHTTPServer
import urllib
import cgi
import SocketServer
try:
  from cStringIO import StringIO
except ImportError:
  from StringIO import StringIO
from SimpleHTTPServer import SimpleHTTPRequestHandler

#mm# config section
cfg_hidescript = True
cfg_ip = '0.0.0.0' #mm# use 0.0.0.0 for all ifs and localhost for local only
cfg_port = 8000
cfg_showhidden = False
cfg_symlink_highlight = False
cfg_symlink_suffix = '@'
cfg_useimages = False

class RequestHandler(SimpleHTTPRequestHandler):

  def list_directory(self, path):
    """Helper to produce a directory listing (absent index.html).
    Return value is either a file object, or None (indicating an
    error).  In either case, the headers are sent, making the
    interface the same as for send_head().
    """
    
    try:
      list = os.listdir(path)
    except os.error:
      self.send_error(404, "No permission to list directory")
      return None
    list.sort(key=lambda a: a.lower())
    f = StringIO()
    displaypath = cgi.escape(urllib.unquote(self.path))
    f.write("<!DOCTYPE html>\n")
    f.write("<html>\n<head><title>pyHTTPease :: %s</title>\n" % displaypath)
    f.write("<link rel='icon' type='image/png' href='data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAA5xJREFUeNosU2tom2UUfr5LsqRN05imNU1bbcfWpE1pa6ezdZsmzHUTLGPqJogTmX80gogI+scJ/hLBC/jHfwpDRf3RjlGVaXVlG1tW2y5bXM3icm9uX/MlTZrbd3t9FzxweDkvPM855znnMDhyASzPglSbAMHpUafVNzNmHd3tMLXrdRyTSJelFX8gvXrpz3kpF/oESi4PtQyAYkiavpQAh8+be079/usHP6TUYEYmhQYhYp0QiRCiUM/T+Ks/8sT57JcZ6CePAVYKdFACQl/vAt/z8vK1D89vkdUUIcGsRu4IGtkQVLIWl0ggIZN/sgrZrBLybZCQkZPnasCgF9C1CPg2s/F9l7Nj2rhLhaQBisqApcSb0SwKebHVngYGalNCoriDrrExoyP+3Ln0jc/GaXqR73W0nzHqG8hpBoQpt5kF/lr2I7IRgbATxnZVgqLIMOg4rNxMwNztwJ6Jg31C8PtXKMEXvKWDc4TW/bhzM4Cs14t9jziRqdeRKobw+kvH4Q/noKoaxKIISQWktgF0WDuh03fOtAhoG0RTdUgm0vhZnEetOotumwNCsYxbmzswthnpdAhM7Qasr63jsQOTkLdrUKSdBxiGsfC1UiFn7x9+WJUZON1DMGUvw38lBU0jWJifh73/IXhnHqXJqEB0zq/qZqGY6zhxlt+/vIoDXLWmWvY+8bxnatgELXMdnKkLs097MTU+hpERJ3rtD6IhKRC3K4hFYzg2dBXeEx/BYmk32Iyxcb7+75WPg0s/Hnefnpu8W25i7pAL6WIdlZKIXDyM+GYGHKtCzwFvHLwHa48TvN4OW9/j4AOLfTydWyO79PnRb5I3Lo7sd08kt6qQ6Zalwrfx2vgibO4AFUnBfetyTMK1zwfIAtCIgmEIy+917wajkfzdjYVTA3NPhuKJJBz9/UgLRdjYNRw6uQi9lobWjIHIBQq+RQXUkI2vE1lGmH/m8BRYlqUlR+s/ffqO03PmbOjyxm207aLjIRr0zRWgHkbk718QSwotMQk4SDJZ+fqC9i5fKBQhSZLe53trYXBwyLUjc6WerevM8EDCnBPpCtZCrfL3jB6lzmLpt+9wxCc56RddO2yzorgFURRQKpV6CdG1adBZdA21kyllGIPBBCFzD816hXoNZZ0HRvMg/jd6OaTCTE9TNXkekUj0KUEQPBrLyV3QjBNWxcNysL35nt3Fo9JC1LVuvPB29EUKvETD/P1j+k+AAQCnnM5d6c7yVAAAAABJRU5ErkJggg=='>")
    f.write("<meta http-equiv='content-type' content='text/html; charset=UTF-8'>\n<style type='text/css'>\n")
    f.write("body {\n  background-color:#f0f0f0;\n  margin:22px 33px;\n  color:#000;\n}\n")
    f.write("h1 {\n  font:22px Georgia, serif;\n}\n")
    f.write("a:link {\n  text-decoration:none;\n  color:#3d8bbf;\n}\n")
    f.write("a:visited {\n  text-decoration:none;\n  color:#255473;\n}\n")
    f.write("a:hover, a:active {\n  text-decoration:none;\n  color:#f07d2c;\n}\n")
    f.write("table {\n  font:16px 'Courier New', Courier;\n  margin:3px 0;\n}\n")
    f.write("tr:hover {\n background-color:#e0e0e0;\n}\n")
    f.write("td.filesize {\n  color:#777;\n  padding-left:1em;\n  text-align:right;\n}\n")
    f.write("span.path {\n  font:16px 'Courier New', Courier;\n}\n")
    
    if cfg_useimages:
      f.write("span.ico {\n  line-height:16px;\n padding-left:22px;\n background-repeat:no-repeat;\n  background-position: left center;\n}\n")
      f.write("span.ico_file {\n  background-image:url(data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAQAAAC1+jfqAAAABGdBTUEAAK/INwWK6QAAABl0RVh0U29mdHdhcmUAQWRvYmUgSW1hZ2VSZWFkeXHJZTwAAAC4SURBVCjPdZFbDsIgEEWnrsMm7oGGfZrohxvU+Iq1TyjU60Bf1pac4Yc5YS4ZAtGWBMk/drQBOVwJlZrWYkLhsB8UV9K0BUrPGy9cWbng2CtEEUmLGppPjRwpbixUKHBiZRS0p+ZGhvs4irNEvWD8heHpbsyDXznPhYFOyTjJc13olIqzZCHBouE0FRMUjA+s1gTjaRgVFpqRwC8mfoXPPEVPS7LbRaJL2y7bOifRCTEli3U7BMWgLzKlW/CuebZPAAAAAElFTkSuQmCC);\n}\n")
      f.write("span.ico_folder {\n  background-image:url(data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABGdBTUEAAK/INwWK6QAAABl0RVh0U29mdHdhcmUAQWRvYmUgSW1hZ2VSZWFkeXHJZTwAAAGrSURBVDjLxZO7ihRBFIa/6u0ZW7GHBUV0UQQTZzd3QdhMQxOfwMRXEANBMNQX0MzAzFAwEzHwARbNFDdwEd31Mj3X7a6uOr9BtzNjYjKBJ6nicP7v3KqcJFaxhBVtZUAK8OHlld2st7Xl3DJPVONP+zEUV4HqL5UDYHr5xvuQAjgl/Qs7TzvOOVAjxjlC+ePSwe6DfbVegLVuT4r14eTr6zvA8xSAoBLzx6pvj4l+DZIezuVkG9fY2H7YRQIMZIBwycmzH1/s3F8AapfIPNF3kQk7+kw9PWBy+IZOdg5Ug3mkAATy/t0usovzGeCUWTjCz0B+Sj0ekfdvkZ3abBv+U4GaCtJ1iEm6ANQJ6fEzrG/engcKw/wXQvEKxSEKQxRGKE7Izt+DSiwBJMUSm71rguMYhQKrBygOIRStf4TiFFRBvbRGKiQLWP29yRSHKBTtfdBmHs0BUpgvtgF4yRFR+NUKi0XZcYjCeCG2smkzLAHkbRBmP0/Uk26O5YnUActBp1GsAI+S5nRJJJal5K1aAMrq0d6Tm9uI6zjyf75dAe6tx/SsWeD//o2/Ab6IH3/h25pOAAAAAElFTkSuQmCC);\n}\n")
      f.write("span.ico_parent {\n  background-image:url(data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAAidJREFUeNqkk7trVEEUxr+5+3ATd0NQN8FlVyUKJgELC9OYWKj/gKWNIhF0O0FttFK0sLJUbPwbDFgIFkJATWV8oQSMuioYdzdm33vndTxz7427hZAFp7kz557fd74zD0FEGHRceXFxyWir7s49mN2MeYPCl59feJ2Nj89kk2NHi0/OvNqMi60cXH1ZTFpj3zN4YF96AtZafKx8wNdKaUVJdSjuklYeH1lOjUxPC9FviOA3Pn1D+uB3bSivPQNtNSxZDMWGIbtyDwssxEMb3mRh9mFCCOG4AAbPdbcycWn5Rp4SoJvVEvLpAgw7+Lz2BSdj1Vvz5xZvBwLQ1IWV2/yf92BkjHdmhPkMUrkTyM3cSYLblI/moYxhBwbl9TKOZeVpJiMBJTyykmHOtQTbKUG11tD89QyJ1G42pCB9yQIqEGD7HLN7HRqPtjJjdQeyzXHZgmrUkZk8i9TOKfczaOnajncY3T7KZizmxo8DS8XhnoDyEB8aw+jUeV5YOMvsg7v6Ab3xFGRq2K9roEqd503k8tex6pPXJ8CA4W1ovwmSyTRAegNW/Q7WrBLFnUCLC/jMhGcVCviuJT4iVWawFiY7KJiziK5HcChApAOmJyCJOzWcuB6BUcW/Yo0ebLthm7pPgKS1ul0VqpkUsBmukID7gnYx5EpJkBd+hbtQnY5jqCfQ9RdW7586zDtXYCv/fB8quvHu5mssgo/g7UBvYavh4T/HHwEGADlsWXOjVQPaAAAAAElFTkSuQmCC);\n}\n")
      f.write("span.ico_image {\n  background-image:url(data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABGdBTUEAAK/INwWK6QAAABl0RVh0U29mdHdhcmUAQWRvYmUgSW1hZ2VSZWFkeXHJZTwAAAIcSURBVDjLjZO/T1NhFIafc+/trdRaYk1KUEEWjXHRaCSik+E/cDHGzYXB2YHRhMRFY1SYmRgYHZ3VxIRFDYMraMC2hrbQXm7v9+M4UGobiOEk7/adN+9zvnNEVQEQkYvAGBDy/6oBm6rqAVBVeia30jRtGmOctVaPU5qmuri4+AaYAgJVHTKYNsa4drutnU6nr1arpY1GQ6vVqlprdXt7W5eWlvomMv/uw6tSofB4p+NOF0biYtc48tEAhXiuTZzh/s1xyuUyWZbhvWdlZeXt3Nzca14sf6zW6nXf7uzrcfq9s6sLy5+1Xq8fQQKmo1ZCvlAoyo+tXT5tPGO09IckM2zWznH3/AJ3rl5ACInjmGazifceay2VSgWASISSBaz3FIs1RnJlPF18vEG1keDVk1lLFEWICM45wvAfYqTKriqje0lGI01x2qFtuuwkKQ26oEKcCwnDEBFBRA6HfmBw8JWwl3o2ti7j8+u0TUKzcYkrY/n+wyAIEJEjSxEglLyH5r7j+tg8T1oVZr8GzE69JIoiFMiM7zeHYUgQBAMJVBGU77+eYoxhLcvIxnNk6w8xxvDo3hqH+yIieO+HEkQB/qe6bPL5g/cckCkDiBhjOJULhlCGDJIkXX2z+m3GeW4UCnExyxxxHIIOLNLk2WP5AaQXTYDb1tovgHCy8lEUzQS9g1LAO+f2AX+SZudcAjgZOOeJ3jkHJ0zggNpfYEZnU63wHeoAAAAASUVORK5CYII=);\n}\n")
      f.write("span.ico_archive {\n  background-image:url(data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAQAAAC1+jfqAAAABGdBTUEAAK/INwWK6QAAABl0RVh0U29mdHdhcmUAQWRvYmUgSW1hZ2VSZWFkeXHJZTwAAAEUSURBVCjPXdFNSsMAEIbh0Su4teAdIgEvJB5C14K4UexCEFQEKfivtKIIIlYQdKPiDUTRKtb0x6ZJ+volraEJ3+zmycwkMczGzTE3lwkbxeLE5XTqQfTIjhIm6bCy9E/icoOoyR4v7PLDN+8ibxQHxGzE3JBfHrgUalDnQ6BNk1WRFPjs66kDNTxqg0Uh5qYg4IkrjrS9pTWfmvKaBaGaNU4EY+Lpkq88eKZKmTAhbd3i5UFZg0+TzV1d1FZy4FCpJCAQ8DUnA86ZpciiXjbQhK7aObDOGnNsUkra/WRAiQXdvSwWpBkGvQpnbHHMRvqRlCgBqkm/dd2745YbtofafsOcPiiMTc1fzNzHma4O/XLHCtgfTLBbxm6KrMIAAAAASUVORK5CYII=);\n}\n")
      f.write("span.ico_text {\n  background-image:url(data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAQAAAC1+jfqAAAABGdBTUEAAK/INwWK6QAAABl0RVh0U29mdHdhcmUAQWRvYmUgSW1hZ2VSZWFkeXHJZTwAAADoSURBVBgZBcExblNBGAbA2ceegTRBuIKOgiihSZNTcC5LUHAihNJR0kGKCDcYJY6D3/77MdOinTvzAgCw8ysThIvn/VojIyMjIyPP+bS1sUQIV2s95pBDDvmbP/mdkft83tpYguZq5Jh/OeaYh+yzy8hTHvNlaxNNczm+la9OTlar1UdA/+C2A4trRCnD3jS8BB1obq2Gk6GU6QbQAS4BUaYSQAf4bhhKKTFdAzrAOwAxEUAH+KEM01SY3gM6wBsEAQB0gJ+maZoC3gI6iPYaAIBJsiRmHU0AALOeFC3aK2cWAACUXe7+AwO0lc9eTHYTAAAAAElFTkSuQmCC);\n}\n")
      
    f.write("</style>\n</head>\n<body>\n<h1>pyHTTPease</h1>\n")
    
    # path-link construction
    f.write("<span class='path'><a href='/'>/</a>")
    foo = displaypath.split('/')
    bar = '/'
    for foobar in foo:
      if foobar is not '':
        bar = bar + foobar + '/'
        f.write("<a href='%s'>%s/</a>" % (bar, foobar))
    
    f.write("</span><br>\n<hr>\n<table border='0'>\n")
    f.write("<tr>")
    if not cfg_useimages: f.write("<th>&nbsp;</th>")
    f.write("<th align='left'>Filename</th><th align='center'>Size</th></tr>\n")
    if displaypath != "/":
      if cfg_useimages: f.write("<tr><td><a href='%s'><span class='ico ico_parent'>[parent dir]</span></a></td><td>&nbsp;</td></tr>\n" % posixpath.split(posixpath.split(displaypath)[0])[0])
      else: f.write("<tr><td align='center'>&#x25B2;</td><td><a href='%s'>[parent dir]</a></td><td>&nbsp;</td></tr>\n" % posixpath.split(posixpath.split(displaypath)[0])[0])
    for name in list:
      
      #mm# hide . hidden files
      if name.startswith('.') and not cfg_showhidden: continue
      
      #mm# hide script
      if name.startswith(os.path.split(os.path.realpath(__file__))) and cfg_hidescript: continue
      
      fullname = os.path.join(path, name)
      displayname = linkname = name
      
      #mm# file size
      filesize = os.path.getsize(fullname)
      if filesize < 1000:
        unit = ' &nbsp;B'
        divider = 1
      elif filesize < 1000000:
        unit = ' KB'
        divider = 1000
      elif filesize < 1000000000:
        unit = ' MB'
        divider = 1000000
      else:
        unit = ' GB'
        divider = 1000000000
      filesize_str = str("{0:.2f}".format(float(filesize)/divider)) + unit
      
      # File type detection
      if name.endswith('.zip'): filetype = 'archive'
      elif name.endswith('.bz2'): filetype = 'archive'
      elif name.endswith('.7z'): filetype = 'archive'
      elif name.endswith('.gz'): filetype = 'archive'
      elif name.endswith('.rar'): filetype = 'archive'
      elif name.endswith('.png'): filetype = 'image'
      elif name.endswith('.jpg'): filetype = 'image'
      elif name.endswith('.gif'): filetype = 'image'
      elif name.endswith('.txt'): filetype = 'text'
      elif name.endswith('.cfg'): filetype = 'text'
      else: filetype = 'file'
      
      if not cfg_useimages: entrysymbol = '&#x25A1;'
      # Append / for directories or @ for symbolic links
      if os.path.isdir(fullname):
        displayname = name + "/"
        linkname = name + "/"
        #mm#
        filesize_str = '--'
        filetype = 'folder'
        if not cfg_useimages: entrysymbol = '&#x25A0;'
      if os.path.islink(fullname) and cfg_symlink_highlight:
        displayname = name + cfg_symlink_suffix
        # Note: a link to a directory displays with @ and links with /
      if cfg_useimages:
        f.write('<tr><td><a href="%s"><span class="ico ico_%s">%s</span></a></td><td class="filesize">%s</td></tr>\n'
          % (urllib.quote(linkname), filetype, cgi.escape(displayname), filesize_str))
      else:
        f.write('<tr><td>%s</td><td><a href="%s">%s</a></td><td class="filesize">%s</td></tr>\n'
          % (entrysymbol, urllib.quote(linkname), cgi.escape(displayname), filesize_str))

    f.write("</table>\n<hr>\n</body>\n</html>\n")
    length = f.tell()
    f.seek(0)
    self.send_response(200)
    self.send_header("Content-type", "text/html")
    self.send_header("Content-Length", str(length))
    self.end_headers()
    return f

os.chdir(os.path.dirname(os.path.realpath(__file__))) #mm# only needed when run as .command under OS X
httpd = SocketServer.ThreadingTCPServer((cfg_ip, cfg_port), RequestHandler)
print "Serving HTTP on " + str(cfg_ip) + ":" + str(cfg_port)
httpd.serve_forever()

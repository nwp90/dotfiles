#!/usr/bin/env python
# -*- coding: utf-8
# vim: set fileencoding=utf-8

# Copyright 2008-2009 Thomas Capricelli <orzel@freehackers.org>
# mercurial extension released under the GNU General Public Licence (GPLv2)

#
# To use this extension, add something like this to your ~/.hgrc :
#
# activity=/home/orzel/hg/hgactivity/activity.py
#
# (using the atual path, of course)
#
# will appear in 'hg --help'
'''create an image file displaying the activity of the current repository'''

from mercurial import demandimport, patch, util
from mercurial.templatefilters import person

demandimport.ignore.extend([
        'matplotlib',
        'matplotlib.dates',
        'matplotlib.ticker',
        'matplotlib.units',
        'matplotlib.collections',
        'matplotlib.axis',
        'matplotlib.pyplot',
        'matplotlib.contour',
        'pkg_resources',
        'resource_stream',
        ])

# demandimport is evil, breaks everything, is impossible to fix, nobody
# will help you on irc, and it will probably try to eat your children as
# well. Disable it.
demandimport.disable()

import re
import datetime
from mercurial.i18n import gettext as _
from mercurial import hg
from mercurial.node import short, hex


class Options:
    pass

#
# Extension callback
#
def activity(ui, repo, **opts):
    # The doc string below will show up in 'hg activity --help'
    """
    Create a file called activity.png displaying the activity of the current
    repository

    By default, the activity is computed using the number of commits. There
    is an option to consider instead the number of lines modified in the
    changesets (--uselines).

    Most options are self explanatory.
    The map file format used to specify aliases is fairly simple:
    <alias name>; <actual name>
    This file is only used when displaying 'splitted' activity.

    The name listed after the option --exclude are those found in the
    mercurial repository. That is, before the map file is applied.
    """

    cl = repo.changelog

    # parse options
    options = Options()

    options.split = opts.get('splitauthors')
    options.filename = opts.get('filename')
    options.width = opts.get('width')
    options.height = opts.get('height')
    options.skipmerges = opts.get('skipmerges')
    options.maxauthors = opts.get('maxauthors')
    options.uselines = opts.get('uselines')
    options.hidetags = opts.get('hidetags')
    options.repo = repo
    if opts.get('datemin'):
        options.datemin = datetime.datetime.strptime(opts.get('datemin'), '%Y-%m-%d')
    else:
        options.datemin = None
    if opts.get('datemax'):
        options.datemax = datetime.datetime.strptime(opts.get('datemax'), '%Y-%m-%d')
    else:
        options.datemax = None
    if hasattr(cl,'count'):
        options.length = cl.count() # mercurial 1.0.2 and previous
    else:
        options.length = len(cl) # mercurial crew as of today (2008-10-31)
    exclude = opts.get('exclude')
    if exclude:
        options.exclude = exclude.split(',')
    else:
        options.exclude = []

    print "There are %d changesets" % options.length

    # handle aliases
    options.amap = {}
    aliases = opts.get('aliases')
    if aliases:
        from os import path
        if path.exists(aliases):
            try:
                for l in open(aliases, "r"):
                    l = l.strip()
                    alias, actual = l.split()
                    options.amap[alias.strip()] = actual.strip()
            except:
                print "Some problem was found parsing the alias file '%s', check it. Meanwhile it is ignored." % aliases
        else:
            print "Alias file '%s' does not exist, ignored." % aliases

    # do it
    dates_tab = collect_data(cl,options)
    if len(dates_tab)<1:
        print "No data available with those option"
        exit(1)
    if options.hidetags:
        tags= []
    else:
        tags =  map_tags(repo, options)
    draw_graph(options, dates_tab, tags)

    print "Created the file '%s'" % options.filename

cmdtable = {
    # cmd name        function call
    "activity": (activity,
                 # see mercurial/fancyopts.py for all of the command
                 # flag options.
                 [
                 ('o', 'filename', 'activity.png', _('name of the file created')),
                 ('', 'width', 800, _('Width of the graph in pixels')),
                 ('', 'height', 600, _('Height of the graph in pixels')),
                 ('', 'datemin', '', _('Start date of the graph (yyyy-mm-dd)')),
                 ('', 'datemax', '', _('End date of the graph (yyyy-mm-dd)')),
                 ('', 'splitauthors', None, _('Display a different graph for every author')),
                 ('', 'maxauthors', 4, _('Maximum number of authors displayed')),
                 ('', 'exclude', '', _('Comma-separated list of authors to ignore (for both global and splitted activity)')),
                 ('', 'aliases', '', _('file with email aliases')),
                 ('', 'skipmerges', False, _('Do not consider merge commits')),
                 ('', 'uselines', False, _('Use the number of lines modified instead of the number of commits')),
                 ('', 'hidetags', False, _('Does not display the tags on the X axis')),
                 ],
                 "hg activity [OPTION]... ")
}

def map_tags(repo, options):
    tags= []
    for tagname, rev in repo.tags().items():
        if tagname=='tip': continue
        date = datetime.datetime.fromtimestamp( repo.changectx(rev).date()[0])
        if options.datemin!=None and date<options.datemin:
            continue
        if options.datemax!=None and date>options.datemax:
            continue
        tags.append((date,tagname))
    tags.sort()
    return tags

def changedlines(repo, rev):
    # get context
    ctx = repo.changectx(rev)
    # get parents
    parents = ctx.parents()
    if len(parents)!=1: return 0 # merge
    lines = 0
    diff = ''.join(patch.diff(repo, parents[0].node(), ctx.node()))
    for l in diff.split('\n'):
        if (l.startswith("+") and not l.startswith("+++ ") or
            l.startswith("-") and not l.startswith("--- ")):
            lines += 1
#    print "changedlines : %d lines" % lines
    return lines


def collect_data(cl,options):
    data = {}
    namemap = {}
    if not options.split:
        data["Overall activity"] = {}
    localactivity = 1
    # starting with mercurial 1.1, this could be simplified by iterating in cl directly
    for i in xrange(options.length):
        node = cl.read(cl.node(i))
        # Check whether the number of changed files == 0
        if options.skipmerges and len(node[3]) == 0:
        	continue # Skip merges
        # find out date and filter
        date = datetime.datetime.fromtimestamp(node[2][0])
        if options.datemin!=None and date<options.datemin:
            continue
        if options.datemax!=None and date>options.datemax:
            continue
        # find out who this is
        who = node[1]
        email = util.email(who)
        namemap[email] = person(who)
        if email in options.exclude:
            continue
        if options.uselines:
            localactivity = changedlines(options.repo, i)
        if options.split:
            # data is dictionnary mapping an author name to the data for
            # this author
            email = options.amap.get(email, email) # alias remap
            if not data.has_key(email):
                data[email] = {}
            data[email][date] = localactivity
        else:
            # data only contains one entry for the global graphic
            data["Overall activity"][date] = localactivity
    options.namemap = namemap
    return data

def convolution(datemin,datemax,data):
    date = datemin
    # convolution window
    wmin = wmax = 0
    # you can play with this number to have a more or less smooth curve
    number = 1000 # number of points we want to compute
    period = (datemax-datemin)/number # period at which we compute a value
    wperiod = period * 25 # length of the convolution window
    wperiodsec= (wperiod.days*24*3600)+wperiod.seconds
    dates, values = [], [] # return values
    mydates = data.keys()
    mydates.sort()
    length=len(mydates)
    for x in xrange(number):
        date += period
        while wmin<length and mydates[wmin]<date-wperiod:
            wmin+=1
        while wmax<length and mydates[wmax]<date+wperiod:
            wmax+=1
        value = 0.
        for a in range(wmin,wmax):
            delta = mydates[a]-date
            deltasec= abs((delta.days*24*3600)+delta.seconds)
            value+=data[mydates[a]]-float(deltasec)/float(wperiodsec)
        values.append(value)
        dates.append(date)
    return dates, values

def draw_graph(options, dates_tab, tags):
    try:
        import matplotlib.pyplot as plt
        import matplotlib.dates as pl_dates
        import matplotlib
    except:
        print "You need matplotlib in your python path for this program to work"
        exit(1)
    years    = pl_dates.YearLocator()   # every year
    months   = pl_dates.MonthLocator()  # every month
    days = pl_dates.DayLocator()  # every month
    yearsFmt = pl_dates.DateFormatter('%Y')
    monthsFmt = pl_dates.DateFormatter("%b '%y")
    daysFmt = pl_dates.DateFormatter("%d %b")
    mondays  = pl_dates.WeekdayLocator(pl_dates.MONDAY)


    datemin = options.datemin
    if datemin is None:
        datemin = min([min(d.keys()) for d in  dates_tab.values()])
    datemax = options.datemax
    if datemax is None:
        datemax = max([max(d.keys()) for d in  dates_tab.values()])
    period = datemax-datemin
    if period.days<3:
        datemin -= datetime.timedelta(2)
        datemax += datetime.timedelta(2)
        datemax = datemax-datemin
    else:
        datemin -= period/20 # 5%
        datemax += period/20 # 5%

    # print "using date min/max: ", datemin, datemax
    # compare contributions
    contribs = dates_tab.keys()
    contribs.sort(key= lambda k : -len(dates_tab[k]))
    print "%d committers" % len(contribs)
    contribs=contribs[0:min(len(contribs),max(5,options.maxauthors))] # only keeps the best ones for display

    # create plot
    fig = plt.figure()
    ax = fig.add_subplot(111)

    # all graph displayed, maxauthor applies only to the legend
    for author in contribs:
        dates, values = convolution(datemin, datemax, dates_tab[author])
        ax.plot( dates, values, label=options.namemap.get(author, author) )

    # display tags
    tagypos = 0
    for date, name in tags:
        ax.plot_date([date], [00], 'ro')
#        ax.plot([date.toordinal()], [0], 'bo')
        ax.text(date.toordinal(), 0, name,
        withdash=True, dashdirection=0, dashlength=50+tagypos, rotation='horizontal', dashrotation='vertical')
        tagypos += 20
        if tagypos>90:
            tagypos=0

    ax.text(124, 10, "coucou", withdash=True)
    # format the ticks
    if (datemax-datemin).days>600:
        ax.xaxis.set_major_locator(years)
        ax.xaxis.set_major_formatter(yearsFmt)
        ax.xaxis.set_minor_locator(months)
    elif (datemax-datemin).days>30:
        ax.xaxis.set_major_locator(months)
        ax.xaxis.set_major_formatter(monthsFmt)
        ax.xaxis.set_minor_locator(mondays)
    else:
        ax.xaxis.set_major_locator(days)
        ax.xaxis.set_major_formatter(daysFmt)

    ax.set_xlim(datemin,datemax)

    # format the coords message box
    ax.format_xdata = pl_dates.DateFormatter('%Y-%m-%d')
    ax.format_ydata = None
    ax.grid(True)

    # rotates and right aligns the x labels, and moves the bottom of the
    # axes up to make room for them
    fig.autofmt_xdate()
    if options.width<50: options.width=50
    if options.height<30: options.height=30
    fig.set_dpi(100)
    fig.set_size_inches(options.width/100.0,options.height/100.0)

    if len(dates_tab)<=options.maxauthors:
        plt.legend(loc='best', shadow=True)
    else:
        plt.legend(contribs[0:options.maxauthors], loc='best', shadow=True)
    plt.savefig(options.filename)

# vim: ai ts=4 sts=4 et sw=4

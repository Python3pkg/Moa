#!/usr/bin/env python
#
# Copyright 2009 Mark Fiers
# Plant & Food Research
#
# This file is part of Moa - http://github.com/mfiers/Moa
#
# Moa is free software: you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free
# Software Foundation, either version 3 of the License, or (at your
# option) any later version.
#
# Moa is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
# or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public
# License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Moa.  If not, see <http://www.gnu.org/licenses/>.
#
import sys
import logging

l = logging.getLogger('moa')
handler = logging.StreamHandler()
logmark = chr(27) + '[0;44mU' + \
          chr(27) + '[0m ' 

formatter = logging.Formatter(
    logmark + '%(message)s')

handler.setFormatter(formatter)
l.addHandler(handler)

l.setLevel(logging.INFO)

def exitError(message):
    l.fatal(message)
    sys.exit(-1)

def setVerbose():
    l.setLevel(logging.DEBUG)



#!/usr/bin/python

# Convert CppMT output to a  frame, x, y, w, h  format
# Note that we require 0 rotation of the bounding box
############################################################################
#
# Acknowledgements
#
# The IDInteraction Processing Pipelines were developed in the IDInteraction project, funded by the Engineering and Physical Sciences Research Council, UK through grant agreement number EP/M017133/1.
# Licence
#
# Copyright (c) 2015, 2016 The University of Manchester, UK.
#
# Licenced under LGPL version 2.1. See LICENCE for details.
#
# Author: David Mawdsley

import pandas as pd
import sys

inFileName = sys.argv[1]
outFileName = sys.argv[2]

cppMTdata = pd.read_csv(inFileName, sep = ",",
names = ["frame", "time", "actpt", "bbcx", "bbcy", \
    "bbw","bbh","bbrot","bbv1x","bbv1y","bbv2x","bbv2y", \
    "bbv3x", "bbv3y", "bbv4x","bbv4y"], skiprows=1)

if cppMTdata.bbrot[0] != 0.0 or not(max(cppMTdata.bbrot) == min(cppMTdata.bbrot)):
    print "Bounding box rotation must be 0 for all frames"
    quit()

outdata = pd.DataFrame({'frame' : cppMTdata.frame,
                        'x' : cppMTdata.bbv2x,
                        'y' : cppMTdata.bbv2y,
                        'w' : cppMTdata.bbv4x - cppMTdata.bbv2x,
                        'h' : cppMTdata.bbv4y - cppMTdata.bbv2y})

outdata.to_csv(outFileName)

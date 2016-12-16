#!/usr/bin/python

# Obtain a single bounding box for each frame, given several bounding boxes
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

# TODO Handle input arguments better.  Want 1 output file >=1 input file
# Will also need to handle both opencv and CppMT formats
# TODO eventually - detect outlier bboxes, extrapolate where bb missing etc.

import numpy as np
import pandas as pd
import sys, getopt

infile = sys.argv[1]
outfile = sys.argv[2]

print "Reading from: " + infile
print "Outputting to: " + outfile

# TODO get datatypes working in docker container
boxdata = pd.read_csv(infile, sep = ",", header = None, \
    names = ["frame", "x","y","w","h","classifier"]) #, \
    #dtype = {'frame':np.int32, 'x':np.float_, 'y':np.float_, 'w':np.float_, \
    #'h':np.float_})

grouped = boxdata[['x', 'y', 'w', 'h']].groupby(boxdata['frame'])

meanbox = grouped.mean()

meanbox.to_csv(outfile)

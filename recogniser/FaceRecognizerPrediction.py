#!/usr/bin/python

# Use ground truth data and FaceRecognizer to train and predict for each participant

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

import cv2
import pandas as pd
import numpy as np
import sys
import time
start_time = time.time()

WINDOW_NAME = "FaceClassify"

def get_attention(time, annotationdata):
    # Return the attention at time time, given in ms
    earliertimes =annotationdata.ix[annotationdata.ms <= time]

    attention = earliertimes["attentionnum"].iloc[-1]

    return(attention)

def scale_images(images, scaleto):
    scaled_images = []


    # Scale all images to this size
    for img in images:
        scaled = cv2.resize(img, scaleto)
        scaled_images.append(scaled)

    return scaled_images

#cv2.namedWindow(WINDOW_NAME)


video = cv2.VideoCapture(sys.argv[1])
boundingboxes = pd.read_csv(sys.argv[2], sep = ",")
groundtruth = pd.read_csv(sys.argv[3], sep = ",", \
        names = ["ms", "ipad", "tv", "elsewhere", "attentionlocation"], \
        skiprows = 1)
skiptime = int(sys.argv[4]) # in ms
trainingtime_min = float(sys.argv[5]) # In minutes.  FROM EXPRIMENT TIME
classifier = sys.argv[6]
outfile = sys.argv[7]
# Make groundtruth attention categorial and get numerical equivalent
# (need ints for OpenCV interface)
groundtruth['attentionlocation'] = groundtruth['attentionlocation'].astype('category')
groundtruth['attentionnum'] = groundtruth['attentionlocation'].cat.codes



# TODO Will need to compare performance of the various FaceRecognizers

if classifier == "LBPH":
    facerecog = cv2.createLBPHFaceRecognizer()
elif classifier == "Eigen":
    facerecog = cv2.createEigenFaceRecognizer(num_components=60)
elif classifier == "Fisher":
    facerecog == cv2.createFisherFaceRecognizer(0)
else:
    print "Unrecognised FaceRecognizer: " + classifier
    quit()


# Get training time on same timeline and units as video
trainingtime = trainingtime_min*60*1000 + skiptime

# Ground truth data starts when the experiment starts.   So we add the
# skiptime to each timestamp
groundtruth.ms = groundtruth.ms + skiptime

video.set(cv2.cv.CV_CAP_PROP_POS_MSEC, skiptime)
frame = video.get(cv2.cv.CV_CAP_PROP_POS_FRAMES)
frametime = video.get(cv2.cv.CV_CAP_PROP_POS_MSEC)
got, img = video.read()
# Train the classifier
# We may not have a face for each frame.  May make more sense to loop over
# boundingboxes rather than "play" the video?? (may be slower to decode though?
# presumably format isn't optimised for random access?)

training_data = []
training_data_labels = []

test_data = []
test_data_labels = []
print "Loading data"
while got:

    bbox = boundingboxes.ix[boundingboxes.frame == frame]
    if not bbox.empty:
        face = img[int(bbox.y):int(bbox.y+bbox.h), int(bbox.x):int(bbox.x+bbox.h)]
#        cv2.imshow(WINDOW_NAME, face)
#        if cv2.waitKey(1) & 0xFF == ord('q'):
#            break
        grey = cv2.equalizeHist(cv2.cvtColor(face, cv2.COLOR_BGR2GRAY))
        if frametime <= trainingtime:
            training_data.append(grey)
            training_data_labels.append(get_attention(frametime, groundtruth))
        else:
            test_data.append(grey)
            test_data_labels.append(get_attention(frametime, groundtruth))

    got, img = video.read()
    frame = video.get(cv2.cv.CV_CAP_PROP_POS_FRAMES)
    frametime = video.get(cv2.cv.CV_CAP_PROP_POS_MSEC)

print("Loaded data")
print("--- %s seconds ---" % (time.time() - start_time))


# Need to make all the images the same size.
# TODO Think about how to handle this when the bbox isn't square (e.g. CppMT)

print "Scaling data"
maxtrain = max(img.shape for img in training_data)
maxtest = max(img.shape for img in test_data)

print maxtrain
print maxtest


scaled_images = scale_images(training_data, max(maxtrain, maxtest))
tdl = np.asarray(training_data_labels).astype("int")
print "Scaled data"
print("--- %s seconds ---" % (time.time() - start_time))


print "Training classifier"
facerecog.train(scaled_images, tdl)

predictions = []
confidences = []
print "Trained classifier with " + str(len(scaled_images)) + " frames"
print np.bincount(tdl)

print("--- %s seconds ---" % (time.time() - start_time))
print "Predicting"
for img, truth in zip(test_data, test_data_labels):
    pred, conf = facerecog.predict(img)
    predictions.append(pred)
    confidences.append(conf)

d = {'truth' : test_data_labels, \
    'pred' : predictions, \
    'confidence' : confidences}

results = pd.DataFrame(d)
results.to_csv(outfile)

print "All done"
print("--- %s seconds ---" % (time.time() - start_time))

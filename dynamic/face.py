#!/usr/bin/python

import cv2
import os
import csv
import sys
import pandas as pd

WINDOW_NAME = 'Detection'


cascadeFolder = '/usr/share/opencv/haarcascades/'

face_cascades_files = ['haarcascade_frontalface_default.xml', \
                'haarcascade_frontalface_alt.xml', \
                'haarcascade_frontalface_alt2.xml', \
                'haarcascade_frontalface_alt_tree.xml' ]

cols = ["frame", "x", "y", "w", "h", "cf"]

face_cascades_colours = [(255,0,0), (0,255,0), (0,0,255), (255,255,255)]

cascadeClassifiers = list()

for c in face_cascades_files:
    classifier = cv2.CascadeClassifier(cascadeFolder + c)
    if classifier.empty():
        print  "Could not load classifier: " + cascadeFolder + c
        quit()
    cascadeClassifiers.append(classifier)


print "loaded " + str(len(cascadeClassifiers)) + " cascade classifiers"

video = cv2.VideoCapture(sys.argv[1])

cv2.namedWindow(WINDOW_NAME)


if(len(sys.argv)==4):
    print >> sys.stderr, ("Skipping " + sys.argv[3] + " ms")
    video.set(cv2.cv.CV_CAP_PROP_POS_MSEC, int(sys.argv[3]))


got, img = video.read()
ox = 0
oy = 0
ow, oh, _ = img.shape
#print ox, oy, ow, oh

results = []

while got:
    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)

    # from facedetect.py example TODO - try this
    gray = cv2.equalizeHist(gray)

    frame = video.get(cv2.cv.CV_CAP_PROP_POS_FRAMES)

    for (cc, cf, bc) in zip(cascadeClassifiers, face_cascades_files, face_cascades_colours):
        faces = cc.detectMultiScale(gray, 1.3, 5)
        for (x, y, w, h) in faces:
            x_w = x + w
            y_h = y + h
            cv2.rectangle(img, (x, y), (x_w, y_h), bc, 1)
            roi_gray = gray[y:y_h, x:x_w]

            results.append((frame, x, y, w, h, cf))


    cv2.imshow(WINDOW_NAME, img)

    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

    got, img = video.read()




pdresults = pd.DataFrame(results )

pdresults.to_csv(sys.argv[2], index=False, header=False )
video.release()
cv2.destroyAllWindows()

#!/usr/bin/python

import cv2
import os
import csv
import sys


#WINDOW_NAME = 'Detection'


face_cascade = cv2.CascadeClassifier('/usr/share/opencv/haarcascades/haarcascade_frontalface_alt2.xml')
#face_cascade = cv2.CascadeClassifier('/usr/share/opencv/lbpcascades/lbpcascade_frontalface.xml')
#eye_cascade = cv2.CascadeClassifier('/usr/share/opencv/haarcascades/haarcascade_eye.xml')
#eye_cascade = cv2.CascadeClassifier('/usr/share/opencv/haarcascades/haarcascade_eye_tree_eyeglasses.xml')
eye_cascade = cv2.CascadeClassifier('/usr/share/opencv/haarcascades/haarcascade_mcs_eyepair_small.xml')
#video = cv2.VideoCapture('/opt/windows/idi-test/star_jump.mp4')
#video = cv2.VideoCapture('/mnt/IDInteraction/dual_screen_free_experiment/video/experiment2_individual_streams/high_quality/front/P01_video.mp4')

print sys.argv[1:3]

video = cv2.VideoCapture(sys.argv[1])

#cv2.namedWindow(WINDOW_NAME)

facecsvfile = open(sys.argv[2], 'w')
facewriter = csv.writer(facecsvfile)

eyecsvfile = open(sys.argv[3], 'w')
eyewriter = csv.writer(eyecsvfile)

got, img = video.read()
ox = 0
oy = 0
ow, oh, _ = img.shape
#print ox, oy, ow, oh
frame = 0
while got:
    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    gray_sm = gray[oy:oh, ox:ow]
    #print gray_sm.shape
    frame = frame + 1
    print frame

    faces = face_cascade.detectMultiScale(gray_sm, 1.3, 5)
    for (x, y, w, h) in faces:
        x_w = x + w
        y_h = y + h
        cv2.rectangle(img, (x, y), (x_w, y_h), (255, 0, 0), 1)
        roi_gray = gray[y:y_h, x:x_w]

        facewriter.writerow([frame, x, y, w, h])

        eyes = eye_cascade.detectMultiScale(roi_gray)

        for (ex, ey, ew, eh) in eyes:
            cv2.rectangle(img, (x + ex, y + ey), (x + ex + ew, y + ey + eh), (0, 255, 0), 1)
            eyewriter.writerow([frame, ex, ey, ew, eh])

#    cv2.imshow(WINDOW_NAME, img)



 #   if cv2.waitKey(1) & 0xFF == ord('q'):
 #       break

    got, img = video.read()

video.release()
cv2.destroyAllWindows()
facecsvfile.close()

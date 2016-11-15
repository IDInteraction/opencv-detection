import cv2

body_cascade = cv2.CascadeClassifier('/usr/share/opencv/haarcascades/haarcascade_mcs_upperbody.xml')
#video = cv2.VideoCapture('/opt/windows/idi-test/star_jump.mp4')
video = cv2.VideoCapture('/opt/windows/idi-test/P01_video.mp4')

while True:
    _, img = video.read()
    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)

    bodies = body_cascade.detectMultiScale(gray, 1.3, 5)
    for (x,y,w,h) in bodies:
        cv2.rectangle(img,(x,y),(x+w,y+h),(255,0,0),2)

    cv2.imshow('img', img)
    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

video.release()
cv2.destroyAllWindows()

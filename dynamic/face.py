import cv2

WINDOW_NAME = 'Detection'

face_cascade = cv2.CascadeClassifier('/usr/share/opencv/haarcascades/haarcascade_frontalface_alt2.xml')
#face_cascade = cv2.CascadeClassifier('/usr/share/opencv/lbpcascades/lbpcascade_frontalface.xml')
#eye_cascade = cv2.CascadeClassifier('/usr/share/opencv/haarcascades/haarcascade_eye.xml')
eye_cascade = cv2.CascadeClassifier('/usr/share/opencv/haarcascades/haarcascade_eye_tree_eyeglasses.xml')

video = cv2.VideoCapture('/opt/windows/idi-test/star_jump.mp4')
#video = cv2.VideoCapture('/opt/windows/idi-test/P01_video.mp4')
cv2.namedWindow(WINDOW_NAME)

got, img = video.read()
ox = 0
oy = 0
ow, oh, _ = img.shape
print ox, oy, ow, oh

while got:
    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    gray_sm = gray[oy:oh, ox:ow]
    print gray_sm.shape

    faces = face_cascade.detectMultiScale(gray_sm, 1.3, 5)
    for (x, y, w, h) in faces:
        x_w = x + w
        y_h = y + h
        cv2.rectangle(img, (x, y), (x_w, y_h), (255, 0, 0), 1)
        roi_gray = gray[y:y_h, x:x_w]
        eyes = eye_cascade.detectMultiScale(roi_gray)
        for (ex, ey, ew, eh) in eyes:
            cv2.rectangle(img, (x + ex, y + ey), (x + ex + ew, y + ey + eh), (0, 255, 0), 1)

    cv2.imshow(WINDOW_NAME, img)
    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

    got, img = video.read()

video.release()
cv2.destroyAllWindows()

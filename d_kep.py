import mediapipe as mp 
import numpy as np 
import cv2 
import pyautogui
import time
#y
UPThresh = 80
DOWNThresh = 240
SETBOMBThresh = 400
#x
LEFTThresh = 200
RIGHTThresh = 440

prevHeight = 0
newHeight = 0
sustain_B = 0
keyIsDown = False
keepkeyIsDown = False #wasd
nowIsDownKey = "0"
nowIsDownKeepKey = "0"
isPausing = False
startPressKeyt = 0
duringPressKeyt = 0.2
isQuit = False

def inFramecheck(LandmarkList):	#
	if (LandmarkList[0].visibility > 0.7) and (LandmarkList[15].visibility > 0.7):
		return True
	return False

def checkUP(LandmarkList):	#
	if LandmarkList[0].y*480 < UPThresh:
		return True 
	return False
def checkDOWN(LandmarkList):	#
	if LandmarkList[0].y*480 > DOWNThresh:
		return True 
	return False
def checkSETBOMB(LandmarkList):	#
	if LandmarkList[15].y*480 > SETBOMBThresh and LandmarkList[16].y*480 > SETBOMBThresh:
		return True 
	return False

def checkLEFT(LandmarkList):	#
	if LandmarkList[0].x*640 < LEFTThresh:
		return True 
	return False
def checkRIGHT(LandmarkList):	#
	if LandmarkList[0].x*640 > RIGHTThresh:
		return True 
	return False
def checkMIDDLE(LandmarkList):	#
	if LandmarkList[0].x*640 > RIGHTThresh:
		return False
	if LandmarkList[0].x*640 < LEFTThresh:
		return False
	if LandmarkList[0].y*480 > DOWNThresh:
		return False
	if LandmarkList[0].y*480 < UPThresh:
		return False
	return True

def keyFree():
	if keyIsDown:
		pyautogui.keyUp( nowIsDownKey )
	if keepkeyIsDown:
		pyautogui.keyUp( nowIsDownKeepKey )
	return


while isQuit==False:
	arr = np.zeros((10))
	pose = mp.solutions.pose
	drawing = mp.solutions.drawing_utils
	poseC = pose.Pose()
	cap = cv2.VideoCapture(0)

	stime = time.time()
	etime = time.time()
	while True:
		stime = time.time()
		try:
			_, frm = cap.read()
			frm = cv2.flip(frm,1)
			rgb = cv2.cvtColor(frm, cv2.COLOR_BGR2RGB)
			cv2.line(frm, (0, UPThresh), (640,UPThresh), (255,0,0), 2)
			cv2.line(frm, (0, DOWNThresh), (640,DOWNThresh), (255,0,0), 2)
			cv2.line(frm, (0, SETBOMBThresh), (640,SETBOMBThresh), (255,0,0), 2)
			cv2.line(frm, (LEFTThresh, 0), (LEFTThresh,480), (255,0,0), 2)
			cv2.line(frm, (RIGHTThresh, 0), (RIGHTThresh,480), (255,0,0), 2)
			res = poseC.process(rgb)

			drawing.draw_landmarks(frm, res.pose_landmarks, pose.POSE_CONNECTIONS)

			if res:
				if res.pose_landmarks and inFramecheck(res.pose_landmarks.landmark):

					if isPausing == True and keyIsDown == False:
						print("Run")
						keyIsDown = True
						startPressKeyt = time.time()
						nowIsDownKey = "r"
						pyautogui.keyDown(nowIsDownKey)
						cv2.putText(frm, nowIsDownKeepKey, (30,70), cv2.FONT_HERSHEY_SIMPLEX, 1, (0,0,255), 3)
						isPausing = False
					elif checkSETBOMB(res.pose_landmarks.landmark):
						sustain_B += 1
					elif checkUP(res.pose_landmarks.landmark) and ( keepkeyIsDown == False or not nowIsDownKeepKey == "w"):
						if keepkeyIsDown:
							pyautogui.keyUp( nowIsDownKeepKey )
						print("UP")
						nowIsDownKeepKey = "w"
						pyautogui.keyDown(nowIsDownKeepKey)
						keepkeyIsDown = True
						cv2.putText(frm, nowIsDownKeepKey, (30,70), cv2.FONT_HERSHEY_SIMPLEX, 1, (0,0,255), 3)
						#sustain_B = 0
					elif checkDOWN(res.pose_landmarks.landmark) and ( keepkeyIsDown == False or not nowIsDownKeepKey == "s"):
						if keepkeyIsDown:
							pyautogui.keyUp( nowIsDownKeepKey )
						print("DOWN")
						nowIsDownKeepKey = "s"
						pyautogui.keyDown(nowIsDownKeepKey)
						keepkeyIsDown = True
						cv2.putText(frm, nowIsDownKeepKey, (30,70), cv2.FONT_HERSHEY_SIMPLEX, 1, (0,0,255), 3)
						
					elif checkLEFT(res.pose_landmarks.landmark) and ( keepkeyIsDown == False or not nowIsDownKeepKey == "a"):
						if keepkeyIsDown:
							pyautogui.keyUp( nowIsDownKeepKey )
						print("LEFT")
						nowIsDownKeepKey = "a"
						pyautogui.keyDown(nowIsDownKeepKey)
						keepkeyIsDown = True
						cv2.putText(frm, nowIsDownKeepKey, (30,70), cv2.FONT_HERSHEY_SIMPLEX, 1, (0,0,255), 3)
						
					elif checkRIGHT(res.pose_landmarks.landmark) and ( keepkeyIsDown == False or not nowIsDownKeepKey == "d"):
						if keepkeyIsDown:
							pyautogui.keyUp( nowIsDownKeepKey )
						print("RIGHT")
						nowIsDownKeepKey = "d"
						pyautogui.keyDown(nowIsDownKeepKey)
						keepkeyIsDown = True
						cv2.putText(frm, nowIsDownKeepKey, (30,70), cv2.FONT_HERSHEY_SIMPLEX, 1, (0,0,255), 3)
						
					elif checkMIDDLE(res.pose_landmarks.landmark):
						if keepkeyIsDown:
							pyautogui.keyUp( nowIsDownKeepKey )
							print("FreeKeep:",nowIsDownKeepKey)
						keepkeyIsDown = False
					if sustain_B > 5 and keyIsDown == False:
						print("SPACE")
						keyIsDown = True
						startPressKeyt = time.time()
						nowIsDownKey = "space"
						pyautogui.keyDown(nowIsDownKey)
						cv2.putText(frm, nowIsDownKey, (30,70), cv2.FONT_HERSHEY_SIMPLEX, 1, (0,0,255), 3)
						sustain_B = 0
					if checkSETBOMB(res.pose_landmarks.landmark)==False:
						sustain_B = 0
				else:
					cv2.putText(frm, "PAUSE", (30,70), cv2.FONT_HERSHEY_SIMPLEX, 1, (0,0,255), 2)
					if isPausing == False and keyIsDown == False:
						print("PAUSE")
						keyIsDown = True
						startPressKeyt = time.time()
						nowIsDownKey = "esc"
						pyautogui.keyDown(nowIsDownKey)
						isPausing = True
				
				if keyIsDown:
					#print("chk:",nowIsDownKey)
					endt = time.time()
					if (endt - startPressKeyt) > duringPressKeyt:
						print("Free:",nowIsDownKey)
						pyautogui.keyUp( nowIsDownKey )
						keyIsDown = False
					

			etime = time.time()

			cv2.putText(frm, str(int(1/(etime - stime))), (30,30), cv2.FONT_HERSHEY_SIMPLEX, 1, (0,255,0), 2)
			cv2.imshow("window", frm)
			
			if cv2.waitKey(1) == 27:
				keyFree()
				cap.release()
				cv2.destroyAllWindows()
				isQuit=True
				break
		except BaseException as e:
			print (e)
			break







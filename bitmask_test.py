from PIL import Image
from multiprocessing.dummy import Pool as ThreadPool
import numpy as np
import time
import cv2
img = Image.open('test5.jpeg')
pix = img.load();
import matplotlib.pyplot as plt

RED_THRESHOLD = 220

def create_bitmask_pil(red_threshold, pix, width, height):
    arr = []
    for x in range(width):
        row = []
        for y in range(height):
            (r, g, b) = pix[x,y]
            if (r > red_threshold):
                row.append(1)
            else:
                row.append(0)
        arr.append(row)
    return arr



def create_bitmask_cv(red_threshold, array):
    arr = []
    for x in range(len(array)):
        row = []
        for y in range(len(array[x])):
            [b, g, r] = array[x][y]
            # print(f'{int(r)} > {red_threshold}: {int(r) > red_threshold}')
            # print(int(r) > red_threshold)
            if (int(r) > red_threshold):
                row.append(1)
            else:
                row.append(0)
        arr.append(row)
    return arr


def create_bitmask(red_threshold, data, width, height, type):
    if type == 'cv':
        return create_bitmask_cv(red_threshold, data)
    else:
        return create_bitmask_pil(red_threshold, data, width, height)

def find_center(bitmask, width, height):
    x_avg = 0
    y_avg = 0
    count = 1
    for x in range(width):
        for y in range(height):
            if bitmask[x][y]:
                x_avg = x_avg + (x - x_avg)/count;
                y_avg = y_avg + (y - y_avg)/count;
                count += 1;
    x_avg = int(x_avg)
    y_avg = int(y_avg)
    return x_avg, y_avg

def draw_center(bitmask, x, y):
    margin=10
    for x in range(x-margin, x+margin):
        for y in range(y-margin, y+margin):
            bitmask[x][y] = 2;

def show_bitmask(bitmask):
    image_array = np.array(bitmask, dtype=np.uint8)
    image_array.astype(dtype=np.uint8)

    plt.imshow(bitmask, interpolation='none')
    plt.show()


results = []

def get_ppg_value(frame):
    currentTime = round(time.time() * 1000)
    bitmask = create_bitmask_cv(RED_THRESHOLD, frame)
    x, y = find_center(bitmask, len(bitmask), len(bitmask[0]))
    return currentTime, x,y



def get_frames(path):
    cap = cv2.VideoCapture(path)
    frames = []
    count = 20
    while(cap.isOpened()):
        count -= 1
        ret, frame = cap.read()
        frames.append(frame)
        # break
        if count == 0 or (cv2.waitKey(1) & 0xFF == ord('q')):
            break
    cap.release()
    cv2.destroyAllWindows()
    return frames

def calculateParallel(frames, threads=2):
    pool = ThreadPool(threads)
    results = pool.map(get_ppg_value, frames)
    pool.close()
    pool.join()
    return results

frames = get_frames('test_video.mp4')
results = calculateParallel(frames, threads=20)
print(results)
from os import writev
import matplotlib.pyplot as plt
from PIL import Image
from numpy.lib.type_check import imag
from scipy.ndimage.filters import gaussian_filter1d
import multiprocessing as mp
import numpy as np
import time
import cv2
import os
from math import radians, tan


RED_THRESHOLD = 220


def create_bitmask_pil(red_threshold, pix, width, height):
    arr = []
    for x in range(width):
        row = []
        for y in range(height):
            (r, g, b) = pix[x, y]
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
                row.append(150)
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
                x_avg = x_avg + (x - x_avg)/count
                y_avg = y_avg + (y - y_avg)/count
                count += 1
    x_avg = int(x_avg)
    y_avg = int(y_avg)
    print(x_avg, y_avg)
    return x_avg, y_avg


def draw_center(bitmask, x, y):
    margin = 10
    for mx in range(x-margin, x+margin):
        for my in range(y-margin, y+margin):
            bitmask[mx][my] = 255


def list_to_np_array(bitmask):
    image_array = np.array(bitmask, dtype=np.uint8)
    image_array.astype(dtype=np.uint8)
    return image_array


def show_bitmask(bitmask):

    plt.imshow(bitmask, interpolation='none')
    plt.draw()
    plt.pause(500)


results = []


def out_of_bitmask(bitmask, x, y, width, height):
    margin = 2
    vote = {'yes': 0, 'no': 0}
    for i in range(x-margin, x+margin):
        for j in range(y-margin, y+margin):
            if 0 < i < width and 0 < j < height:
                if bitmask[i][j]:
                    vote['no'] += 1
                else:
                    vote['yes'] += 1
    result = vote['yes'] > vote['no']
    return result


def get_specific_radius(bitmask, a, x, y, width, height, step_function):
    def y_function(x):
        return int(tan(a)*x + y)
    mx = x
    hit_threshhold_border = False
    distance = 0
    print(f"--------------------{a}")
    print(x)

    while(0 < mx < width):
        my = y_function(mx)
        if 0 < my < height:
            distance += 1
            if out_of_bitmask(bitmask, mx, my, width, height):
                hit_threshhold_border = True
                break
        else:
            break
        mx = step_function(mx)
    print(f"hit: {hit_threshhold_border}")
    print(mx)

    return distance, hit_threshhold_border


def find_radius(bitmask, x, y, width, height):
    angles = [
        radians(0),
        radians(45),
        radians(90),
        radians(135),
    ]
    radiuses = []
    for a in angles:
        radius, valid = get_specific_radius(
            bitmask, a, x, y, width, height, lambda x: x+1)
        if valid:
            radiuses.append(radius)
        radius, valid = get_specific_radius(
            bitmask, a, x, y, width, height, lambda x: x-1)
        if valid:
            radiuses.append(radius)
    print(f"Radius count {len(radiuses)}")
    print(f"{radiuses}")
    return np.average(radiuses)


def calculate_radius(bitmask):
    x, y = find_center(bitmask, len(bitmask), len(bitmask[0]))
    width = len(bitmask)
    height = len(bitmask[0])
    ppg_value = find_radius(bitmask, x, y, width, height)
    return ppg_value


def get_ppg_value(frame):
    currentTime = round(time.time() * 1000)
    bitmask = create_bitmask_cv(RED_THRESHOLD, frame)
    if bitmask == None:
        return -1
    ppg_value = calculate_radius(bitmask)
    return currentTime, ppg_value


def get_frames(path):
    cap = cv2.VideoCapture(path)
    frames = []
    c = 0
    while(cap.isOpened()):
        ret, frame = cap.read()
        frames.append(frame)
        c += 1
        if c == 330 or frame is None:
            break
    cap.release()
    cv2.destroyAllWindows()
    return frames


def calculateParallelPpgValues(frames, processes=mp.cpu_count()):
    pool = mp.Pool(processes)
    results = pool.map(get_ppg_value, frames)
    pool.close()
    pool.join()
    return results


def get_bitmasked_frame(frame):
    bitmask = create_bitmask_cv(RED_THRESHOLD, frame)
    put_center_point(bitmask, 1920, 1080)
    bitmask = np.array(bitmask, dtype=np.uint8)
    return bitmask


def calculateParallelBitmaskedFrames(frames, processes=mp.cpu_count()):
    pool = mp.Pool(processes)
    results = pool.map(get_bitmasked_frame, frames)
    pool.close()
    pool.join()
    return results


def create_ppg_chart():
    frames = get_frames('test_video.mp4')
    start_time = time.time()
    results = calculateParallelPpgValues(frames)
    duration = time.time() - start_time

    print(results)
    y = list(map(lambda t: t[1], results))
    x = range(len(y))
    ysmoothed = gaussian_filter1d(y, sigma=2)
    p = plt.plot(x, ysmoothed)
    # p = plt.plot(x, y, '-ok')
    plt.show()
    print(f"Duration {duration} seconds")


def put_center_point(bitmask, width, height):
    x, y = find_center(bitmask, width, height)
    draw_center(bitmask, x, y)


def write_bitmask(bitmask, out):
    image = list_to_np_array(bitmask)
    out.write(image)


def create_bitmask_video(path, out_path):
    cap = cv2.VideoCapture(path)
    frames = []
    c = 0
    frame_size = (1080, 1920)

    while(cap.isOpened()):
        ret, frame = cap.read()
        frames.append(frame)
        c += 1
        if c == 350 or frame is None:
            break
    cap.release()
    out = cv2.VideoWriter(
        out_path, cv2.VideoWriter_fourcc(*'MJPG'), 30, frame_size, 0)
    start_time = time.time()
    bitmasks = calculateParallelBitmaskedFrames(frames)
    duration = time.time() - start_time
    print(f"Duration {duration} seconds")
    for bitmask in bitmasks:
        out.write(bitmask)
    out.release()
    cv2.destroyAllWindows()
    return frames


def analyze_image():
    img = Image.open('scan.jpg')
    print(f"size {img.size}")
    img = cv2.imread('scan.jpg')
    # pix = img.load()
    # bitmask = create_bitmask_pil(RED_THRESHOLD, pix, img.width, img.height)
    bitmask = create_bitmask_cv(RED_THRESHOLD, img)
    print(calculate_radius(bitmask))
    show_bitmask(bitmask)
    # print(img.size)


if __name__ == '__main__':
    # create_ppg_chart()
    create_bitmask_video('test_video.mp4', 'out_bitmask.avi')

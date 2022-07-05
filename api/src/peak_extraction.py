from scipy.signal import find_peaks
from config import SHORTEST_NN, MIN_PROMINENCE


def _construct_peak_points(x, y, peak_indices):
    px, py = [], []
    for peak_index in list(peak_indices):
        px.append(x[peak_index])
        py.append(y[peak_index])
    return px, py


def print_prominences(prominences):
    for i in range(len(prominences)):
        print(f'{i}: {prominences[i]}')


def find_ppg_peaks(x, y, info):
    time_per_frame = 1 / info['freq']
    distance = SHORTEST_NN / time_per_frame
    peak_indices, properties = find_peaks(y, distance=distance, prominence=(MIN_PROMINENCE, None))
    # print_prominences(list(properties['prominences']))
    peak_points = _construct_peak_points(x, y, peak_indices)
    return peak_points

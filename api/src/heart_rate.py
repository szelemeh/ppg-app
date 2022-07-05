from peak_extraction import find_ppg_peaks
from src.time_domain_methods import get_nn_intervals


def get_heart_rate(x, y, info):
    heart_beat_points = find_ppg_peaks(x, y, info)
    nn_intervals, info = get_nn_intervals(heart_beat_points, info)
    beats_count = len(nn_intervals)
    measurements_in_minute = 60 * 1000 / info['time']
    return int(beats_count * measurements_in_minute)

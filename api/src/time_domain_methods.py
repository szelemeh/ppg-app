import numpy as np
import pandas as pd
from peak_extraction import find_ppg_peaks


def remove_nn_outliers(nn_intervals, info):
    q1 = np.percentile(nn_intervals, 2)
    q3 = np.percentile(nn_intervals, 98)

    def is_outlier(nn):
        r = nn <= q1 or nn >= q3
        return r

    for nn in nn_intervals:
        outlier = is_outlier(nn)
        if outlier:
            info['time'] -= nn

    return list(filter(lambda x: not is_outlier(x), nn_intervals)), info


def get_nn_intervals(heart_beat_points, info):
    x, y = heart_beat_points
    nn_intervals = []
    prev_beat_mls = x[0]
    for i in range(1, len(x)):
        beat_mls = x[i]
        nn_intervals.append(beat_mls - prev_beat_mls)
        prev_beat_mls = beat_mls
    return remove_nn_outliers(nn_intervals, info)


def get_sdnn(nn_intervals):
    return int(np.std(nn_intervals))


def get_mean_nn(nn_intervals):
    return int(np.mean(nn_intervals))


def get_nn_differences(nn_intervals):
    differences = []
    prev_nn = nn_intervals[0]
    for i in range(1, len(nn_intervals)):
        curr_nn = nn_intervals[i]
        diff = curr_nn - prev_nn
        differences.append(diff)
        prev_nn = curr_nn
    return differences


def get_rmssd(nn_intervals):
    differences = get_nn_differences(nn_intervals)
    differences = list(map(lambda nn: nn * nn, differences))
    mean = np.mean(differences)
    return int(np.sqrt(mean))


def get_nn50(nn_intervals):
    nn50 = 0
    differences = get_nn_differences(nn_intervals)
    for diff in differences:
        if abs(diff) > 50:
            nn50 += 1
    return nn50


def get_pnn50(nn_intervals):
    nn50 = get_nn50(nn_intervals)
    proportion = nn50 / (len(nn_intervals) - 1)
    return int(round(proportion, 2) * 100)


def get_mxdmn(nn_intervals):
    max_nn = max(nn_intervals)
    min_nn = min(nn_intervals)
    mxdmn = abs(max_nn - min_nn)
    return mxdmn


def build_bin_tuples(nn_intervals):
    min_nn = min(nn_intervals)
    max_nn = max(nn_intervals)
    curr = min_nn
    bin_tuples = []
    while curr < max_nn:
        bin_tuples.append((curr, curr + 50))
        curr += 50
    return bin_tuples


def group_nn_intervals(nn_intervals, distribution):
    grouped_nns = {}
    for i in range(len(nn_intervals)):
        nn = nn_intervals[i]
        if type(distribution[i]) is pd.Interval:
            chosen_bin = distribution[i].left, distribution[i].right
            if chosen_bin in grouped_nns:
                grouped_nns[chosen_bin].append(nn)
            else:
                grouped_nns[chosen_bin] = [nn]
    return grouped_nns


def find_biggest_bin(bin_sizes, bin_tuples):
    biggest_bin = None
    biggest_count = -1
    for i in range(len(bin_sizes)):
        count = bin_sizes[i]
        bin_tuple = bin_tuples[i]
        if count > biggest_count:
            biggest_count = count
            biggest_bin = bin_tuple
    return biggest_bin


def distribute_nn_intervals(nn_intervals):
    bin_tuples = build_bin_tuples(nn_intervals)
    bins = pd.IntervalIndex.from_tuples(bin_tuples)
    distribution = pd.cut(nn_intervals, bins)
    return distribution, bin_tuples


def get_mo(nn_intervals):
    distribution, bin_tuples = distribute_nn_intervals(nn_intervals)
    bin_sizes = distribution.value_counts()
    grouped_nns = group_nn_intervals(nn_intervals, distribution)
    biggest_bin = find_biggest_bin(bin_sizes, bin_tuples)
    mo = int(np.median(grouped_nns[biggest_bin]))
    return mo


def get_amo(nn_intervals):
    distribution, _ = distribute_nn_intervals(nn_intervals)
    bin_sizes = distribution.value_counts()
    biggest_height = max(bin_sizes)
    amo = int(round(biggest_height / len(nn_intervals), 2) * 100)
    return amo


def get_time_domain_methods(x, y, info):
    heart_beat_points = find_ppg_peaks(x, y, info)
    nn_intervals, info = get_nn_intervals(heart_beat_points, info)
    return [
        {
            'type': 'sdnn',
            'value': get_sdnn(nn_intervals)
        },
        {
            'type': 'Mean NN',
            'value': get_mean_nn(nn_intervals)
        },
        {
            'type': 'RMSSD',
            'value': get_rmssd(nn_intervals)
        },
        {
            'type': 'NN50',
            'value': get_nn50(nn_intervals)
        },
        {
            'type': 'pNN50',
            'value': get_pnn50(nn_intervals)
        },
        {
            'type': 'MxDMn',
            'value': get_mxdmn(nn_intervals)
        },
        {
            'type': 'Mo',
            'value': get_mo(nn_intervals)
        },
        {
            'type': 'AMo',
            'value': get_amo(nn_intervals)
        },
    ]

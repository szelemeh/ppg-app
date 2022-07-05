import numpy as np

from data_preparation import prepare_data
from time_domain_methods import get_nn_intervals
from visualization import show_plot_with_peaks
from peak_extraction import find_ppg_peaks
from info import extract_info
from matplotlib import pyplot as plt
from heart_rate import get_heart_rate
import json

data = json.load(open('data.json'))['measurements'][0]
info = extract_info(data)
x, y = prepare_data(data)

print(f'Q1: {np.percentile(y, 3)}')
print(f'Median: {np.mean(y)}')
print(f'Q3: {np.percentile(y, 97)}')
print(f'Std: {np.std(y)}')
print(info)
px, py = find_ppg_peaks(x, y, info)
# print(f'Peaks count: {len(px)}')
# print(f'Info: {info}')
# print(f'Heart rate: {get_heart_rate(x, y, info)}')
show_plot_with_peaks(x, y, px, py)
heart_beat_points = find_ppg_peaks(x, y, info)
nn_intervals = get_nn_intervals(heart_beat_points)
print(f'Q1: {np.percentile(nn_intervals, 2)}')
print(f'Median: {np.mean(nn_intervals)}')
print(f'Q3: {np.percentile(nn_intervals, 98)}')
print(f'Std: {np.std(nn_intervals)}')
print(nn_intervals)

plt.plot(nn_intervals)
plt.show()

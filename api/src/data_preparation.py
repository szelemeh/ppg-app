from scipy.signal import lfilter
from config import NOISE_REDUCTION_N


def shift_ppg_point_left(ppg_point, amount_to_shift):
    return {
        'timestamp': ppg_point['timestamp'] - amount_to_shift,
        'value': ppg_point['value']
    }


def map_ppg_point_to_point(ppg_point):
    return {'x': ppg_point['timestamp'], 'y': ppg_point['value']}


def convert_to_points(ppg_points):
    first_timestamp = ppg_points[0]['timestamp']
    return map(lambda ppg_point: map_ppg_point_to_point(shift_ppg_point_left(ppg_point, first_timestamp)), ppg_points)


def split_points(points):
    xs, ys = [], []
    for p in points:
        xs.append(p['x'])
        ys.append(p['y'])
    return xs, ys


def flip_vertically(y):
    max_val = max(y)
    return list(map(lambda val: max_val - val, y))


def reduce_noise(y, n=NOISE_REDUCTION_N):
    b = [1.0 / n] * n
    a = 1
    return lfilter(b, a, y)


def get_normalized_ppg_points(x, y, n):
    y = reduce_noise(y, n)
    ppg_points = []
    for i in range(len(x)):
        ppg_points.append({
            'timestamp': x[i],
            'value': y[i]

        })
    return ppg_points


def scale(y, a=0, b=100):
    min_y = min(y)
    max_y = max(y)

    def map_f(val):
        return ((b - a) * (val - min_y)) / (max_y - min_y)

    return list(map(map_f, y))


def prepare_data(data):
    points = convert_to_points(data['ppgPoints'])
    x, y = split_points(points)
    y = flip_vertically(y)
    y = reduce_noise(y)
    y = scale(y)
    return x, y

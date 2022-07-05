def extract_info(data):
    ppg_points = data['ppgPoints']
    if len(ppg_points) == 0:
        return {'count': 0,
                'time': 0,
                'freq': 0}

    first = ppg_points[0]
    last = ppg_points[-1]
    time = last['timestamp'] - first['timestamp']
    count = len(ppg_points)
    freq = count / time
    return {
        'count': count,
        'time': time,
        'freq': freq,
        'age': data['age']
    }

from src.data_preparation import prepare_data, get_normalized_ppg_points


def normalize(data):
    x, y = prepare_data(data)
    normalized_ppg_points = get_normalized_ppg_points(x, y, data['normalizationDegree'])
    return {
        'ppgPoints': normalized_ppg_points
    }

from src.data_preparation import prepare_data
from src.heart_rate import get_heart_rate
from src.higher_order_metrics import get_stress_index
from src.metrics_rating import rate_metrics
from src.info import extract_info
from src.time_domain_methods import get_time_domain_methods
from src.db import insert_measurement


def metrics(data):
    # insert_measurement(data)
    derived_metrics = []
    info = extract_info(data)
    x, y = prepare_data(data)
    hr_value = get_heart_rate(x, y, info)
    derived_metrics.append({
        'value': hr_value,
        'type': 'heartRate'
    })
    si = get_stress_index(x, y, info)
    derived_metrics += get_time_domain_methods(x, y, info)
    rated_metrics = rate_metrics(derived_metrics, info['age'])
    return {
        'metrics': rated_metrics,
        'si': si
    }

from hrv_demographics import DEMOGRAPHICS


def rate_metrics(metrics, age):
    def add_rating(metric):
        rating = None
        if metric['type'] in DEMOGRAPHICS:
            age_groups = DEMOGRAPHICS[metric['type']]
            for age_group in age_groups:
                if age_group['from'] <= age <= age_group['to']:
                    min_value = age_group['value'] - age_group['std']
                    max_value = age_group['value'] + age_group['std']
                    rating = min_value <= metric['value'] <= max_value
        metric['rating'] = rating
        return metric

    return list(map(add_rating, metrics))

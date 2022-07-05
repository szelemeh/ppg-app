from src.peak_extraction import find_ppg_peaks
from src.time_domain_methods import get_nn_intervals, get_mo, get_amo, get_mxdmn


def si_f(amo, mo, mxdnn):
    mo = mo / 1000.0
    mxdnn = mxdnn / 1000.0
    si = (amo / (2 * mo * mxdnn))
    return si


def get_stress_index(x, y, info):
    heart_beat_points = find_ppg_peaks(x, y, info)
    nn_intervals, info = get_nn_intervals(heart_beat_points, info)
    mo = get_mo(nn_intervals)
    amo = get_amo(nn_intervals)
    mxdnn = get_mxdmn(nn_intervals)
    si = si_f(amo, mo, mxdnn)
    return si

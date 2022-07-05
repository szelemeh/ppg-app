import matplotlib.pyplot as plt
import numpy as np


def show_plot(x, y):
    plt.plot(x, y)
    plt.show()


def show_plot_with_peaks(x, y, px, py):
    plt.plot(x, y)
    plt.plot(px, py, 'o')
    plt.show()


def der(x, y):
    return x[:-1], np.diff(y) / np.diff(x)


def show_der(x, y):
    dx, dy = der(x, y)
    show_plot(dx, dy)

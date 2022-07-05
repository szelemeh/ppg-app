from flask import Flask, request, jsonify
from src.metrics_controller import metrics
from db import insert_measurement, get_measurements, delete_measurements
import json

from src.ppg_points_controller import normalize

app = Flask(__name__)


@app.route('/metrics', methods=['POST'])
def GET_metrics():
    data = request.json
    ppg_metrics = metrics(data)
    return jsonify(ppg_metrics)


@app.route('/ppg-points', methods=['POST'])
def POST_ppg_points():
    data = request.json
    ppg_points_normalized = normalize(data)
    return jsonify(ppg_points_normalized)


@app.route('/measurements', methods=['GET'])
def GET_measurements():
    measurements = get_measurements()
    response = {
        'measurements': measurements
    }
    return jsonify(response)


@app.route('/measurements', methods=['DELETE'])
def DELETE_measurements():
    delete_measurements()
    return jsonify({})


if __name__ == '__main__':
    app.run(threaded=True, port=8000)

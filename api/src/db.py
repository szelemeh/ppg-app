from tinydb import TinyDB
from datetime import datetime
from config import DATETIME_FORMAT

MEASUREMENTS_TABLE = 'measurements'
db = TinyDB('../db.json')


def insert_measurement(data):
    data['created_at'] = datetime.now().strftime(DATETIME_FORMAT)
    db.table(MEASUREMENTS_TABLE).insert(data)


def get_measurements():
    return db.table(MEASUREMENTS_TABLE).all()


def delete_measurements():
    return db.table(MEASUREMENTS_TABLE).truncate()

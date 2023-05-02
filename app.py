from flask import Flask, request, jsonify, make_response
from flask_sqlalchemy import SQLAlchemy
from sqlalchemy import event
from os import environ
from datetime import datetime, date

app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = environ.get('DB_URL')
db = SQLAlchemy(app)


class User(db.Model):
    __tablename__ = 'users'

    id = db.Column(db.Integer, unique=True, primary_key=True)
    name = db.Column(db.String(80), nullable=False)
    lastname = db.Column(db.String(80), nullable=False)
    birthdate = db.Column(db.Date)
    job_title = db.Column(db.String(80), unique=True, nullable=False)
    phone_number = db.Column(db.Unicode(255))

    def __init__(self, id, name, lastname, birthdate, job_title, phone_number):
        self.id = id
        self.name = name
        self.lastname = lastname
        self.birthdate = birthdate
        self.job_title = job_title
        self.phone_number = phone_number

    def json(self):
        return {'id': self.id, 'Name': self.name, 'Lastname': self.lastname, 'Birthdate': self.birthdate,
                'Job Title': self.job_title, 'Phone Number': self.phone_number}

db.create_all()
new_user = User('1', 'benjamin', 'Elharrar', date(1980, 1, 16), 'DevOps manager', '0546867987')
db.session.add(new_user)
db.session.commit()


class User_log(db.Model):
    __tablename__ = 'user_log'

    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'))
    modified_on = db.Column(db.DateTime, default=datetime.utcnow)
    action = db.Column(db.String(100))

    def json(self):
        return {'id': self.id, 'user_id': self.user_id, 'modified_on': self.modified_on, 'action': self.action}


db.create_all()


@event.listens_for(User, "after_insert")
def insert_user_log(mapper, connection, target):
    po = User_log.__table__
    connection.execute(po.insert().values(user_id=target.id, action='insert'))


# create a test route
@app.route('/test', methods=['GET'])
def test():
    return make_response(jsonify({'message': 'test route'}), 200)


# create a user
@app.route('/create', methods=['POST'])
def create_user():
    try:
        data = request.get_json()
        new_user = User(id=data['id'], name=data['name'], lastname=data['lastname'], birthdate=datetime.strptime(data['birthdate'], '%Y-%m-%d').date(),
                        job_title=data['job_title'], phone_number=data['phone_number'])
        db.session.add(new_user)
        db.session.commit()
        return make_response(jsonify({'message': 'user created'}), 201)
    except Exception as e:
        #return make_response(jsonify({'data':data,'message': str(e)}), 500)
        return make_response(jsonify({'message': 'error creating user'}), 500)


# get all users
@app.route('/list', methods=['GET'])
def get_users():
    try:
        users = User.query.all()
        return make_response(jsonify([user.json() for user in users]), 200)
    except Exception as e:
        return make_response(jsonify({'message': 'error getting users'}), 500)

# get top 50 logs
@app.route('/logs', methods=['GET'])
def get_logs():
    try:
        logs = User_log.query.order_by(User_log.modified_on.desc()).limit(50).all()
        return make_response(jsonify([log.json() for log in logs]), 200)
    except Exception as e:
        #return make_response(jsonify({'message': str(e)}), 500)
        return make_response(jsonify({'message': 'error getting logs'}), 500)


# get a user by id
@app.route('/employee/<int:id>', methods=['GET'])
def get_user(id):
    try:
        user = User.query.filter_by(id=id).first()
        if user:
            return make_response(jsonify({'user': user.json()}), 200)
        return make_response(jsonify({'message': 'user not found'}), 404)
    except Exception as e:
        return make_response(jsonify({'message': 'error getting user'}), 500)

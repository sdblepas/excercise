from flask import Flask, request, jsonify, make_response
from flask_sqlalchemy import SQLAlchemy
from sqlalchemy import event
from os import environ
from datetime import datetime

app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = environ.get('DB_URL')
db = SQLAlchemy(app)


class User(db.Model):
    __tablename__ = 'users'

    id = db.Column(db.Integer, unique=True, primary_key=True)
    name = db.Column(db.String(80), nullable=False)
    lastname = db.Column(db.String(80), nullable=False)
    birthdate = db.Column(db.DateTime)
    job_title = db.Column(db.String(80), unique=True, nullable=False)
    phone_number = db.Column(db.Unicode(255))

    def json(self):
        return {'id': self.id, 'Name': self.name, 'Lastname': self.lastname, 'Birthdate': self.birthdate,
                'Job Title': self.job_title, 'Phone Number': self.phone_number}


db.drop_all()
db.create_all()
admin = User('1', 'Benjamin', 'Elharrar', datetime(1980, 1, 16, 8, 10, 10, 10), 'DevOps Manager', '546867987')
db.session.add(admin)


class User_log(db.Model):
    __tablename__ = 'user_log'

    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'))
    modified_on = db.Column(db.DateTime, default=datetime.utcnow)
    action = db.Column(db.String(100))


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
        new_user = User(id=data['id'], Name=data['name'], Lastname=data['lastname'], Birthdate=data['birthdate'],
                        Job_Title=data['job_title'], Phone_Number=data['phone_number'])
        db.session.add(new_user)
        db.session.commit()
        return make_response(jsonify({'message': 'user created'}), 201)
    except e:
        return make_response(jsonify({'message': 'error creating user'}), 500)


# get all users
@app.route('/list', methods=['GET'])
def get_users():
    try:
        users = User.query.all()
        return make_response(jsonify([user.json() for user in users]), 200)
    except e:
        return make_response(jsonify({'message': 'error getting users'}), 500)


# get a user by id
@app.route('/employee/<int:id>', methods=['GET'])
def get_user(id):
    try:
        user = User.query.filter_by(id=id).first()
        if user:
            return make_response(jsonify({'user': user.json()}), 200)
        return make_response(jsonify({'message': 'user not found'}), 404)
    except e:
        return make_response(jsonify({'message': 'error getting user'}), 500)

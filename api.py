from flask import Flask, request
from flask_restful import Resource, Api
import json
from flask_sqlalchemy import SQLAlchemy
from datetime import datetime, date, timedelta

app = Flask(__name__)
api = Api(app,default_mediatype='application/json')
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:////root/app/api-db.db'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
db = SQLAlchemy(app)


class HelloWorld(db.Model):
    name = db.Column(db.String(64), primary_key=True)
    dateOfBirth = db.Column(db.Date)
    def __repr__(self):
        return '<HelloWorld {}>'.format(self.name) 

class Api(Resource):
    def get(self, user_name):
	messages = {}
	user = HelloWorld.query.filter_by(name=user_name).first_or_404()
	user_date=user.dateOfBirth
	if (user_date - date.today()).days == 0:
		messages[user_name]={'message': 'Hello ' + user_name + '! Happy birthday! ' }
	elif ( (user_date - date.today()).days >0 and (user_date - date.today()).days <= 5 ):
		messages[user_name]={'message': 'Hello ' + user_name + '! Your birthday is in 5 days ' }
	else:
		messages[user_name]=''
	return json.dumps(messages[user_name]), 200

    def put(self, user_name):
	names = {}
	names[user_name] = request.get_json(force=True)
	hw = HelloWorld(name=user_name, dateOfBirth=datetime.strptime(names[user_name]['dateOfBirth'], '%Y-%m-%d' ) )
	try:
	  db.session.add(hw)
	  db.session.commit()
	  return '', 204
	except:
	  db.session.rollback() 
	  return json.dumps({'message': 'user already exists'}), 500
 	
api.add_resource(Api, '/Hello/<string:user_name>')

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=80, debug=True)


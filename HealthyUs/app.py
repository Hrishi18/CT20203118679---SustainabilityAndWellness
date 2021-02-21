import csv
from flask import Flask, render_template,request,redirect,url_for
import diseaseprediction
import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore
from flask_mail import Mail,Message

from chatterbot import ChatBot
from chatterbot.trainers import ChatterBotCorpusTrainer


app = Flask(__name__)

cred = credentials.Certificate("serviceAccountKey.json")
firebase_admin.initialize_app(cred)
db=firestore.client()


app.config['MAIL_SERVER']='smtp.gmail.com'
app.config['MAIL_PORT']=465
app.config['MAIL_USERNAME']="healthyus.healthcare@gmail.com"
app.config['MAIL_PASSWORD']="healthyustcs"
app.config['MAIL_USE_TLS']=False
app.config['MAIL_USE_SSL']=True
mail=Mail(app)


english_bot = ChatBot("Chatterbot",storage_adapter="chatterbot.storage.SQLStorageAdapter")
trainer = ChatterBotCorpusTrainer(english_bot)
trainer.train("chatterbot.corpus.english")
trainer.train("data/data.yml")


with open('templates/Testing.csv', newline='') as f:
        reader = csv.reader(f)
        symptoms = next(reader)
        symptoms = symptoms[:len(symptoms)-1]        
        
@app.route('/', methods=['GET'])
def dropdown():
    return render_template('includes/default.html')

@app.route('/disease_predict', methods=['GET'])
def disease_predict():
    docs = db.collection('profileInfo').get()
    for doc in docs:
        dt=doc.to_dict()
        selected_symptoms = dt['Symptoms']
        if selected_symptoms==[]:
            print("Hrishi")
            uid= dt['Uid']
            data = {'HealthStatus': str("Fit")}
            db.collection('profileInfo').document(uid).set(data, merge=True)
            continue
                
        uid= dt['Uid']
        disease = diseaseprediction.dosomething(selected_symptoms)
        data = {'HealthStatus': str(disease[0])}
        db.collection('profileInfo').document(uid).set(data, merge=True)
        
        if dt['Mailed']==0:
            email = dt['EmailId']
            subject = "Healthy Us - Your Health Status"
            msg = "Hey there, as per our disease prediction algorithm there are chances you might have "+disease[0]+". Please consult a doctor for further medical analysis."
            message = Message(subject,sender="hrishikesh.gawas99@gmail.com",recipients=[email])
            message.body = msg
            mail.send(message)
            mailed_value = {'Mailed': 1}
            db.collection('profileInfo').document(uid).set(mailed_value, merge=True)
   
    return render_template('disease_predict.html')

 
@app.route('/about_us', methods=['GET'])
def about_us():
    return render_template('about_us.html')


@app.route('/chatbot')
def chatbot():
    return render_template('chatbot.html')


@app.route("/get")
def get_bot_response():
     userText = request.args.get("msg") #get data from input,we write js  to index.html
     return str(english_bot.get_response(userText))


if __name__ == '__main__':
    app.run(debug=True)
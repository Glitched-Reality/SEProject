from flask import Flask,render_template,request
from random import randint

app=Flask(__name__)

@app.route("/")
def index():
    #show form to get person's name
    return render_template("index.html")

@app.route("/hello")
def hello():
    num1=randint(1,100)
    num2=randint(1,100)
    #this will look in URL for a parameter --> ?person=dogs
    name=request.args.get("person","Royals")#Royals is plaveholder
    if not name:
        name="There"
    return render_template("hello.html",
    placeholder=name,lucky1=num1,lucky2=num2)


@app.route("/goodbye")
def goodbye():
    return render_template("goodbye.html")

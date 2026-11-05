from flask import Flask,render_template,request,redirect,session
from flask_session import Session
from random import randint

app=Flask(__name__)
#session configuration
app.config["SESSION_PERMANENT"]=False
app.config["SESSION_TYPE"]="cachelib"
Session(app)

@app.route("/")
def index():
    if request.args.get("luckyUser"):
        #set the session variable
        session["LUCKY_USER"]=request.args.get("luckyUser")
    #is there isnt a luckyNumbers session variable
    if not session.get("luckyNumbers"):
        luckyNumbers=[]
        for i in range(5):
            luckyNumbers.append(randint(0,99))
        #now add the luckyNumbers to the session
        session["luckyNumbers"]=luckyNumbers
    return render_template("index.html")

@app.route("/reset")
def logout():
    session.clear()#delete all session variables
    return redirect("/")
@app.route("/new")
def newNumbers():
    session.pop("luckyNumbers")#only removes the luckyNumbers variable
    return redirect("/")


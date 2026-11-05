from flask import Flask,render_template,request,redirect,session,abort,flash
from flask_session import Session
from datetime import datetime
import queries as q#dont remember dogbox here
from werkzeug.security import generate_password_hash,check_password_hash

app=Flask(__name__)

# Configure Session
app.config["SESSION_PERMENANT"]=False
app.config["SESSION_TYPE"]='cachelib'
Session(app)
app.secret_key="ashfiw3r4tgnWBE$W&*#$H"
# Create all your routes below here

@app.route("/")
def index():
    if session.get("user"):
        return render_template("user.html")
    else:
        return render_template("index.html")

@app.route("/test/<string:test>")
def Test(test):
    #first=str(q.getUserID(test))
    #second=q.selectUserTasks(test,request.args.get("bel"))
    #return f"{first} \n {second} \n {request.args} \n {request.args.get("bel")}"
    end=test
    count=0
    for i in range(1,len(end)+1):
        end=end[1:-i]+end[0]+end[-i:]
        count+=1
    return f"{end}\n:{count}:{len(test)}"

@app.route("/user")
def user():
    if session.get("user"):
        return render_template("user.html")
    else:
        return render_template("userLogin.html")

@app.route("/user/login",methods=["GET","POST"])
def userlogin():
    if request.method=="GET":
        return render_template("userLogin.html")
    else:
        info=request.form
        usernames=q.getUsernames()
        if not info.get("username"):
            flash("Sorry, please enter a username")
            return render_template("userLogin.html")
        elif info.get("username") not in usernames:
            flash(f"Sorry, {info.get("username")} is not a user. \n If new user, please make an account.")
            #flash(f"usenames: {usernames}")
            #flash(f"info: {info}")
            return render_template("userLogin.html")
        password=q.getUserPassword(info.get("username"))
        if (not password)or(password==info.get("password"))or(check_password_hash(password,info.get("password"))):
            session["user"]=info.get("username")
            flash(f"User {session.get("user")} logged in")
            return redirect("/user")
        else:
            flash("Sorry, your password is incorrect")#i do know that this can be exploited to find users and passwords, i'm just doing it to check things are working
            return render_template("userLogin.html")

@app.route("/user/new",methods=["GET","POST"])
def createUser():
    if request.method=="GET":
        return render_template("userLogin.html",new=True)
    else:
        info=request.form
        #flash(f"unique: {q.isUsernameUnique(info.get("username"))}")
        #flash(f"info: {info}")
        if not info.get("username"):
            flash("Sorry, please enter a username")
            return render_template("userLogin.html",new=True)
        elif q.isUsernameUnique(info.get("username")):
            flash(f"Sorry, {info.get("username")} is not availiable. Please enter a new username.")
            return render_template("userLogin.html",new=True)
        else:
            userID=q.addUser(info)
            session["user"]=info.get("username")
            flash(f"User #{userID} added.")
            #flash(f"username: {info.get("username")}")
            #flash(f"password: {q.getUserPassword(info.get("username"))}")
            return render_template("user.html")

@app.route("/user/logout")
def logout():
    user=session.pop("user")
    flash(f"{user} logged out.")
    return redirect("/user/login")

@app.route("/tasks")
def tasks():
    tasks=q.getUserTasks(session.get("user"))
    return render_template("tasks.html",tasks=tasks)

@app.route("/tasks/add",methods=["GET","POST"])
def addtask():
    if request.method=="GET":
        return render_template("addTask.html")
    else:
        task=mutForm(request.form)
        result=q.addUserTask(session.get("user"),task)
        if type(result)==int:
            flash(f"Task #{result} Added")
        elif type(result)==str:
            flash(result)
        else:
            flash("How")
        return redirect("/tasks")

# @app.route("/tasks/<int:taskID>")
# def showTask(taskID):
#     return render_template("showTask.html")

@app.route("/tasks/<int:taskID>/edit",methods=["POST","GET"])
def editTask(taskID):
    #return f"{type(q.isUserTask(session.get("user"),taskID))}:::{request.method}:::{taskID}:::{q.isUserTask(session.get("user"),taskID)}"
    if request.method=="GET":
        if q.isUserTask(session.get("user"),taskID)==True:
            task=q.getUserTask(session.get("user"),taskID)
            return render_template("addTask.html",task=task)
        else:
            flash("Sorry, you cant edit that task")
            return redirect("/tasks")
    else:
        task=mutForm(request.form)
        result=q.editUserTask(session.get("user"),taskID,task)
        if type(result)==int:
            flash(f"Task #{taskID} edited, {result} rows edited")
        elif type(result)==str:
            flash(result)
        else:
            flash("How")
        return redirect("/tasks")

@app.route("/tasks/<int:taskID>/delete")
def deleteTask(taskID):
    result=q.deleteUserTask(session.get("user"),taskID)
    if type(result)==int:
        flash(f"Task #{taskID} deleted")
    else:
        flash(f"Error: {result}")
    return redirect("/tasks")

def mutForm(form):
    task={
        "taskName":form.get("taskName"),
        "date":form.get("date"),
        "description":form.get("description"),
        "priority":form.get("priority"),
        "done":form.get("done",0)
    }
    return task

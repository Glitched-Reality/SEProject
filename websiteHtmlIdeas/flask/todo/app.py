from flask import Flask, render_template,request,redirect
from datetime import datetime
import pytz

app=Flask(__name__)

TODOS=[]


@app.route("/")
def index():
    return render_template("index.html",numTasks=len(TODOS))

@app.route("/add",methods=["GET","POST"])
def add():
    if request.method=="GET":
        #get current date for form
        today=datetime.now(pytz.timezone("America/Indianapolis"))
        #show a form for the user to add a new task
        return render_template("add.html",today=today.strftime("%Y-%m-%d"))
    else:#user submitted the form
        #get the date here
        task=request.form.get("task","")
        taskDate=request.form.get("taskDate","normal")
        taskPriority=request.form.get("taskPriority","normal")
        #validation
        if task=="":
            msg="Please enter a valid task"
            return render_template("error.html",errorMSG=msg)
        elif taskDate=="":
            msg="Invalid date for this task"
            return render_template("error.html",errorMSG=msg)
        elif taskPriority=="":
            msg="No priority was selected"
            return render_template("error.html",errorMSG=msg)
        else:
            #now add the task to the TODOS task
            #create a python dictinary (dict)
            todo={
                "name":task,
                "date":taskDate,
                "priority":taskPriority
            }
            #add the dict to the list of TODOS
            TODOS.append(todo)

            return redirect("/show")

@app.route("/show")
def show():
    #show a list of all TODOS
    taskList=TODOS
    return render_template("show.html",taskList=taskList)


@app.route("/delete/<int:index>")
def delete(index):
    #check to see if there is a task at that index
    if index>=len(TODOS):
        msg="NO TASK FOUND!!! (>_<)"
        return render_template("error.html",errorMSG=msg)
    else:
        task=TODOS[index]
        #usually when you delete, you would get confirmation from user
        TODOS.pop(index)#delete task from TODOS
        return render_template("delete.html",task=task)

@app.route("/edit/<int:index>")
def edit(index):
    if index>=len(TODOS):
        msg="NO TASK FOUND!!! \n(>_<)"
        return render_template("error.html",errorMSG=msg)
    task=TODOS[index]
    return render_template("add.html",task=task,today=task["date"])


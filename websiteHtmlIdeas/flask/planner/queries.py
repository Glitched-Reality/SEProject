from cs50 import SQL
from werkzeug.security import generate_password_hash,check_password_hash
db = SQL("sqlite:///planner.db")

# Create your functions for working with your database below here

def getUsernames():
    sql="select username from users order by username"
    result=db.execute(sql)
    for i in range(0,len(result)):
        result[i]=result[i].get("username")
    return result


def getUserPassword(username):
    sql="select password from users where username=?"
    result=db.execute(sql,username)
    result=result[0].get("password")
    return result


def isUsernameUnique(username):
    data=getUsernames()
    if username in data:
        return True
    else:
        return False


def addUser(user):
    if not user.get("password"):
        sql="insert into users(username) values(?)"
        result=db.execute(sql,str(user.get("username")))
    else:
        sql="insert into users(username,password) values(?,?)"
        password=generate_password_hash(user.get("password"))
        result=db.execute(sql,str(user.get("username")),password)
    return result


def getUserID(user):
    sql="select userID from users where username=?"
    result=db.execute(sql,str(user))
    if len(result)==0:
        return None
    elif len(result)>1:
        return None
    else:
        return int(result[0].get("userID"))


def isUserTask(user,taskID):
    userID=getUserID(user)
    if not userID:
        return False
    sql="select * from tasks where userID=? and taskID=?"
    result=db.execute(sql,userID,int(taskID))
    if len(result)==1:
        return True
    else:
        return False


def getUserTasks(user):
    userID=getUserID(user)
    if not userID:
        return []
    sql="select * from tasks where userID=? order by date"
    result=db.execute(sql,userID)
    return result


def selectUserTasks(user,options):
    #TODO section later
    return None
    userID=getUserID(user)
    if not userID:
        return []
    sql="select * from tasks where userID=? "
    #if options.get("week")==""
    return "hr"


def addUserTask(user,info):
    userID=getUserID(user)
    taskName=info.get("taskName",None)
    date=info.get("date",None)
    description=info.get("description",None)
    priority=info.get("priority",None)
    done=info.get("done",None)
    hadError=False
    errorMSG=""
    sql="insert into tasks (userID,taskName,date,description,priority,done) values(?,?,?,?,?,?)"
    if not userID:
        hadError=True
        errorMSG=f"No userID found for user: {user}"
    else:
        userID=int(userID)
    if not taskName:
        hadError=True
        errorMSG="Task not named"
    else:
        taskName=str(taskName)
    if not date:
        #need to find way to check if in date format
        hadError=True
        errorMSG="No date selected"
    else:
        date=str(date)
    if not description:
        description=None
    else:
        description=str(description)
    if not priority:
        priority=None
    elif type(int(str(priority).replace(".","")))!=int:
        hadError=True
        errorMSG=f"Priority is not int: {priority}"
    elif not -5<=int(str(priority).replace(".",""))<=5:
        hadError=True
        errorMSG=f"Priority not between -5 and 5: {priority}"
    else:
        priority=int(str(priority).replace(".",""))
    if not done:
        done=None
    elif type(int(str(done).replace(".","")))!=int:
        hadError=True
        errorMSG=f"Done is not int: {done}"
    elif not 0<=int(str(done).replace(".",""))<=1:
        hadError=True
        errorMSG=f"Done is not True or False: {done}"
    else:
        done=int(str(done).replace(".",""))
    if hadError:
        return str(errorMSG)
    else:
        result=db.execute(sql,userID,taskName,date,description,priority,done)
        return int(result)

def getUserTask(user,taskID):
    userID=getUserID(user)
    if not userID:
        return None
    sql="select * from tasks where userID=? and taskID=?"
    result=db.execute(sql,userID,taskID)
    return result[0]

def editUserTask(user,taskID,info):
    userID=getUserID(user)
    taskName=info.get("taskName",None)
    date=info.get("date",None)
    description=info.get("description",None)
    priority=info.get("priority",None)
    done=info.get("done",None)
    hadError=False
    errorMSG=""
    sql="update tasks set userID=?,taskName=?,date=?,description=?,priority=?,done=? where taskID=?"
    if not userID:
        hadError=True
        errorMSG=f"No userID found for user: {user}"
    elif not isUserTask(user,taskID):
        hadError=True
        errorMSG=f"{taskID} isnt {user}'s task"
    else:
        userID=int(userID)
    if not taskName:
        hadError=True
        errorMSG="Task not named"
    else:
        taskName=str(taskName)
    if not date:
        #need to find way to check if in date format
        hadError=True
        errorMSG="No date selected"
    else:
        date=str(date)
    if not description:
        description=None
    else:
        description=str(description)
    if not priority:
        priority=None
    elif type(int(str(priority).replace(".","")))!=int:
        hadError=True
        errorMSG=f"Priority is not int: {priority}"
    elif not -5<=int(str(priority).replace(".",""))<=5:
        hadError=True
        errorMSG=f"Priority not between -5 and 5: {priority}"
    else:
        priority=int(str(priority).replace(".",""))
    if not done:
        done=None
    elif type(int(str(done).replace(".","")))!=int:
        hadError=True
        errorMSG=f"Done is not int: {done}{type(done)}"
    elif not 0<=int(str(done).replace(".",""))<=1:
        hadError=True
        errorMSG=f"Done is not True or False: {done}"
    else:
        done=int(str(done).replace(".",""))
    if hadError:
        return str(errorMSG)
    else:
        result=db.execute(sql,userID,taskName,date,description,priority,done,taskID)
        return int(result)

def deleteUserTask(user,taskID):
    if isUserTask(user,taskID):
        userID=getUserID(user)
        sql="delete from tasks where userID=? and taskID=?"
        result=db.execute(sql,userID,taskID)
        return int(result)
    else:
        return str(f"Not user task: {user},{taskID}")

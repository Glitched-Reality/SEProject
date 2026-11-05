from cs50 import SQL
db=SQL("sqlite:///dogbox.db")

#add owner to database
def addOwner(owner):
    sql="insert into owners (firstName,lastName,email) values (?,?,?)"
    ownerID=db.execute(sql,
                       owner.get("firstName"),
                       owner.get("lastName"),
                       owner.get("email"))
    if ownerID>0:
        return ownerID
    else:
        return None

def getOwnerChoices():
    sql="select ownerID,firstName,lastName from owners order by lastName"
    owners=db.execute(sql)
    ownersList=[(0,"Choose an owner",{"disabled":True})]
    #loop through list of dicts and create the tuples
    for owner in owners:
        fullName=owner.get("firstName")+" "+owner.get("lastName")
        ownerTuple=(owner.get("ownerID"),fullName)
        ownersList.append(ownerTuple)
    return ownersList

def getOwnerByID(ownerID):
    sql="select * from owners where ownerID=?"
    owners=db.execute(sql,ownerID)
    if owners:
        return owners[0]#just one owner
    else:
        return None

def updateOwner(ownerID,info):
    sql="update owners set firstName=?,lastName=?,email=? where ownerID=?"
    numRows=db.execute(sql,
                       info.get("firstName"),
                       info.get("lastName"),
                       info.get("email"),
                       ownerID)
    if numRows:
        return True
    else:
        return False

def addDog(info):
    sql="insert into dogs (name,breed,gender,age,ownerID) values (?,?,?,?,?)"
    dogID=db.execute(sql,
                     info.get("name"),
                     info.get("breed"),
                     info.get("gender"),
                     info.get("age"),
                     info.get("ownerID"))
    if dogID>0:
        return dogID
    else:
        return None

def getDogChoices(ownerID):
    sql="select dogID,name from dogOwners where ownerID=?"
    dogs=db.execute(sql,ownerID)
    dogsList=[(0,"Choose a dog",{"disabled":True})]
    #loop through list of dicts and create the tuples
    for dog in dogs:
        name=dog.get("name")
        dogTuple=(dog.get("dogID"),name)
        dogsList.append(dogTuple)
    if len(dogsList)>1:
        id=int(dogsList[1][0])
        dogsList[0]=(id,"Choose a dog",{"disabled":True})
    return dogsList

def getDogByID(dogID):
    sql="select * from dogs where dogID=?"
    dogs=db.execute(sql,dogID)
    if dogs:
        return dogs[0]
    else:
        None

def getOwnersDogs(ownerID):
    sql="select * from dogOwners where ownerID=?"
    dogs=db.execute(sql,ownerID)
    if dogs:
        return dogs
    else:
        None

def updateDog(dogID,info):
    sql="update dogs set name=?,breed=?,gender=?,age=?,ownerID=? where dogID=?"
    numRows=db.execute(sql,
                       info.get("name"),
                       info.get("breed"),
                       info.get("gender"),
                       info.get("age"),
                       info.get("ownerID"),
                       dogID)
    if numRows:
        return True
    else:
        return False

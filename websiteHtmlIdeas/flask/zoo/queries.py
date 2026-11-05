from cs50 import SQL
from secrets import token_hex

#connect to the database
db=SQL("sqlite:///fishelzoo.db")

def getExhibitNames():
    sql="select name from exhibits order by name"
    results=db.execute(sql)
    return results

def getExhibitDetails(name):
    sql="select * from exhibits where name=?"
    results=db.execute(sql,name)
    if len(results)==1:
        return results[0]#give back the list if only dictionary inside
    else:
        return None

def getAnimalsByExhibit(name):
    sql="select * from animals where exhibit=? order by species"
    results=db.execute(sql,name)
    if len(results)==0:
        return None
    else:
        return results

def getAnimalDetails(id):
    sql="select * from animals where id=?"
    results=db.execute(sql,id)
    if len(results)!=1:
        return None
    return results[0]

def addAnimal(animal):#animal is dictionary
    sql="insert into animals (species,diet,habitat,description,population,exhibit) values (?,?,?,?,?,?)"
    animalId=db.execute(sql,
                       animal.get("species"),
                       animal.get("diet"),
                       animal.get("habitat"),
                       animal.get("description"),
                       animal.get("population"),
                       animal.get("exhibit")
                       )
    return animalId

def addTicketOrder(ticket):
    sql="insert into tickets (name,contact,visitDate,numTickets,confirmation) values(?,?,?,?,?)"
    name=ticket.get("visitorName")
    contact=ticket.get("visitorContact")
    visitDate=ticket.get("visitDate")
    numTickets=ticket.get("numberOfTickets")
    confirmation=token_hex(4)#secure random token
    orderNum=db.execute(sql,name,contact,visitDate,numTickets,confirmation)
    return orderNum

def getAllTickets():
    sql="select * from tickets"
    #skipping over error checking
    return db.execute(sql)

def delTicketByOrderNumber(ticketNum):
    sql="delete from tickets where orderNumber=?"
    numDeleted=db.execute(sql,ticketNum)
    return numDeleted

def getTicketByOrderNumber(ticketNum):
    sql="select * from tickets where orderNumber=?"
    #skip error checking
    return db.execute(sql,ticketNum)

def editTicketByOrderNumber(ticketNum,ticket):
    sql="update tickets set name=?,contact=?,visitDate=?,numTickets=? where orderNumber=?"
    numEdited=db.execute(sql,
                         ticket.get("name"),
                         ticket.get("contact"),
                         ticket.get("visitDate"),
                         ticket.get("numTickets"),
                         ticketNum
                         )
    return numEdited

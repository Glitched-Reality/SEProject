from flask import Flask,render_template,request,redirect,session,abort,flash
from flask_session import Session
from datetime import datetime

#bring in the queries functions
import queries as q

app=Flask(__name__)
app.config["SESSION_TYPE"]="cachelib"
app.config["SESSION_PERMANENT"]=False
Session(app)
#add this for message flashing
app.secret_key=""

@app.route("/")
def index():
    #get the exhibit names from the database
    exhibitsList=q.getExhibitNames()
    return render_template("index.html",exhibits=exhibitsList)

@app.post("/exhibits")
def exhibits():
    #get the name from the form
    exhibitName=request.form.get("exhibitName")
    #set the session for exhibit
    session["exhibit"]=exhibitName
    flash(f"I will remember this choice: {exhibitName}")
    #use the name to query the database
    exhibitDetails=q.getExhibitDetails(exhibitName)
    if not exhibitDetails:
        return f"ERROR - NO EXHIBITS MATCHING {exhibitName.upper()}"
    else:
        return render_template("exhibitsDetail.html",exhibit=exhibitDetails)

@app.route("/animals/<exhibit>")
def animals(exhibit):
    animalsList=q.getAnimalsByExhibit(exhibit)
    return render_template("exhibitAnimals.html",animalsList=animalsList)

@app.route("/animals")
def showAnimals():
    if session.get("exhibit"):#if an exhibit been selected from the user
        return redirect(f"/animals/{session.get("exhibit")}")
    else:
        return redirect("/")

@app.route("/animals/<int:animalId>")
def showAnimalDetails(animalId):
    #get the details for the animal from the database
    animalDetails=q.getAnimalDetails(animalId)
    if animalDetails:
        return render_template("animalDetails.html",animalDetails=animalDetails)
    else:
        abort(404)

@app.route("/add",methods=["GET","POST"])
def add():
    if request.method=="GET":
        #show the form
        exhibits=q.getExhibitNames()
        return render_template("add.html",exhibits=exhibits)
    else:#post request
        #process the request
        #currently trusting user did things correctly
        animal={
            "species":request.form.get("species"),
            "diet":request.form.get("diet"),
            "habitat":request.form.get("habitat"),
            "population":int(request.form.get("population")),
            "description":request.form.get("description"),
            "exhibit":request.form.get("exhibit")
        }
        animalId=q.addAnimal(animal)#animal is dict
        if animalId>0:
            flash(f"The {animal.get('species')} was added to the database")
        return redirect(f"/animals/{animalId}")

@app.route("/tickets",methods=["GET","POST"])
def tickets():
    if request.method=="GET":#the user clicked on the link
        #show the ticket order form
        today=datetime.now().strftime("%Y-%m-%d")# 2025-03-20
        return render_template("ticketsForm.html",today=today)
    else:#user fills out the form
        ticketOrder=request.form
        if not session.get("cart"):#if there isn't a cart already
            session["cart"]=[]
        #add the ticket order to the cart
        session["cart"].append(ticketOrder)
        flash(f"Your {ticketOrder.get('numberOfTickets')} ticket(s) were added to the cart.")
        return redirect("/cart")

@app.route("/cart")
def showCart():
    if not session.get("cart"):
        flash("Your cart is empty, order tickets here.")
        return redirect("/tickets")
    else:
        return render_template("cart.html")

@app.route("/cart/delete/<int:index>")
def cartDelete(index):
    if index>=len(session.get("cart")):
        flash(f"Order number doesn't exist: {index}")
        abort(404)
    else:
        order=session.get("cart")[index]
        session.get("cart").pop(index)
        flash(f"Order for {order.get("visitorName")} of {order.get("numberOfTickets")} ticket(s)")
        return render_template("cart.html")

@app.route("/cart/edit/<int:index>",methods=["GET","POST"])
def cartEdit(index):
    if index>=len(session.get("cart")):
        flash(f"Order number doesn't exist: {index}")
        abort(404)
    elif request.method=="GET":
        order=session.get("cart")[index]
        today=datetime.now().strftime("%Y-%m-%d")# 2025-03-20
        return render_template("ticketsForm.html",order=order,index=index,today=today)
    else:
        order=request.form
        #TODO
        session.get("cart")[index]=order
        flash(f"Order {index} has been edited.")
        return render_template("cart.html")

@app.route("/cart/emptyCart",methods=["GET","POST"])
def emptyCart():
    if request.method=="GET":
        #make sure there is a cart (this is done in /cart route)
        session["emptyCart"]=True
    else:#they want to empty the cart
        #empty the cart
        session.pop("cart")#this will remove only the cart session variable
        session.pop("emptyCart")
    return redirect("/cart")

@app.route("/cart/cancelEmpty")
def cancelEmpty():
    session.pop("emptyCart")
    return redirect("/cart")

@app.route("/cart/checkout")
def checkout():
    #show a confirmation page similar to emptycart (take in payment though)
    #skipped for this example

    completedOrders=[]
    #add our orders to the database
    ticketOrders=session.get("cart",None)
    if not ticketOrders:
        flash("You have nothing in your cart")
        return redirect("/tickets")
    else:
        for ticket in ticketOrders:
            orderNum=q.addTicketOrder(ticket)
            completedOrders.append(orderNum)
        if len(completedOrders)>0:
            flash(f"Your tickets have been ordered {completedOrders}")
            session.pop("cart")
            return redirect("/")
        else:
            flash("Something went wrong with your order. Contact the Zoo Ticket Office.")
            return redirect("/")

@app.route("/tickets/history")
def ticketsHistory():
    #first we need to get all the tickets from our database
    allTickets=q.getAllTickets()
    return render_template("ticketsHistory.html",tickets=allTickets)

@app.route("/tickets/delete/<int:ticketNum>")
def ticketsDelete(ticketNum):
    #we will use the ticket number to delete 1 row from our database
    result=q.delTicketByOrderNumber(ticketNum)
    #skipping over the confirmation steps
    #should ask user for confirmation number before we delete
    if result==1:#only one ticket deleted
        flash(f"There was {result} ticket deleted for order # {ticketNum}")
    else:
        flash(f"Sorry, order # {ticketNum} is not a valid order.")
    return redirect("/tickets/history")

@app.route("/tickets/edit/<int:ticketNum>",methods=["GET","POST"])
def ticketsEdit(ticketNum):
    if request.method=="GET":
        #get the information for the one ticket order selected
        ticket=q.getTicketByOrderNumber(ticketNum)
        #show a form with data filled in so the user can edit it
        return render_template("ticketsEdit.html",ticket=ticket[0])
    else:#user made some changes and submitted the form
        #get the form data
        editedTicket=request.form
        # return request.data
        result=q.editTicketByOrderNumber(ticketNum,editedTicket)
        if result==1:
            flash(f"Ticket was updated for {editedTicket.get("name")}.")
        else:
            flash(f"Ticket error happened")
        return redirect("/tickets/history")


@app.errorhandler(404)
def pageNotFound(e):
    return render_template("pageNotFound.html")

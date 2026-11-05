from flask import Flask,render_template,redirect,flash,session
from flask_session import Session
#from forms import ownerForm
import forms as f
import queries as q

app=Flask(__name__)
app.config["SECRET_KEY"]="sn456vb8290dafl;L;fnla"
app.config["SESSION_TYPE"]="cachelib"
app.config["SESSION_PERMANENT"]=False
Session(app)

@app.route("/")
def index():
    return render_template("index.html")

@app.route("/add/owner",methods=["GET","POST"])
def addOwner():
    #make a form to add new owner
    form=f.ownerForm()
    #how to submit form
    if form.validate_on_submit():
        ownerID=q.addOwner(form.data)
        flash(f"New owner was added with id of {ownerID}")
        info="Welcome to DogBox new user!"
        return render_template("ownerAddDog.html",owner=form.data,info=info)

    return render_template("ownerForm.html",form=form,action="add")

@app.route("/edit/owner",methods=["GET","POST"])
def editOwner():
    #in order to edit an owner's info we must first know what owner the user selected
    chooseOwner=f.chooseOwnerForm()
    #now get all owner ID's and full names of owners from database
    ownerChoices=q.getOwnerChoices()
    #add the ownerChoices to the form
    chooseOwner.ownerID.choices=ownerChoices
    if chooseOwner.validate_on_submit():
        ownerID=chooseOwner.ownerID.data
        #we need all info about owner in our database
        owner=q.getOwnerByID(ownerID)
        ownerForm=f.ownerForm(data=owner)
        return render_template("ownerForm.html",form=ownerForm,action="edit",ownerID=ownerID)
    return render_template("chooseOwner.html",form=chooseOwner,action="/edit/owner")

@app.route("/edit/owner/<int:ownerID>",methods=["POST"])
def updateOwner(ownerID):
    #TODO
    #get the data from the form
    form=f.ownerForm()
    updatedInfo=form.data
    #use the ownerID to update our database with the new data from the form
    if form.validate_on_submit():
        wasUpdated=q.updateOwner(ownerID,updatedInfo)
        #show the user a message that update was successful or not
        flash(f"Changes saved for {updatedInfo.get('firstName')+" "+updatedInfo.get('lastName')}")
        return redirect("/")
    flash("ERROR! No changes were made!")
    return redirect("/edit/owner")

@app.route("/add/dog",methods=["GET","POST"])
def addDog():
    form=f.dogForm()
    ownerChoices=q.getOwnerChoices()
    form.ownerID.choices=ownerChoices
    if form.validate_on_submit():
        dogID=q.addDog(form.data)
        flash(f"New dog has been added with id of {dogID} to owner with id {form.data.get("ownerID")}")
        return redirect("/")
    return render_template("dogForm.html",form=form,action="add")

@app.route("/edit/dog",methods=["GET","POST"])
def editDog():
    chooseOwner=f.chooseOwnerForm()
    ownerChoices=q.getOwnerChoices()
    chooseOwner.ownerID.choices=ownerChoices
    chooseDog=f.chooseDogForm()
    if session.get("dogList"):
        chooseDog.dogID.choices=session.get("dogList")
    dogForm=f.dogForm()
    if chooseOwner.validate_on_submit():
        ownerID=chooseOwner.ownerID.data
        dogList=q.getDogChoices(ownerID)
        if len(dogList)>1:
            chooseDog.dogID.choices=dogList
            session["dogList"]=dogList
            return render_template("chooseDog.html",form=chooseDog,action="/edit/dog")
        else:
            if session.get("dogList"):
                session["dogList"].pop()
            flash(f"No dogs for owner ID {ownerID}")
            info="You don't have any registered dogs, please add one."
            owner=q.getOwnerByID(ownerID)
            return render_template("ownerAddDog.html",owner=owner,info=info)
    if chooseDog.validate_on_submit():
        if session.get("dogList"):
            session["dogList"].pop()
        dogID=chooseDog.dogID.data
        # return dogID
        dog=q.getDogByID(dogID)
        dogForm=f.dogForm(data=dog)
        dogForm.ownerID.choices=ownerChoices
        return render_template("dogForm.html",form=dogForm,dogID=dogID)
    return render_template("chooseOwner.html",form=chooseOwner,action="/edit/dog")

@app.route("/edit/dog/<int:dogID>",methods=["POST"])
def updateDog(dogID):
    form=f.dogForm()
    form.ownerID.choices=q.getOwnerChoices()
    updatedInfo=form.data
    #use the ownerID to update our database with the new data from the form
    if form.validate_on_submit():
        wasUpdated=q.updateDog(dogID,updatedInfo)
        #show the user a message that update was successful or not
        flash(f"Changes saved for {updatedInfo.get('name')}")
        return redirect("/")
    flash("ERROR! No changes were made!")
    return redirect("/edit/dog")

@app.route("/show/dog",methods=["GET","POST"])
def showDogs():
    chooseOwner=f.chooseOwnerForm()
    chooseOwner.ownerID.choices=q.getOwnerChoices()
    if chooseOwner.validate_on_submit():
        ownerID=chooseOwner.ownerID.data
        owner=q.getOwnerByID(ownerID)
        dogs=q.getOwnersDogs(ownerID)
        if dogs:
            return render_template("showDogs.html",owner=owner,dogs=dogs)
        else:
            info="No dogs registered for you, please add one."
            return render_template("ownerAddDog.html",owner=owner,info=info)
    return render_template("chooseOwner.html",form=chooseOwner,action="/show/dog")


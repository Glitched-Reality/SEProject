from flask import Flask,render_template,request,redirect


app=Flask(__name__)

PLAYLIST_NAME="None"
PLAYLIST=[]

@app.route("/")
def index():

    return render_template("index.html",numSongs=len(PLAYLIST))

@app.route("/add",methods=["GET","POST"])
def add():
    if request.method=="GET":
        if PLAYLIST_NAME=="None":
            return render_template("add.html")
        else:
            return render_template("add.html",playlistName=True)
    else:
        title=request.form.get("title","")
        artist=request.form.get("artist","")
        genre=request.form.get("genre","")
        rating=request.form.get("rating","")
        if title=="":
            msg="No title input"
            return render_template("error.html",errorMSG=msg)
        elif artist=="":
            msg="No artist input"
            return render_template("error.html",errorMSG=msg)
        elif genre=="":
            msg="No genre selected"
            return render_template("error.html",errorMSG=msg)
        elif rating=="":
            msg="No rating selected"
            return render_template("error.html",errorMSG=msg)
        else:
            song={
                "title":title.title(),
                "artist":artist.title(),
                "genre":genre.title(),
                "rating":int(rating)
            }
            PLAYLIST.append(song)


            return redirect("/show")

@app.route("/show")
def show():
    if PLAYLIST_NAME=="None":
        return render_template("add.html")
    else:
        return render_template("show.html",playlistName=PLAYLIST_NAME.title(),playlist=PLAYLIST)

@app.route("/newPlaylist",methods=["POST","GET"])
def newPlaylist():
    global PLAYLIST_NAME
    if request.method=="GET":
        return render_template("newPlaylist.html")
    elif request.method=="POST":
        name=request.form.get("playlistName","")
        if name=="":
            msg="Please enter a name for the Playlist!"
            return render_template("error.html",errorMSG=msg)
        else:
            PLAYLIST_NAME=name
            return redirect("/show")
    else:
        return render_template("error.html",errorMSG="notheing happened")

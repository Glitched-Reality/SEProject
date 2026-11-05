from flask_wtf import FlaskForm
from wtforms import StringField,EmailField,SelectField,SubmitField,IntegerField
from wtforms.validators import InputRequired,NumberRange

# a form for owners (add/edit)
class ownerForm(FlaskForm):
    #now list out the fielsd we need for the form
    firstName=StringField("First Name:",validators=[InputRequired()])
    lastName=StringField("Last Name:",validators=[InputRequired()])
    email=EmailField("Email:",validators=[InputRequired()])

class chooseOwnerForm(FlaskForm):
    ownerID=SelectField("Owner's Name:",validators=[InputRequired()],coerce=int,default=0)
    submit=SubmitField("Next")

class dogForm(FlaskForm):
    ownerID=SelectField("Owner's Name:",validators=[InputRequired()],coerce=int,default=0)
    name=StringField("Dog's Name:",validators=[InputRequired()])
    breed=StringField("Dog's Breed:",validators=[InputRequired()])
    gender=SelectField("Dog's Gender:",validators=[InputRequired()],choices=[("","Choose Dog's Gender:",{"disabled":True}),("M","Male"),("F","Female")],default="M")
    age=IntegerField("Dog's Age:",validators=[InputRequired(),NumberRange(0)],default=0)

class chooseDogForm(FlaskForm):
    dogID=SelectField("Dog's's Name:",validators=[InputRequired()],coerce=int,default=0)
    submit=SubmitField("Next")

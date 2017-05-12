#!/usr/bin/python
from flask import Flask
from werkzeug import secure_filename
from flask import Flask, flash, render_template, Response, url_for, request, redirect, flash, session
from subprocess import call
import shlex
import subprocess
import os
import flask


app = Flask(__name__)

cwd = os.getcwd()
UPLOAD_FOLDER = cwd
UPGRADE_FOLDER = cwd + "/upgrade"
ALLOWED_EXTENSIONS = set(['csv'])

app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER
app.config['UPGRADE_FOLDER'] = UPGRADE_FOLDER
app.secret_key = 'some_secret'

if not os.path.exists('upgrade'):
	os.makedirs('upgrade')

@app.route("/")
def main():
    return render_template('index.html')

def allowed_file(filename):
    return '.' in filename and \
           filename.rsplit('.', 1)[1] in ALLOWED_EXTENSIONS

@app.route("/singleNodeUpload", methods=['POST'])
def singleNodeUpload():
    if request.method == 'POST':
	file = request.files['single_node_file']
	file.filename = "single_node_servers.csv"
	if file and allowed_file(file.filename):
	    filename = secure_filename(file.filename)
	    file.save(os.path.join(app.config['UPLOAD_FOLDER'], filename))
    else:
	return "Something goes wrong !!!!"	    
    return render_template('index.html')

@app.route("/multiNodeUpload", methods=['POST'])
def multiNodeUpload():
    if request.method == 'POST':
	file = request.files['multi_node_file']
	file.filename = "multi_node_servers.csv"
	if file and allowed_file(file.filename):
	    filename = secure_filename(file.filename)
	    file.save(os.path.join(app.config['UPLOAD_FOLDER'], filename))
    else:
	return "Something goes wrong !!!!"	    
    return render_template('index.html')

@app.route("/addNodeUpload", methods=['POST'])
def addNodeUpload():
    if request.method == 'POST':
	file = request.files['add_node_file']
	file.filename = "add_node_servers.csv"
	if file and allowed_file(file.filename):
	    filename = secure_filename(file.filename)
	    file.save(os.path.join(app.config['UPLOAD_FOLDER'], filename))
	    flash('You were successfully uploaded a CSV file')
    else:
	return "Something goes wrong !!!!"	    
    return render_template('index.html')


@app.route("/commUpload", methods=['POST'])
def commUpload():
    if request.method == 'POST':
	file = request.files['com_file']
	file.filename = "com_servers.csv"
	if file and allowed_file(file.filename):
	    filename = secure_filename(file.filename)
	    file.save(os.path.join(app.config['UPLOAD_FOLDER'], filename))
    else:
	return "Something goes wrong !!!!"	    
    return render_template('index.html')

@app.route("/decommUpload", methods=['POST'])
def decommUpload():
    if request.method == 'POST':
	file = request.files['decom_file']
	file.filename = "decom_servers.csv"
	if file and allowed_file(file.filename):
	    filename = secure_filename(file.filename)
	    file.save(os.path.join(app.config['UPLOAD_FOLDER'], filename))
    else:
	return "Something goes wrong !!!!"	    
    return render_template('index.html')

@app.route("/upgradeUpload", methods=['POST'])
def upgradeUpload():
    if request.method == 'POST':
	file = request.files['upgrade_file']
	if file:
	    filename = secure_filename(file.filename)
	    file.save(os.path.join(app.config['UPGRADE_FOLDER'], filename))
    else:
	return "Something goes wrong !!!!"	    
    return render_template('index.html')


@app.route("/singlenode/")
def singlenode():
   singleNode = subprocess.check_output(['./installHadoop.sh'],   stderr=subprocess.PIPE, stdin=subprocess.PIPE, shell=True)
   #p,err = p.communicate()
   
   return render_template(shlex.split('singleNode.html'), outNode=singleNode)
   return flask.Response(commissionnode(), mimetype='text/html')


@app.route("/commissionnode/")
def commissionnode():
	
   comNode = subprocess.check_output(['./commission.sh'],   stderr=subprocess.PIPE, stdin=subprocess.PIPE, shell=True)
   #comNode,err = comNode.communicate()
   return render_template(shlex.split('commissionNode.html'), outNode=comNode)
   return flask.Response(commissionnode(), mimetype='text/html')

@app.route("/decommissionnode/")
def decommissionnode():
   decomNode = subprocess.check_output(['./decommission.sh'],  stderr=subprocess.PIPE, stdin=subprocess.PIPE, shell=True)
   #decomNode,err = decomNode.communicate()
	
   return render_template(shlex.split('decommissionNode.html'), deoutNode=decomNode)
   return flask.Response(commissionnode(), mimetype='text/html')

@app.route("/upgradehadoop/")
def upgradehadoop():
   upgradeNode = subprocess.check_output(['./upgrade.sh'],  stderr=subprocess.PIPE, stdin=subprocess.PIPE, shell=True)
   #decomNode,err = decomNode.communicate()
	
   return render_template(shlex.split('upgrade.html'), deoutNode=upgradeNode)
   return flask.Response(commissionnode(), mimetype='text/html')


if __name__ == "__main__":
   import webbrowser
   webbrowser.open('http://localhost:5000')
   app.run(use_reloader=True)

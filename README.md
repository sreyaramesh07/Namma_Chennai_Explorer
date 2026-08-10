# Namma Chennai Explorer V1

Namma Chennai Explorer V1 is a beginner-friendly command-line project that stores and searches Chennai travel information. It uses Python to interact with a MySQL database.

## Technologies used

- Python
- MySQL
- mysql-connector-python

## Project folder structure

```text
Namma Chennai Explorer/
|-- python.py       # Python command-line program
|-- database.sql    # MySQL database, tables and sample data
|-- README.md       # Project instructions
```

## Create the database

1. Open MySQL Workbench and connect to your MySQL server.
2. Open `database.sql` from this project folder.
3. Click the lightning-bolt Execute button.
4. The script creates the `namma_chennai` database, three tables, and Chennai sample data.

## Install the Python package

Open the VS Code terminal in this project folder and run:

```bash
pip install mysql-connector-python
```

## Configure MySQL login details

Open `python.py` and update the `DB_CONFIG` section near the top:

```python
"user": "root",
"password": "YOUR_MYSQL_PASSWORD",
```

Replace `YOUR_MYSQL_PASSWORD` with the password for your MySQL user. If your MySQL username is not `root`, change that too.

## Run the program

After running `database.sql` and installing the package, use this command in the VS Code terminal:

```bash
python python.py
```

## What the program can do

- Display all Chennai places.
- Search places by category, such as `Beach`, `Temple`, or `Museum`.
- Search places by an area, such as `Mylapore` or `Marina`.
- Find places within an entry-fee budget.
- Search food recommendations by food name, type, or location.

## Future versions

- V1 - Python + MySQL
- V2 - HTML + CSS
- V3 - Flask
- V4 - JavaScript
- V5 - Maps API
- V6 - AI Trip Planner
- V7 - Weather + Live Information

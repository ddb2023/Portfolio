# DBManagement.py
# Dan Bennett
# 01/31/2019
# Program to allow retrieval and manipulation of
# documents from a Mongo database. The program requires
# authentication in order to access the database.
from pymongo import MongoClient
import sys
import json
from pprint import pprint
from pymongo import errors as mongoerrors
from bson import json_util 
from pymongo import ASCENDING, DESCENDING
import datetime
import hashlib

# Connect to the MongoDB server
client = MongoClient('localhost', 27017)  

# Use the market database
db = client.market

# Function to authenticate user
def authenticate():
  choice = 0
  while choice != 4:
    print("To log in enter 1 ")
    print("To create a new account enter 2 ")
    print("To reset your password enter 3 ")
    print("To quit enter 4 ")
    choice = input('Enter choice ')
    
    # Option 1 of authenticate(), log in
    if(choice == 1):
      uname = input("Enter user name ")
      pwd = input("Enter password ")
      try:
        fh = open('~/workspace', 'r') 
      except: 
        print("User name does not exist")
        authenticate()
      hashedPwd = hashlib.md5(pwd)
      fin = open(uname, 'r')
      fin.readline()
      fin.close()
    if(hashedPwd == fin.readline()):
      return
    else:
      print("Password incorrect")
      authenticate()

  # Option 2 of authenticate(), create new account
  if(choice == 2):
    uname = input("Enter your user name")
    pwd = input("Enter your password")
    hashedPwd = hashlib.md5(pwd)
    recoveryPhrase = input("Enter a password reset phrase")
    hashedRecoveryPhrase = hashlib.md5(recoveryPhrase)
  # check for existance of file before creating a new one
    try:
      fh = open('~/workspace', 'r') 
    except: 
      print("User name already exist")
      authenticate()  
    fout = open(uname, wa)
    fout.write(hashedPwd)
    fout.write(hashedRecoveryPhrase)
    authenticate()
  
    # Option 3 of authenticate(), reset password
    if(choice == 3):
      uname = input("Enter user name")
  # check for existance of user file  
      fin = open(uname, w)
      recoveryPhrase = input("Enter password reset phrase")
      hashedRecoveryPhrase = hashlib.md5(recoveryPhrase)
      fileHashedPwd = fin.readline()
      fileHashedRecoveryPhrase = fin.readline()
      fin.close()
    if(fileHashedRecoveryPhrase == hashedRecoveryPhrase):
      pwd = input("Enter new password")
      hashedPwd = hashlib.md5(pwd)
      recoveryPhrase = input("Enter new recovery phrase")
      hashedRecoveryPhrase = hashlib.md5(recoveryPhrase)
      fout.open(uname, w)
      fout.write(hashedPwd)
      fout.write(hashedRecoveryPhrase)
      authenticate()
    else:
      print("Recovery phrase incorrect")
      authenticate()

# Function to find stocks within the range specifed for 50-day simple moving average
def Fifty_Day_Simple_Moving_Average():
  low = input("Enter low value WITHOUT quotes: ")
  high = input("Enter high value WITHOUT quotes: ")
  result = db.stocks.find({"50-Day Simple Moving Average": {"$gt": low, "$lt": high}}).count() # Find stocks according to specifed range
  return result

# Function to find stocks in specifed industry
def industry_tickers():
  industry = raw_input("Enter the industry WITHOUT quotes: ")
  result = db.stocks.find({"Industry": industry}, {"Ticker" : 1, "_id" : 0}) # Find stocks in specifed industry
  for x in result: # Print group of stocks found
    pprint (x)
  return
  
# Function to find sum of shares outstanding in specifed sector and industry
def total_shares_outstanding():
  null = '' # Initialize null
  total = '' # Initialize variable total
  sector = raw_input("Enter the sector WITHOUT quotes: ")
  industry = raw_input("Enter the industry WITHOUT quotes: ")
  for item in db.stocks.aggregate([ # Begin aggregation
    {"$match": {"Sector": sector}}, # Use match to winnow stocks considered in query to specifed sector
    {"$match": {"Industry": industry}}, # Use match to winnow stocks considered in query to specifed industry
    {"$project": {"Sector" : 1, "Industry": 1, "Shares Outstanding": 1}}, # Use project to select stocks to consider in query
    {"$group": {'_id': null, total: {"$sum" : "$Shares Outstanding"}}}]): # Use group to get final results of query including sum of shares outstanding
    pprint (item)
  return

# Function to insert a document into the stocks collection  
def insert_new_document():
  choice = 0
  while choice != 4:
    print("To insert a document with a file enter 1 ")
    print("To insert a prefab document enter 2 ")
    print("To insert a document from the keyboard enter 3")
    print("To stop inserting enter 4")
    
    choice = input('Enter a choice ')
    
    # Option 1 of insert_new_document()
    if(choice == 1): 
      name = input("Enter the filename to insert WITH quotes: ")
      try:
        with open(name) as f:
          data = json.load(f) # Open file specified by the user
          db.stocks.insert(data) # Insert new document from file into collection
      except:
        print ("Document not inserted")
      else:
        print ("Document inserted")
      return

  # Option 2 of insert_new_document()
    if(choice == 2):
      t1 = { "id" : "10021-2015-TEST", "Ticker": "T1", "certificate_number" : 9278807, "business_name" : "TEST INC.", "date" : "Feb 20 2017", "result" : "No Violation Issued", "sector" : "TEST Retail Dealer - 127", "address" : { "city" : "RIDGEWOOD", "zip" : 11385, "street" : "MENAHAN ST", "number" : 5555 } }
      try:
        db.stocks.insert(t1) # Insert document that is encoded in this program above into stocks collection
      except:
        print("Document not inserted")
      else:
        print("Document inserted")
      return
  
  # Option 3 of insert_new_document()
    if(choice == 3):
      key = raw_input("Enter key: ") # Enter key for new data
      value = raw_input("Enter value: ") # Enter value for new data
      test_document = ({key: value}) #Assign key/value pair to variable test_document
    try:
      db.stocks.insert(test_document) # Insert new document into stocks collection
    except:
      print("Document not inserted")
    else:
      print("Document inserted")
    return

    if(choice == 4):
      return

# Implementation of option 1 of insert_new_document()
def insert_file():
  name = input("Enter the filename to insert WITH quotes: ")
  try:
    with open(name) as f: # Open file specified by user
      data = json.load(f) # Load file contents
      db.stocks.insert(data) # Insert new document from file into collection
  except:
    print ("Document not inserted")
  else:
    print ("Document inserted")
  return

# Implementation of option 2 of insert_new_document()
def insert_prefab_document():
  try:
    db.stocks.insert(t1) # Insert document that is encoded in this program into stocks collection
  except:
    print ("Document not inserted")
  else:
    print ("Document inserted")
  return

# Implementation of option 3 of insert_new_document()
def insert_keyboard():
  document = sys.stdin.readlines() # Read from keyboard document to insert into collection
  print (document)
  try:
    db.stocks.insert(document) # Insert document into collection
  except:
    print ("Document not inserted")
  else:
    print ("Document inserted")
  return
 
# Function to read a document from the stocks collection
def read_document():
  key = raw_input("Enter key WITHOUT quotes: ") # Enter key of key/value pair
  value = raw_input("Enter value WITHOUT quotes: ") # Enter value of key/value pair
  query = db.stocks.find({key: value}) # Search for document using key/value pair
  for document in query:
    pprint(document)
  if query.retrieved == 0:
    print ("No document found")
    
# Function to update specified stock's volume
def update_document_volume():
  ticker_symbol = input("Enter the ticker symbol IN QUOTES ")
  try:
    db.stocks.update({"Ticker": ticker_symbol}, {'$set': {"Volume": 1000000}}, upsert = True) # Update volume of specified stock
  except:
    print("Document not updated")
  else:
    cursor = db.stocks.find({"Ticker": ticker_symbol}) # Display stock data to prove update was successful
    for document in cursor:
      pprint(document)
  return

# Function to remove a document from the stocks collection
def remove_document():
  ticker_symbol = input("Enter the ticker symbol IN QUOTES ")
  try:
    db.stocks.remove({"Ticker": ticker_symbol}) # Remove specified stock
  except:
    print("Document not found")
  else:
    print("Document removed")
  return
  
# Main function for selecting functions to perform
def main():
  authenticate()
  choice = 0
  while choice != 8:
    print("To count companies with a 50-Day Simple Moving Average within a range enter 1 ")
    print("To retrieve ticker symbols for companies in a particular industry enter 2 ")
    print("To find total shares outstanding for a sector and industry enter 3 ")
    print("To insert a document enter 4 ")
    print("To read a document enter 5 ")
    print("To update a document's volume enter 6 ")
    print("To delete a document enter 7 ")
    print("To quit enter 8 ")

    choice = input('Enter a choice ')
    
    # Create a document choice
    if(choice == 1):
      print (Fifty_Day_Simple_Moving_Average)
      
    # Read a document choice  
    if(choice == 2):
      document = industry_tickers()

    # Find toal shares outstanding  
    if(choice == 3):
      document = total_shares_outstanding()

    # Create a document choice
    if(choice == 4):
      document = insert_new_document()

    # Read a document choice  
    if(choice == 5):
      document = read_document()

    # Update a document choice  
    if(choice == 6):
      document = update_document_volume()

    # Delete a document choice
    if(choice == 7):
      remove_document()    
    
    # Quit program choice
    if(choice == 8):
      client.close()
    
  print('Good bye!')
 
# Close connection with server
client.close()
 
main()
from fastapi import FastAPI, File, UploadFile, Form
import sqlite3
import io

app = FastAPI()

# Create table if it doesn't exist
conn = sqlite3.connect('trades.db')
c = conn.cursor()
c.execute("""CREATE TABLE IF NOT EXISTS trades (
    id INTEGER PRIMARY KEY,
    symbol TEXT NOT NULL,
    open_price REAL NOT NULL,
    take_profit REAL NOT NULL,
    stop_loss REAL NOT NULL,
    lots REAL NOT NULL,
    profit REAL NOT NULL,
    open_time DATETIME NOT NULL
)""")
conn.commit()
conn.close()

# Parse trades from text into list
def parse_trades(text):
    return text.split('|')

# Process single trade text into dict  
def process_trade(trade):
    data = trade.split('&')
    processed = {}
    for d in data:
        key, value = d.split('=')
        processed[key] = value
    return processed


def convert_text_to_dict(text):
    """
    Convert text to a dictionary.

    Args:
        text (str): Text to convert.

    Returns:
        dict: Dictionary containing the converted text.
    """
    print(type(text))
    text=str(text)
    data = text.split('&')
    dict = {}
    for d in data:
        key, value = d.split('=')
        try:
            value = float(value)
        except ValueError:
            pass
        dict[key] = value
    return dict
    

# Insert trade dict into SQLite DB
def insert_db(trade):
    trade=convert_text_to_dict(trade)
    conn = sqlite3.connect('trades.db')
    c = conn.cursor()
    c.execute("""INSERT INTO trades 
              (symbol, open_price, take_profit, stop_loss, lots, profit, open_time) 
              VALUES 
              (:symbol, :open_price, :take_profit, :stop_loss, :lots, :profit, :open_time)""", 
              trade)
    conn.commit()
    conn.close()
              
# FastAPI endpoint          
@app.post("/trades")
async def upload_trades(file: UploadFile = File(...)): 

    # Print received file
    print(f"Received file: {file.filename}")
    

    # Save uploaded text file 
    """with open('example.txt', 'w', encoding='utf-8') as f:
        f.write(await file.read().decode())"""
    
    

    # Process trades
    trades_text = (await file.read()).decode('utf-8')
    trades = parse_trades(trades_text)
    for trade in trades:
        print(trade)
        processed = process_trade(trade)  
        insert_db(processed)

    return {"status": "success"}

# -*- coding: utf-8 -*-

import mysql.connector as sql
import pandas as pd

c = sql.connect(host='localhost', database='invoices', user='root', password='lasers5')

# Entire table
vendors_df = pd.read_sql('select * from vendors', c, index_col = 'vendor_id')
invoices_df = pd.read_sql('select * from invoices', c, index_col = 'invoice_id')

# Join - from sql
invoices_vendors_df = pd.read_sql('select * from vendors join invoices using (vendor_id)', c)

# Join - from spyder
vendor_invoice_merge = pd.merge(vendors_df, invoices_df, on = 'vendor_id')

# Timing
def sql_join(c):
    return pd.read_sql('select * from vendors join invoices using (vendor_id)', c)
# %timeit sql_join(c) --- run that command in console
# c.close() when we are done
    
# --------------------------------------------------------------------------------------
    
"""
Line items greater than average
"""

def sql_anomalies(c):
    cmd = ('select invoice_number, account_description, sum(line_item_amt)' +
           'from invoices' +
           'join invoice_line_items using (invoice_id)' +
           'join general_ledger_accounts using (account_number)' +
           'where line_item_amt > ' +
           '    (select avg(line_item_amt) from invoice_line_items)' +
           'group by invoice_number, account_description;')
    return pd.read_sql(cmd, c)

# ----------------------------------------------------

def pandas_anomalies(c):
    invoices_df = pd.read_sql('select * from invoices', c, index_col = 'invoice_id')
    line_items_df = pd.read_sql('select * from invoice_line_items', c)
    accounts_df = pd.read_sql('select * from general_ledger_accounts', c, index_col = 'account_number')
    
    # Average
    avg_amt = line_items_df['line_item_amt'].mean()
    
    # group by invoice + act, sum them up, only take 1 col
    sum_by_acct = line_items_df.groupby(['invoice_id','account_number']).sum()['line_item_amt']
    
    # only line items that are above this ^  -- then give the table a normal index
    above_avg = sum_by_acct[sum_by_acct > avg_amt].reset_index()
    
    # filtering out the below avg line items
    final = pd.merge(above_avg, invoices_df, on = 'invoice_id')
    
    # getting acct info
    final = pd.merge(final, accounts_df, on='account_number')
    return final[['invoice_number', 'account_description', 'line_item_amt']]
# %timeit pandas_anomalies(c)

# ------------------------------------------------------
































import urllib.request
import time
import requests
from bs4 import BeautifulSoup
import numpy as np


def make_request(link):
    try:
        response = requests.get(link)
        response.raise_for_status()  # Проверяем успешность запроса
        return response
    except requests.exceptions.RequestException as e:
        print("Произошла ошибка при выполнении запроса:", e)
        return None

def extracting_name_iin(link):
    max_retries = 5
    retries = 0
    wait_time = 3
    while retries < max_retries:
        response = make_request(link)
        if response and response.status_code == 200:
            break  # Выход из цикла, если запрос успешен
        print(f"Ошибка при запросе, повторная попытка через {wait_time} секунд...")
        time.sleep(wait_time)
        retries += 1
    else:
        print("Достигнуто максимальное количество повторов, запрос не удался.")
        return pd.DataFrame({'Address': [np.nan]})
    
    
    soup = BeautifulSoup(urllib.request.urlopen(link).read(),'lxml')

    table = soup.find_all('table')
    if not table:
        return pd.DataFrame({'Address': [np.nan]})

    df1 = pd.read_html(str(table))[2].drop([1,1]).T.drop([0,0]).reset_index()
    df1.set_axis(['index', 'ИИН Руководителя', 'ФИО'], axis='columns', inplace=True) #меняю названия для коллон
#     display(df1)
    df2 = pd.read_html(str(table))[3]
#     display(df2)
    extracted_col = df2["Полный адрес(рус)"]
    
    extracted_col = df2["Полный адрес(рус)"].str.cat(sep='; ') #все адреса складываю в один 

    new_dataframe = pd.concat([df1, pd.Series([extracted_col], name="Address")], axis=1).drop(['index'], axis=1)
#     display(new_dataframe)
    return new_dataframe


soup = BeautifulSoup(urllib.request.urlopen("https://www.goszakup.gov.kz/ru/registry/rqc?count_record=2000&page=1").read(),'lxml') #
table = soup('table')[0]
final_df = pd.read_html(str(table))[0]
final_df.drop_duplicates(subset=['Наименование потенциального поставщика'])

dfs = []
i = 0
for row in table.find_all('tr'):
    for link in row.find_all('a', href=True):
        df = extracting_name_iin(link['href'])
        i+=1
        print('Loading ', i)
        dfs.append(df)
        time.sleep(3)

        
big_dataframe = pd.concat(dfs, ignore_index = True)

result_df = pd.concat([final_df, big_dataframe], axis=1) #result
result_df = result_df.drop('Наименование, номер и дата выдачи документа, на основании которого потенциальный поставщик включен в Перечень', axis=1)
result_df = result_df.drop('№', axis=1)

result_df = result_df.drop_duplicates(subset=['Наименование потенциального поставщика'])

result_df.reset_index(drop=True, inplace=True)

result_df.to_excel('result.xlsx', index=False)

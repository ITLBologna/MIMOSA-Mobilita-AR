 #
 # Copyright 2022-2023 bitApp S.r.l.
 #
 # This program is free software: you can redistribute it and/or modify
 # it under the terms of the GNU General Public License as published by
 # the Free Software Foundation, either version 3 of the License, or
 # (at your option) any later version.
 #
 # This program is distributed in the hope that it will be useful,
 # but WITHOUT ANY WARRANTY; without even the implied warranty of
 # MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 # GNU General Public License for more details.
 #
 # You should have received a copy of the GNU General Public License
 # along with this program.  If not, see <http://www.gnu.org/licenses/>.
 #
 # Mimosa ETL
 #
 #
 # Contact: info@bitapp.it
 #

import boto3
import os
from dotenv.main import load_dotenv
import pandas as pd
import numpy as np
from sklearn import  cluster
import scipy
import matplotlib.pyplot as plt
import seaborn as sns
import folium
from datetime import datetime,timedelta
import folium
from geodatasets import get_path 
import io
from PIL import Image
from openpyxl import Workbook
from geopy import distance
import time as tempo
from folium.plugins import AntPath, BeautifyIcon
load_dotenv()

#recall credential in anonymous way
botoresource = boto3.resource ('dynamodb',
    aws_access_key_id = os.environ["AWS_ACCESS_KEY_ID"],
    aws_secret_access_key= os.environ["AWS_SECRET_ACCESS_KEY"],
    region_name=os.environ["AWS_DEFAULT_REGION" ])

local_path = os.environ["LOCAL_PATH"]

# scan della tabella users e tracking data
user_table = botoresource.Table('users').scan()

# query dynamodb
# table_query = botoresource.Table('trackingdata').quw    .query(KeyConditionExpression=('user_id')   .eq('5afcd480-9d8a-11ed-be38-af968430147e'))
# table = botoresource.Table('trackingdata').query(
#         KeyConditionExpression="user_id = :user_id and tracking_posixtime > :e",
#         ExpressionAttributeValues={
#             ":user_id": 'e8d71190-bde6-11ed-b0ec-c94e287dd75b',
#             ":e": 0,
#         },
#     )
#print(len(table['Items']))

# fine query dynamodb

#variabili di appoggio
unique_user_list = []#empty list
# user_id = "5afcd480-9d8a-11ed-be38-af968430147e"


# cicla la lista degli user e salva la lista nella unique_user_list
for user in user_table['Items']: 
    unique_user_list.append(user['user_id'])#attached to the empty list the user_id unique list

# oper ogni user, cicla la tabella dei tracking data, recuperando le coordinate e i dati di quello user 
for user_id in unique_user_list:


    total_frame_data = pd.DataFrame()

    # recupero tracking data per lo user corrente
    table = botoresource.Table('trackingdata').query(
        KeyConditionExpression="user_id = :user_id and tracking_posixtime > :e",
        ExpressionAttributeValues={
            ":user_id": user_id,
            ":e": 0,
        },
    )

    # ciclo sulla tabella dei tracking data 
    for tracking_row in table['Items']:
        date = tracking_row['tracking_posixtime']/1000# conversion posixtime in real date (/1000 because they are calculate in millisecond)
        dt = datetime.fromtimestamp(int(date))#same as above
        user_data_frame = pd.DataFrame(tracking_row['tracking_data'])#data frame from original data
        user_data_frame['user_id'] = tracking_row['user_id']#add to user_data_frame a column user_id from column user_id in x
        user_data_frame['date'] = dt#add to user_data_frame a column date from vector dt
        total_frame_data = pd.concat([total_frame_data,user_data_frame])#attached to the empty data frame the complete data frame
        total_frame_data = total_frame_data.drop('posix_time', axis=1)#drop column posix_time from original data frame for the new one 
        total_frame_data = total_frame_data[(total_frame_data["heading"]>1)&(total_frame_data["speed"]>0)]#pulizia dataframe da valori anomali
       
    
        


        #CREATE TIME INTERVAL
        time = total_frame_data['date']
        # Imposta la colonna delle date come indice del dataframe
        #total_frame_data.set_index('date', inplace=True)
        # Arrotonda le date all'intervallo desiderato
        time = pd.to_datetime(time)
        # Arrotonda le date all'intervallo desiderato
        rounded_time = pd.to_datetime(np.floor(time.values.astype(np.int64) / (30 * 60 * 1e9)) * (30 * 60 * 1e9))
        # Crea un nuovo dataframe con le date arrotondate
        rounded_df = pd.DataFrame({'date': time, 'rounded_date': rounded_time})
        # Crea i sottoinsiemi di intervallo di tempo sul dataframe arrotondato
        intervallo_T = '30T'  # Intervallo di 30 minuti
        intervallo_T = pd.Timedelta(minutes=30)  # Intervallo di 30 minuti
        # Itera sul dataframe
        prev_intervallo = None  # Intervallo di riferimento iniziale
        prev_punto = None
        #date_visitati = set()
        punto_unique = []
        latitudine = []
        longitudine = []
        for index, row in total_frame_data.iterrows():
            punto = row['date']
            lat = row['lat']
            lon = row['lon']
            # Determina l'intervallo corrente
            if prev_intervallo is None or punto >= prev_intervallo + intervallo_T:
                intervallo = punto.floor(intervallo_T)
                prev_intervallo = intervallo 
                #punto = pd.Series(punto)
                # Verifica se il punto è già presente nella lista punto_unique
                if punto not in punto_unique:
                    punto_unique.append(punto)
                    latitudine.append(lat)
                    longitudine.append(lon)
        # Stampa i risultati unici
        data = []
        for index, punto in enumerate(punto_unique):
            lat = latitudine[index]
            lon = longitudine[index]
            data.append({'Punto': index+1, 'Data': punto, 'Latitudine': lat, 'Longitudine': lon})
            #print(f"Punto {index+1}: {punto} (Lat: {lat}, Lon: {lon})")   
        df_punti = pd.DataFrame(data)
        #print(df_punti['Latitudine'])
        settimana = []
        weekend = []
        for punto in punto_unique:
            giorno_settimana = punto.day_of_week  # Restituisce il numero del giorno della settimana (0 = lunedì, 6 = domenica)
            if giorno_settimana < 5:  # Giorni dal lunedì al venerdì (0-4) sono durante la settimana
                settimana.append(punto)
            else:  # Sabato (5) e domenica (6) sono durante il fine settimana
                weekend.append(punto)

    # Creazione del workbook Excel
    workbook = Workbook()
    sheet = workbook.active

    # Intestazioni delle colonne
    colonne = ['Punto', 'Data', 'Latitudine', 'Longitudine', 'Giorno della settimana']
    sheet.append(colonne)

    # Aggiunta dei dati delle colonne
    for index, punto in enumerate(punto_unique):
        lat = latitudine[index]
        lon = longitudine[index]
        giorno_settimana = 'Settimana' if punto in settimana else 'Fine settimana'
        dati = [index+1, punto, lat, lon, giorno_settimana]
        sheet.append(dati)

    nome_file_excel = 'punti1.xlsx'
    workbook.save(nome_file_excel)
                                

    if (len(total_frame_data) > 0):
        #START K_MEANS
        #choose column which i need from full data frame
        X = total_frame_data[["lon","lat"]]
        
        max_k = 10 #max number of cluster 
        ## iterations
        distortions = []
        for i in range(1, max_k+1):
            if len(X) >= i:
                model = cluster.KMeans(n_clusters=i, init='k-means++', max_iter=300, n_init=10, random_state=0)
                model.fit(X)
                distortions.append(model.inertia_)
        ## best k: the lowest derivative
        #k = [i*100 for i in np.diff(distortions,2)].index(min([i*100 for i in np.diff(distortions,2)]))
        if distortions:
            derivatives = [i*100 for i in np.diff(distortions, 2)]
            if derivatives:
                k = derivatives.index(min(derivatives))
            else:
                k = 0# Imposta un valore predefinito per `k` se non ci sono abbastanza dati per creare i cluster
        else:
            k = 0 
        
        # plot
        fig, ax = plt.subplots()
        line = ax.plot(range(1, len(distortions)+1), distortions)
        ax.axvline(k, ls='--', color="red", label="k = "+str(k))
        ax.set(title='The Elbow Method', xlabel='Number of clusters', ylabel="Distortion")
        ax.legend()
        ax.grid(True)
        #start k_means clustering
        # Calcola il valore di k corrispondente al punto in cui viene tracciata la linea rossa
        
        k= int(line[0].get_xdata()[k-1])
        if len(X) >= k:
            model = cluster.KMeans(n_clusters=k, init='k-means++')
            ## clustering
            dtf_X = X.copy()
            dtf_X["cluster"] = model.fit_predict(X)
            # ## find real centroids
            closest, distances = scipy.cluster.vq.vq(model.cluster_centers_, dtf_X.drop("cluster", axis=1).values.astype(np.float128))
            dtf_X["centroids"] = 0
            for i in closest:
                    dtf_X["centroids"].iloc[i] = 1
            # add clustering info to the original dataset
            total_frame_data[["cluster","centroids"]] =dtf_X[["cluster","centroids"]]
            total_frame_data.sample(k)
            
            #create one list contain latitudine coordinates and another one contain longitudine coordinate
            dtf2=dtf_X.loc[dtf_X['centroids'] == 1, 'lat'].tolist()
            dtf3=dtf_X.loc[dtf_X['centroids'] == 1, 'lon'].tolist()
            #put beside the 2 new previous list in a new dataframe contain coordinate of the centroids
            dtf_centroids = pd.DataFrame({'lat': dtf2, 'lon': dtf3})
            
            
            # print('centroidi')
            # # plot
            fig, ax = plt.subplots()
            sns.scatterplot(x="lon", y="lat", data=total_frame_data, 
                                palette=sns.color_palette("bright",k),
                                hue='cluster', size="centroids", size_order=[1,0],
                                legend="brief", ax=ax).set_title('Clustering')
            th_centroids = model.cluster_centers_
            ax.scatter(th_centroids[:,0], th_centroids[:,1], s=50, c='black', 
                        marker="x")
        else: 
            print(".")
            # continue
        # plt.show()
        
        #fix starting point map( Cesena in this case)
        lat= dtf_centroids['lat'][0]
        lng= dtf_centroids['lon'][0]
        #create an empty real map from folium library
        map = folium.Map(location=[lat,lng])
        ##put geographic point on a real map
        for row in dtf_centroids.iterrows():
            #convert dataframe point in float point and creare new markers on the map alongside the centroids
            dtf_centroids.apply(lambda row: folium.Marker(location=[row["lat"], row["lon"]]).add_to(map), axis=1)
            
        for row in df_punti.iterrows():    
        #convert dataframe point in float point and creare new markers on the map alongside the centroids
            df_punti.apply(lambda row: folium.Marker(location=[row["Latitudine"], row["Longitudine"]],icon=folium.Icon(color='green')).add_to(map), axis=1)

        # #convert from .html to .png file
        # #print('inizio immagine')
        # img_data = map._to_png(5)
        # img = Image.open(io.BytesIO(img_data))
        # #print('salva immagine')

        # img.save(local_path + 'marker_map_' + user_id + '.png')

        # Creazione di un array numpy vuoto per le distanze
        distances = np.empty((len(df_punti), len(dtf_centroids)))
        associations = []
        for i in range(0, len(df_punti)):
            for j in range(0, len(dtf_centroids)):

                coord_geo_1 = (df_punti['Latitudine'].iloc[i], df_punti['Longitudine'].iloc[i])
                coord_geo_2 = (dtf_centroids['lat'].iloc[j], dtf_centroids['lon'].iloc[j])

                var_distance = round(distance.distance(coord_geo_1, coord_geo_2).m) 
                    # Aggiunta della distanza alla lista
                # Aggiunta della distanza all'array numpy
                distances[i, j] = var_distance
                # Creazione del dataframe con la variabile var_distance
            df_distances = pd.DataFrame(distances, columns=dtf_centroids.index)
                #print(df_distances)
        # Esportazione del dataframe in un file Excel
        #df_distances.to_excel(local_path + 'distances_' + user_id + '.xlsx', index=False)
        #ALLOCARE TEMPI TEMPORALI NEI CENTROIDI PIU' VICINI
        #tenere conto delle distanze tra df_punti e centroids, dato a appartenente a punti e b,c appartente a centroidi, a viene associato al punto b se la sua distanza con b è minore rispetto a quella con c
            centroid_index = distances[i].argmin()
            associations.append(centroid_index) 
        df_punti['Centroid_Index'] = associations
        # Reset degli indici per considerare la colonna che indicizza i centroidi come colonna
        dtf_centroids = dtf_centroids.reset_index()
        #denominare questa 'nuova' colonna con centroid_index per poter unire dopo i due dataframe in base a questi indici
        new_columns = { dtf_centroids.columns[0]:'Centroid_Index'}
        dtf_centroids = dtf_centroids.rename(columns=new_columns)
        #dtf_centroids.to_excel(local_path + "centroidi_" + user_id + ".xlsx")
        # Unire i DataFrame df e df_centroids in base alla colonna "Centroid_Index"
        df_merged = df_punti.merge(dtf_centroids, on="Centroid_Index", how="left")
        # Eliminare due colonne che non servono più
        columns_to_drop = ['Latitudine', 'Longitudine']
        df_merged = df_merged.drop(columns=columns_to_drop)
        df_merged.to_excel(local_path + 'merge' + user_id + '.xlsx', index=False)
        #CREAZIONE PERCORSO
        df_merged['coordinate'] = df_merged.apply(lambda row: str(row['lat']) + ' ' + str(row['lon']), axis=1)    
        new_dataframe = pd.DataFrame()
        for i in range(len(df_merged) - 1):
            if df_merged['Data'].iloc[i+1]-df_merged['Data'].iloc[i]<pd.Timedelta(hours=3):
                coord_i = df_merged['coordinate'].iloc[i]
                coord_i_plus_1 = df_merged['coordinate'].iloc[i+1]
                concatenated_str = coord_i + ' ' + coord_i_plus_1
                
                new_dataframe = new_dataframe.append(pd.Series([concatenated_str]), ignore_index=True)
        #new_dataframe.to_excel(local_path + 'finaldf' + user_id + '.xlsx', index=False)
        df_string = new_dataframe.to_string(index=False,header=None)
    
        with open(local_path + 'finaldf' + user_id + '.txt', 'w') as f:
            f.write(df_string)    

        tempo.sleep(1)
    # plt.show()
#exit()



     











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

from dotenv.main import load_dotenv
import os
import requests
from zipfile import ZipFile
from io import BytesIO

## Path to save results
load_dotenv()
local_path_dataset = os.environ['LOCAL_PATH_DATASET']

files = {
    'AGENCY_ID': 'GTFS ZIP URL',
}

## Download data from urls, extract data from archivezip e save it locally
for agency in files:
    # Download the file by sending the request to the URL
    req = requests.get(files[agency])
    print(agency, 'Download completed')

    # extracting the zip file contents
    zipfile = ZipFile(BytesIO(req.content))
    zipfile.extractall(local_path_dataset + '/' + agency)
    print(agency, 'Unzip completed')

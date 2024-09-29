"""
Currently PongoDB consists of a single endpoint though provides the base schematic so many more can be added

More endpoints can be found on the MongoDB website
"""

import requests
import json

# General purpose
def Merge(x, y):
    z = x.copy()
    z.update(y)
    return z

class Mongo:
    def __init__(self, APIKey, Cluster):
        self.URL = "https://data.mongodb-api.com/app/data-uumun/endpoint/data/v1/action"
        self.APIKey = APIKey

        self.Cluster = Cluster
        self.Collection = ""
        self.Database = ""

    def MakePayload(self, Data):
        return json.dumps(Merge({
            "collection": self.Collection,
            "database": self.Database,
            "dataSource": self.Cluster,
        }, Data))

    def Request(self, Endpoint, Data):
        Payload = self.MakePayload(Data)
        Headers = {
            'Content-Type': 'application/json',
            'Access-Control-Request-Headers': '*',
            'api-key': self.APIKey
        }
        print(self.URL + Endpoint)

        return requests.request("POST", self.URL + Endpoint, headers=Headers, data=Payload)

    def SetCollection(self, CollectionName):
        self.Collection = CollectionName

    def SetDatabase(self, DatabaseName):
        self.Database = DatabaseName

Database = Mongo("kA8eydkNDjEmgTRes8gj0FCCF05iy8Y31INDCaI9lRkSJb3tgMH8DV4UB5zHS4Yk", "KeysHwids")
Database.SetDatabase("NewDatabase")
Database.SetCollection("TestCollection")

print(
		Database.Request(
        		"/findOne", 
                {
                	"projection": {"_id": 1}
                }
        	).content
    )